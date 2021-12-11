# Module:   TeamsFunctions
# Function: CallQueue
# Author:   David Eberhardt
# Updated:  01-OCT-2020
# Status:   Live

#TEST Overflow & Timeout - Voicemail does not work as desired!?
#VALIDATE Adding Users where SIP and UPN are different results in error?

function Set-TeamsCallQueue {
  <#
  .SYNOPSIS
    Set-CsCallQueue with UPNs instead of IDs
  .DESCRIPTION
    Does all the same things that Set-CsCallQueue does, but differs in a few significant respects:
    UserPrincipalNames can be provided instead of IDs, FileNames (FullName) can be provided instead of IDs
    File Import is handled by this Script
    Set-CsCallQueue   is used to apply parameters dependent on specification.
    Partial implementation is possible, output will show differences.
  .PARAMETER Name
    Required. Friendly Name of the Call Queue. Used to Identify the Object
  .PARAMETER DisplayName
    Optional. Updates the Name of the Call Queue. Name will be normalised (unsuitable characters are filtered)
  .PARAMETER AgentAlertTime
    Optional. Time in Seconds to alert each agent. Works depending on Routing method
    Size AgentAlertTime and TimeoutThreshold depending on Routing method and # of Agents available.
  .PARAMETER AllowOptOut
    Optional Switch. Allows Agents to Opt out of receiving calls from the Call Queue
  .PARAMETER UseDefaultMusicOnHold
    Optional Switch. Indicates whether the default Music On Hold should be used.
  .PARAMETER WelcomeMusicAudioFile
    Optional or $NULL. Path to Audio File to be used as a Welcome message
    Accepted Formats: MP3, WAV or WMA, max 5MB
  .PARAMETER MusicOnHoldAudioFile
    Optional. Path to Audio File to be used as Music On Hold.
    Accepted Formats: MP3, WAV or WMA, max 5MB
  .PARAMETER OverflowAction
    Optional. Action to be taken if the Queue size limit (OverflowThreshold) is reached
    Forward requires specification of OverflowActionTarget
    Default: DisconnectWithBusy, Values: DisconnectWithBusy, Forward, VoiceMail, SharedVoiceMail
  .PARAMETER OverflowActionTarget
    Situational. Required only if OverflowAction is not DisconnectWithBusy
    UserPrincipalName of the Target
  .PARAMETER OverflowSharedVoicemailTextToSpeechPrompt
    Situational. Text to be read for a Shared Voicemail greeting. Requires LanguageId
    Required if OverflowAction is SharedVoicemail and OverflowSharedVoicemailAudioFile is $null
  .PARAMETER OverflowSharedVoicemailAudioFile
    Situational. Path to the Audio File for a Shared Voicemail greeting
    Required if OverflowAction is SharedVoicemail and OverflowSharedVoicemailTextToSpeechPrompt is $null
  .PARAMETER EnableOverflowSharedVoicemailTranscription
    Situational. Boolean Switch. Requires specification of LanguageId
    Enables a transcription of the Voicemail message to be sent to the Group mailbox
  .PARAMETER OverflowThreshold
    Optional. Time in Seconds for the OverflowAction to trigger
  .PARAMETER TimeoutAction
    Optional. Action to be taken if the TimeoutThreshold is reached
    Forward requires specification of TimeoutActionTarget
    Default: Disconnect, Values: Disconnect, Forward, VoiceMail, SharedVoiceMail
  .PARAMETER TimeoutActionTarget
    Situational. Required only if TimeoutAction is not Disconnect
    UserPrincipalName of the Target
  .PARAMETER TimeoutSharedVoicemailTextToSpeechPrompt
    Situational. Text to be read for a Shared Voicemail greeting. Requires LanguageId
    Required if TimeoutAction is SharedVoicemail and TimeoutSharedVoicemailAudioFile is $null
  .PARAMETER TimeoutSharedVoicemailAudioFile
    Situational. Path to the Audio File for a Shared Voicemail greeting
    Required if TimeoutAction is SharedVoicemail and TimeoutSharedVoicemailTextToSpeechPrompt is $null
  .PARAMETER EnableTimeoutSharedVoicemailTranscription
    Situational. Boolean Switch. Requires specification of LanguageId
    Enables a transcription of the Voicemail message to be sent to the Group mailbox
  .PARAMETER TimeoutThreshold
    Optional. Time in Seconds for the TimeoutAction to trigger
  .PARAMETER RoutingMethod
    Optional. Describes how the Call Queue is hunting for an Agent.
    Serial will Alert them one by one in order specified (Distribution lists will contact alphabethically)
    Attendant behaves like Parallel if PresenceBasedRouting is used.
    Default: Attendant, Values: Attendant, Serial, RoundRobin, LongestIdle
  .PARAMETER PresenceBasedRouting
    Optional. Default: FALSE. If used alerts Agents only when they are available (Teams status).
  .PARAMETER ConferenceMode
    Optional. Will establish a conference instead of a direct call and should help with connection time.
    Default: TRUE,   Microsoft Default: FALSE
  .PARAMETER DistributionLists
    Optional. Display Names of DistributionLists or Groups. Their members are to become Agents in the Queue.
    Mutually exclusive with TeamAndChannel. Can be combined with Users.
    Will be parsed after Users if they are specified as well.
    To be considered for calls, members of the DistributionsLists must be Enabled for Enterprise Voice.
  .PARAMETER Users
    Optional. UserPrincipalNames of Users that are to become Agents in the Queue.
    Mutually exclusive with TeamAndChannel. Can be combined with DistributionLists.
    Will be parsed first. Order is only important if Serial Routing is desired (See Parameter RoutingMethod)
    Users are only added if they have a PhoneSystem license and are or can be enabled for Enterprise Voice.
  .PARAMETER ChannelUsers
    Optional. UserPrincipalNames of Users. Unknown use-case right now. Feeds Parameter ChannelUserObjectId
    Users are only added if they have a PhoneSystem license and are or can be enabled for Enterprise Voice.
  .PARAMETER TeamAndChannel
    Optional. Uses a Channel to route calls to. Members of the Channel become Agents in the Queue.
    Mutually exclusive with Users and DistributionLists.
    Acceptable format for Team and Channel is "TeamIdentifier\ChannelIdentifier".
    Acceptable Identifier for Teams are GroupId (GUID) or DisplayName. NOTE: DisplayName may not be unique.
    Acceptable Identifier for Channels are Id (GUID) or DisplayName.
  .PARAMETER ResourceAccountsForCallerId
    Optional. Resource Account to be used for allowing Agents to use its number as a Caller Id.
  .PARAMETER LanguageId
    Optional Language Identifier indicating the language that is used to play shared voicemail prompts.
    This parameter becomes a required parameter If either OverflowAction or TimeoutAction is set to SharedVoicemail.
  .PARAMETER Force
    Suppresses confirmation prompt to enable Users for Enterprise Voice, if Users are specified
    Currently no other impact
  .EXAMPLE
    Set-TeamsCallQueue -Name "My Queue" -DisplayName "My new Queue Name"
    Changes the DisplayName of Call Queue "My Queue" to "My new Queue Name"
  .EXAMPLE
    Set-TeamsCallQueue -Name "My Queue" -UseMicrosoftDefaults
    Changes the Call Queue "My Queue" to use Microsoft Default Values
  .EXAMPLE
    Set-TeamsCallQueue -Name "My Queue" -OverflowThreshold 5 -TimeoutThreshold 90
    Changes the Call Queue "My Queue" to overflow with more than 5 Callers waiting and a timeout window of 90s
  .EXAMPLE
    Set-TeamsCallQueue -Name "My Queue" -MusicOnHoldAudioFile C:\Temp\Moh.wav -WelcomeMusicAudioFile C:\Temp\WelcomeMessage.wmv
    Changes the Call Queue "My Queue" with custom Audio Files
  .EXAMPLE
    Set-TeamsCallQueue -Name "My Queue" -AgentAlertTime 15 -RoutingMethod Serial -AllowOptOut:$false -DistributionLists @(List1@domain.com,List2@domain.com)
    Changes the Call Queue "My Queue" alerting every Agent nested in Azure AD Groups List1@domain.com and List2@domain.com in sequence for 15s.
  .EXAMPLE
    Set-TeamsCallQueue -Name "My Queue" -OverflowAction Forward -OverflowActionTarget SIP@domain.com -TimeoutAction Voicemail
    Changes the Call Queue "My Queue" forwarding to SIP@domain.com for Overflow and to Voicemail when it times out.
  .INPUTS
    System.String
  .OUTPUTS
    System.Object or None
  .NOTES
    Audio Files, if not found will result in errors being generated.
    This deviates from the behaviour in New-TeamsCallQueue
    WelcomeMusicAudioFile - Setting not changed. If set before, this will remain.
    MusicOnHoldAudioFile - Setting not changed. If set before, this will remain.
    OverflowSharedVoicemailAudioFile - Setting not changed. OverflowAction will not be changed
    TimeoutSharedVoicemailAudioFile - Setting not changed. TimeoutAction will not be changed
    .COMPONENT
    TeamsCallQueue
  .FUNCTIONALITY
    Changes a Call Queue with friendly names as input
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Set-TeamsCallQueue.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsCallQueue.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  #>

  [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
  [Alias('Set-TeamsCQ')]
  [OutputType([System.Void], [System.Object])]
  param(
    [Parameter(Mandatory, ValueFromPipelineByPropertyName, HelpMessage = 'UserPrincipalName of the Call Queue')]
    [string]$Name,

    [Parameter(HelpMessage = 'Changes the Name to this DisplayName')]
    [string]$DisplayName,

    [Parameter(HelpMessage = 'Time an agent is alerted in seconds (15-180s)')]
    [ValidateScript( {
        If ($_ -ge 15 -and $_ -le 180) {
          $True
        }
        else {
          throw [System.Management.Automation.ValidationMetadataException] 'Must be a value between 30 and 180s (3 minutes)'
          $false
        }
      })]
    [int16]$AgentAlertTime,

    [Parameter(HelpMessage = 'Can agents opt in or opt out from taking calls from a Call Queue (Default: TRUE)')]
    [boolean]$AllowOptOut,

    #region Overflow Params
    [Parameter(HelpMessage = 'Action to be taken for Overflow')]
    [Validateset('DisconnectWithBusy', 'Forward', 'Voicemail', 'SharedVoicemail')]
    [Alias('OA')]
    [string]$OverflowAction,

    [Parameter(HelpMessage = 'TEL URI or UPN that is targeted upon overflow, only valid for forwarded calls')]
    [Alias('OAT')]
    [string]$OverflowActionTarget,

    #region OverflowAction = SharedVoiceMail
    # if OverflowAction is SharedVoicemail one of the following two have to be provided
    [Parameter(HelpMessage = 'Text-to-Voice Message. This will require the LanguageId Parameter')]
    [Alias('OfSVmTTS')]
    [string]$OverflowSharedVoicemailTextToSpeechPrompt,

    [Parameter(HelpMessage = 'Path to Audio File for Overflow SharedVoiceMail Message')]
    [Alias('OfVMFile')]
    [ArgumentCompleter( { 'C:\Temp\' })]
    [string]$OverflowSharedVoicemailAudioFile,

    [Parameter(HelpMessage = 'Using this Parameter will make a Transcription of the Voicemail message available in the Mailbox')]
    [Alias('TranscribeOfVm')]
    [bool]$EnableOverflowSharedVoicemailTranscription,
    #endregion

    [Parameter(HelpMessage = 'Time in seconds (0-200s) before timeout action is triggered (Default: 30, Note: Microsoft default: 50)')]
    [Alias('OfThreshold', 'OfQueueLength')]
    [ValidateScript( {
        If ($_ -ge 0 -and $_ -le 200) {
          $True
        }
        else {
          throw [System.Management.Automation.ValidationMetadataException] 'OverflowThreshold: Must be a value between 0 and 200s.'
          $false
        }
      })]
    [int16]$OverflowThreshold,
    #endregion

    #region Timeout Params
    [Parameter(HelpMessage = 'Action to be taken for Timeout')]
    [Validateset('Disconnect', 'Forward', 'Voicemail', 'SharedVoicemail')]
    [Alias('TA')]
    [string]$TimeoutAction,

    # if TimeoutAction is not Disconnect, this is required
    [Parameter(HelpMessage = 'TEL URI or UPN that is targeted upon timeout, only valid for forwarded calls')]
    [Alias('TAT')]
    [string]$TimeoutActionTarget,

    #region TimeoutAction = SharedVoiceMail
    # if TimeoutAction is SharedVoicemail one of the following two have to be provided
    [Parameter(HelpMessage = 'Text-to-Voice Message. This will require the LanguageId Parameter')]
    [Alias('ToSVmTTS')]
    [string]$TimeoutSharedVoicemailTextToSpeechPrompt,

    [Parameter(HelpMessage = 'Path to Audio File for the SharedVoiceMail Message')]
    [Alias('ToVMFile')]
    [ArgumentCompleter( { 'C:\Temp\' })]
    [string]$TimeoutSharedVoicemailAudioFile,

    [Parameter(HelpMessage = 'Using this Parameter will make a Transcription of the Voicemail message available in the Mailbox')]
    [Alias('TranscribeToVm')]
    [bool]$EnableTimeoutSharedVoicemailTranscription,
    #endregion

    [Parameter(HelpMessage = 'Time in seconds (0-2700s) before timeout action is triggered (Default: 30, Note: Microsoft default: 1200)')]
    [Alias('ToThreshold')]
    [ValidateScript( {
        If ($_ -ge 0 -and $_ -le 2700) {
          $True
        }
        else {
          throw [System.Management.Automation.ValidationMetadataException] 'TimeoutThreshold: Must be a value between 0 and 2700s, will be rounded to nearest 15s intervall (0/15/30/45)'
          $false
        }
      })]
    [int16]$TimeoutThreshold,
    #endregion

    [Parameter(HelpMessage = 'Method to alert Agents')]
    [Validateset('Attendant', 'Serial', 'RoundRobin', 'LongestIdle')]
    [string]$RoutingMethod = 'Attendant',

    [Parameter(HelpMessage = 'If used, Agents receive calls only when their presence state is Available')]
    [boolean]$PresenceBasedRouting,

    [Parameter(HelpMessage = 'Indicates whether the default Music On Hold is used')]
    [boolean]$UseDefaultMusicOnHold,

    [Parameter(HelpMessage = 'If used, Conference mode is used to establish calls')]
    [boolean]$ConferenceMode,

    #region Music files
    [Parameter(HelpMessage = 'Path to Audio File for Welcome Message')]
    [AllowNull()]
    [ArgumentCompleter( { '<Your Text-to-speech-string>', 'C:\Temp\' })]
    [string]$WelcomeMusicAudioFile,

    [Parameter(HelpMessage = 'Path to Audio File for MusicOnHold (cannot be used with UseDefaultMusicOnHold switch!)')]
    [AllowNull()]
    [ArgumentCompleter( { 'C:\Temp\' })]
    [string]$MusicOnHoldAudioFile,
    #endregion

    #region Agents
    [Parameter(HelpMessage = 'Name of one or more Distribution Lists')]
    [string[]]$DistributionLists,

    [Parameter(HelpMessage = 'UPN of one or more Users')]
    [string[]]$Users,

    [Parameter(HelpMessage = 'UPN of one or more Channel Users')]
    [string[]]$ChannelUsers,

    [Parameter(HelpMessage = "Team and Channel in the format 'Team\Channel'")]
    [ValidateScript( { $_ -match '\\' })]
    [ArgumentCompleter( { '<Team Name or ID>\<Channel Name or ID>' })]
    [string]$TeamAndChannel,

    [Parameter(HelpMessage = 'UPN of one or more Resource Accounts used for Caller Id')]
    [string[]]$ResourceAccountsForCallerId,
    #endregion

    [Parameter(HelpMessage = 'Language Identifier from Get-CsAutoAttendantSupportedLanguage.')]
    [ValidateScript( {
        if (-not $global:TeamsFunctionsCsAutoAttendantSupportedLanguageIds) { $global:TeamsFunctionsCsAutoAttendantSupportedLanguageIds = (Get-CsAutoAttendantSupportedLanguage).Id }
        if ($_ -in $TeamsFunctionsCsAutoAttendantSupportedLanguageIds) { $True } else {
          throw [System.Management.Automation.ValidationMetadataException] "Parameter 'LanguageId' must be of the set: $TeamsFunctionsCsAutoAttendantSupportedLanguageIds"
        }
      })]
    [ArgumentCompleter( {
        if (-not $global:TeamsFunctionsCsAutoAttendantSupportedLanguageIds) { $global:TeamsFunctionsCsAutoAttendantSupportedLanguageIds = (Get-CsAutoAttendantSupportedLanguage).Id }
        $TeamsFunctionsCsAutoAttendantSupportedLanguageIds | Sort-Object | ForEach-Object {
          [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', "$($TeamsFunctionsCsAutoAttendantSupportedLanguageIds.Count) records available")
        }
      })]
    [string]$LanguageId,


    [Parameter(HelpMessage = 'By default, no output is generated, PassThru will display the Object changed')]
    [switch]$PassThru,

    [Parameter(HelpMessage = 'Suppresses confirmation prompt to enable Users for Enterprise Voice, if Users are specified')]
    [switch]$Force
  ) #param

  begin {
    Show-FunctionStatus -Level Live
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

    # Asserting AzureAD Connection
    if ( -not $script:TFPSSA) { $script:TFPSSA = Assert-AzureADConnection; if ( -not $script:TFPSSA ) { break } }

    # Asserting MicrosoftTeams Connection
    if ( -not (Assert-MicrosoftTeamsConnection) ) { break }

    # Setting Preference Variables according to Upstream settings
    if (-not $PSBoundParameters.ContainsKey('Verbose')) { $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference') }
    if (-not $PSBoundParameters.ContainsKey('Confirm')) { $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference') }
    if (-not $PSBoundParameters.ContainsKey('WhatIf')) { $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference') }
    if (-not $PSBoundParameters.ContainsKey('Debug')) { $DebugPreference = $PSCmdlet.SessionState.PSVariable.GetValue('DebugPreference') } else { $DebugPreference = 'Continue' }
    if ( $PSBoundParameters.ContainsKey('InformationAction')) { $InformationPreference = $PSCmdlet.SessionState.PSVariable.GetValue('InformationAction') } else { $InformationPreference = 'Continue' }

    #Initialising Counters
    $private:StepsID0, $private:StepsID1 = Get-WriteBetterProgressSteps -Code $($MyInvocation.MyCommand.Definition) -MaxId 1
    $private:ActivityID0 = $($MyInvocation.MyCommand.Name)
    [int] $private:CountID0 = [int] $private:CountID1 = 1

    #region Validating Input
    $StatusID0 = 'Validating Input'
    # Language has to be normalised as the Id is case sensitive
    $CurrentOperationID0 = 'LanguageId'
    Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
    if ($PSBoundParameters.ContainsKey('LanguageId')) {
      $Language = $($LanguageId.Split('-')[0]).ToLower() + '-' + $($LanguageId.Split('-')[1]).ToUpper()
      Write-Verbose "LanguageId '$LanguageId' normalised to '$Language'"
      if ((Get-CsAutoAttendantSupportedLanguage -Id $Language).VoiceResponseSupported) {
        Write-Information "INFO:    Call Queue: LanguageId '$Language' - Voice Responses supported"
      }
      else {
        Write-Information "INFO:    Call Queue: LanguageId '$Language' - Voice Responses are not supported"
      }
    }

    # Mutual exclusivity of Channel and Users/Groups
    $CurrentOperationID0 = 'Checking for mutual exclusivity of Channel and Users/Groups'
    Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
    if ($PSBoundParameters.ContainsKey('TeamAndChannel') -and ($PSBoundParameters.ContainsKey('Users') -or $PSBoundParameters.ContainsKey('DistributionLists'))) {
      Write-Warning "Parameter 'TeamAndChannel' cannot be combined with Users or Groups. It will be ignored!"
      [void]$PSBoundParameters.Remove('TeamAndChannel')
    }
  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    # re-Initialising counters for Progress bars (for Pipeline processing)
    [int] $private:CountID0 = 2

    #region PREPARATION
    $StatusID0 = 'Querying Object'
    # preparing Splatting Object
    $Parameters = $null

    #region Query Unique Element
    $CurrentOperationID0 = "Finding unique result for provided Name '$Name'"
    Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
    if ( $Name -match '^[0-9a-f]{8}-([0-9a-f]{4}\-){3}[0-9a-f]{12}$' ) {
      #Identity or ObjectId
      Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand) - ID - '$Name'"
      $CallQueue = Get-CsCallQueue -Identity "$Name" -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
    }
    else {
      #Name
      Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand) - Name - '$Name'"
      # Initial Query to determine unique result (single object)
      $CallQueue = Get-CsCallQueue -NameFilter "$Name" -WarningAction SilentlyContinue
      $CallQueue = $CallQueue | Where-Object Name -EQ "$Name"
    }

    if ($null -eq $CallQueue) {
      Write-Error "'$Name' No Object found" -Category ParserError -RecommendedAction "Please check 'Name' provided" -ErrorAction Stop
    }
    elseif ($CallQueue.GetType().BaseType.Name -eq 'Array') {
      Write-Error "'$Name' Multiple Results found! Cannot determine unique result." -Category ParserError -RecommendedAction 'Please use Set-CsCallQueue with the -Identity switch!' -ErrorAction Stop
    }
    else {
      $ID = $CallQueue.Identity
      Write-Information "INFO:    Call Queue '$Name' Call Queue found: Identity: $ID"
      $Parameters += @{'Identity' = $ID }
    }
    #endregion

    $StatusID0 = "'$($CallQueue.Name)' - Processing Name, Audio Files & Queue Options"
    #region DisplayName
    $CurrentOperationID0 = 'DisplayName'
    Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
    # Normalising $DisplayName
    if ($PSBoundParameters.ContainsKey('DisplayName')) {
      $NameNormalised = Format-StringForUse -InputString "$DisplayName" -As DisplayName
      Write-Information "INFO:    Call Queue '$Name' DisplayName normalised to: '$NameNormalised'"
      $Parameters += @{'Name' = "$NameNormalised" }
    }
    else {
      $NameNormalised = "$Name"
    }
    #endregion

    #region Music On Hold
    $CurrentOperationID0 = 'Music On Hold Audio File'
    Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
    if ($PSBoundParameters.ContainsKey('MusicOnHoldAudioFile') -and $PSBoundParameters.ContainsKey('UseDefaultMusicOnHold')) {
      Write-Warning -Message "'$NameNormalised' MusicOnHoldAudioFile and UseDefaultMusicOnHold are mutually exclusive. UseDefaultMusicOnHold is ignored!"
      $UseDefaultMusicOnHold = $false
    }
    if ($PSBoundParameters.ContainsKey('MusicOnHoldAudioFile')) {
      if ($null -ne $MusicOnHoldAudioFile) {
        # File import handles file existence, format & size requirements
        $MOHFileName = Split-Path $MusicOnHoldAudioFile -Leaf
        Write-Verbose -Message "'$NameNormalised' MusicOnHoldAudioFile:  Parsing: '$MOHFileName'"
        try {
          $MOHFile = Import-TeamsAudioFile -ApplicationType CallQueue -File "$MusicOnHoldAudioFile" -ErrorAction STOP
          Write-Information "INFO:    Call Queue '$NameNormalised' MusicOnHoldAudioFile:  Using:   '$($MOHFile.FileName)'"
          $Parameters += @{'MusicOnHoldAudioFileId' = $MOHFile.Id }
        }
        catch {
          Write-Error -Message "Import of MusicOnHoldAudioFile: '$MOHFileName' failed. Please check file size and compression ratio. If in doubt, provide WAV" -Category InvalidData -RecommendedAction 'Please check file size and compression ratio. If in doubt, provide WAV'
          return
        }
      }
      else {
        Write-Verbose -Message "'$NameNormalised' MusicOnHoldAudioFile: Using:   DEFAULT"
      }
    }
    elseif ($UseDefaultMusicOnHold -and $PSBoundParameters.ContainsKey('UseDefaultMusicOnHold')) {
      Write-Verbose -Message "'$NameNormalised' MusicOnHoldAudioFile:  Using:   DEFAULT"
      $Parameters += @{'UseDefaultMusicOnHold' = $true }
    }
    else {
      Write-Verbose -Message "'$NameNormalised' MusicOnHoldAudioFile:  Using:   EXISTING SETTING"
    }
    #endregion

    #region Welcome Message
    $CurrentOperationID0 = 'Welcome Message Audio File'
    Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
    if ($PSBoundParameters.ContainsKey('WelcomeMusicAudioFile')) {
      if ($WelcomeMusicAudioFile -eq "$null") {
        $Parameters += @{'WelcomeMusicAudioFileId' = "$null" }
      }
      elseif ($null -ne $WelcomeMusicAudioFile) {
        # File import handles file existence, format & size requirements
        $WMFileName = Split-Path $WelcomeMusicAudioFile -Leaf
        Write-Verbose -Message "'$NameNormalised' WelcomeMusicAudioFile: Parsing: '$WMFileName'"
        try {
          $WMFile = Import-TeamsAudioFile -ApplicationType CallQueue -File "$WelcomeMusicAudioFile" -ErrorAction STOP
          Write-Information "INFO:    Call Queue '$NameNormalised' WelcomeMusicAudioFile: Using:   '$($WMFile.FileName)'"
          $Parameters += @{'WelcomeMusicAudioFileId' = $WMFile.Id }
        }
        catch {
          Write-Error -Message "Import of WelcomeMusicAudioFile: '$WMFileName' failed. Please check file size and compression ratio. If in doubt, provide WAV" -Category InvalidData -RecommendedAction 'Please check file size and compression ratio. If in doubt, provide WAV'
          Write-Verbose -Message "'$NameNormalised' WelcomeMusicAudioFile: Using:   NONE or EXISTING"
        }
      }
      else {
        Write-Verbose -Message "'$NameNormalised' WelcomeMusicAudioFile: Using:   NONE"
        $Parameters += @{'WelcomeMusicAudioFileId' = $null }
      }
    }
    else {
      Write-Verbose -Message "'$NameNormalised' WelcomeMusicAudioFile: Using:   EXISTING SETTING"
    }
    #endregion

    #region Routing metrics, Thresholds and Language
    # One Progress operation for all Parameters
    $CurrentOperationID0 = 'Routing metrics, Thresholds and Language'
    Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0

    #region ValueSet Parameters
    # RoutingMethod
    if ($PSBoundParameters.ContainsKey('RoutingMethod')) {
      $Parameters += @{'RoutingMethod' = $RoutingMethod }
    }
    #endregion

    #region Boolean Parameters
    # PresenceBasedRouting
    if ($PSBoundParameters.ContainsKey('PresenceBasedRouting')) {
      if ($PresenceBasedRouting) {
        $Parameters += @{'PresenceBasedRouting' = $true }
      }
      else {
        $Parameters += @{'PresenceBasedRouting' = $false }
      }
    }
    # AllowOptOut
    if ($PSBoundParameters.ContainsKey('AllowOptOut')) {
      if ($AllowOptOut) {
        $Parameters += @{'AllowOptOut' = $true }
      }
      else {
        $Parameters += @{'AllowOptOut' = $false }
      }
    }
    # ConferenceMode
    if ($PSBoundParameters.ContainsKey('ConferenceMode')) {
      if ($ConferenceMode) {
        $Parameters += @{'ConferenceMode' = $true }
      }
      else {
        $Parameters += @{'ConferenceMode' = $false }
      }
    }
    #endregion

    #region Valued Parameters
    # AgentAlertTime
    if ($PSBoundParameters.ContainsKey('AgentAlertTime')) {
      $Parameters += @{'AgentAlertTime' = $AgentAlertTime }
    }
    # OverflowThreshold
    if ($PSBoundParameters.ContainsKey('OverflowThreshold')) {
      $Parameters += @{'OverflowThreshold' = $OverflowThreshold }
    }
    # TimeoutThreshold
    if ($PSBoundParameters.ContainsKey('TimeoutThreshold')) {
      $Parameters += @{'TimeoutThreshold' = $TimeoutThreshold }
    }
    #endregion


    #region Language
    if ($PSBoundParameters.ContainsKey('LanguageId')) {
      $Parameters += @{'LanguageId' = $Language }
    }
    else {
      $Language = $CallQueue.LanguageId
    }

    # Checking for Parameters which would require LanguageId
    if ($null -eq $Language -and `
      (($PSBoundParameters.ContainsKey('OverflowSharedVoicemailTextToSpeechPrompt')) -or `
        ($PSBoundParameters.ContainsKey('TimeoutSharedVoicemailTextToSpeechPrompt')) -or `
        ($PSBoundParameters.ContainsKey('EnableOverflowSharedVoicemailTranscription')) -or `
        ($PSBoundParameters.ContainsKey('EnableTimeoutSharedVoicemailTranscription')))) {

      Write-Error "'$NameNormalised' LanguageId is not set and not provided. This is required for using Text-to-Voice prompts or Transcription." -ErrorAction Stop -RecommendedAction 'Add Parameter LanguageId'
      return
    }
    #endregion
    #endregion


    #region Overflow
    $StatusID0 = "'$($CallQueue.Name)' - Processing Overflow Parameters"
    #region OverflowAction
    $CurrentOperationID0 = 'OverflowAction'
    Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
    if ($PSBoundParameters.ContainsKey('OverflowAction')) {
      Write-Verbose -Message "'$NameNormalised' OverflowAction '$OverflowAction' Parsing requirements"
      if ($PSBoundParameters.ContainsKey('OverflowActionTarget')) {
        # We have a Target
        if ($OverflowAction -eq 'DisconnectWithBusy') {
          #but we don't need one
          Write-Verbose -Message "'$NameNormalised' OverflowAction '$OverflowAction' does not require an OverflowActionTarget. It will not be processed" -Verbose
          # Remove OverflowActionTarget if set
          [void]$PSBoundParameters.Remove('OverflowActionTarget')
          #$Parameters += @{'OverflowActionTarget' = $null }
        }
        else {
          # OK
          Write-Verbose -Message "'$NameNormalised' OverflowAction '$OverflowAction' and OverflowActionTarget '$OverflowActionTarget' specified. Processing both."
        }
      }
      elseif ($OverflowAction -ne 'DisconnectWithBusy') {
        Write-Warning -Message "'$NameNormalised' OverflowAction '$OverflowAction' not set! Parameter OverflowActionTarget missing"
      }
      elseif ($OverflowAction -eq 'DisconnectWithBusy') {
        if ($PSBoundParameters.ContainsKey('OverflowActionTarget')) {
          Write-Verbose -Message "'$NameNormalised' OverflowAction '$OverflowAction': OverflowActionTarget will be removed." -Verbose
          # Remove OverflowActionTarget if set
          [void]$PSBoundParameters.Remove('OverflowActionTarget')
        }
      }
      # NEW: Adding Action only with a Target | SET: Adding Action if specified
      $Parameters += @{'OverflowAction' = $OverflowAction }
    }
    else {
      $OverflowAction = $CallQueue.OverflowAction
      Write-Verbose -Message "'$NameNormalised' Parameter OverflowAction not present. Using existing setting: '$OverflowAction'"
    }
    #endregion

    #region OverflowActionTarget
    # Processing for Target is dependent on Action
    $CurrentOperationID0 = 'OverflowActionTarget'
    Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
    if ($PSBoundParameters.ContainsKey('OverflowActionTarget')) {
      Write-Verbose -Message "'$NameNormalised' Parsing OverflowActionTarget" -Verbose
      try {
        switch ($OverflowAction) {
          'DisconnectWithBusy' {
            # Explicit setting of DisconnectWithBusy
            if (-not $PSBoundParameters.ContainsKey('OverflowAction')) {
              Write-Verbose -Message "'$NameNormalised' OverflowAction '$OverflowAction': No Overflow-Parameters are processed" -Verbose
            }
            #else: No Action
          }
          'Forward' {
            # Forward requires an OverflowActionTarget (Tel URI, ObjectId of UPN of a User or an Application Instance to be translated to GUID)
            $Target = $OverflowActionTarget
            $CallTarget = $null
            $CallTarget = Get-TeamsCallableEntity -Identity "$Target"
            switch ( $CallTarget.ObjectType ) {
              'TelURI' {
                #Telephone Number (E.164)
                $Parameters += @{'OverflowActionTarget' = $CallTarget.Identity }
              }
              'User' {
                try {
                  $Assertion = $null
                  $Assertion = Assert-TeamsCallableEntity -Identity "$($CallTarget.Entity)" -Terminate -InformationAction SilentlyContinue -WarningAction SilentlyContinue -ErrorAction Stop
                  if ($Assertion) {
                    $Parameters += @{'OverflowActionTarget' = $CallTarget.Identity }
                  }
                  else {
                    Write-Warning -Message "'$NameNormalised' OverflowAction '$OverflowAction': OverflowActionTarget '$OverflowActionTarget' not asserted"
                  }
                }
                catch {
                  Write-Warning -Message "'$NameNormalised' OverflowAction '$OverflowAction': OverflowActionTarget '$OverflowActionTarget' Error: $($_.Exception.Message)"
                }
              }
              'ApplicationEndpoint' {
                try {
                  $Assertion = $null
                  $Assertion = Assert-TeamsCallableEntity -Identity "$($CallTarget.Entity)" -Terminate -InformationAction SilentlyContinue -WarningAction SilentlyContinue -ErrorAction Stop
                  if ($Assertion) {
                    $Parameters += @{'OverflowActionTarget' = $CallTarget.Identity }
                  }
                  else {
                    Write-Warning -Message "'$NameNormalised' OverflowAction '$OverflowAction': OverflowActionTarget '$OverflowActionTarget' not asserted"
                  }
                }
                catch {
                  Write-Warning -Message "'$NameNormalised' OverflowAction '$OverflowAction': OverflowActionTarget '$OverflowActionTarget' Error: $($_.Exception.Message)"
                }
              }
              default {
                # Capturing any other specified Target that does not match for the Forward
                Write-Warning -Message "'$NameNormalised' OverflowAction '$OverflowAction': OverflowActionTarget '$OverflowActionTarget' is incompatible and is not processed!"
                Write-Verbose -Message "'$NameNormalised' OverflowAction '$OverflowAction': OverflowActionTarget expected is: Tel URI or a UPN of a User or Resource Account" -Verbose
              }
            }
          }
          'VoiceMail' {
            # VoiceMail requires an OverflowActionTarget (UPN of a User to be translated to GUID)
            $Target = $OverflowActionTarget
            $CallTarget = Get-TeamsCallableEntity -Identity "$Target"
            if ($CallTarget.ObjectType -eq 'User') {
              try {
                $Assertion = $null
                $Assertion = Assert-TeamsCallableEntity -Identity "$($CallTarget.Entity)" -Terminate -InformationAction SilentlyContinue -WarningAction SilentlyContinue -ErrorAction Stop
                if ($Assertion) {
                  $Parameters += @{'OverflowActionTarget' = $CallTarget.Identity }
                }
                else {
                  Write-Warning -Message "'$NameNormalised' OverflowAction '$OverflowAction': OverflowActionTarget '$OverflowActionTarget' not asserted"
                }
              }
              catch {
                Write-Warning -Message "'$NameNormalised' OverflowAction '$OverflowAction': OverflowActionTarget '$OverflowActionTarget' Error: $($_.Exception.Message)"
              }
            }
            else {
              Write-Warning -Message "'$NameNormalised' OverflowAction '$OverflowAction': OverflowActionTarget '$OverflowActionTarget' is incompatible and is not processed!"
              Write-Verbose -Message "'$NameNormalised' OverflowAction '$OverflowAction': OverflowActionTarget expected is: UPN of a User" -Verbose
            }
          }
          'SharedVoiceMail' {
            # SharedVoiceMail requires an OverflowActionTarget (UPN of a Group to be translated to GUID)
            #region SharedVoiceMail prerequisites
            if ($PSBoundParameters.ContainsKey('OverflowSharedVoicemailAudioFile') -and $PSBoundParameters.ContainsKey('OverflowSharedVoicemailTextToSpeechPrompt')) {
              # Both Parameters provided
              Write-Verbose -Message "'$NameNormalised' OverflowAction '$OverflowAction': OverflowSharedVoicemailAudioFile and OverflowSharedVoicemailTextToSpeechPrompt are mutually exclusive. Processing File only" -Verbose
              [void]$PSBoundParameters.Remove('OverflowSharedVoicemailTextToSpeechPrompt')
            }
            elseif (-not $PSBoundParameters.ContainsKey('OverflowSharedVoicemailAudioFile') -and -not $PSBoundParameters.ContainsKey('OverflowSharedVoicemailTextToSpeechPrompt')) {
              # Neither Parameter provided
              Write-Error -Message "'$NameNormalised' OverflowAction '$OverflowAction': Parameter OverflowSharedVoicemailAudioFile or OverflowSharedVoicemailTextToSpeechPrompt missing" -ErrorAction Stop -RecommendedAction 'Add one of the two parameters'
              return
            }
            elseif ($PSBoundParameters.ContainsKey('OverflowSharedVoicemailTextToSpeechPrompt')) {
              if (($null -eq $CallQueue.LanguageId) -and (-not $PSBoundParameters.ContainsKey('LanguageId'))) {
                Write-Error -Message "'$NameNormalised' OverflowAction '$OverflowAction': OverflowSharedVoicemailTextToSpeechPrompt requires Language selection. Please provide Parameter LanguageId" -ErrorAction Stop -RecommendedAction 'Add Parameter LanguageId'
                return
              }
              elseif ($PSBoundParameters.ContainsKey('LanguageId')) {
                Write-Verbose -Message "'$NameNormalised' OverflowAction '$OverflowAction': OverflowSharedVoicemailTextToSpeechPrompt: Language '$Language' is used" -Verbose
              }
              else {
                Write-Verbose -Message "'$NameNormalised' OverflowAction '$OverflowAction': OverflowSharedVoicemailTextToSpeechPrompt: Language '$($CallQueue.LanguageId)' is already set"
              }
            }
            elseif ($PSBoundParameters.ContainsKey('OverflowSharedVoicemailAudioFile')) {
              # Asserting provided Audio File
              if ( -not (Assert-TeamsAudioFile "$OverflowSharedVoicemailAudioFile")) {
                [void]$Parameters.Remove('OverflowSharedVoicemailAudioFile')
              }
            }
            #endregion

            #region OverflowAction SharedVoicemail - Processing Parameters
            # For NEW, we process all under the condition that a Greeting is there.
            # For SET, we process the TimeoutActionTarget, Greeting & EnableTimeoutSharedVoicemailTranscription separately!

            #region OverflowAction SharedVoicemail - Processing OverflowActionTarget
            if ($PSBoundParameters.ContainsKey('OverflowActionTarget')) {
              Write-Verbose -Message "'$NameNormalised' OverflowAction '$OverflowAction': OverflowActionTarget '$OverflowActionTarget' - Querying Object"
              $CallTarget = $null
              $CallTarget = Get-TeamsCallableEntity -Identity "$OverflowActionTarget"
              switch ( $CallTarget.ObjectType ) {
                'Group' {
                  $OverflowActionTargetId = $CallTarget.Identity
                  Write-Verbose -Message "'$NameNormalised' OverflowAction '$OverflowAction': OverflowActionTarget '$OverflowActionTarget' - Object found!"
                  $Parameters += @{'OverflowActionTarget' = $OverflowActionTargetId }
                }
                'Unknown' {
                  Write-Warning -Message "'$NameNormalised' OverflowAction '$OverflowAction': OverflowActionTarget '$OverflowActionTarget' not set! Error enumerating Target"
                }
                default {
                  Write-Warning -Message "'$NameNormalised' OverflowAction '$OverflowAction': OverflowActionTarget '$OverflowActionTarget' not a Group!"
                }
              }
            }
            #endregion

            #region OverflowAction SharedVoicemail - Processing Greeting
            if (-not $PSBoundParameters.ContainsKey('OverflowSharedVoicemailAudioFile') -and -not $PSBoundParameters.ContainsKey('OverflowSharedVoicemailTextToSpeechPrompt')) {
              # Not processing SharedVoicemail parameters if - after validation - neither AudioFile nor Text-to-Voice are present
              Write-Warning -Message "'$NameNormalised' OverflowAction '$OverflowAction': Parameter OverflowSharedVoicemailAudioFile or OverflowSharedVoicemailTextToSpeechPrompt missing"
              #Write-Error -Message "'$NameNormalised' OverflowAction '$OverflowAction': Parameter OverflowSharedVoicemailAudioFile or OverflowSharedVoicemailTextToSpeechPrompt missing" -ErrorAction Stop -RecommendedAction 'Add one of the two parameters'
              #return
            }
            else {
              #region OverflowAction SharedVoicemail - Processing OverflowSharedVoicemailAudioFile
              if ($PSBoundParameters.ContainsKey('OverflowSharedVoicemailAudioFile')) {
                if ($OverflowAction -ne 'SharedVoicemail') {
                  Write-Verbose -Message "'$NameNormalised' OverflowSharedVoicemailAudioFile:  Not processing Parameter as it is not valid for OverflowAction '$OverflowAction'" -Verbose
                }
                else {
                  $OfSVmFileName = Split-Path $OverflowSharedVoicemailAudioFile -Leaf
                  Write-Verbose -Message "'$NameNormalised' OverflowSharedVoicemailAudioFile:  Parsing: '$OfSVmFileName'"
                  try {
                    $OfSVmFile = Import-TeamsAudioFile -ApplicationType CallQueue -File "$OverflowSharedVoicemailAudioFile" -ErrorAction STOP
                    Write-Information "INFO:    Call Queue '$NameNormalised' OverflowSharedVoicemailAudioFile:  Using:   '$($OfSVmFile.FileName)'"
                    $Parameters += @{'OverflowSharedVoicemailAudioFilePrompt' = $OfSVmFile.Id }
                  }
                  catch {
                    Write-Error -Message "Import of OverflowSharedVoicemailAudioFile: '$OfSVmFileName' failed." -Category InvalidData -RecommendedAction 'Please check file size and compression ratio. If in doubt, provide WAV'
                    return
                  }
                }
              }
              #endregion

              #region OverflowAction SharedVoicemail - Processing OverflowSharedVoicemailTextToSpeechPrompt
              if ($PSBoundParameters.ContainsKey('OverflowSharedVoicemailTextToSpeechPrompt')) {
                if ($OverflowAction -ne 'SharedVoicemail') {
                  Write-Verbose -Message "'$NameNormalised' OverflowSharedVoicemailAudioFile:  Not processing Parameter as it is not valid for OverflowAction '$OverflowAction'" -Verbose
                }
                else {
                  $Parameters += @{'OverflowSharedVoicemailTextToSpeechPrompt' = "$OverflowSharedVoicemailTextToSpeechPrompt" }
                }
              }
              #endregion
            }
            #endregion

            #region OverflowAction SharedVoicemail - Processing EnableOverflowSharedVoicemailTranscription
            if ($PSBoundParameters.ContainsKey('EnableOverflowSharedVoicemailTranscription')) {
              if ($OverflowAction -ne 'SharedVoicemail') {
                Write-Verbose -Message "'$NameNormalised' OverflowSharedVoicemailAudioFile:  Not processing Parameter as it is not valid for OverflowAction '$OverflowAction'" -Verbose
              }
              else {
                $Parameters += @{'EnableOverflowSharedVoicemailTranscription' = $EnableOverflowSharedVoicemailTranscription }
              }
            }
            #endregion
            #endregion
          }
        }
      }
      catch {
        Write-Warning -Message "'$NameNormalised' OverflowAction '$OverflowAction': OverflowActionTarget '$OverflowActionTarget' not set! Error enumerating Target: $($_.Exception.Message)"
      }
    }
    else {
      # Verifying whether OverflowAction DisconnectWithBusy is used to blank the Target
      if ($OverflowAction -eq 'DisconnectWithBusy') {
        # Remove OverflowActionTarget if set
        [void]$PSBoundParameters.Remove('OverflowActionTarget')
      }
    }
    #endregion

    #region OverflowAction Parameter cleanup
    if ($Parameters.OverflowActionTarget -eq '') {
      [void]$Parameters.Remove('OverflowActionTarget')
    }
    if ($Parameters.ContainsKey('OverflowAction') -and (-not $Parameters.ContainsKey('OverflowActionTarget')) -and ($OverflowAction -ne 'DisconnectWithBusy')) {
      Write-Verbose -Message "'$NameNormalised' OverflowAction '$OverflowAction': Action not set as OverflowActionTarget was not correctly enumerated" -Verbose
      [void]$Parameters.Remove('OverflowAction')
    }
    else {
      if ($Parameters.ContainsKey('OverflowAction')) {
        Write-Information "INFO:    Call Queue '$NameNormalised' OverflowAction used: '$OverflowAction'"
      }
    }
    # For NEW: We remove all SharedVoicemail Parameters if no Target is present
    # For SET: Parameters may be applied individually (no removal of SharedVoicemail parameters)
    if ( $Parameters.OverflowActionTarget) {
      Write-Information "INFO:    Call Queue '$NameNormalised' OverflowActionTarget: '$OverflowActionTarget'"
    }
    #endregion
    #endregion

    #region Timeout
    $StatusID0 = "'$($CallQueue.Name)' - Processing Timeout Parameters"
    #region TimeoutAction
    $CurrentOperationID0 = 'TimeoutAction'
    Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
    if ($PSBoundParameters.ContainsKey('TimeoutAction')) {
      Write-Verbose -Message "'$NameNormalised' TimeoutAction '$TimeoutAction' Parsing requirements"
      if ($PSBoundParameters.ContainsKey('TimeoutActionTarget')) {
        # We have a Target
        if ($TimeoutAction -eq 'Disconnect') {
          #but we don't need one
          Write-Verbose -Message "'$NameNormalised' TimeoutAction '$TimeoutAction' does not require an TimeoutActionTarget. It will not be processed" -Verbose
          # Remove TimeoutActionTarget if set
          [void]$PSBoundParameters.Remove('TimeoutActionTarget')
          #$Parameters += @{'TimeoutActionTarget' = $null }
        }
        else {
          # OK
          Write-Verbose -Message "'$NameNormalised' TimeoutAction '$TimeoutAction' and TimeoutActionTarget '$TimeoutActionTarget' specified. Processing both."
        }
      }
      elseif ($TimeoutAction -ne 'Disconnect') {
        Write-Warning -Message "'$NameNormalised' TimeoutAction '$TimeoutAction' not set! Parameter TimeoutActionTarget missing"
      }
      elseif ($TimeoutAction -eq 'Disconnect') {
        if ($PSBoundParameters.ContainsKey('TimeoutActionTarget')) {
          Write-Verbose -Message "'$NameNormalised' TimeoutAction '$TimeoutAction': TimeoutActionTarget will be removed." -Verbose
          # Remove TimeoutActionTarget if set
          [void]$PSBoundParameters.Remove('TimeoutActionTarget')
        }
      }
      # NEW: Adding Action only with a Target | SET: Adding Action if specified
      $Parameters += @{'TimeoutAction' = $TimeoutAction }
    }
    else {
      $TimeoutAction = $CallQueue.TimeoutAction
      Write-Verbose -Message "'$NameNormalised' Parameter TimeoutAction not present. Using existing setting: '$TimeoutAction'"
    }
    #endregion

    #region TimeoutActionTarget
    # Processing for Target is dependent on Action
    $CurrentOperationID0 = 'TimeoutActionTarget'
    Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
    if ($PSBoundParameters.ContainsKey('TimeoutActionTarget')) {
      Write-Verbose -Message "'$NameNormalised' Parsing TimeoutActionTarget" -Verbose
      try {
        switch ($TimeoutAction) {
          'Disconnect' {
            # Explicit setting of DisconnectWithBusy
            if (-not $PSBoundParameters.ContainsKey('TimeoutAction')) {
              Write-Verbose -Message "'$NameNormalised' TimeoutAction '$TimeoutAction': No Timeout-Parameters are processed" -Verbose
            }
            #else: No Action
          }
          'Forward' {
            # Forward requires an TimeoutActionTarget (Tel URI, ObjectId of UPN of a User or an Application Instance to be translated to GUID)
            $Target = $TimeoutActionTarget
            $CallTarget = Get-TeamsCallableEntity -Identity "$Target"
            switch ( $CallTarget.ObjectType ) {
              'TelURI' {
                #Telephone Number (E.164)
                $Parameters += @{'TimeoutActionTarget' = $CallTarget.Identity }
              }
              'User' {
                try {
                  $Assertion = $null
                  $Assertion = Assert-TeamsCallableEntity -Identity "$($CallTarget.Entity)" -Terminate -InformationAction SilentlyContinue -WarningAction SilentlyContinue -ErrorAction Stop
                  if ($Assertion) {
                    $Parameters += @{'TimeoutActionTarget' = $CallTarget.Identity }
                  }
                  else {
                    Write-Warning -Message "'$NameNormalised' TimeoutAction '$TimeoutAction': TimeoutActionTarget '$TimeoutActionTarget' not asserted"
                  }
                }
                catch {
                  Write-Warning -Message "'$NameNormalised' TimeoutAction '$TimeoutAction': TimeoutActionTarget '$TimeoutActionTarget' Error: $($_.Exception.Message)"
                }
              }
              'ApplicationEndpoint' {
                try {
                  $Assertion = $null
                  $Assertion = Assert-TeamsCallableEntity -Identity "$($CallTarget.Entity)" -Terminate -InformationAction SilentlyContinue -WarningAction SilentlyContinue -ErrorAction Stop
                  if ($Assertion) {
                    $Parameters += @{'TimeoutActionTarget' = $CallTarget.Identity }
                  }
                  else {
                    Write-Warning -Message "'$NameNormalised' TimeoutAction '$TimeoutAction': TimeoutActionTarget '$TimeoutActionTarget' not asserted"
                  }
                }
                catch {
                  Write-Warning -Message "'$NameNormalised' TimeoutAction '$TimeoutAction': TimeoutActionTarget '$TimeoutActionTarget' Error: $($_.Exception.Message)"
                }
              }
              default {
                # Capturing any other specified Target that does not match for the Forward
                Write-Warning -Message "'$NameNormalised' TimeoutAction '$TimeoutAction': TimeoutActionTarget '$TimeoutActionTarget' is incompatible and is not processed!"
                Write-Verbose -Message "'$NameNormalised' TimeoutAction '$TimeoutAction': TimeoutActionTarget expected is: Tel URI or a UPN of a User or Resource Account" -Verbose
              }
            }
          }
          'VoiceMail' {
            # VoiceMail requires an TimeoutActionTarget (UPN of a User to be translated to GUID)
            $Target = $TimeoutActionTarget
            $CallTarget = Get-TeamsCallableEntity -Identity "$Target"
            if ($CallTarget.ObjectType -eq 'User') {
              try {
                $Assertion = $null
                $Assertion = Assert-TeamsCallableEntity -Identity "$($CallTarget.Entity)" -Terminate -WarningAction SilentlyContinue -ErrorAction Stop
                if ($Assertion) {
                  $Parameters += @{'TimeoutActionTarget' = $CallTarget.Identity }
                }
                else {
                  Write-Warning -Message "'$NameNormalised' TimeoutAction '$TimeoutAction': TimeoutActionTarget '$TimeoutActionTarget' not asserted"
                }
              }
              catch {
                Write-Warning -Message "'$NameNormalised' TimeoutAction '$TimeoutAction': TimeoutActionTarget '$TimeoutActionTarget' Error: $($_.Exception.Message)"
              }
            }
            else {
              Write-Warning -Message "'$NameNormalised' TimeoutAction '$TimeoutAction': TimeoutActionTarget '$TimeoutActionTarget' is incompatible and is not processed!"
              Write-Verbose -Message "'$NameNormalised' TimeoutAction '$TimeoutAction': TimeoutActionTarget expected is: UPN of a User" -Verbose
            }
          }
          'SharedVoiceMail' {
            # SharedVoiceMail requires an TimeoutActionTarget (UPN of a Group to be translated to GUID)
            #region SharedVoiceMail prerequisites
            if ($PSBoundParameters.ContainsKey('TimeoutSharedVoicemailAudioFile') -and $PSBoundParameters.ContainsKey('TimeoutSharedVoicemailTextToSpeechPrompt')) {
              # Both Parameters provided
              Write-Verbose -Message "'$NameNormalised' TimeoutAction '$TimeoutAction': TimeoutSharedVoicemailAudioFile and TimeoutSharedVoicemailTextToSpeechPrompt are mutually exclusive. Processing File only" -Verbose
              [void]$PSBoundParameters.Remove('TimeoutSharedVoicemailTextToSpeechPrompt')
            }
            elseif (-not $PSBoundParameters.ContainsKey('TimeoutSharedVoicemailAudioFile') -and -not $PSBoundParameters.ContainsKey('TimeoutSharedVoicemailTextToSpeechPrompt')) {
              # Neither Parameter provided
              Write-Error -Message "'$NameNormalised' TimeoutAction '$TimeoutAction': Parameter TimeoutSharedVoicemailAudioFile or TimeoutSharedVoicemailTextToSpeechPrompt missing" -ErrorAction Stop -RecommendedAction 'Add one of the two parameters'
              return
            }
            elseif ($PSBoundParameters.ContainsKey('TimeoutSharedVoicemailTextToSpeechPrompt')) {
              if (-not $PSBoundParameters.ContainsKey('LanguageId')) {
                Write-Error -Message "'$NameNormalised' TimeoutAction '$TimeoutAction': TimeoutSharedVoicemailTextToSpeechPrompt requires Language selection. Please provide Parameter LanguageId" -ErrorAction Stop -RecommendedAction 'Add Parameter LanguageId'
                return
              }
              else {
                Write-Verbose -Message "'$NameNormalised' TimeoutAction '$TimeoutAction': TimeoutSharedVoicemailTextToSpeechPrompt: Language '$Language' is used" -Verbose
              }
            }
            elseif ($PSBoundParameters.ContainsKey('TimeoutSharedVoicemailAudioFile')) {
              # Asserting provided Audio File
              if ( -not (Assert-TeamsAudioFile 'TimeoutSharedVoicemailAudioFile')) {
                [void]$Parameters.Remove('TimeoutSharedVoicemailAudioFile')
              }
            }
            #endregion

            #region TimeoutAction SharedVoicemail - Processing Parameters
            # For NEW, we process all under the condition that a Greeting is there.
            # For SET, we process them TimeoutActionTarget, Greeting & EnableTimeoutSharedVoicemailTranscription separately!

            #region TimeoutAction SharedVoicemail - Processing TimeoutActionTarget
            if ($PSBoundParameters.ContainsKey('TimeoutActionTarget')) {
              Write-Verbose -Message "'$NameNormalised' TimeoutAction '$TimeoutAction': TimeoutActionTarget '$TimeoutActionTarget' - Querying Object"
              $CallTarget = $null
              $CallTarget = Get-TeamsCallableEntity -Identity "$TimeoutActionTarget"
              switch ( $CallTarget.ObjectType ) {
                'Group' {
                  $TimeoutActionTargetId = $CallTarget.Identity
                  Write-Verbose -Message "'$NameNormalised' TimeoutAction '$TimeoutAction': TimeoutActionTarget '$TimeoutActionTarget' - Object found!"
                  $Parameters += @{'TimeoutActionTarget' = $TimeoutActionTargetId }
                }
                'Unknown' {
                  Write-Warning -Message "'$NameNormalised' TimeoutAction '$TimeoutAction': TimeoutActionTarget '$TimeoutActionTarget' not set! Error enumerating Target"
                }
                default {
                  Write-Warning -Message "'$NameNormalised' TimeoutAction '$TimeoutAction': TimeoutActionTarget '$TimeoutActionTarget' not a Group!"
                }
              }
            }
            #endregion

            #region OverflowAction SharedVoicemail - Processing Greeting
            if (-not $PSBoundParameters.ContainsKey('TimeoutSharedVoicemailAudioFile') -and -not $PSBoundParameters.ContainsKey('TimeoutSharedVoicemailTextToSpeechPrompt')) {
              # Not processing SharedVoicemail parameters if - after validation - neither AudioFile nor Text-to-Voice are present
              Write-Warning -Message "'$NameNormalised' TimeoutAction '$TimeoutAction': Parameter TimeoutSharedVoicemailAudioFile or TimeoutSharedVoicemailTextToSpeechPrompt missing"
              #Write-Error -Message "'$NameNormalised' OverflowAction '$OverflowAction': Parameter TimeoutSharedVoicemailAudioFile or TimeoutSharedVoicemailTextToSpeechPrompt missing" -ErrorAction Stop -RecommendedAction 'Add one of the two parameters'
              #return
            }
            else {
              #region TimeoutAction SharedVoicemail - Processing TimeoutSharedVoicemailAudioFile
              if ($PSBoundParameters.ContainsKey('TimeoutSharedVoicemailAudioFile')) {
                if ($TimeoutAction -ne 'SharedVoicemail') {
                  Write-Verbose -Message "'$NameNormalised' TimeoutSharedVoicemailAudioFile:  Not processing Parameter as it is not valid for TimeoutAction '$TimeoutAction'" -Verbose
                }
                else {
                  $ToSVmFileName = Split-Path $TimeoutSharedVoicemailAudioFile -Leaf
                  Write-Verbose -Message "'$NameNormalised' TimeoutSharedVoicemailAudioFile:  Parsing: '$ToSVmFileName'"
                  try {
                    $ToSVmFile = Import-TeamsAudioFile -ApplicationType CallQueue -File "$TimeoutSharedVoicemailAudioFile" -ErrorAction STOP
                    Write-Information "INFO:    Call Queue '$NameNormalised' TimeoutSharedVoicemailAudioFile:  Using:   '$($ToSVmFile.FileName)'"
                    $Parameters += @{'TimeoutSharedVoicemailAudioFilePrompt' = $ToSVmFile.Id }
                  }
                  catch {
                    Write-Error -Message "Import of TimeoutSharedVoicemailAudioFile: '$ToSVmFileName' failed." -Category InvalidData -RecommendedAction 'Please check file size and compression ratio. If in doubt, provide WAV'
                    return
                  }
                }
              }
              #endregion

              #region TimeoutAction SharedVoicemail - Processing TimeoutSharedVoicemailTextToSpeechPrompt
              if ($PSBoundParameters.ContainsKey('TimeoutSharedVoicemailTextToSpeechPrompt')) {
                if ($TimeoutAction -ne 'SharedVoicemail') {
                  Write-Verbose -Message "'$NameNormalised' TimeoutSharedVoicemailAudioFile:  Not processing Parameter as it is not valid for TimeoutAction '$TimeoutAction'" -Verbose
                }
                else {
                  $Parameters += @{'TimeoutSharedVoicemailTextToSpeechPrompt' = "$TimeoutSharedVoicemailTextToSpeechPrompt" }
                }
              }
              #endregion
            }
            #endregion

            #region TimeoutAction SharedVoicemail - Processing EnableTimeoutSharedVoicemailTranscription
            if ($PSBoundParameters.ContainsKey('EnableTimeoutSharedVoicemailTranscription')) {
              if ($TimeoutAction -ne 'SharedVoicemail') {
                Write-Verbose -Message "'$NameNormalised' TimeoutSharedVoicemailAudioFile:  Not processing Parameter as it is not valid for TimeoutAction '$TimeoutAction'" -Verbose
              }
              else {
                $Parameters += @{'EnableTimeoutSharedVoicemailTranscription' = $EnableOverflowSharedVoicemailTranscription }
              }
            }
            #endregion
            #endregion
          }
        }
      }
      catch {
        Write-Warning -Message "'$NameNormalised' TimeoutAction '$TimeoutAction': TimeoutActionTarget '$TimeoutActionTarget' not set! Error enumerating Target: $($_.Exception.Message)"
      }
    }
    else {
      # Verifying whether OverflowAction DisconnectWithBusy is used to blank the Target
      if ($TimeoutAction -eq 'Disconnect') {
        # Remove TimeoutActionTarget if set
        [void]$PSBoundParameters.Remove('TimeoutActionTarget')
      }
    }
    #endregion

    #region TimeoutAction Parameter cleanup
    if ($Parameters.TimeoutActionTarget -eq '') {
      [void]$Parameters.Remove('TimeoutActionTarget')
    }
    if ($Parameters.ContainsKey('TimeoutAction') -and (-not $Parameters.ContainsKey('TimeoutActionTarget')) -and ($TimeoutAction -ne 'Disconnect')) {
      Write-Verbose -Message "'$NameNormalised' TimeoutAction '$TimeoutAction': Action not set as TimeoutActionTarget was not correctly enumerated" -Verbose
      [void]$Parameters.Remove('TimeoutAction')
    }
    else {
      if ($Parameters.ContainsKey('TimeoutAction')) {
        Write-Information "INFO:    Call Queue '$NameNormalised' TimeoutAction: '$TimeoutAction'"
      }
    }
    # For NEW: We remove all SharedVoicemail Parameters if no Target is present
    # For SET: Parameters may be applied individually (no removal of SharedVoicemail parameters)
    if ($Parameters.TimeoutActionTarget) {
      Write-Information "INFO:    Call Queue '$NameNormalised' TimeoutActionTarget: '$TimeoutActionTarget'"
    }
    #endregion
    #endregion


    #region Agents & Accounts
    $StatusID0 = "'$($CallQueue.Name)' - Agents, Channel, Users & Caller Id"
    #region Channel
    $CurrentOperationID0 = 'Parsing Channel'
    Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
    if ($PSBoundParameters.ContainsKey('TeamAndChannel')) {
      Write-Verbose -Message "'$NameNormalised' Parsing Team and Channel" -Verbose
      try {
        $Team, $Channel = Get-TeamAndChannel -String "$FullChannelId"
        Write-Information "INFO:    Call Queue '$NameNormalised' TeamAndChannel: Team '$($Team.DisplayName)' - Channel '$($Channel.DisplayName)' will be added to the Call Queue"
        $Parameters += @{'ChannelId' = $Channel.Id }
      }
      catch {
        Write-Warning -Message "TeamAndChannel: Error parsing Object. Target will not be added to the Call Queue. Exception: $($_.Exception.Message)"
      }
    }
    #endregion

    #region ChannelUsers - Parsing and verifying ChannelUsers
    $CurrentOperationID0 = 'Parsing ChannelUsers'
    Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
    if ($PSBoundParameters.ContainsKey('ChannelUsers')) {
      Write-Verbose -Message "'$NameNormalised' Parsing ChannelUsers"
      [System.Collections.ArrayList]$ChannelUsersIdList = @()
      foreach ($ChannelUser in $ChannelUsers) {
        $Assertion = $null
        $CallTarget = $null
        $CallTarget = Get-TeamsCallableEntity -Identity "$ChannelUser"
        if ( $CallTarget.ObjectType -ne 'User') {
          Write-Warning -Message "'$NameNormalised' Object '$ChannelUser' is not a User, omitting Object!"
          continue
        }
        try {
          # Asserting Object - Validation of Type
          $Assertion = Assert-TeamsCallableEntity -Identity "$($CallTarget.Entity)" -Terminate -WarningAction SilentlyContinue -ErrorAction Stop
          if ( $Assertion ) {
            Write-Information "INFO:    User '$ChannelUser' will be added to CallQueue"
            [void]$ChannelUsersIdList.Add($CallTarget.Identity)
          }
          else {
            Write-Warning -Message "'$NameNormalised' Object '$ChannelUser' not found or in unusable state, omitting Object!"
            continue
          }
        }
        catch {
          Write-Warning -Message "'$NameNormalised' Object '$ChannelUser' not in correct state or not enabled for Enterprise Voice, omitting Object!"
          Write-Debug "Exception: $($_.Exception.Message)"
          continue
        }
      }

      if ($UserIdList.Count -gt 0) {
        Write-Verbose -Message "'$NameNormalised' Users: Adding $($ChannelUsersIdList.Count) ChannelUsers to the Queue" -Verbose
        $Parameters += @{'ChannelUserObjectId' = @($ChannelUsersIdList) }
      }
    }
    #endregion


    #region Users - Parsing and verifying Users
    $CurrentOperationID0 = 'Parsing Users'
    Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
    if ($PSBoundParameters.ContainsKey('Users')) {
      Write-Verbose -Message "'$NameNormalised' Parsing Users"
      [System.Collections.ArrayList]$UserIdList = @()
      foreach ($User in $Users) {
        $Assertion = $null
        $CallTarget = $null
        $CallTarget = Get-TeamsCallableEntity -Identity "$User"
        if ( $CallTarget.ObjectType -ne 'User') {
          Write-Warning -Message "'$NameNormalised' Object '$User' is not a User, omitting Object!"
          continue
        }
        try {
          # Asserting Object - Validation of Type
          $Assertion = Assert-TeamsCallableEntity -Identity "$($CallTarget.Entity)" -Terminate -WarningAction SilentlyContinue -ErrorAction Stop
          if ( $Assertion ) {
            Write-Information "INFO:    User '$($CallTarget.Entity)' will be added to CallQueue"
            [void]$UserIdList.Add($CallTarget.Identity)
          }
          else {
            Write-Warning -Message "'$NameNormalised' Object '$User' not found or in unusable state, omitting Object!"
            continue
          }
        }
        catch {
          Write-Warning -Message "'$NameNormalised' Object '$User' not in correct state or not enabled for Enterprise Voice, omitting Object!"
          Write-Debug "Exception: $($_.Exception.Message)"
          continue
        }
      }

      if ($UserIdList.Count -gt 0) {
        Write-Verbose -Message "'$NameNormalised' Users: Adding $($UserIdList.Count) Users as Agents to the Queue" -Verbose
        $Parameters += @{'Users' = @($UserIdList) }
      }
    }
    #endregion

    #region Groups - Parsing Distribution Lists and their Users
    $CurrentOperationID0 = 'Parsing Distribution Lists'
    Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
    if ($PSBoundParameters.ContainsKey('DistributionLists')) {
      Write-Verbose -Message "'$NameNormalised' Parsing Distribution Lists" -Verbose
      [System.Collections.ArrayList]$DLIdList = @()
      foreach ($DL in $DistributionLists) {
        $DLObject = $null
        $DLObject = Get-TeamsCallableEntity -Identity "$DL"
        if ($DLObject) {
          Write-Information "INFO:    Call Queue '$NameNormalised' Group '$DL' will be added to the Call Queue"
          # Test whether Users in DL are enabled for EV and/or licensed?

          # Add to List
          [void]$DLIdList.Add($DLObject.Identity)
        }
        else {
          Write-Warning -Message "Group '$DL' not found or not unique in AzureAd, omitting Group!"
        }
      }

      if ($DLIdList.Count -gt 0) {
        Write-Verbose -Message "'$NameNormalised' Groups: Adding $($DLIdList.Count) Groups to the Queue" -Verbose
        $Parameters += @{'DistributionLists' = @($DLIdList) }
        Write-Information 'INFO: Group members are parsed by the subsystem and are not validated regarding Licensing or EV-Enablement'
      }
    }
    #endregion


    #region ResourceAccountsForCallerId - Parsing and verifying Parsing Resource Accounts for Caller Id
    $CurrentOperationID0 = 'Parsing Resource Accounts for Caller Id'
    Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
    if ($PSBoundParameters.ContainsKey('ResourceAccountsForCallerId')) {
      Write-Verbose -Message "'$NameNormalised' Parsing Resource Accounts for Caller Id"
      [System.Collections.ArrayList]$OboResourceAccountIds = @()
      foreach ($RA in $ResourceAccountsForCallerId) {
        $Assertion = $null
        $CallTarget = $null
        $CallTarget = Get-TeamsCallableEntity -Identity "$RA"
        if ( $CallTarget.ObjectType -ne 'ApplicationEndpoint') {
          Write-Warning -Message "'$NameNormalised' Object '$RA' is not a Resource Account, omitting Object!"
          continue
        }
        try {
          # Asserting Object - Validation of Type
          $Assertion = Assert-TeamsCallableEntity -Identity "$($CallTarget.Entity)" -Terminate -WarningAction SilentlyContinue -ErrorAction Stop
          if ( $Assertion ) {
            Write-Information "INFO:    Call Queue '$NameNormalised' Resource Account '$RA' will be added to CallQueue"
            [void]$RAIdList.Add($CallTarget.Identity)
          }
          else {
            Write-Warning -Message "'$NameNormalised' Object '$RA' not found or in unusable state, omitting Object!"
            continue
          }
        }
        catch {
          Write-Warning -Message "'$NameNormalised' Object '$RA' not in correct state or not enabled for Enterprise Voice, omitting Object!"
          Write-Debug "Exception: $($_.Exception.Message)"
          continue
        }
      }

      if ($OboResourceAccountIds.Count -gt 0) {
        Write-Verbose -Message "'$NameNormalised' Resource Account: Adding $($OboResourceAccountIds.Count) Resource Accounts for Caller Id to the Queue" -Verbose
        $Parameters += @{'OboResourceAccountIds' = @($OboResourceAccountIds) }
      }
    }
    #endregion
    #endregion


    #region Common parameters
    $Parameters += @{'WarningAction' = 'SilentlyContinue' }
    $Parameters += @{'ErrorAction' = 'Stop' }
    #endregion
    #endregion


    #region ACTION
    $StatusID0 = 'Applying settings'
    $CurrentOperationID0 = "Changing Call Queue: '$NameNormalised'"
    Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
    if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
      "  Function: $($MyInvocation.MyCommand.Name) - Parameters:", ($Parameters | Format-Table -AutoSize | Out-String).Trim() | Write-Debug
    }

    # Set the Call Queue with all Parameters provided
    if ($PSCmdlet.ShouldProcess("$NameNormalised", 'Set-CsCallQueue')) {
      $null = (Set-CsCallQueue @Parameters)
      Write-Verbose -Message "SUCCESS: '$NameNormalised' Call Queue settings applied"
    }
    #endregion


    #region OUTPUT
    # Re-query output
    if ( $PassThru ) {
      $CurrentOperationID0 = 'Preparing Output'
      Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
      $CallQueueFinal = Get-TeamsCallQueue -Name "$NameNormalised" -WarningAction SilentlyContinue
      $CallQueueFinal = $CallQueueFinal | Where-Object Name -EQ "$NameNormalised"
    }
    else {
      $CallQueueFinal = $null
    }
    Write-Progress -Id 0 -Activity $ActivityID0 -Completed
    Write-Output $CallQueueFinal
    #endregion

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"

  } #end
} #Set-TeamsCallQueue
