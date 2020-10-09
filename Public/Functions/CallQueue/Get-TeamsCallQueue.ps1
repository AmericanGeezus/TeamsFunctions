# Module:   TeamsFunctions
# Function: CallQueue
# Author:		David Eberhardtt
# Updated:  01-OCT-2020
# Status:   PreLive

#FIXME TimeoutActionTarget not enumerated (User) - Also check OverflowActionTarget for the same (breakout check?)
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
  .PARAMETER ConciseView
    Optional Switch. Displays reduced set of Parameters for better visibility
    Parameters relating to Language & Shared Voicemail are not shown.
	.EXAMPLE
		Get-TeamsCallQueue
		Same result as Get-CsCallQueue
	.EXAMPLE
		Get-TeamsCallQueue -Name "My CallQueue"
		Returns an Object for every Call Queue found with the String "My CallQueue"
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
    [string]$Name,

    [switch]$ConciseView
  ) #param

  begin {
    Show-FunctionStatus -Level PreLive
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.Mycommand)"

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
    Write-Verbose -Message "[PROCESS] $($MyInvocation.Mycommand)"

    # Capturing no input
    try {
      if (-not $PSBoundParameters.ContainsKey('Name')) {
        Write-Verbose -Message "No parameters specified. Acting as an Alias to Get-CsCallQueue" -Verbose
        Write-Verbose -Message "Warnings are suppressed for this operation. Please query with -Name to display them" -Verbose
        Get-CsCallQueue -WarningAction SilentlyContinue -ErrorAction STOP
      }
      else {
        foreach ($DN in $Name) {
          Write-Verbose -Message "[PROCESS] $($MyInvocation.Mycommand) - '$DN'"
          # Finding all Queues with this Name (Should return one Object, but since it IS a filter, handling it as an array)
          #$Queues = Get-CsCallQueue -NameFilter "$DN" -WarningAction SilentlyContinue -ErrorAction STOP
          # NOTE: Like AAs, piping to "FL *" can show more information. Here though, there is no benefit
          $Queues = Get-CsCallQueue -NameFilter "$DN" -WarningAction SilentlyContinue -ErrorAction STOP -WarningVariable $Warnings

          if ($null -ne $Queues) {
            if ($PSBoundParameters.ContainsKey('ConciseView')) {
              Write-Verbose -Message "ConciseView: Parameters relating to Language & Shared Voicemail are not shown." -Verbose
            }
          }

          # Initialising Arrays
          [System.Collections.ArrayList]$UserObjects = @()
          [System.Collections.ArrayList]$DLObjects = @()
          [System.Collections.ArrayList]$AgentObjects = @()
          [System.Collections.ArrayList]$AIObjects = @()

          # Reworking Objects
          Write-Verbose -Message "[PROCESS] Finding parsable Objects for $($Queues.Count) Queues"
          foreach ($Q in $Queues) {
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
            Write-Verbose -Message "'$($Q.Name)' - Parsing OverflowActionTarget"
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

            #region Endpoints - DistributionLists and Agents
            Write-Verbose -Message "'$($Q.Name)' - Parsing DistributionLists"
            foreach ($DL in $Q.DistributionLists) {
              $DLObject = Get-AzureADGroup -ObjectId $DL -WarningAction SilentlyContinue | Select-Object DisplayName, Description, SecurityEnabled, MailEnabled, MailNickName, Mail
              [void]$DLObjects.Add($DLObject)
            }
            # Output: $DLObjects.DisplayName

            Write-Verbose -Message "'$($Q.Name)' - Parsing Users"
            foreach ($User in $Q.Users) {
              $UserObject = Get-AzureADUser -ObjectId "$($User.Guid)" -WarningAction SilentlyContinue | Select-Object UserPrincipalName, DisplayName, JobTitle, CompanyName, Country, UsageLocation, PreferredLanguage
              [void]$UserObjects.Add($UserObject)
            }
            # Output: $UserObjects.UserPrincipalName

            Write-Verbose -Message "'$($Q.Name)' - Parsing Agents"
            foreach ($Agent in $Q.Agents) {
              $AgentObject = Get-AzureADUser -ObjectId "$($Agent.ObjectId)" -WarningAction SilentlyContinue | Select-Object UserPrincipalName, DisplayName, JobTitle, CompanyName, Country, UsageLocation, PreferredLanguage
              [void]$AgentObjects.Add($AgentObject)
            }
            # Output: $AgentObjects.UserPrincipalName
            #endregion

            #region Application Instance UPNs
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
            Write-Verbose -Message "'$($Q.Name)' - Constructing Output Object"
            # Building custom Object with Friendly Names
            if ($PSBoundParameters.ContainsKey('ConciseView')) {
              $QueueObject = [PSCustomObject][ordered]@{
                Identity                  = $Q.Identity
                Name                      = $Q.Name
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

                TimeoutThreshold          = $Q.TimeoutThreshold
                TimeoutAction             = $Q.TimeoutAction
                TimeoutActionTarget       = $TAT
                TimeoutActionTargetType   = $Q.TimeoutActionTarget.Type

                Users                     = $UserObjects.UserPrincipalName
                DistributionLists         = $DLObjects.DisplayName

                Agents                    = $AgentObjects.UserPrincipalName
                ApplicationInstances      = $AIObjects.Userprincipalname
              }
            }
            else {
              # Displays all except reserved Parameters (Microsoft Internal)
              $QueueObject = [PSCustomObject][ordered]@{
                Identity                                       = $Q.Identity
                Name                                           = $Q.Name
                UseDefaultMusicOnHold                          = $Q.UseDefaultMusicOnHold
                MusicOnHoldAudioFileName                       = $Q.MusicOnHoldFileName
                WelcomeMusicAudioFileName                      = $Q.WelcomeMusicFileName
                RoutingMethod                                  = $Q.RoutingMethod
                PresenceBasedRouting                           = $Q.PresenceBasedRouting
                AgentAlertTime                                 = $Q.AgentAlertTime
                AllowOptOut                                    = $Q.AllowOptOut
                ConferenceMode                                 = $Q.ConferenceMode
                OverflowThreshold                              = $Q.OverflowThreshold
                OverflowAction                                 = $Q.OverflowAction
                OverflowActionTarget                           = $OAT
                OverflowActionTargetType                       = $Q.OverflowActionTarget.Type
                OverflowSharedVoicemailAudioFilePrompt         = $Q.OverflowSharedVoicemailAudioFilePrompt
                OverflowSharedVoicemailAudioFilePromptFileName = $Q.OverflowSharedVoicemailAudioFilePromptFileName
                OverflowSharedVoicemailTextToSpeechPrompt      = $Q.OverflowSharedVoicemailTextToSpeechPrompt
                EnableOverflowSharedVoicemailTranscription     = $Q.EnableOverflowSharedVoicemailTranscription
                TimeoutThreshold                               = $Q.TimeoutThreshold
                TimeoutAction                                  = $Q.TimeoutAction
                TimeoutActionTarget                            = $TAT
                TimeoutActionTargetType                        = $Q.TimeoutActionTarget.Type
                TimeoutSharedVoicemailAudioFilePrompt          = $Q.TimeoutSharedVoicemailAudioFilePrompt
                TimeoutSharedVoicemailAudioFilePromptFileName  = $Q.TimeoutSharedVoicemailAudioFilePromptFileName
                TimeoutSharedVoicemailTextToSpeechPrompt       = $Q.TimeoutSharedVoicemailTextToSpeechPrompt
                EnableTimeoutSharedVoicemailTranscription      = $Q.EnableTimeoutSharedVoicemailTranscription
                LanguageId                                     = $Q.LanguageId
                #LineUri                                    = $Q.LineUri
                MusicOnHoldAudioFileId                         = $Q.MusicOnHoldAudioFileId
                WelcomeMusicAudioFileId                        = $Q.WelcomeMusicAudioFileId
                Users                                          = $UserObjects.UserPrincipalName
                DistributionLists                              = $DLObjects.DisplayName
                DistributionListsLastExpanded                  = $Q.DistributionListsLastExpanded
                AgentsInSyncWithDistributionLists              = $Q.AgentsInSyncWithDistributionLists
                AgentsCapped                                   = $Q.AgentsCapped
                Agents                                         = $AgentObjects.UserPrincipalName
                ApplicationInstances                           = $AIObjects.Userprincipalname
              }

            }
            #endregion

            # Output
            if ($Warnings) {
              Write-Warning -Message $Warnings
            }
            Write-Output $QueueObject
          }
        }
      }
    }
    catch {
      Write-Error -Message 'Could not query Call Queues' -Category OperationStopped
      Write-ErrorRecord $_ #This handles the error message in human readable format.
      return
    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.Mycommand)"

  } #end
} #Get-TeamsCallQueue
