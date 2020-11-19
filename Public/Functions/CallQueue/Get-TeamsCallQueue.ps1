# Module:   TeamsFunctions
# Function: CallQueue
# Author:		David Eberhardt
# Updated:  01-OCT-2020
# Status:   PreLive




function Get-TeamsCallQueue {
  <#
	.SYNOPSIS
		Queries Call Queues and displays friendly Names (UPN or Displayname)
	.DESCRIPTION
		Same functionality as Get-CsCallQueue, but display reveals friendly Names,
		like UserPrincipalName or DisplayName for the following connected Objects
    OverflowActionTarget, TimeoutActionTarget, Agents, DistributionLists and ApplicationInstances (Resource Accounts)
	.PARAMETER Name
		Optional. Searches all Call Queues for this name (multiple results possible).
    If omitted, Get-TeamsCallQueue acts like an Alias to Get-CsCallQueue (no friendly names)
  .PARAMETER Detailed
    Optional Switch. Displays all Parameters of the CallQueue
    This also shows parameters relating to Ids and Diagnostic Parameters.
	.EXAMPLE
		Get-TeamsCallQueue
		Same result as Get-CsCallQueue
	.EXAMPLE
		Get-TeamsCallQueue -Name "My CallQueue"
		Returns an Object for every Call Queue found with the String "My CallQueue"
		Agents, DistributionLists, Targets and Resource Accounts are displayed with friendly name.
	.EXAMPLE
		Get-TeamsCallQueue -Name "My CallQueue" -Detailed
    Returns an Object for every Call Queue found with the String "My CallQueue"
    Displays additional Parameters used for Diagnostics & Shared Voicemail.
		Agents, DistributionLists, Targets and Resource Accounts are displayed with friendly name.
  .INPUTS
    System.String
  .OUTPUTS
    System.Object
  .NOTES
    Main difference to Get-CsCallQueue (apart from the friendly names) is that the
    Output view is by default detailed
	.FUNCTIONALITY
		Get-CsCallQueue with friendly names instead of GUID-strings for connected objects
	.LINK
		New-TeamsCallQueue
		Get-TeamsCallQueue
    Set-TeamsCallQueue
    Remove-TeamsCallQueue
    New-TeamsAutoAttendant
    Get-TeamsAutoAttendant
    Set-TeamsAutoAttendant
    Remove-TeamsAutoAttendant
    Get-TeamsResourceAccountAssociation
    New-TeamsResourceAccountAssociation
		Remove-TeamsResourceAccountAssociation
  #>

  [CmdletBinding()]
  [Alias('Get-TeamsCQ')]
  [OutputType([System.Object[]])]
  param(
    [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = 'Partial or full Name of the Call Queue to search')]
    [AllowNull()]
    [string[]]$Name,

    [switch]$Detailed
  ) #param

  begin {
    Show-FunctionStatus -Level PreLive
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

    # Asserting AzureAD Connection
    if (-not (Assert-AzureADConnection)) { break }

    # Asserting SkypeOnline Connection
    if (-not (Assert-SkypeOnlineConnection)) { break }

    # Setting Preference Variables according to Upstream settings
    if (-not $PSBoundParameters.ContainsKey('Verbose')) {
      $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference')
    }
    if (-not $PSBoundParameters.ContainsKey('Confirm')) {
      $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference')
    }
    if (-not $PSBoundParameters.ContainsKey('WhatIf')) {
      $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference')
    }

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    # Capturing no input
    if (-not $PSBoundParameters.ContainsKey('Name')) {
      Write-Verbose -Message "Name not specified, listing call queue names only. Please query contents by targeting them with -Name" -Verbose
      (Get-CsCallQueue -WarningAction SilentlyContinue -ErrorAction STOP).Name
    }
    else {
      #CHECK Explore Workflows with Parallel parsing:
      #foreach -parallel ($DN in $Name) {
      $DNCounter = 0
      foreach ($DN in $Name) {
        Write-Progress -Id 0 -Status "Queue '$DN'" -CurrentOperation "Querying CsCallQueue" -Activity $MyInvocation.MyCommand -PercentComplete ($DNCounter / $($Name.Count) * 100)
        $DNCounter++
        Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand) - '$DN'"
        # Finding all Queues with this Name (Should return one Object, but since it IS a filter, handling it as an array)
        $Queues = Get-CsCallQueue -NameFilter "$DN" -WarningAction SilentlyContinue -ErrorAction STOP -WarningVariable $Warnings

        if ( -not $Queues) {
          $QueueCount = 0
        }
        elseif ($($Queues.GetType().BaseType.Name) -eq "Object") {
          $QueueCount = 1
        }
        else {
          $QueueCount = $Queues.Count
        }

        # Initialising Arrays
        [System.Collections.ArrayList]$UserObjects = @()
        [System.Collections.ArrayList]$DLObjects = @()
        #[System.Collections.ArrayList]$AgentObjects = @()
        [System.Collections.ArrayList]$AIObjects = @()

        # Reworking Objects
        Write-Verbose -Message "[PROCESS] Finding parsable Objects for $QueueCount Queues"
        foreach ($Q in $Queues) {
          # Initialising counters for Progress bars
          [int]$step = 0
          [int]$sMax = 6
          Write-Progress -Id 1 -Status "Found Queue '$($Q.Name)'" -CurrentOperation "Parsing OverflowActionTarget" -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
          #region Finding OverflowActionTarget
          Write-Verbose -Message "'$($Q.Name)' - Parsing OverflowActionTarget"
          if ($null -eq $Q.OverflowActionTarget) {
            $OAT = $null
          }
          else {
            switch ($Q.OverflowActionTarget.Type) {
              "ApplicationEndpoint" {
                try {
                  $OATobject = Get-CsOnlineApplicationInstance -ObjectId "$($Q.OverflowActionTarget.Id)" -WarningAction SilentlyContinue -ErrorAction STOP
                  $OAT = $OATobject.UserPrincipalName
                }
                catch {
                  Write-Warning -Message "'$($Q.Name)' OverflowActionTarget: Not enumerated"
                }
              }
              "Mailbox" {
                try {
                  $OATobject = Get-AzureADGroup -ObjectId "$($Q.OverflowActionTarget.Id)" -WarningAction SilentlyContinue -ErrorAction STOP
                  $OAT = $OATobject.DisplayName
                }
                catch {
                  Write-Warning -Message "'$($Q.Name)' OverflowActionTarget: Not enumerated"
                }
              }
              "User" {
                try {
                  $OATobject = Get-AzureADUser -ObjectId "$($Q.OverflowActionTarget.Id)" -WarningAction SilentlyContinue -ErrorAction STOP
                  $OAT = $OATobject.UserPrincipalName
                }
                catch {
                  Write-Warning -Message "'$($Q.Name)' OverflowActionTarget: Not enumerated"
                }
              }
              "Phone" {
                try {
                  $OATobject = Get-AzureADUser -ObjectId "$($Q.OverflowActionTarget.Id)" -WarningAction SilentlyContinue -ErrorAction STOP
                  $OAT = $OATobject.UserPrincipalName
                }
                catch {
                  Write-Warning -Message "'$($Q.Name)' OverflowActionTarget: Not enumerated"
                }
              }
              default {
                try {
                  $OATobject = Get-AzureADUser -ObjectId "$($Q.OverflowActionTarget.Id)" -WarningAction SilentlyContinue -ErrorAction STOP
                  $OAT = $OATobject.UserPrincipalName
                  if ($null -eq $OAT) {
                    try {
                      $OATobject = Get-AzureADGroup -ObjectId "$($Q.OverflowActionTarget.Id)" -WarningAction SilentlyContinue -ErrorAction STOP
                      $OAT = $OATobject.DisplayName
                      if ($null -eq $OAT) {
                        throw
                      }
                    }
                    catch {
                      Write-Warning -Message "'$($Q.Name)' OverflowActionTarget: Not enumerated"
                    }
                  }
                }
                catch {
                  Write-Warning -Message "'$($Q.Name)' OverflowActionTarget: Not enumerated"
                }
              }
            }
          }
          # Output: $OAT, $Q.OverflowActionTarget.Type
          #endregion

          #region Finding TimeoutActionTarget
          $step++
          Write-Progress -Id 1 -Status "Found Queue '$($Q.Name)'" -CurrentOperation "Parsing TimeoutActionTarget" -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
          Write-Verbose -Message "'$($Q.Name)' - Parsing TimeoutActionTarget"
          if ($null -eq $Q.TimeoutActionTarget) {
            $TAT = $null
          }
          else {
            switch ($Q.TimeoutActionTarget.Type) {
              "ApplicationEndpoint" {
                try {
                  $TATobject = Get-CsOnlineApplicationInstance -ObjectId "$($Q.TimeoutActionTarget.Id)" -WarningAction SilentlyContinue -ErrorAction STOP
                  $TAT = $TATObject.UserPrincipalName
                }
                catch {
                  Write-Warning -Message "'$($Q.Name)' TimeoutActionTarget: Not enumerated"
                }
              }
              "Mailbox" {
                try {
                  $TATobject = Get-AzureADGroup -ObjectId "$($Q.TimeoutActionTarget.Id)" -WarningAction SilentlyContinue -ErrorAction STOP
                  $TAT = $TATObject.DisplayName
                }
                catch {
                  Write-Warning -Message "'$($Q.Name)' TimeoutActionTarget: Not enumerated"
                }
              }
              "User" {
                try {
                  $TATobject = Get-AzureADUser -ObjectId "$($Q.TimeoutActionTarget.Id)" -WarningAction SilentlyContinue -ErrorAction STOP
                  $TAT = $TATObject.UserPrincipalName
                }
                catch {
                  Write-Warning -Message "'$($Q.Name)' TimeoutActionTarget: Not enumerated"
                }
              }
              default {
                try {
                  $TATobject = Get-AzureADUser -ObjectId "$($Q.TimeoutActionTarget.Id)" -WarningAction SilentlyContinue -ErrorAction STOP
                  $TAT = $TATObject.UserPrincipalName
                  if ($null -eq $TAT) {
                    try {
                      $TATobject = Get-AzureADGroup -ObjectId "$($Q.TimeoutActionTarget.Id)" -WarningAction SilentlyContinue -ErrorAction STOP
                      $TAT = $TATObject.DisplayName
                      if ($null -eq $TAT) {
                        throw
                      }
                    }
                    catch {
                      Write-Warning -Message "'$($Q.Name)' TimeoutActionTarget: Not enumerated"
                    }
                  }
                }
                catch {
                  Write-Warning -Message "'$($Q.Name)' TimeoutActionTarget: Not enumerated"
                }
              }
            }
          }
          # Output: $TAT, $Q.TimeoutActionTarget.Type
          #endregion

          #region Endpoints
          # Distribution Lists
          #CHECK resolving DLs? Nested objects (count at least?)
          $step++
          Write-Progress -Id 1 -Status "Found Queue '$($Q.Name)'" -CurrentOperation "Parsing DistributionLists" -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
          Write-Verbose -Message "'$($Q.Name)' - Parsing DistributionLists"
          foreach ($DL in $Q.DistributionLists) {
            $DLObject = Get-AzureADGroup -ObjectId $DL -WarningAction SilentlyContinue | Select-Object DisplayName, Description, SecurityEnabled, MailEnabled, MailNickName, Mail
            #Add-Member -Force -InputObject $DLObject -MemberType ScriptMethod -Name ToString -Value [System.Environment]::NewLine + (($this | Select-Object DisplayName | Format-Table -HideTableHeaders | Out-String) -replace '^\s+|\s+$')
            [void]$DLObjects.Add($DLObject)
          }
          # Output: $DLObjects.DisplayName

          # Users
          $step++
          Write-Progress -Id 1 -Status "Found Queue '$($Q.Name)'" -CurrentOperation "Parsing DistributionLists" -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
          Write-Verbose -Message "'$($Q.Name)' - Parsing Users"
          foreach ($User in $Q.Users) {
            $UserObject = Get-AzureADUser -ObjectId "$($User.Guid)" -WarningAction SilentlyContinue | Select-Object UserPrincipalName, DisplayName, JobTitle, CompanyName, Country, UsageLocation, PreferredLanguage
            [void]$UserObjects.Add($UserObject)
          }
          # Output: $UserObjects.UserPrincipalName

          <# Removed due to duplicity
          # parsing users twice is not great.
          # Agents
          Write-Verbose -Message "'$($Q.Name)' - Parsing Agents"
          foreach ($Agent in $Q.Agents) {
            $AgentObject = Get-AzureADUser -ObjectId "$($Agent.ObjectId)" -WarningAction SilentlyContinue | Select-Object UserPrincipalName, DisplayName, JobTitle, CompanyName, Country, UsageLocation, PreferredLanguage
            [void]$AgentObjects.Add($AgentObject)
          }
          # Output: $AgentObjects.UserPrincipalName
          #>
          #endregion

          #region Application Instance UPNs
          $step++
          Write-Progress -Id 1 -Status "Found Queue '$($Q.Name)'" -CurrentOperation "Parsing Resource Accounts" -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
          Write-Verbose -Message "'$($Q.Name)' - Parsing Resource Accounts"
          foreach ($AI in $Q.ApplicationInstances) {
            $AIObject = $null
            $AIObject = Get-CsOnlineApplicationInstance | Where-Object { $_.ObjectId -eq $AI } | Select-Object UserPrincipalName, DisplayName, PhoneNumber
            if ($null -ne $AIObject) {
              [void]$AIObjects.Add($AIObject)
            }
          }

          # Output: $AIObjects.UserPrincipalName
          #endregion

          #region Creating Output Object
          $step++
          Write-Progress -Id 1 -Status "Found Queue '$($Q.Name)'" -CurrentOperation "Constructing Output Object" -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
          Write-Verbose -Message "'$($Q.Name)' - Constructing Output Object"
          # Building custom Object with Friendly Names
          $QueueObject = [PSCustomObject][ordered]@{
            Identity                  = $Q.Identity
            Name                      = $Q.Name
            LanguageId                = $Q.LanguageId
            UseDefaultMusicOnHold     = $Q.UseDefaultMusicOnHold
            MusicOnHoldAudioFileName  = $Q.MusicOnHoldFileName
            WelcomeMusicAudioFileName = $Q.WelcomeMusicFileName
            RoutingMethod             = $Q.RoutingMethod
            PresenceBasedRouting      = $Q.PresenceBasedRouting
            AgentAlertTime            = $Q.AgentAlertTime
            AllowOptOut               = $Q.AllowOptOut
            ConferenceMode            = $Q.ConferenceMode
            OverflowThreshold         = $Q.OverflowThreshold
            OverflowAction            = $Q.OverflowAction
            OverflowActionTarget      = $OAT
            OverflowActionTargetType  = $Q.OverflowActionTarget.Type
          }

          if ($PSBoundParameters.ContainsKey('Detailed') -or $OverflowActionTargetType -eq 'SharedVoiceMail') {
            # Displays SharedVoiceMail Parameters only if OverflowActionTargetType is set to SharedVoicemail
            $QueueObject | Add-Member -MemberType NoteProperty -Name OverflowSharedVoicemailAudioFilePrompt -Value $Q.OverflowSharedVoicemailAudioFilePrompt
            $QueueObject | Add-Member -MemberType NoteProperty -Name OverflowSharedVoicemailAudioFilePromptFileName -Value $Q.OverflowSharedVoicemailAudioFilePromptFileName
            $QueueObject | Add-Member -MemberType NoteProperty -Name OverflowSharedVoicemailTextToSpeechPrompt -Value $Q.OverflowSharedVoicemailTextToSpeechPrompt
            $QueueObject | Add-Member -MemberType NoteProperty -Name EnableOverflowSharedVoicemailTranscription -Value $Q.EnableOverflowSharedVoicemailTranscription
          }

          # Adding Timeout Parameters
          $QueueObject | Add-Member -MemberType NoteProperty -Name TimeoutThreshold -Value $Q.TimeoutThreshold
          $QueueObject | Add-Member -MemberType NoteProperty -Name TimeoutAction -Value $Q.TimeoutAction
          $QueueObject | Add-Member -MemberType NoteProperty -Name TimeoutActionTarget -Value $TAT
          $QueueObject | Add-Member -MemberType NoteProperty -Name TimeoutActionTargetType -Value $Q.TimeoutActionTarget.Type

          if ($PSBoundParameters.ContainsKey('Detailed') -or $TimeoutActionTargetType -eq 'SharedVoiceMail') {
            # Displays SharedVoiceMail Parameters only if TimeoutActionTargetType is set to SharedVoicemail
            $QueueObject | Add-Member -MemberType NoteProperty -Name TimeoutSharedVoicemailAudioFilePrompt -Value $Q.TimeoutSharedVoicemailAudioFilePrompt
            $QueueObject | Add-Member -MemberType NoteProperty -Name TimeoutSharedVoicemailAudioFilePromptFileName -Value $Q.TimeoutSharedVoicemailAudioFilePromptFileName
            $QueueObject | Add-Member -MemberType NoteProperty -Name TimeoutSharedVoicemailTextToSpeechPrompt -Value $Q.TimeoutSharedVoicemailTextToSpeechPrompt
            $QueueObject | Add-Member -MemberType NoteProperty -Name EnableTimeoutSharedVoicemailTranscription -Value $Q.EnableTimeoutSharedVoicemailTranscription
          }

          # Adding Agent Information
          $QueueObject | Add-Member -MemberType NoteProperty -Name Users -Value $UserObjects.UserPrincipalName
          $QueueObject | Add-Member -MemberType NoteProperty -Name DistributionLists -Value $DLObjects.DisplayName
          $QueueObject | Add-Member -MemberType NoteProperty -Name DistributionListsLastExpanded -Value $Q.DistributionListsLastExpanded
          $QueueObject | Add-Member -MemberType NoteProperty -Name AgentsInSyncWithDistributionLists -Value $Q.AgentsInSyncWithDistributionLists
          $QueueObject | Add-Member -MemberType NoteProperty -Name AgentsCapped -Value $Q.AgentsCapped
          #$QueueObject | Add-Member -MemberType NoteProperty -Name Agents -Value $AgentObjects.UserPrincipalName

          if ($PSBoundParameters.ContainsKey('Detailed')) {
            # Displays all except reserved Parameters (Microsoft Internal)
            $QueueObject | Add-Member -MemberType NoteProperty -Name MusicOnHoldAudioFileId -Value $Q.MusicOnHoldAudioFileId
            $QueueObject | Add-Member -MemberType NoteProperty -Name WelcomeMusicAudioFileId -Value $Q.WelcomeMusicAudioFileId
            $QueueObject | Add-Member -MemberType NoteProperty -Name MusicOnHoldFileDownloadUri -Value $Q.MusicOnHoldFileDownloadUri
            $QueueObject | Add-Member -MemberType NoteProperty -Name WelcomeMusicFileDownloadUri -Value $Q.WelcomeMusicFileDownloadUri
            $QueueObject | Add-Member -MemberType NoteProperty -Name Description -Value $Q.Description
          }

          # Adding Resource Accounts
          $QueueObject | Add-Member -MemberType NoteProperty -Name ApplicationInstances -Value $AIObjects.Userprincipalname
          #endregion

          # Output
          Write-Progress -Id 1 -Status "Found Queue '$($Q.Name)'" -Activity $MyInvocation.MyCommand -Completed
          if ($Warnings) {
            Write-Warning -Message $Warnings
          }
          Write-Output $QueueObject
        }
      }
    }

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"

  } #end
} #Get-TeamsCallQueue
