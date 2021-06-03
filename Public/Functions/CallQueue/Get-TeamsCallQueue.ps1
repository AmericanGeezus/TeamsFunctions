# Module:   TeamsFunctions
# Function: CallQueue
# Author:		David Eberhardt
# Updated:  01-JAN-2021
# Status:   Live

#TEST Switch ChannelUsers (ChannelUserObjectId), ResourceAccountsForChannelId (OboResourceAccountIds)
#TODO enable lookup with identity (ObjectId) as well! (enabling Pipeline Input) - Add Regex Validation to ObjectId format to change how it is looked up!

function Get-TeamsCallQueue {
  <#
	.SYNOPSIS
		Queries Call Queues and displays friendly Names (UPN or Displayname)
	.DESCRIPTION
		Same functionality as Get-CsCallQueue, but display reveals friendly Names,
		like UserPrincipalName or DisplayName for the following connected Objects
    OverflowActionTarget, TimeoutActionTarget, Agents, DistributionLists and ApplicationInstances (Resource Accounts)
	.PARAMETER Name
		Optional. Searches all Call Queues for this name (unique results).
    If omitted, Get-TeamsCallQueue acts like an Alias to Get-CsCallQueue (no friendly names)
	.PARAMETER SearchString
		Optional. Searches all Call Queues for this string (multiple results possible).
  .PARAMETER Detailed
    Optional Switch. Displays all Parameters of the CallQueue
    This also shows parameters relating to Ids and Diagnostic Parameters.
	.EXAMPLE
		Get-TeamsCallQueue
		Same result as Get-CsCallQueue
	.EXAMPLE
		Get-TeamsCallQueue -Name "My CallQueue"
		Returns an Object for every Call Queue found with the exact Name "My CallQueue"
	.EXAMPLE
		Get-TeamsCallQueue -Name "My CallQueue" -Detailed
    Returns an Object for every Call Queue found with the String "My CallQueue"
    Displays additional Parameters used for Diagnostics & Shared Voicemail.
	.EXAMPLE
		Get-TeamsCallQueue -SearchString "My CallQueue"
    Returns an Object for every Call Queue matching the String "My CallQueue"
    Synonymous with Get-CsCallQueue -NameFilter "My CallQueue", but output shown differently.
	.EXAMPLE
		Get-TeamsCallQueue -Name "My CallQueue" -SearchString "My CallQueue"
		Returns an Object for every Call Queue found with the exact Name "My CallQueue" and
    Returns an Object for every Call Queue matching the String "My CallQueue"
  .INPUTS
    System.String
  .OUTPUTS
    System.Object
  .NOTES
    Without any parameters, Get-TeamsCallQueue will show names only
		Agents, DistributionLists, Targets and Resource Accounts are displayed with friendly name.
    Main difference to Get-CsCallQueue (apart from the friendly names) is that the
    Output view more concise
  .COMPONENT
    TeamsCallQueue
	.FUNCTIONALITY
		Get-CsCallQueue with friendly names instead of GUID-strings for connected objects
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  .LINK
    about_TeamsCallQueue
	.LINK
		New-TeamsCallQueue
	.LINK
		Get-TeamsCallQueue
	.LINK
    Set-TeamsCallQueue
	.LINK
    Remove-TeamsCallQueue
	.LINK
    Get-TeamsAutoAttendant
	.LINK
    Get-TeamsResourceAccount
	.LINK
    Get-TeamsResourceAccountAssociation
  #>

  [CmdletBinding()]
  [Alias('Get-TeamsCQ')]
  [OutputType([System.Object[]])]
  param(
    [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = 'Full Name of the Call Queue')]
    [AllowNull()]
    [string[]]$Name,

    [Parameter(HelpMessage = 'Partial or full Name of the Call Queue to search')]
    [Alias('NameFilter')]
    [string]$SearchString,

    [switch]$Detailed
  ) #param

  begin {
    Show-FunctionStatus -Level Live
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"
    Write-Verbose -Message "Need help? Online:  $global:TeamsFunctionsHelpURLBase$($MyInvocation.MyCommand)`.md"

    # Asserting AzureAD Connection
    if (-not (Assert-AzureADConnection)) { break }

    # Asserting MicrosoftTeams Connection
    if (-not (Assert-MicrosoftTeamsConnection)) { break }

    # Setting Preference Variables according to Upstream settings
    if (-not $PSBoundParameters.ContainsKey('Verbose')) { $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference') }
    if (-not $PSBoundParameters.ContainsKey('Confirm')) { $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference') }
    if (-not $PSBoundParameters.ContainsKey('WhatIf')) { $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference') }
    if (-not $PSBoundParameters.ContainsKey('Debug')) { $DebugPreference = $PSCmdlet.SessionState.PSVariable.GetValue('DebugPreference') } else { $DebugPreference = 'Continue' }
    if ( $PSBoundParameters.ContainsKey('InformationAction')) { $InformationPreference = $PSCmdlet.SessionState.PSVariable.GetValue('InformationAction') } else { $InformationPreference = 'Continue' }

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    # Capturing no input
    if (-not $PSBoundParameters.ContainsKey('Name') -and -not $PSBoundParameters.ContainsKey('SearchString')) {
      Write-Information 'No Parameters - Listing names only. To query individual items, please provide Parameter Name or SearchString'
      Get-CsCallQueue -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | Select-Object Name
      return
    }
    else {
      #region Query objects
      $Queues = @()
      if ($PSBoundParameters.ContainsKey('Name')) {
        # Lookup
        Write-Verbose -Message "Parameter 'Name' - Querying unique result for each provided Name"
        foreach ($DN in $Name) {
          Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand) - Name - '$DN'"
          $QueuesByName = Get-CsCallQueue -NameFilter "$DN" -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
          $QueuesByName = $QueuesByName | Where-Object Name -EQ "$DN"
          $Queues += $QueuesByName
        }
      }

      if ($PSBoundParameters.ContainsKey('SearchString')) {
        # Search
        Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand) - SearchString - '$SearchString'"
        $QueuesByString = Get-CsCallQueue -NameFilter "$SearchString" -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
        $Queues += $QueuesByString
      }
    }
    #endregion

    # Parsing found Objects
    Write-Verbose -Message "[PROCESS] Processing found Queues: $QueueCount"
    $QueueCounter = 0
    [int]$QueueCount = $Queues.Count
    #CHECK Explore Workflows with Parallel parsing:
    #foreach -parallel ($Q in $Queues) {
    foreach ($Q in $Queues) {
      # Initialising counters for Progress bars
      Write-Progress -Id 0 -Status "Queue '$($Q.Name)'" -Activity $MyInvocation.MyCommand -PercentComplete ($QueueCounter / $QueueCount * 100)
      $QueueCounter++
      [int]$step = 0
      [int]$sMax = 8

      # Initialising Arrays
      [System.Collections.ArrayList]$UserObjects = @()
      [System.Collections.ArrayList]$DLNames = @()
      [System.Collections.ArrayList]$AIObjects = @()
      [System.Collections.ArrayList]$OboObjects = @()

      if ( $Detailed ) {
        [System.Collections.ArrayList]$ChannelUserObjects = @()
        [System.Collections.ArrayList]$AgentObjects = @()
        $sMax = $sMax + 2
      }

      #region Finding OverflowActionTarget
      $Operation = 'Parsing OverflowActionTarget'
      Write-Progress -Id 1 -Status "Queue '$($Q.Name)'" -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message "'$($Q.Name)' - $Operation"
      $OAT = $null
      if ($Q.OverflowActionTarget) {
        $OAT = Get-TeamsCallableEntity -Identity "$($Q.OverflowActionTarget.Id)" -WarningAction SilentlyContinue
      }
      # Output: $OAT
      #endregion

      #region Finding TimeoutActionTarget
      $step++
      Write-Progress -Id 1 -Status "Queue '$($Q.Name)'" -CurrentOperation 'Parsing TimeoutActionTarget' -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message "'$($Q.Name)' - Parsing TimeoutActionTarget"
      $TAT = $null
      if ($Q.TimeoutActionTarget) {
        $TAT = Get-TeamsCallableEntity -Identity "$($Q.TimeoutActionTarget.Id)" -WarningAction SilentlyContinue
      }
      # Output: $TAT
      #endregion

      #region Endpoints
      # Channel
      $Operation = 'Parsing Channel'
      $step++
      Write-Progress -Id 1 -Status "Queue '$($Q.Name)'" -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message "'$($Q.Name)' - $Operation"
      if ($Q.ChannelId) {
        $FullChannelId = $Q.DistributionLists.Guid + '\' + $Q.ChannelId
        $Team, $Channel = Get-TeamAndChannel -String "$FullChannelId"
        $TeamAndChannelName = $Team.DisplayName + '\' + $Channel.DisplayName
      }
      # Output: $ChannelObject

      # Distribution Lists
      $Operation = 'Parsing DistributionLists'
      $step++
      Write-Progress -Id 1 -Status "Queue '$($Q.Name)'" -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message "'$($Q.Name)' - $Operation"
      foreach ($DL in $Q.DistributionLists) {
        #$DLObject = Get-UniqueAzureADGroup "$DL" -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
        $DLObject = Get-AzureADGroup -ObjectId "$DL" -WarningAction SilentlyContinue
        if ($DLObject) {
          #Add-Member -Force -InputObject $DLObject -MemberType ScriptMethod -Name ToString -Value [System.Environment]::NewLine + (($this | Select-Object DisplayName | Format-Table -HideTableHeaders | Out-String) -replace '^\s+|\s+$')
          [void]$DLNames.Add($DLObject.DisplayName)
        }
      }
      # Output: $DLNames

      # Users
      $Operation = 'Parsing Users'
      $step++
      Write-Progress -Id 1 -Status "Queue '$($Q.Name)'" -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message "'$($Q.Name)' - $Operation"
      foreach ($User in $Q.Users) {
        $UserObject = Get-AzureADUser -ObjectId "$($User.Guid)" -WarningAction SilentlyContinue | Select-Object UserPrincipalName, DisplayName, JobTitle, CompanyName, Country, UsageLocation, PreferredLanguage
        [void]$UserObjects.Add($UserObject)
      }
      # Output: $UserObjects.UserPrincipalName

      if ( $Detailed ) {
        # Parsing Channel Users when the detailed Switch is used
        $Operation = 'Parsing Channel Users'
        $step++
        Write-Progress -Id 1 -Status "Queue '$($Q.Name)'" -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
        Write-Verbose -Message "'$($Q.Name)' - $Operation"
        foreach ($User in $Q.ChannelUserObjectId) {
          $ChannelUserObject = Get-AzureADUser -ObjectId "$($User.Guid)" -WarningAction SilentlyContinue | Select-Object UserPrincipalName, DisplayName, JobTitle, CompanyName, Country, UsageLocation, PreferredLanguage
          [void]$ChannelUserObjects.Add($ChannelUserObject)
        }
        # Output: $UserObjects.UserPrincipalName

        # Parsing Agents only when the detailed Switch is used
        $Operation = 'Parsing Agents'
        $step++
        Write-Progress -Id 1 -Status "Queue '$($Q.Name)'" -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
        Write-Verbose -Message "'$($Q.Name)' - $Operation"

        foreach ($Agent in $Q.Agents) {
          $AgentObject = Get-AzureADUser -ObjectId "$($Agent.ObjectId)" -WarningAction SilentlyContinue | Select-Object UserPrincipalName, DisplayName, JobTitle, CompanyName, Country, UsageLocation, PreferredLanguage
          [void]$AgentObjects.Add($AgentObject)
        }
        # Output: $AgentObjects.UserPrincipalName
      }
      #endregion

      #region Application Instance UPNs
      $Operation = 'Parsing Resource Accounts (Associated)'
      $step++
      Write-Progress -Id 1 -Status "Queue '$($Q.Name)'" -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message "'$($Q.Name)' - $Operation"
      foreach ($AI in $Q.ApplicationInstances) {
        $AIObject = $null
        $AIObject = Get-CsOnlineApplicationInstance | Where-Object { $_.ObjectId -eq $AI } | Select-Object UserPrincipalName, DisplayName, PhoneNumber
        if ($null -ne $AIObject) {
          [void]$AIObjects.Add($AIObject)
        }
      }
      # Output: $AIObjects.UserPrincipalName
      #endregion

      #region Application Instance UPNs
      $Operation = 'Parsing Resource Accounts (Caller Id)'
      $step++
      Write-Progress -Id 1 -Status "Queue '$($Q.Name)'" -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message "'$($Q.Name)' - $Operation"
      foreach ($OboRA in $Q.OboResourceAccountIds) {
        $OboObject = $null
        $OboObject = Get-CsOnlineApplicationInstance | Where-Object { $_.ObjectId -eq $OboRA } | Select-Object UserPrincipalName, DisplayName, PhoneNumber
        if ($null -ne $OboObject) {
          [void]$OboObjects.Add($OboObject)
        }
      }
      # Output: $OboObjects.UserPrincipalName
      #endregion

      #region Creating Output Object
      # Building custom Object with Friendly Names
      $Operation = 'Constructing Output Object'
      $step++
      Write-Progress -Id 1 -Status "Queue '$($Q.Name)'" -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message "'$($Q.Name)' - $Operation"
      $QueueObject = $null
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
        OverflowActionTarget      = $OAT.Entity
        OverflowActionTargetType  = $OAT.Type
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
      $QueueObject | Add-Member -MemberType NoteProperty -Name TimeoutActionTarget -Value $TAT.Entity
      $QueueObject | Add-Member -MemberType NoteProperty -Name TimeoutActionTargetType -Value $TAT.Type

      if ($PSBoundParameters.ContainsKey('Detailed') -or $TimeoutActionTargetType -eq 'SharedVoiceMail') {
        # Displays SharedVoiceMail Parameters only if TimeoutActionTargetType is set to SharedVoicemail
        $QueueObject | Add-Member -MemberType NoteProperty -Name TimeoutSharedVoicemailAudioFilePrompt -Value $Q.TimeoutSharedVoicemailAudioFilePrompt
        $QueueObject | Add-Member -MemberType NoteProperty -Name TimeoutSharedVoicemailAudioFilePromptFileName -Value $Q.TimeoutSharedVoicemailAudioFilePromptFileName
        $QueueObject | Add-Member -MemberType NoteProperty -Name TimeoutSharedVoicemailTextToSpeechPrompt -Value $Q.TimeoutSharedVoicemailTextToSpeechPrompt
        $QueueObject | Add-Member -MemberType NoteProperty -Name EnableTimeoutSharedVoicemailTranscription -Value $Q.EnableTimeoutSharedVoicemailTranscription
      }

      # Adding Agent Information
      $QueueObject | Add-Member -MemberType NoteProperty -Name TeamAndChannel -Value $TeamAndChannelName
      $QueueObject | Add-Member -MemberType NoteProperty -Name Users -Value $UserObjects.UserPrincipalName
      $QueueObject | Add-Member -MemberType NoteProperty -Name DistributionLists -Value $DLNames
      $QueueObject | Add-Member -MemberType NoteProperty -Name DistributionListsLastExpanded -Value $Q.DistributionListsLastExpanded
      $QueueObject | Add-Member -MemberType NoteProperty -Name AgentsInSyncWithDistributionLists -Value $Q.AgentsInSyncWithDistributionLists
      $QueueObject | Add-Member -MemberType NoteProperty -Name AgentsCapped -Value $Q.AgentsCapped

      if ($PSBoundParameters.ContainsKey('Detailed')) {
        # Displays Agents
        $QueueObject | Add-Member -MemberType NoteProperty -Name Agents -Value $AgentObjects.UserPrincipalName
        $QueueObject | Add-Member -MemberType NoteProperty -Name ChannelUsers -Value $ChannelUserObjects.UserPrincipalName
        # Displays all except reserved Parameters (Microsoft Internal)
        $QueueObject | Add-Member -MemberType NoteProperty -Name MusicOnHoldAudioFileId -Value $Q.MusicOnHoldAudioFileId
        $QueueObject | Add-Member -MemberType NoteProperty -Name WelcomeMusicAudioFileId -Value $Q.WelcomeMusicAudioFileId
        $QueueObject | Add-Member -MemberType NoteProperty -Name MusicOnHoldFileDownloadUri -Value $Q.MusicOnHoldFileDownloadUri
        $QueueObject | Add-Member -MemberType NoteProperty -Name WelcomeMusicFileDownloadUri -Value $Q.WelcomeMusicFileDownloadUri
        $QueueObject | Add-Member -MemberType NoteProperty -Name Description -Value $Q.Description
      }

      # Adding Resource Accounts
      $QueueObject | Add-Member -MemberType NoteProperty -Name ResourceAccountsAssociated -Value $AIObjects.Userprincipalname
      $QueueObject | Add-Member -MemberType NoteProperty -Name ResourceAccountsForCallerId -Value $OboObjects.Userprincipalname
      #endregion

      # Output
      Write-Progress -Id 1 -Status "Queue '$($Q.Name)'" -Activity $MyInvocation.MyCommand -Completed
      Write-Progress -Id 0 -Status "Queue '$($Q.Name)'" -Activity $MyInvocation.MyCommand -Completed

      Write-Output $QueueObject
    }

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"

  } #end
} #Get-TeamsCallQueue
