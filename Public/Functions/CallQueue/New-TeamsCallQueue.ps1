# Module:   TeamsFunctions
# Function: CallQueue
# Author:		David Eberhardt
# Updated:  01-DEC-2020
# Status:   RC




function New-TeamsCallQueue {
  <#
  .SYNOPSIS
    New-CsCallQueue with UPNs instead of IDs
  .DESCRIPTION
    This function handles all options New-CsCallQueue offers.
    It can be seen as a replacement/upgrade, but it differs in a few significant respects:
    UserPrincipalNames can be provided instead of IDs, FileNames (FullName) can be provided instead of IDs
    File Import is handled by this Script
    Small changes to defaults (see Parameter UseMicrosoftDefaults for details)
    Partial implementation is possible, output will show differences.
  .PARAMETER Name
    Name of the Call Queue. Name will be normalised (unsuitable characters are filtered)
    Used as the DisplayName - Visible in Teams
  .PARAMETER UseMicrosoftDefaults
    This script uses different default values for some parameters than New-CsCallQueue
    Using this switch will instruct the Script to adhere to Microsoft defaults.
    ChangedPARAMETER:      This Script   Microsoft    Reason:
    - OverflowThreshold:      10            50          Smaller Queue Size (Waiting Callers) more universally useful
    - TimeoutThreshold:       30s           1200s       Shorter Threshold for timeout more universally useful
    - UseDefaultMusicOnHold:  TRUE*         NONE        ONLY if neither UseDefaultMusicOnHold nor MusicOnHoldAudioFile are specificed
    NOTE: This only affects parameters which are NOT specified when running the script.
  .PARAMETER AgentAlertTime
    Optional. Time in Seconds to alert each agent. Works depending on Routing method
    NOTE: Size AgentAlertTime and TimeoutThreshold depending on Routing method and # of Agents available.
  .PARAMETER AllowOptOut
    Optional Switch. Allows Agents to Opt out of receiving calls from the Call Queue
  .PARAMETER UseDefaultMusicOnHold
    Optional Switch. Indicates whether the default Music On Hold should be used.
  .PARAMETER WelcomeMusicAudioFile
    Optional. Path to Audio File to be used as a Welcome message
    Accepted Formats: MP3, WAV or WMA format, max 5MB
  .PARAMETER MusicOnHoldAudioFile
    Optional. Path to Audio File to be used as Music On Hold.
    Required if UseDefaultMusicOnHold is not specified/set to TRUE
    Accepted Formats: MP3, WAV or WMA format, max 5MB
  .PARAMETER OverflowAction
    Optional. Default: DisconnectWithBusy, Values: DisconnectWithBusy, Forward, VoiceMail, SharedVoiceMail
    Action to be taken if the Queue size limit (OverflowThreshold) is reached
    Forward requires specification of OverflowActionTarget
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
    Optional. Default:  30s,   Microsoft Default:   50s (See Parameter UseMicrosoftDefaults)
    Time in Seconds for the OverflowAction to trigger
  .PARAMETER TimeoutAction
    Optional. Default: Disconnect, Values: Disconnect, Forward, VoiceMail, SharedVoiceMail
    Action to be taken if the TimeoutThreshold is reached
    Forward requires specification of TimeoutActionTarget
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
    Optional. Default:  30s,   Microsoft Default:  1200s (See Parameter UseMicrosoftDefaults)
    Time in Seconds for the TimeoutAction to trigger
  .PARAMETER RoutingMethod
    Optional. Default: Attendant, Values: Attendant, Serial, RoundRobin,LongestIdle
    Describes how the Call Queue is hunting for an Agent.
    Serial will Alert them one by one in order specified (Distribution lists will contact alphabethically)
    Attendant behaves like Parallel if PresenceBasedRouting is used.
  .PARAMETER PresenceBasedRouting
    Optional. Default: FALSE. If used alerts Agents only when they are available (Teams status).
  .PARAMETER ConferenceMode
    Optional. Default: TRUE,   Microsoft Default: FALSE
    Will establish a conference instead of a direct call and should help with connection time.
    Documentation vague.
  .PARAMETER DistributionLists
    Optional. Display Names of DistributionLists or Groups to be used as Agents.
    Will be parsed after Users if they are specified as well.
  .PARAMETER Users
    Optional. UPNs of Users.
    Will be parsed first. Order is only important if Serial Routing is desired (See Parameter RoutingMethod)
    Users are only added if they have a PhoneSystem license and are or can be enabled for Enterprise Voice.
  .PARAMETER LanguageId
    Optional Language Identifier indicating the language that is used to play shared voicemail prompts.
    This parameter becomes a required parameter If either OverflowAction or TimeoutAction is set to SharedVoicemail.
  .PARAMETER Silent
    Optional. Does not display output. Use for Bulk provisioning only.
    Will return the Output object, but not display any output on Screen.
  .PARAMETER Force
    Suppresses confirmation prompt to enable Users for Enterprise Voice, if Users are specified
    Currently no other impact
  .EXAMPLE
    New-TeamsCallQueue -Name "My Queue"
    Creates a new Call Queue "My Queue" with the Default Music On Hold
    All other values not specified default to optimised defaults (See Parameter UseMicrosoftDefaults)
  .EXAMPLE
    New-TeamsCallQueue -Name "My Queue" -UseMicrosoftDefaults
    Creates a new Call Queue "My Queue" with the Default Music On Hold
    All values not specified default to Microsoft defaults for New-CsCallQueue (See Parameter UseMicrosoftDefaults)
  .EXAMPLE
    New-TeamsCallQueue -Name "My Queue" -OverflowThreshold 5 -TimeoutThreshold 90
    Creates a new Call Queue "My Queue" and sets it to overflow with more than 5 Callers waiting and a timeout window of 90s
    All values not specified default to optimised defaults (See Parameter UseMicrosoftDefaults)
  .EXAMPLE
    New-TeamsCallQueue -Name "My Queue" -MusicOnHoldAudioFile C:\Temp\Moh.wav -WelcomeMusicAudioFile C:\Temp\WelcomeMessage.wmv
    Creates a new Call Queue "My Queue" with custom Audio Files
    All values not specified default to optimised defaults (See Parameter UseMicrosoftDefaults)
  .EXAMPLE
    New-TeamsCallQueue -Name "My Queue" -AgentAlertTime 15 -RoutingMethod Serial -AllowOptOut:$false -DistributionLists @(List1@domain.com,List2@domain.com)
    Creates a new Call Queue "My Queue" alerting every Agent nested in Azure AD Groups List1@domain.com and List2@domain.com in sequence for 15s.
    All values not specified default to optimised defaults (See Parameter UseMicrosoftDefaults
  .EXAMPLE
    New-TeamsCallQueue -Name "My Queue" -OverflowAction Forward -OverflowActionTarget SIP@domain.com -TimeoutAction Voicemail
    Creates a new Call Queue "My Queue" forwarding to SIP@domain.com for Overflow and to Voicemail when it times out.
    All values not specified default to optimised defaults (See Parameter UseMicrosoftDefaults)
  .INPUTS
    System.String
  .OUTPUTS
    System.Object
  .NOTES
    Currently in Testing
  .FUNCTIONALITY
    Creates a Call Queue with custom settings and friendly names as input
  .LINK
    New-TeamsCallQueue
    Get-TeamsCallQueue
    Set-TeamsCallQueue
    Remove-TeamsCallQueue
    New-TeamsAutoAttendant
    New-TeamsResourceAccount
    New-TeamsResourceAccountAssociation
  #>

  [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
  [Alias('New-TeamsCQ')]
  [OutputType([System.Object])]
  param(
    [Parameter(Mandatory = $true, HelpMessage = "Name of the Call Queue")]
    [string]$Name,

    [Parameter(HelpMessage = "Will adhere to defaults as Microsoft outlines in New-CsCallQueue")]
    [switch]$UseMicrosoftDefaults,

    [Parameter(HelpMessage = "Time an agent is alerted in seconds (15-180s)")]
    [ValidateScript( {
        If ($_ -ge 15 -and $_ -le 180) {
          $True
        }
        else {
          Write-Host "Must be a value between 30 and 180s (3 minutes)" -ForegroundColor Red
          $false
        }
      })]
    [int16]$AgentAlertTime,

    [Parameter(HelpMessage = "Can agents opt in or opt out from taking calls from a Call Queue (Default: TRUE)")]
    [boolean]$AllowOptOut,

    #region Overflow Params
    [Parameter(HelpMessage = "Action to be taken for Overflow")]
    [Validateset("DisconnectWithBusy", "Forward", "Voicemail", "SharedVoicemail")]
    [Alias('OA')]
    [string]$OverflowAction = "DisconnectWithBusy",

    # if OverflowAction is not DisconnectWithBusy, this is required
    [Parameter(HelpMessage = "TEL URI or UPN that is targeted upon overflow, only valid for forwarded calls")]
    [Alias('OAT')]
    [string]$OverflowActionTarget,

    #region OverflowAction = SharedVoiceMail
    # if OverflowAction is SharedVoicemail one of the following two have to be provided
    [Parameter(HelpMessage = "Text-to-speech Message. This will require the LanguageId Parameter")]
    [Alias('OfSVmTTS')]
    [string]$OverflowSharedVoicemailTextToSpeechPrompt,

    [Parameter(HelpMessage = "Path to Audio File for the SharedVoiceMail Message")]
    [Alias('OverflowSharedVMFile')]
    [ValidateScript( {
        If (Test-Path $_) {
          If ((Get-Item $_).length -le 5242880 -and ($_ -match '.mp3' -or $_ -match '.wav' -or $_ -match '.wma')) {
            $True
          }
          else {
            Write-Host "Must be a file of MP3, WAV or WMA format, max 5MB" -ForegroundColor Red
            $false
          }
        }
        else {
          Write-Host "OverflowSharedVoicemailAudioFile: File not found, please verify" -ForegroundColor Red
          $false
        }
      })]
    [string]$OverflowSharedVoicemailAudioFile,

    [Parameter(HelpMessage = "Using this Parameter will make a Transcription of the Voicemail message available in the Mailbox")]
    [Alias('EnableOsVmTranscript')]
    [bool]$EnableOverflowSharedVoicemailTranscription,
    #endregion

    #Deviation from MS Default (50)
    [Parameter(HelpMessage = "Time in seconds (0-200s) before timeout action is triggered (Default: 10, Note: Microsoft default: 50)")]
    [Alias('OfThreshold', 'OfQueueLength')]
    [ValidateScript( {
        If ($_ -ge 0 -and $_ -le 200) {
          $True
        }
        else {
          Write-Host "OverflowThreshold: Must be a value between 0 and 200s." -ForegroundColor Red
          $false
        }
      })]
    [int16]$OverflowThreshold,
    #endregion

    #region Timeout Params
    [Parameter(HelpMessage = "Action to be taken for Timeout")]
    [Validateset("Disconnect", "Forward", "Voicemail", "SharedVoicemail")]
    [Alias('TA')]
    [string]$TimeoutAction = "Disconnect",

    # if TimeoutAction is not Disconnect, this is required
    [Parameter(HelpMessage = "TEL URI or UPN that is targeted upon timeout, only valid for forwarded calls")]
    [Alias('TAT')]
    [string]$TimeoutActionTarget,

    #region TimeoutAction = SharedVoiceMail
    # if TimeoutAction is SharedVoicemail one of the following two have to be provided
    [Parameter(HelpMessage = "Text-to-speech Message. This will require the LanguageId Parameter")]
    [Alias('ToSVmTTS')]
    [string]$TimeoutSharedVoicemailTextToSpeechPrompt,

    [Parameter(HelpMessage = "Path to Audio File for the SharedVoiceMail Message")]
    [Alias('TimeoutSharedVMFile')]
    [ValidateScript( {
        If (Test-Path $_) {
          If ((Get-Item $_).length -le 5242880 -and ($_ -match '.mp3' -or $_ -match '.wav' -or $_ -match '.wma')) {
            $True
          }
          else {
            Write-Host "Must be a file of MP3, WAV or WMA format, max 5MB" -ForegroundColor Red
            $false
          }
        }
        else {
          Write-Host "File not found, please verify" -ForegroundColor Red
          $false
        }
      })]
    [string]$TimeoutSharedVoicemailAudioFile,

    [Parameter(HelpMessage = "Using this Parameter will make a Transcription of the Voicemail message available in the Mailbox")]
    [Alias('EnableToSVmTranscript')]
    [bool]$EnableTimeoutSharedVoicemailTranscription,
    #endregion

    #Deviation from MS Default (1200s)
    [Parameter(HelpMessage = "Time in seconds (0-2700s) before timeout action is triggered (Default: 30, Note: Microsoft default: 1200)")]
    [Alias('ToThreshold')]
    [ValidateScript( {
        If ($_ -ge 0 -and $_ -le 2700) {
          $True
        }
        else {
          Write-Host "TimeoutThreshold: Must be a value between 0 and 2700s, will be rounded to nearest 15s intervall (0/15/30/45)" -ForegroundColor Red
          $false
        }
      })]
    [int16]$TimeoutThreshold,
    #endregion

    [Parameter(HelpMessage = "Method to alert Agents")]
    [Validateset("Attendant", "Serial", "RoundRobin", "LongestIdle")]
    [string]$RoutingMethod = "Attendant",

    [Parameter(HelpMessage = "If used, Agents receive calls only when their presence state is Available")]
    [boolean]$PresenceBasedRouting,

    [Parameter(HelpMessage = "Indicates whether the default Music On Hold is used")]
    [boolean]$UseDefaultMusicOnHold,

    [Parameter(HelpMessage = "If used, Conference mode is used to establish calls")]
    [boolean]$ConferenceMode,

    #region Music files
    [Parameter(HelpMessage = "Path to Audio File for Welcome Message")]
    [AllowNull()]
    [string]$WelcomeMusicAudioFile,

    [Parameter(HelpMessage = "Path to Audio File for MusicOnHold (cannot be used with UseDefaultMusicOnHold switch!)")]
    [ValidateScript( {
        If (Test-Path $_) {
          If ((Get-Item $_).length -le 5242880 -and ($_ -match '.mp3' -or $_ -match '.wav' -or $_ -match '.wma')) {
            $True
          }
          else {
            Write-Host "MusicOnHoldAudioFile: Must be a file of MP3, WAV or WMA format, max 5MB" -ForegroundColor Red
            $false
          }
        }
        else {
          Write-Host "MusicOnHoldAudioFile: File not found, please verify" -ForegroundColor Red
          $false
        }
      })]
    [string]$MusicOnHoldAudioFile,
    #endregion

    #region Agents
    [Parameter(HelpMessage = "Name of one or more Distribution Lists")]
    [string[]]$DistributionLists,

    [Parameter(HelpMessage = "UPN of one or more Users")]
    [string[]]$Users,
    #endregion

    [Parameter(HelpMessage = "Language Identifier from Get-CsAutoAttendantSupportedLanguage.")]
    [ValidateScript( { $_ -in (Get-CsAutoAttendantSupportedLanguage).Id })]
    [string]$LanguageId,

    [Parameter(HelpMessage = "Suppresses confirmation prompt to enable Users for Enterprise Voice, if Users are specified")]
    [switch]$Force
  ) #param

  begin {
    Show-FunctionStatus -Level RC
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

    # Initialising counters for Progress bars
    [int]$step = 0
    [int]$sMax = 11

    $Status = "Verifying input"
    $Operation = "Validating Parameters"
    Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
    Write-Verbose -Message "$Status - $Operation"

    # Language has to be normalised as the Id is case sensitive
    if ($PSBoundParameters.ContainsKey('LanguageId')) {
      $Language = $($LanguageId.Split("-")[0]).ToLower() + "-" + $($LanguageId.Split("-")[1]).ToUpper()
      Write-Verbose "LanguageId '$LanguageId' normalised to '$Language'"
      if ((Get-CsAutoAttendantSupportedLanguage -Id $Language).VoiceResponseSupported) {
        Write-Verbose -Message "LanguageId '$Language' - Voice Responses supported"
      }
      else {
        Write-Verbose -Message "LanguageId '$Language' - Voice Responses not supported"
      }
    }
    else {
      # Checking for Parameters which would require LanguageId
      if (($PSBoundParameters.ContainsKey('OverflowSharedVoicemailTextToSpeechPrompt')) -or `
        ($PSBoundParameters.ContainsKey('TimeoutSharedVoicemailTextToSpeechPrompt')) -or `
        ($PSBoundParameters.ContainsKey('EnableOverflowSharedVoicemailTranscription')) -or `
        ($PSBoundParameters.ContainsKey('EnableTimeoutSharedVoicemailTranscription'))) {

        Write-Error "Parameter LanguageId is required and missing. Text-to-speech prompts or Transcription require specification of a Language. No default is available." -ErrorAction Stop -RecommendedAction "Add Parameter LanguageId"
        return
      }
    }

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    #region PREPARATION
    $Status = "Preparing Parameters"
    # preparing Splatting Object
    $Parameters = $null

    #region Required Parameters: Name
    $Operation = "Name"
    $step++
    Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
    Write-Verbose -Message "$Status - $Operation"

    # Normalising $Name
    $NameNormalised = Format-StringForUse -InputString $Name -As DisplayName
    Write-Verbose -Message "'$Name' DisplayName normalised to: '$NameNormalised'"
    $Parameters += @{'Name' = $NameNormalised }
    #endregion

    #region Music On Hold
    $Operation = "Music On Hold"
    $step++
    Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
    Write-Verbose -Message "$Status - $Operation"

    if ($PSBoundParameters.ContainsKey('MusicOnHoldAudioFile') -and $PSBoundParameters.ContainsKey('UseDefaultMusicOnHold')) {
      Write-Warning -Message "'$NameNormalised' MusicOnHoldAudioFile and UseDefaultMusicOnHold are mutually exclusive. UseDefaultMusicOnHold is ignored!"
      $UseDefaultMusicOnHold = $false
    }
    if ($PSBoundParameters.ContainsKey('MusicOnHoldAudioFile')) {
      $MOHFileName = Split-Path $MusicOnHoldAudioFile -Leaf
      Write-Verbose -Message "'$NameNormalised' MusicOnHoldAudioFile:  Parsing: '$MOHFileName'" -Verbose
      try {
        $MOHFile = Import-TeamsAudioFile -ApplicationType CallQueue -File $MusicOnHoldAudioFile -ErrorAction STOP
        Write-Verbose -Message "'$NameNormalised' MusicOnHoldAudioFile:  Using:   '$($MOHFile.FileName)'"
        $Parameters += @{'MusicOnHoldAudioFileId' = $MOHFile.Id }
      }
      catch {
        Write-Error -Message "Import of MusicOnHoldAudioFile: '$MOHFileName' failed." -Category InvalidData -RecommendedAction "Please check file size and compression ratio. If in doubt, provide WAV"
        Write-Verbose -Message "'$NameNormalised' MusicOnHoldAudioFile:  Using:   DEFAULT"
        $UseDefaultMusicOnHold = $true
        $Parameters += @{'UseDefaultMusicOnHold' = $true }
      }
    }
    else {
      Write-Verbose -Message "'$NameNormalised' MusicOnHoldAudioFile:  Using:   DEFAULT"
      $UseDefaultMusicOnHold = $true
      $Parameters += @{'UseDefaultMusicOnHold' = $true }
    }
    #endregion

    #region Welcome Message
    $Operation = "Welcome Message"
    $step++
    Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
    Write-Verbose -Message "$Status - $Operation"

    if ($PSBoundParameters.ContainsKey('WelcomeMusicAudioFile')) {
      if ($null -ne $WelcomeMusicAudioFile) {
        # Validation - File Exists
        try {
          $null = Test-Path $WelcomeMusicAudioFile
        }
        catch {
          Write-Error -Message "WelcomeMusicAudioFile: File not found" -Category InvalidData
          return
        }

        # Validation - File is provided in the correct format
        try {
          If ((Get-Item $WelcomeMusicAudioFile).length -le 5242880 -and ($WelcomeMusicAudioFile -match '.mp3' -or $WelcomeMusicAudioFile -match '.wav' -or $WelcomeMusicAudioFile -match '.wma')) {
            Write-Verbose -Message "WelcomeMusicAudioFile: Format check passed - SUCCESS"
          }
          else {
            throw
          }
        }
        catch {
          Write-Error -Message "WelcomeMusicAudioFile: Must be a file of MP3, WAV or WMA format, max 5MB" -Category InvalidData
          return
        }

        # File Import
        $WMFileName = Split-Path $WelcomeMusicAudioFile -Leaf
        Write-Verbose -Message "'$NameNormalised' WelcomeMusicAudioFile: Parsing: '$WMFileName'" -Verbose
        try {
          $WMFile = Import-TeamsAudioFile -ApplicationType CallQueue -File $WelcomeMusicAudioFile -ErrorAction STOP
          Write-Verbose -Message "'$NameNormalised' WelcomeMusicAudioFile: Using:   '$($WMFile.FileName)"
          $Parameters += @{'WelcomeMusicAudioFileId' = $WMFile.Id }
        }
        catch {
          Write-Error -Message "Import of WelcomeMusicAudioFile: '$WMFileName' failed." -Category InvalidData -RecommendedAction "Please check file size and compression ratio. If in doubt, provide WAV"
          Write-Verbose -Message "'$NameNormalised' WelcomeMusicAudioFile: Using:   NONE"
        }
      }
      else {
        Write-Verbose -Message "'$NameNormalised' WelcomeMusicAudioFile: Using:   NONE"
      }
    }
    else {
      Write-Verbose -Message "'$NameNormalised' WelcomeMusicAudioFile: Using:   NONE"
    }
    #endregion

    #region Routing metrics, Thresholds and Language
    # One Progress operation for all Parameters
    $Operation = "Routing metrics, Thresholds and Language"
    $step++
    Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
    Write-Verbose -Message "$Status - $Operation"

    #region ValueSet Parameters
    # RoutingMethod
    if ($PSBoundParameters.ContainsKey('RoutingMethod')) {
      $Parameters += @{'RoutingMethod' = $RoutingMethod }
    }

    # AgentAlertTime
    if ($PSBoundParameters.ContainsKey('AgentAlertTime')) {
      Write-Verbose -Message "'$NameNormalised' AgentAlertTime: $AgentAlertTime" -Verbose
      $Parameters += @{'AgentAlertTime' = $AgentAlertTime }
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
    if ($PSBoundParameters.ContainsKey('UseMicrosoftDefaults')) {
      Write-Verbose -Message "'$NameNormalised' Setting default values according to New-CsCallQueue (Microsoft defaults)" -Verbose
      # OverflowThreshold
      if ($PSBoundParameters.ContainsKey('OverflowThreshold')) {
        Write-Verbose -Message "'$NameNormalised' OverflowThreshold: $OverflowThreshold" -Verbose
        $Parameters += @{'OverflowThreshold' = $OverflowThreshold }
      }
      # TimeoutThreshold
      if ($PSBoundParameters.ContainsKey('TimeoutThreshold')) {
        Write-Verbose -Message "'$NameNormalised' TimeoutThreshold: $TimeoutThreshold" -Verbose
        $Parameters += @{'TimeoutThreshold' = $TimeoutThreshold }
      }
    }
    else {
      Write-Verbose -Message "'$NameNormalised' Setting default values according to New-TeamsCallQueue (optimised defaults)" -Verbose
      # OverflowThreshold
      if (-not $PSBoundParameters.ContainsKey('OverflowThreshold')) {
        $OverflowThreshold = 10
      }
      Write-Verbose -Message "'$NameNormalised' OverflowThreshold: $OverflowThreshold" -Verbose
      $Parameters += @{'OverflowThreshold' = $OverflowThreshold }

      # TimeoutThreshold
      if (-not $PSBoundParameters.ContainsKey('TimeoutThreshold')) {
        $TimeoutThreshold = 30
      }
      Write-Verbose -Message "'$NameNormalised' TimeoutThreshold: $TimeoutThreshold" -Verbose
      $Parameters += @{'TimeoutThreshold' = $TimeoutThreshold }
    }
    #endregion


    #region Language
    if ($PSBoundParameters.ContainsKey('LanguageId')) {
      $Parameters += @{'LanguageId' = $Language }
    }

    # Checking for Text-to-speech prompts without providing LanguageId
    # This is already done in the BEGIN block
    #endregion
    #endregion


    #region Overflow
    $Operation = "Overflow"
    $step++
    Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
    Write-Verbose -Message "$Status - $Operation"

    #region Overflow Action
    if ($PSBoundParameters.ContainsKey('OverflowAction')) {
      Write-Verbose -Message "'$NameNormalised' OverflowAction '$OverflowAction' Parsing requirements"
      if ($PSBoundParameters.ContainsKey('OverflowActionTarget')) {
        # We have a Target
        if ($OverflowAction -eq "DisconnectWithBusy") {
          #but we don't need one
          Write-Verbose -Message "'$NameNormalised' OverflowAction '$OverflowAction' does not require an OverflowActionTarget. It will not be processed" -Verbose
        }
        else {
          # OK
          Write-Verbose -Message "'$NameNormalised' OverflowAction '$OverflowAction' and OverflowActionTarget '$OverflowActionTarget' specified. Processing both."
        }
        # NEW: Adding Action only with a Target | SET: Adding Action if specified
        $Parameters += @{'OverflowAction' = $OverflowAction }
      }
      elseif ($OverflowAction -ne "DisconnectWithBusy") {
        Write-Warning -Message "'$NameNormalised' OverflowAction '$OverflowAction' not set! Parameter OverflowActionTarget missing OverflowAction will not be set"
      }
    }
    else {
      $OverflowAction = "DisconnectWithBusy"
      Write-Verbose -Message "'$NameNormalised' Parameter OverflowAction not present. Using existing setting: '$OverflowAction'"
    }
    #endregion

    #region OverflowActionTarget
    # Processing for Target is dependent on Action
    if ($PSBoundParameters.ContainsKey('OverflowActionTarget')) {
      switch ($OverflowAction) {
        "DisconnectWithBusy" {
          # Explicit setting of DisconnectWithBusy
          if (-not $PSBoundParameters.ContainsKey('OverflowAction')) {
            Write-Verbose -Message "'$NameNormalised' OverflowAction '$OverflowAction': No Overflow-Parameters are processed" -Verbose
          }
          #else: No Action
        }
        "Forward" {
          # Forward requires an OverflowActionTarget (Tel URI or UPN of a User to be translated to GUID)
          try {
            if ($OverflowActionTarget -match "^tel:\+\d") {
              #Telephone URI
              $Parameters += @{'OverflowActionTarget' = $OverflowActionTarget }
            }
            elseif ($OverflowActionTarget -match "^\+\d" -and -not ($OverflowActionTarget -match '@')) {
              #Telephone Number (E.164)
              #$OverflowActionTargetNormalised = "tel:" + $OverflowActionTarget
              $OverflowActionTargetNormalised = Format-StringForUse -InputString "$OverflowActionTarget" -As LineURI
              $Parameters += @{'OverflowActionTarget' = $OverflowActionTargetNormalised }
            }
            elseif ($OverflowActionTarget -match '@') {
              #Assume it is a User
              $Identity = $OverflowActionTarget
              if ( Test-AzureADUser $Identity ) {
                $UserObject = Get-CsOnlineUser "$Identity" -WarningAction SilentlyContinue
                $IsLicensed = Test-TeamsUserLicense -Identity $Identity -ServicePlan MCOEV
                if ( -not $IsLicensed  ) {
                  Write-Warning -Message "OverflowActionTarget - Call Target '$Identity' (User) found but not licensed (PhoneSystem). Omitting User"
                }
                else {
                  $IsEVenabled = $UserObject.EnterpriseVoiceEnabled
                  if ( -not $IsEVenabled ) {
                    Write-Verbose -Message "OverflowActionTarget - Call Target '$Identity' (User) found and licensed, but not enabled for EnterpriseVoice" -Verbose
                    if ($Force -or $PSCmdlet.ShouldProcess("$Identity", "Set-CsUser -EnterpriseVoiceEnabled $TRUE")) {
                      $IsEVenabled = $null
                      $IsEVenabled = Enable-TeamsUserForEnterpriseVoice -Identity $Identity -Force
                    }
                  }

                  # Add Target
                  if ( $IsEVenabled ) {
                    Write-Verbose -Message "OverflowActionTarget - Call Target '$Identity' (User) used" -Verbose
                    $Parameters += @{'OverflowActionTarget' = $UserObject.ObjectId }
                  }
                  else {
                    Write-Verbose -Message "OverflowActionTarget - Call Target '$Identity' (User) not enabled for EnterpriseVoice!" -Verbose
                  }
                }
              }
              else {
                Write-Warning -Message "OverflowActionTarget - Call Target '$Identity' (User) not found. Omitting User"
              }
            }
            else {
              # Capturing any other specified Target that does not match for the Forward
              Write-Warning -Message "'$NameNormalised' OverflowAction '$OverflowAction': OverflowActionTarget '$OverflowActionTarget' is incompatible and is not processed!"
              Write-Verbose -Message "'$NameNormalised' OverflowAction '$OverflowAction': OverflowActionTarget expected is a Tel URI or a UPN of a User" -Verbose
            }
          }
          catch {
            Write-Warning -Message "'$NameNormalised' OverflowAction '$OverflowAction': OverflowActionTarget '$OverflowActionTarget' not set! Error enumerating Target"
          }
        }
        "VoiceMail" {
          # VoiceMail requires an OverflowActionTarget (UPN of a User to be translated to GUID)
          $Identity = $OverflowActionTarget
          if ( Test-AzureADUser $Identity ) {
            $UserObject = Get-CsOnlineUser "$Identity" -WarningAction SilentlyContinue
            $IsLicensed = Test-TeamsUserLicense -Identity $Identity -ServicePlan MCOEV
            if ( -not $IsLicensed  ) {
              Write-Warning -Message "OverflowActionTarget - Call Target '$Identity' (User) found but not licensed (PhoneSystem). Omitting User"
            }
            else {
              $IsEVenabled = $UserObject.EnterpriseVoiceEnabled
              if ( -not $IsEVenabled ) {
                Write-Verbose -Message "OverflowActionTarget - Call Target '$Identity' (User) found and licensed, but not enabled for EnterpriseVoice" -Verbose
                if ($Force -or $PSCmdlet.ShouldProcess("$Identity", "Set-CsUser -EnterpriseVoiceEnabled $TRUE")) {
                  $IsEVenabled = $null
                  $IsEVenabled = Enable-TeamsUserForEnterpriseVoice -Identity $Identity -Force
                }
              }

              # Add Target
              if ( $IsEVenabled ) {
                Write-Verbose -Message "OverflowActionTarget - Call Target '$Identity' (User) used" -Verbose
                $Parameters += @{'OverflowActionTarget' = $UserObject.ObjectId }
              }
              else {
                Write-Verbose -Message "OverflowActionTarget - Call Target '$Identity' (User) not enabled for EnterpriseVoice!" -Verbose
              }
            }
          }
          else {
            Write-Warning -Message "OverflowActionTarget - Call Target '$Identity' (User) not found. Omitting User"
          }
        }
        "SharedVoiceMail" {
          # SharedVoiceMail requires an OverflowActionTarget (UPN of a Group to be translated to GUID)
          #region SharedVoiceMail prerequisites
          if ($PSBoundParameters.ContainsKey('OverflowSharedVoicemailAudioFile') -and $PSBoundParameters.ContainsKey('OverflowSharedVoicemailTextToSpeechPrompt')) {
            # Both Parameters provided
            Write-Verbose -Message "'$NameNormalised' OverflowAction '$OverflowAction': OverflowSharedVoicemailAudioFile and OverflowSharedVoicemailTextToSpeechPrompt are mutually exclusive. Processing File only" -Verbose
            [void]$PSBoundParameters.Remove('OverflowSharedVoicemailTextToSpeechPrompt')
          }
          elseif (-not $PSBoundParameters.ContainsKey('OverflowSharedVoicemailAudioFile') -and -not $PSBoundParameters.ContainsKey('OverflowSharedVoicemailTextToSpeechPrompt')) {
            # Neither Parameter provided
            Write-Error -Message "'$NameNormalised' OverflowAction '$OverflowAction': Parameter OverflowSharedVoicemailAudioFile or OverflowSharedVoicemailTextToSpeechPrompt missing" -ErrorAction Stop -RecommendedAction "Add one of the two parameters"
            return
          }
          elseif ($PSBoundParameters.ContainsKey('OverflowSharedVoicemailTextToSpeechPrompt')) {
            if (-not $PSBoundParameters.ContainsKey('LanguageId')) {
              Write-Error -Message "'$NameNormalised' OverflowAction '$OverflowAction': OverflowSharedVoicemailTextToSpeechPrompt requires Language selection. Please provide Parameter LanguageId" -ErrorAction Stop -RecommendedAction "Add Parameter LanguageId"
              return
            }
            else {
              Write-Verbose -Message "'$NameNormalised' OverflowAction '$OverflowAction': OverflowSharedVoicemailTextToSpeechPrompt: Language '$Language' is used" -Verbose
            }
          }
          #endregion

          #region Processing OverflowActionTarget for SharedVoiceMail
          Write-Verbose -Message "'$NameNormalised' OverflowAction '$OverflowAction': OverflowActionTarget '$OverflowActionTarget' - Querying Object"
          $CallTarget = $null
          $CallTarget = Find-AzureAdGroup $OverflowActionTarget -Exact
          if ( $CallTarget ) {
            $OverflowActionTargetId = $CallTarget.ObjectId
            Write-Verbose -Message "'$NameNormalised' OverflowAction '$OverflowAction': OverflowActionTarget '$OverflowActionTarget' - Object found!"
            $Parameters += @{'OverflowActionTarget' = $OverflowActionTargetId }
          }
          else {
            Write-Warning -Message "'$NameNormalised' OverflowAction '$OverflowAction': OverflowActionTarget '$OverflowActionTarget' not set! Error enumerating Target"
          }
          #endregion
        }
      }
    }
    #endregion

    #region OverflowAction SharedVoicemail - Processing
    if ($PSBoundParameters.ContainsKey('OverflowSharedVoicemailAudioFile')) {
      if ($OverflowAction -ne "SharedVoicemail") {
        Write-Verbose -Message "'$NameNormalised' OverflowSharedVoicemailAudioFile:  Not processing Parameter as it is not valid for OverflowAction '$OverflowAction'" -Verbose
      }
      else {
        $OfSVmFileName = Split-Path $OverflowSharedVoicemailAudioFile -Leaf
        Write-Verbose -Message "'$NameNormalised' OverflowSharedVoicemailAudioFile:  Parsing: '$OfSVmFileName'" -Verbose
        try {
          $OfSVmFile = Import-TeamsAudioFile -ApplicationType CallQueue -File $OverflowSharedVoicemailAudioFile -ErrorAction STOP
          Write-Verbose -Message "'$NameNormalised' OverflowSharedVoicemailAudioFile:  Using:   '$($OfSVmFile.FileName)'"
          $Parameters += @{'OverflowSharedVoicemailAudioFilePrompt' = $OfSVmFile.Id }
        }
        catch {
          Write-Error -Message "Import of OverflowSharedVoicemailAudioFile: '$OfSVmFileName' failed." -Category InvalidData -RecommendedAction "Please check file size and compression ratio. If in doubt, provide WAV"
          return
        }
      }
    }

    if ($PSBoundParameters.ContainsKey('OverflowSharedVoicemailTextToSpeechPrompt')) {
      if ($OverflowAction -ne "SharedVoicemail") {
        Write-Verbose -Message "'$NameNormalised' OverflowSharedVoicemailAudioFile:  Not processing Parameter as it is not valid for OverflowAction '$OverflowAction'" -Verbose
      }
      else {
        $Parameters += @{'OverflowSharedVoicemailTextToSpeechPrompt' = $OverflowSharedVoicemailTextToSpeechPrompt }
      }
    }

    if ($PSBoundParameters.ContainsKey('EnableOverflowSharedVoicemailTranscription')) {
      if ($OverflowAction -ne "SharedVoicemail") {
        Write-Verbose -Message "'$NameNormalised' OverflowSharedVoicemailAudioFile:  Not processing Parameter as it is not valid for OverflowAction '$OverflowAction'" -Verbose
      }
      else {
        $Parameters += @{'EnableOverflowSharedVoicemailTranscription' = $EnableOverflowSharedVoicemailTranscription }
      }
    }
    #endregion

    #region OverflowAction Parameter cleanup
    if ($Parameters.ContainsKey('OverflowAction') -and (-not $Parameters.ContainsKey('OverflowActionTarget')) -and ($OverflowAction -ne 'DisconnectWithBusy')) {
      Write-Verbose -Message "'$NameNormalised' OverflowAction '$OverflowAction': Action not set as OverflowActionTarget was not correctly enumerated" -Verbose
      [void]$Parameters.Remove('OverflowAction')
    }
    #endregion
    #endregion

    #region Timeout
    $Operation = "Timeout"
    $step++
    Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
    Write-Verbose -Message "$Status - $Operation"

    #region TimeoutAction
    if ($PSBoundParameters.ContainsKey('TimeoutAction')) {
      Write-Verbose -Message "'$NameNormalised' TimeoutAction '$TimeoutAction' Parsing requirements"
      if ($PSBoundParameters.ContainsKey('TimeoutActionTarget')) {
        # We have a Target
        if ($TimeoutAction -eq "Disconnect") {
          #but we don't need one
          Write-Verbose -Message "'$NameNormalised' TimeoutAction '$TimeoutAction' does not require an TimeoutActionTarget. It will not be processed" -Verbose
        }
        else {
          # OK
          Write-Verbose -Message "'$NameNormalised' TimeoutAction '$TimeoutAction' and TimeoutActionTarget '$TimeoutActionTarget' specified. Processing both."
        }
        # NEW: Adding Action only with a Target | SET: Adding Action if specified
        $Parameters += @{'TimeoutAction' = $TimeoutAction }
      }
      elseif ($TimeoutAction -ne "Disconnect") {
        Write-Warning -Message "'$NameNormalised' TimeoutAction '$TimeoutAction' not set! Parameter TimeoutActionTarget missing"
      }
    }
    else {
      $TimeoutAction = "Disconnect"
      Write-Verbose -Message "'$NameNormalised' Parameter TimeoutAction not present. Using existing setting: '$TimeoutAction'"
    }
    #endregion

    #region TimeoutActionTarget
    # Processing for Target is dependent on Action
    if ($PSBoundParameters.ContainsKey('TimeoutActionTarget')) {
      switch ($TimeoutAction) {
        "Disconnect" {
          # Explicit setting of DisconnectWithBusy
          if (-not $PSBoundParameters.ContainsKey('TimeoutAction')) {
            Write-Verbose -Message "'$NameNormalised' TimeoutAction '$TimeoutAction': No Timeout-Parameters are processed" -Verbose
          }
          #else: No Action
        }
        "Forward" {
          # Forward requires an TimeoutActionTarget (Tel URI or UPN of a User to be translated to GUID)
          try {
            if ($TimeoutActionTarget -match "^tel:\+\d") {
              #Telephone URI
              $Parameters += @{'TimeoutActionTarget' = $TimeoutActionTarget }
            }
            elseif ($TimeoutActionTarget -match "^\+\d" -and -not ($TimeoutActionTarget -match '@')) {
              #Telephone Number (E.164)
              #$TimeoutActionTargetNormalised = "tel:" + $TimeoutActionTarget
              $TimeoutActionTarget = Format-StringForUse -InputString "$TimeoutActionTarget" -As LineURI
              $Parameters += @{'TimeoutActionTarget' = $TimeoutActionTargetNormalised }
            }
            elseif ($TimeoutActionTarget -match '@') {
              #Assume it is a User
              $Identity = $TimeoutActionTarget
              if ( Test-AzureADUser $Identity ) {
                $UserObject = Get-CsOnlineUser "$Identity" -WarningAction SilentlyContinue
                $IsLicensed = Test-TeamsUserLicense -Identity $Identity -ServicePlan MCOEV
                if ( -not $IsLicensed  ) {
                  Write-Warning -Message "TimeoutActionTarget - Call Target '$Identity' (User) found but not licensed (PhoneSystem). Omitting User"
                }
                else {
                  $IsEVenabled = $UserObject.EnterpriseVoiceEnabled
                  if ( -not $IsEVenabled) {
                    Write-Verbose -Message "TimeoutActionTarget - Call Target '$Identity' (User) found and licensed, but not enabled for EnterpriseVoice" -Verbose
                    if ($Force -or $PSCmdlet.ShouldProcess("$Identity", "Set-CsUser -EnterpriseVoiceEnabled $TRUE")) {
                      $IsEVenabled = $null
                      $IsEVenabled = Enable-TeamsUserForEnterpriseVoice -Identity $Identity -Force
                    }
                  }

                  # Add Target
                  if ( $IsEVenabled ) {
                    Write-Verbose -Message "TimeoutActionTarget - Call Target '$Identity' (User) used" -Verbose
                    $Parameters += @{'TimeoutActionTarget' = $UserObject.ObjectId }
                  }
                  else {
                    Write-Verbose -Message "TimeoutActionTarget - Call Target '$Identity' (User) not enabled for EnterpriseVoice!" -Verbose
                  }
                }
              }
              else {
                Write-Warning -Message "TimeoutActionTarget - Call Target '$Identity' (User) not found. Omitting User"
              }
            }
            else {
              # Capturing any other specified Target that does not match for the Forward
              Write-Warning -Message "'$NameNormalised' TimeoutAction '$TimeoutAction': TimeoutActionTarget '$TimeoutActionTarget' is incompatible and is not processed!"
              Write-Verbose -Message "'$NameNormalised' TimeoutAction '$TimeoutAction': TimeoutActionTarget expected is a Tel URI or a UPN of a User" -Verbose
            }
          }
          catch {
            Write-Warning -Message "'$NameNormalised' TimeoutAction '$TimeoutAction': TimeoutActionTarget '$TimeoutActionTarget' not set! Error enumerating Target"
          }
        }
        "VoiceMail" {
          # VoiceMail requires an TimeoutActionTarget (UPN of a User to be translated to GUID)
          $Identity = $TimeoutActionTarget
          if ( Test-AzureADUser $Identity ) {
            $UserObject = Get-CsOnlineUser "$Identity" -WarningAction SilentlyContinue
            $IsLicensed = Test-TeamsUserLicense -Identity $Identity -ServicePlan MCOEV
            if ( -not $IsLicensed  ) {
              Write-Warning -Message "TimeoutActionTarget - Call Target '$Identity' (User) found but not licensed (PhoneSystem). Omitting User"
            }
            else {
              $IsEVenabled = $UserObject.EnterpriseVoiceEnabled
              if ( -not $IsEVenabled ) {
                Write-Verbose -Message "TimeoutActionTarget - Call Target '$Identity' (User) found and licensed, but not enabled for EnterpriseVoice" -Verbose
                if ($Force -or $PSCmdlet.ShouldProcess("$Identity", "Set-CsUser -EnterpriseVoiceEnabled $TRUE")) {
                  $IsEVenabled = $null
                  $IsEVenabled = Enable-TeamsUserForEnterpriseVoice -Identity $Identity -Force
                }
              }

              # Add Target
              if ( $IsEVenabled ) {
                Write-Verbose -Message "TimeoutActionTarget - Call Target '$Identity' (User) used" -Verbose
                $Parameters += @{'TimeoutActionTarget' = $UserObject.ObjectId }
              }
              else {
                Write-Verbose -Message "TimeoutActionTarget - Call Target '$Identity' (User) not enabled for EnterpriseVoice!" -Verbose
              }
            }
          }
          else {
            Write-Warning -Message "TimeoutActionTarget - Call Target '$Identity' (User) not found. Omitting User"
          }
        }
        "SharedVoiceMail" {
          # SharedVoiceMail requires an TimeoutActionTarget (UPN of a Group to be translated to GUID)
          #region SharedVoiceMail prerequisites
          if ($PSBoundParameters.ContainsKey('TimeoutSharedVoicemailAudioFile') -and $PSBoundParameters.ContainsKey('TimeoutSharedVoicemailTextToSpeechPrompt')) {
            # Both Parameters provided
            Write-Verbose -Message "'$NameNormalised' TimeoutAction '$TimeoutAction': TimeoutSharedVoicemailAudioFile and TimeoutSharedVoicemailTextToSpeechPrompt are mutually exclusive. Processing File only" -Verbose
            [void]$PSBoundParameters.Remove('TimeoutSharedVoicemailTextToSpeechPrompt')
          }
          elseif (-not $PSBoundParameters.ContainsKey('TimeoutSharedVoicemailAudioFile') -and -not $PSBoundParameters.ContainsKey('TimeoutSharedVoicemailTextToSpeechPrompt')) {
            # Neither Parameter provided
            Write-Error -Message "'$NameNormalised' TimeoutAction '$TimeoutAction': Parameter TimeoutSharedVoicemailAudioFile or TimeoutSharedVoicemailTextToSpeechPrompt missing" -ErrorAction Stop -RecommendedAction "Add one of the two parameters"
            return
          }
          elseif ($PSBoundParameters.ContainsKey('TimeoutSharedVoicemailTextToSpeechPrompt')) {
            if (-not $PSBoundParameters.ContainsKey('LanguageId')) {
              Write-Error -Message "'$NameNormalised' TimeoutAction '$TimeoutAction': TimeoutSharedVoicemailTextToSpeechPrompt requires Language selection. Please provide Parameter LanguageId" -ErrorAction Stop -RecommendedAction "Add Parameter LanguageId"
              return
            }
            else {
              Write-Verbose -Message "'$NameNormalised' TimeoutAction '$TimeoutAction': TimeoutSharedVoicemailTextToSpeechPrompt: Language '$Language' is used" -Verbose
            }
          }
          #endregion

          #region Processing TimeoutActionTarget for SharedVoiceMail
          Write-Verbose -Message "'$NameNormalised' TimeoutAction '$TimeoutAction': TimeoutActionTarget '$TimeoutActionTarget' - Querying Object"
          $CallTarget = $null
          $CallTarget = Find-AzureAdGroup $TimeoutActionTarget -Exact
          if ( $CallTarget ) {
            Write-Verbose -Message "'$NameNormalised' TimeoutAction '$TimeoutAction': TimeoutActionTarget '$TimeoutActionTarget' - Object found!"
            $TimeoutActionTargetId = $CallTarget.ObjectId
            $Parameters += @{'TimeoutActionTarget' = $TimeoutActionTargetId }
          }
          else {
            Write-Warning -Message "'$NameNormalised' TimeoutAction '$TimeoutAction': TimeoutActionTarget '$TimeoutActionTarget' not set! Error enumerating Target"
          }
          #endregion
        }
      }
    }
    #endregion

    #region TimeoutAction SharedVoicemail - Processing
    if ($PSBoundParameters.ContainsKey('TimeoutSharedVoicemailAudioFile')) {
      if ($TimeoutAction -ne "SharedVoicemail") {
        Write-Verbose -Message "'$NameNormalised' TimeoutSharedVoicemailAudioFile:  Not processing Parameter as it is not valid for TimeoutAction '$TimeoutAction'" -Verbose
      }
      else {
        $ToSVmFileName = Split-Path $TimeoutSharedVoicemailAudioFile -Leaf
        Write-Verbose -Message "'$NameNormalised' TimeoutSharedVoicemailAudioFile:  Parsing: '$ToSVmFileName'" -Verbose
        try {
          $ToSVmFile = Import-TeamsAudioFile -ApplicationType CallQueue -File $TimeoutSharedVoicemailAudioFile -ErrorAction STOP
          Write-Verbose -Message "'$NameNormalised' TimeoutSharedVoicemailAudioFile:  Using:   '$($ToSVmFile.FileName)'"
          $Parameters += @{'TimeoutSharedVoicemailAudioFilePrompt' = $ToSVmFile.Id }
        }
        catch {
          Write-Error -Message "Import of TimeoutSharedVoicemailAudioFile: '$ToSVmFileName' failed." -Category InvalidData -RecommendedAction "Please check file size and compression ratio. If in doubt, provide WAV"
          return
        }
      }
    }

    if ($PSBoundParameters.ContainsKey('TimeoutSharedVoicemailTextToSpeechPrompt')) {
      if ($TimeoutAction -ne "SharedVoicemail") {
        Write-Verbose -Message "'$NameNormalised' TimeoutSharedVoicemailAudioFile:  Not processing Parameter as it is not valid for TimeoutAction '$TimeoutAction'" -Verbose
      }
      else {
        $Parameters += @{'TimeoutSharedVoicemailTextToSpeechPrompt' = $TimeoutSharedVoicemailTextToSpeechPrompt }
      }
    }

    if ($PSBoundParameters.ContainsKey('EnableTimeoutSharedVoicemailTranscription')) {
      if ($TimeoutAction -ne "SharedVoicemail") {
        Write-Verbose -Message "'$NameNormalised' TimeoutSharedVoicemailAudioFile:  Not processing Parameter as it is not valid for TimeoutAction '$TimeoutAction'" -Verbose
      }
      else {
        $Parameters += @{'EnableTimeoutSharedVoicemailTranscription' = $EnableOverflowSharedVoicemailTranscription }
      }
    }
    #endregion

    #region TimeoutAction Parameter cleanup
    if ($Parameters.ContainsKey('TimeoutAction') -and (-not $Parameters.ContainsKey('TimeoutActionTarget')) -and ($TimeoutAction -ne 'DisconnectWithBusy')) {
      Write-Verbose -Message "'$NameNormalised' TimeoutAction '$TimeoutAction': Action not set as TimeoutActionTarget was not correctly enumerated" -Verbose
      [void]$Parameters.Remove('TimeoutAction')
    }
    #endregion
    #endregion


    #region Users - Parsing and verifying Users
    $Operation = "Parsing Users"
    $step++
    Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
    Write-Verbose -Message "$Status - $Operation"

    [System.Collections.ArrayList]$UserIdList = @()
    if ($PSBoundParameters.ContainsKey('Users')) {
      Write-Verbose -Message "'$NameNormalised' - Parsing Users"
      foreach ($User in $Users) {
        if ( Test-AzureADUser $User ) {
          $UserObject = Get-CsOnlineUser "$User" -WarningAction SilentlyContinue
          $IsLicensed = Test-TeamsUserLicense -Identity $User -ServicePlan MCOEV
          if ( -not $IsLicensed  ) {
            Write-Warning -Message "User '$User' found but not licensed (PhoneSystem). Omitting User"
          }
          else {
            $IsEVenabled = $UserObject.EnterpriseVoiceEnabled
            if ( -not $IsEVenabled ) {
              Write-Verbose -Message "User '$User' found and licensed, but not enabled for EnterpriseVoice" -Verbose
              if ($Force -or $PSCmdlet.ShouldProcess("$User", "Set-CsUser -EnterpriseVoiceEnabled $TRUE")) {
                $IsEVenabled = $null
                $IsEVenabled = Enable-TeamsUserForEnterpriseVoice -Identity $User -Force
              }
            }

            # Add Target
            if ( $IsEVenabled ) {
              Write-Verbose -Message "User '$User' will be added to CallQueue" -Verbose
              [void]$UserIdList.Add($UserObject.ObjectId)
            }
            else {
              Write-Warning -Message "User '$User' Enterprise Voice Status: User not enabled - Omitting User"
            }
          }
        }
        else {
          Write-Warning -Message "'$NameNormalised' User '$User' not found in AzureAd, omitting user!"
        }
      }
    }
    # NEW: Processing always / SET: Processing only when specified
    Write-Verbose -Message "'$NameNormalised' Users: Adding $($UserIdList.Count) Users as Agents to the Queue" -Verbose
    if ($UserIdList.Count -gt 0) {
      $Parameters += @{'Users' = @($UserIdList) }
    }
    #endregion

    #region Groups - Parsing Distribution Lists and their Users
    $Operation = "Parsing Distribution Lists"
    $step++
    Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
    Write-Verbose -Message "$Status - $Operation"

    [System.Collections.ArrayList]$DLIdList = @()
    if ($PSBoundParameters.ContainsKey('DistributionLists')) {
      Write-Verbose -Message "'$NameNormalised' Parsing Distribution Lists"
      foreach ($DL in $DistributionLists) {
        $DLObject = $null
        $DLObject = Find-AzureAdGroup "$DL" -Exact
        if ($DLObject) {
          Write-Verbose -Message "Group '$DL' will be added to the Call Queue" -Verbose
          # Test whether Users in DL are enabled for EV and/or licensed?

          # Add to List
          [void]$DLIdList.Add($DLObject.ObjectId)
        }
        else {
          Write-Warning -Message "Group '$DL' not found or not unique in AzureAd, omitting Group!"
        }
      }
      # NEW: Processing always / SET: Processing only when specified
      Write-Verbose -Message "'$NameNormalised' Groups: Adding $($DLIdList.Count) Groups to the Queue" -Verbose
      if ($DLIdList.Count -gt 0) {
        $Parameters += @{'DistributionLists' = @($DLIdList) }
        Write-Verbose -Message "NOTE: Group members are parsed by the subsystem" -Verbose
        Write-Verbose -Message "Currently no verification steps are taken against Licensing or EV-Enablement of Members" -Verbose
      }
    }
    #endregion


    #region Common parameters
    $Parameters += @{'WarningAction' = 'Continue' }
    $Parameters += @{'ErrorAction' = 'Stop' }
    #endregion
    #endregion


    #region ACTION
    # DEBUG Information
    if ($PSBoundParameters.ContainsKey("Debug")) {
      "Function: $($MyInvocation.MyCommand.Name)", ($Parameters | Format-Table -AutoSize | Out-String).Trim() | Write-Debug
    }

    # Create CQ (New-CsCallQueue)
    $Status = "Creating Object"
    $Operation = "Creating Call Queue: '$NameNormalised'"
    $step++
    Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
    Write-Verbose -Message "$Status - $Operation"
    if ($PSCmdlet.ShouldProcess("$UserPrincipalName", "New-CsCallQueue")) {
      try {
        # Create the Call Queue with all enumerated Parameters passed through splatting
        $null = (New-CsCallQueue @Parameters)
        Write-Verbose -Message "SUCCESS: '$NameNormalised' Call Queue created with all Parameters"
      }
      catch {
        Write-Error -Message "Error creating the Call Queue: $($_.Exception.Message)" -Category InvalidOperation
        return
      }
    }
    else {
      return
    }
    #endregion


    #region OUTPUT
    $Status = "Creating Object"
    $Operation = "Querying Object"
    $step++
    Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
    Write-Verbose -Message "$Status - $Operation"

    $CallQueueFinal = Get-TeamsCallQueue -Name "$NameNormalised" -WarningAction SilentlyContinue
    Write-Progress -Id 0 -Status "Complete" -Activity $MyInvocation.MyCommand -Completed
    Write-Output $CallQueueFinal
    #endregion

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"

  } #end
} #New-TeamsCallQueue
