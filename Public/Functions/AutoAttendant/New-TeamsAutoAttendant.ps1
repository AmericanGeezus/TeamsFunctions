﻿# Module:   TeamsFunctions
# Function: AutoAttendant
# Author:   David Eberhardt
# Updated:  01-DEC-2020
# Status:   Live




function New-TeamsAutoAttendant {
  <#
  .SYNOPSIS
    Support function wrapping around New-CsAutoAttendant
  .DESCRIPTION
    This script handles select and limited variety for what Auto Attendants have to offer
    It should be seen as an extension rather than a replacement of New-CsAutoAttendant.
    It is currently still in development!
    UserPrincipalNames can be provided instead of IDs, FileNames (FullName) can be provided instead of IDs
  .PARAMETER Name
    Name of the Auto Attendant. Name will be normalised (unsuitable characters are filtered)
    Used as the DisplayName - Visible in Teams
  .PARAMETER TimeZone
    Required. TimeZone Identifier based on Get-CsAutoAttendantSupportedTimeZone, but abbreviated for easier input.
    Warning: Due to multiple time zone names with in the same relative difference to UTC this MAY produce incongruent output
    The time zone will be correct, but only specifying "UTC+01:00" for example will select the first entry.
    Default Value: "UTC"
  .PARAMETER LanguageId
    Required. Language Identifier indicating the language that is used to play text and identify voice prompts.
    Default Value: "en-US"
  .PARAMETER Operator
    Optional. Creates a Callable entity for the Operator
    Expected are UserPrincipalName (User, ApplicationEndPoint), a TelURI (ExternalPstn), an Office 365 Group Name (SharedVoicemail)
  .PARAMETER BusinessHoursGreeting
    Optional. Creates a Greeting for the Default Call Flow (during business hours) utilising New-TeamsAutoAttendantPrompt
    A supported Audio File or a text string that is parsed by the text-to-voice engine in the Language specified
    The last 4 digits will determine the type. For an AudioFile they are expected to be the file extension: '.wav', '.wma' or 'mp3'
    If DefaultCallFlow is provided, this parameter will be ignored.
  .PARAMETER BusinessHoursCallFlowOption
    Optional. Disconnect, TransferCallToTarget, Menu. Default is Disconnect.
    TransferCallToTarget requires BusinessHoursCallTarget. Menu requires BusinessHoursMenu
    If DefaultCallFlow is provided, this parameter will be ignored.
  .PARAMETER BusinessHoursCallTarget
    Optional. Requires BusinessHoursCallFlowOption to be TransferCallToTarget. Creates a Callable entity for this Call Target.
    Expected are UserPrincipalName (User, ApplicationEndPoint), a TelURI (ExternalPstn), an Office 365 Group Name (SharedVoicemail)
    If DefaultCallFlow is provided, this parameter will be ignored.
  .PARAMETER BusinessHoursMenu
    Optional. Requires BusinessHoursCallFlowOption to be Menu and a BusinessHoursCallTarget
    If DefaultCallFlow is provided, this parameter will be ignored.
  .PARAMETER AfterHoursGreeting
    Optional. Creates a Greeting for the After Hours Call Flow utilising New-TeamsAutoAttendantPrompt
    A supported Audio File or a text string that is parsed by the text-to-voice engine in the Language specified
    The last 4 digits will determine the type. For an AudioFile they are expected to be the file extension: '.wav', '.wma' or 'mp3'
    If CallFlows and CallHandlingAssociations are provided, this parameter will be ignored.
  .PARAMETER AfterHoursCallFlowOption
    Optional. Disconnect, TransferCallToTarget, Menu. Default is Disconnect.
    TransferCallToTarget requires AfterHoursCallTarget. Menu requires AfterHoursMenu
    If CallFlows and CallHandlingAssociations are provided, this parameter will be ignored.
  .PARAMETER AfterHoursCallTarget
    Optional. Requires AfterHoursCallFlowOption to be TransferCallToTarget. Creates a Callable entity for this Call Target
    Expected are UserPrincipalName (User, ApplicationEndPoint), a TelURI (ExternalPstn), an Office 365 Group Name (SharedVoicemail)
    If CallFlows and CallHandlingAssociations are provided, this parameter will be ignored.
  .PARAMETER AfterHoursMenu
    Optional. Requires AfterHoursCallFlowOption to be Menu and a AfterHoursCallTarget
    If CallFlows and CallHandlingAssociations are provided, this parameter will be ignored.
  .PARAMETER AfterHoursSchedule
    Optional. Default Schedule to apply: One of: MonToFri9to5 (default), MonToFri8to12and13to18, Open24x7
    A more granular Schedule can be used with the Parameter -Schedule
    If CallFlows and CallHandlingAssociations are provided, this parameter will be ignored.
  .PARAMETER Schedule
    Optional. Custom Schedule object to apply for After Hours Call Flow
    Object created with New-TeamsAutoAttendantSchedule or New-CsAutoAttendantSchedule
    If CallFlows and CallHandlingAssociations are provided, this parameter will be ignored.
    Using this parameter to provide a Schedule Object will override the Parameter -AfterHoursSchedule
  .PARAMETER HolidaySetGreeting
    Optional. Creates a Greeting for the Holiday Set Call Flow utilising New-TeamsAutoAttendantPrompt
    A supported Audio File or a text string that is parsed by the text-to-voice engine in the Language specified
    The last 4 digits will determine the type. For an AudioFile they are expected to be the file extension: '.wav', '.wma' or 'mp3'
    If CallFlows and CallHandlingAssociations are provided, this parameter will be ignored.
  .PARAMETER HolidaySetCallFlowOption
    Optional. Disconnect, TransferCallToTarget, Menu. Default is Disconnect.
    TransferCallToTarget requires HolidaySetCallTarget. Menu requires HolidaySetMenu
    If CallFlows and CallHandlingAssociations are provided, this parameter will be ignored.
  .PARAMETER HolidaySetCallTarget
    Optional. Requires HolidaySetCallFlowOption to be TransferCallToTarget. Creates a Callable entity for this Call Target
    Expected are UserPrincipalName (User, ApplicationEndPoint), a TelURI (ExternalPstn), an Office 365 Group Name (SharedVoicemail)
    If CallFlows and CallHandlingAssociations are provided, this parameter will be ignored.
  .PARAMETER HolidaySetMenu
    Optional. Requires HolidaySetCallFlowOption to be Menu and a HolidaySetCallTarget
    If CallFlows and CallHandlingAssociations are provided, this parameter will be ignored.
  .PARAMETER HolidaySetSchedule
    Optional. Default Schedule to apply: Either a 2-digit Country Code to create the schedule for the next three years for,
    a Schedule Object created beforehand or an existing Schedule Object ID already created in the Tenant
    If not provided, an empty Schedule Object will be created which will never be in effect.
    If CallFlows and CallHandlingAssociations are provided, this parameter will be ignored.
  .PARAMETER DefaultCallFlow
    Optional. Call Flow Object to pass to New-CsAutoAttendant (used as the Default Call Flow)
    Using this parameter to define the default Call Flow overrides all -BusinessHours Parameters
  .PARAMETER CallFlows
    Optional. Call Flow Object to pass to New-CsAutoAttendant
    Using this parameter to define additional Call Flows overrides all -AfterHours & -HolidaySet Parameters
    Requires Parameter CallHandlingAssociations in conjunction
  .PARAMETER CallHandlingAssociations
    Optional. Call Handling Associations Object to pass to New-CsAutoAttendant
    Using this parameter to define additional Call Flows overrides all -AfterHours & -HolidaySet Parameters
    Requires Parameter CallFlows in conjunction
  .PARAMETER InclusionScope
    Optional. DialScope Object to pass to New-CsAutoAttendant
    Object created with New-TeamsAutoAttendantDialScope or New-CsAutoAttendantDialScope
  .PARAMETER ExclusionScope
    Optional. DialScope Object to pass to New-CsAutoAttendant
    Object created with New-TeamsAutoAttendantDialScope or New-CsAutoAttendantDialScope
  .PARAMETER EnableVoiceResponse
    Optional Switch to be passed to New-CsAutoAttendant
  .PARAMETER EnableTranscription
    Optional. Where possible, tries to enable Voicemail Transcription.
    Effective only for SharedVoicemail Targets as an Operator or MenuOption. Otherwise has no effect.
  .PARAMETER Force
    Suppresses confirmation prompt to enable Users for Enterprise Voice, if Users are specified
    Currently no other impact
  .EXAMPLE
    New-TeamsAutoAttendant -Name "My Auto Attendant"
    Creates a new Auto Attendant "My Auto Attendant" with Defaults
    TimeZone is UTC, Language is en-US and Schedule is Mon-Fri 9to5.
    Business hours and After Hours action is Disconnect
  .EXAMPLE
    New-TeamsAutoAttendant -Name "My Auto Attendant" -TimeZone UTC-05:00 -LanguageId pt-BR -AfterHoursSchedule MonToFri8to12and13to18 -EnableVoiceResponse
    Creates a new Auto Attendant "My Auto Attendant" and sets the TimeZone to UTC-5 and the language to Portuguese (Brazil)
    The Schedule of Mon-Fri 8to12 and 13to18 will be applied. Also enables VoiceResponses
  .EXAMPLE
    New-TeamsAutoAttendant -Name "My Auto Attendant" -Operator "tel:+1555123456"
    Creates a new Auto Attendant "My Auto Attendant" with default TimeZone and Language, but defines an Operator as a Callable Entity (Forward to Pstn)
  .EXAMPLE
    New-TeamsAutoAttendant -Name "My Auto Attendant" -BusinessHoursGreeting "Welcome to Contoso" -BusinessHoursCallFlowOption TransferCallToTarget -BusinessHoursCallTarget $CallTarget
    Creates a new Auto Attendant "My Auto Attendant" with defaults, but defines a Text-to-Voice Greeting, then forwards the Call to the Call Target.
    The CallTarget is queried based on input and created as required. UserPrincipalname for Users or ResourceAccount, Group Name for SharedVoicemail, provided as a string in the Variable $UPN
    This example is equally applicable to AfterHours.
  .EXAMPLE
    New-TeamsAutoAttendant -Name "My Auto Attendant" -DefaultCallFlow $DefaultCallFlow -CallFlows $CallFlows -CallHandlingAssociations $CallHandlingAssociations -InclusionScope $InGroups -ExclusionScope $OutGroups
    Creates a new Auto Attendant "My Auto Attendant" and passes through all objects provided.
    In this example, provided Objects are passed on through tto New-CsAutoAttendant and override other respective Parmeters provided:
    A DefaultCallFlow Object is passed on which overrides all "-BusinessHours"-Parmeters. One or more CallFlows and
    one or more CallHandlingAssociation Objects are passed on overriding all "-AfterHours" and "-HolidaySet" Parameters
    An InclusionScope and an ExclusionScope are defined. These are passed on as-is
    All other values, like Language and TimeZone are defined with their defaults and can still be defined with the Objects.
  .INPUTS
    System.String
  .OUTPUTS
    System.Object
  .NOTES
    BusinessHours Parameters aim to simplify input for the Default Call Flow
    AfterHours Parameters aim to simplify input for the After Hours Call Flow
    HolidaySet Parameters aim to simplify input for the Holiday Set Call Flow
    Use of CsAutoAttendant Parameters will override the respective '-BusinessHours', '-AfterHours' and '-HolidaySet' Parameters

    InclusionScope and ExclusionScope Objects can be created with New-TeamsAutoAttendantDialScope and the Group Names
    This was deliberately not integrated into this CmdLet
  .COMPONENT
    TeamsAutoAttendant
  .FUNCTIONALITY
    Creates a Auto Attendant with custom settings and friendly names as input
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/New-TeamsAutoAttendant.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsAutoAttendant.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  #>

  [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
  [Alias('New-TeamsAA')]
  [OutputType([System.Object])]
  param(
    #region Required Parameters
    [Parameter(Mandatory, ValueFromPipeline, HelpMessage = 'Name of the Auto Attendant')]
    [string]$Name,

    [Parameter(HelpMessage = 'TimeZone Identifier from Get-CsAutoAttendantSupportedTimeZone')]
    #[ValidateSet('UTC-12:00', 'UTC-11:00', 'UTC-10:00', 'UTC-09:00', 'UTC-08:00', 'UTC-07:00', 'UTC-06:00', 'UTC-05:00', 'UTC-04:30', 'UTC-04:00', 'UTC-03:30', 'UTC-03:00', 'UTC-02:00', 'UTC-01:00', 'UTC', 'UTC+01:00', 'UTC+02:00', 'UTC+03:00', 'UTC+03:30', 'UTC+04:00', 'UTC+04:30', 'UTC+05:00', 'UTC+05:30', 'UTC+05:45', 'UTC+06:00', 'UTC+06:30', 'UTC+07:00', 'UTC+08:00', 'UTC+09:00', 'UTC+09:30', 'UTC+10:00', 'UTC+11:00', 'UTC+12:00', 'UTC+13:00', 'UTC+14:00')]
    [ValidateScript( {
        if ( -not $global:TeamsFunctionsCsAutoAttendantSupportedZimeZone ) { $global:TeamsFunctionsCsAutoAttendantSupportedZimeZone = Get-CsAutoAttendantSupportedTimeZone -WarningAction SilentlyContinue }
        [System.Collections.Arraylist]$TimeZoneUTCStrings = ($TeamsFunctionsCsAutoAttendantSupportedZimeZone | Where-Object DisplayName -NotLike '(UTC)*').DisplayName.Substring(1, 9) | Get-Unique
        [void]$TimeZoneUTCStrings.Add('UTC')
        if ($_ -in $TimeZoneUTCStrings) { $True } else {
          throw [System.Management.Automation.ValidationMetadataException] "Parameter 'TimeZone' must be of the set: $($TimeZoneUTCStrings -join ',')"
        }
      })]
    [ArgumentCompleter( {
        if ( -not $global:TeamsFunctionsCsAutoAttendantSupportedZimeZone ) { $global:TeamsFunctionsCsAutoAttendantSupportedZimeZone = Get-CsAutoAttendantSupportedTimeZone -WarningAction SilentlyContinue }
        [System.Collections.Arraylist]$TimeZoneUTCStrings = ($TeamsFunctionsCsAutoAttendantSupportedZimeZone | Where-Object DisplayName -NotLike '(UTC)*').DisplayName.Substring(1, 9) | Get-Unique
        [void]$TimeZoneUTCStrings.Add('UTC')
        $TimeZoneUTCStrings | Sort-Object | ForEach-Object {
          [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', "$($TimeZoneUTCStrings.Count) records available")
        }
      })]
    [string]$TimeZone = 'UTC',

    [Parameter(HelpMessage = 'Language Identifier from Get-CsAutoAttendantSupportedLanguage.')]
    [ValidateScript( {
        if ( -not $global:TeamsFunctionsCsAutoAttendantSupportedLanguage ) { $global:TeamsFunctionsCsAutoAttendantSupportedLanguage = Get-CsAutoAttendantSupportedLanguage -WarningAction SilentlyContinue }
        if ($_ -in $($TeamsFunctionsCsAutoAttendantSupportedLanguage).Id) { $True } else {
          throw [System.Management.Automation.ValidationMetadataException] "Parameter 'LanguageId' must be of the set: $($TeamsFunctionsCsAutoAttendantSupportedLanguage.Id)"
        }
      })]
    [ArgumentCompleter( {
        if ( -not $global:TeamsFunctionsCsAutoAttendantSupportedLanguage ) { $global:TeamsFunctionsCsAutoAttendantSupportedLanguage = Get-CsAutoAttendantSupportedLanguage -WarningAction SilentlyContinue }
        $($TeamsFunctionsCsAutoAttendantSupportedLanguage.Id) | Sort-Object | ForEach-Object {
          [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', "$($TeamsFunctionsCsAutoAttendantSupportedLanguage.Count) records available")
        }
      })]
    [string]$LanguageId = 'en-US',
    #endregion

    #region Business Hours Parameters
    [Parameter(HelpMessage = 'Business Hours Greeting - Text String or Recording')]
    [ArgumentCompleter( { '<Your Text-to-speech-string>', 'C:\Temp\' })]
    [string]$BusinessHoursGreeting,

    [Parameter(HelpMessage = 'Business Hours Call Flow - Default options')]
    [ValidateSet('Disconnect', 'TransferCallToTarget', 'Menu')]
    [string]$BusinessHoursCallFlowOption,

    [Parameter(HelpMessage = 'Business Hours Call Target - BusinessHoursCallFlowOption = TransferCallToTarget')]
    [string]$BusinessHoursCallTarget,

    [Parameter(HelpMessage = 'Business Hours Call Target - BusinessHoursCallFlowOption = Menu')]
    [object]$BusinessHoursMenu,
    #endregion

    #region After Hours Parameters
    [Parameter(HelpMessage = 'After Hours Greeting - Text String or Recording')]
    [ArgumentCompleter( { '<Your Text-to-speech-string>', 'C:\Temp\' })]
    [string]$AfterHoursGreeting,

    [Parameter(HelpMessage = 'After Hours Call Flow - Default options')]
    [ValidateSet('Disconnect', 'TransferCallToTarget', 'Menu')]
    [string]$AfterHoursCallFlowOption,

    [Parameter(HelpMessage = 'After Hours Call Target - AfterHoursCallFlowOption = TransferCallToTarget')]
    [string]$AfterHoursCallTarget,

    [Parameter(HelpMessage = 'After Hours Call Target - AfterHoursCallFlowOption = Menu')]
    [object]$AfterHoursMenu,

    [Parameter(HelpMessage = 'Default Schedule to apply')]
    [ValidateSet('Open24x7', 'MonToFri9to5', 'MonToFri8to12and13to18')]
    [string]$AfterHoursSchedule,
    #endregion

    #region Holiday Set Parameters
    [Parameter(HelpMessage = 'Holiday Set Greeting - Text String or Recording')]
    [ArgumentCompleter( { '<Your Text-to-speech-string>', 'C:\Temp\' })]
    [string]$HolidaySetGreeting,

    [Parameter(HelpMessage = 'Holiday Set Call Flow - Default options')]
    [ValidateSet('Disconnect', 'TransferCallToTarget', 'Menu')]
    [string]$HolidaySetCallFlowOption,

    [Parameter(HelpMessage = 'Holiday Set Call Target - HolidaySetCallFlowOption = TransferCallToTarget')]
    [string]$HolidaySetCallTarget,

    [Parameter(HelpMessage = 'Holiday Set Call Target - HolidaySetCallFlowOption = Menu')]
    [object]$HolidaySetMenu,

    [Parameter(HelpMessage = 'Default Schedule to apply, can be a 2-digit CountryCode a ScheduleObject or an ID of one')]
    [string]$HolidaySetSchedule,
    #endregion

    #region Default Parameters of New-CsAutoAttendant for Pass-through application
    [Parameter(HelpMessage = 'Schedule Object created with New-TeamsAutoAttendantSchedule to apply')]
    [object]$Schedule,

    [Parameter(HelpMessage = 'Default Call Flow')]
    [object]$DefaultCallFlow,

    [Parameter(HelpMessage = 'Call Flows')]
    [object]$CallFlows,

    [Parameter(HelpMessage = 'CallHandlingAssociations')]
    [object]$CallHandlingAssociations,
    #endregion

    [Parameter(HelpMessage = 'Target String for the Operator (UPN, Group Name or Tel URI')]
    [string]$Operator,

    [Parameter(HelpMessage = 'Groups defining the Inclusion Scope')]
    [object]$InclusionScope,

    [Parameter(HelpMessage = 'Groups defining the Exclusion Scope')]
    [object]$ExclusionScope,

    [Parameter(HelpMessage = 'Voice Responses')]
    [switch]$EnableVoiceResponse,

    [Parameter(HelpMessage = 'Tries to Enable Transcription wherever possible')]
    [switch]$EnableTranscription,

    [Parameter(HelpMessage = 'Suppresses confirmation prompt to enable Users for Enterprise Voice, if Users are specified')]
    [switch]$Force

  ) #param

  begin {
    Show-FunctionStatus -Level Live
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"
    Write-Verbose -Message "Need help? Online:  $global:TeamsFunctionsHelpURLBase$($MyInvocation.MyCommand)`.md"

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

    $StatusID0 = 'Verifying input'
    #region Parameter validation
    $CurrentOperationID0 = 'Validating Language, Voice capabilities & Time Zone'
    Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0

    # Language has to be normalised as the Id is case sensitive. Default value: en-US
    $Language = $($LanguageId.Split('-')[0]).ToLower() + '-' + $($LanguageId.Split('-')[1]).ToUpper()
    Write-Verbose "LanguageId '$LanguageId' normalised to '$Language'"
    # Query of Supported Languages based on previously calculated global Variable
    if ( -not $global:TeamsFunctionsCsAutoAttendantSupportedLanguage ) { $global:TeamsFunctionsCsAutoAttendantSupportedLanguage = Get-CsAutoAttendantSupportedLanguage -WarningAction SilentlyContinue }
    $VoiceResponsesSupported = ($global:TeamsFunctionsCsAutoAttendantSupportedLanguage | Where-Object Id -eq "$Language").VoiceResponseSupported

    # TimeZoneId - Generated from $TimeZone. Default value: UTC
    Write-Verbose -Message "TimeZone - Parsing TimeZone '$TimeZone'"
    if ($TimeZone -eq 'UTC') {
      $TimeZoneId = $TimeZone
    }
    else {
      # Query of Supported TimeZones based on previously calculated global Variable
      if ( -not $global:TeamsFunctionsCsAutoAttendantSupportedZimeZone ) { $global:TeamsFunctionsCsAutoAttendantSupportedZimeZone = Get-CsAutoAttendantSupportedTimeZone -WarningAction SilentlyContinue }
      $TimeZoneId = ($global:TeamsFunctionsCsAutoAttendantSupportedZimeZone | Where-Object DisplayName -Like "($TimeZone)*" | Select-Object -First 1).Id
      Write-Verbose -Message "TimeZone - Found! Using: '$TimeZoneId'"
      Write-Information 'TimeZone - This is a correct match for the Time Zone, but might not be fully precise. - Please fine-tune Time Zone in the Admin Center if needed.'
    }

    #region BusinessHours
    # Main Call Flow -- DefaultCallFlow VS BusinessHours*
    $CurrentOperationID0 = 'Validating DefaultCallFlow'
    Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
    if ($DefaultCallFlow) {
      # DefaultCallFlow
      Write-Information 'DefaultCallFlow - Overriding all BusinessHours-Parameters'

      if ($PSBoundParameters.ContainsKey('BusinessHoursGreeting')) { $PSBoundParameters.Remove('BusinessHoursGreeting') }
      if ($PSBoundParameters.ContainsKey('BusinessHoursCallFlowOption')) { $PSBoundParameters.Remove('BusinessHoursCallFlowOption') }
      if ($PSBoundParameters.ContainsKey('BusinessHoursCallTarget')) { $PSBoundParameters.Remove('BusinessHoursCallTarget') }

      # Testing provided Object Type
      if (($DefaultCallFlow | Get-Member | Select-Object TypeName -First 1).TypeName -ne 'Deserialized.Microsoft.Rtc.Management.Hosted.OAA.Models.CallFlow') {
        Write-Error "DefaultCallFlow - Type is not of 'Microsoft.Rtc.Management.Hosted.OAA.Models.CallFlow'. Please provide a Call Flow Object" -Category InvalidType
        break
      }
    }
    else {
      # BusinessHours Parameters
      if (-not $PSBoundParameters.ContainsKey('BusinessHoursCallFlowOption')) {
        Write-Verbose -Message "BusinessHoursCallFlowOption - Parameter not specified. Defaulting to 'Disconnect' No other 'BusinessHours'-Parameters are processed!"
        $BusinessHoursCallFlowOption = 'Disconnect'
      }
      elseif ($BusinessHoursCallFlowOption -eq 'TransferCallToTarget') {
        # Must contain Target
        if (-not $PSBoundParameters.ContainsKey('BusinessHoursCallTarget')) {
          Write-Error -Message "BusinessHoursCallFlowOption (TransferCallToTarget) - Parameter 'BusinessHoursCallTarget' missing"
          break
        }

        # Must not contain a Menu
        if ($PSBoundParameters.ContainsKey('BusinessHoursMenu')) {
          Write-Verbose -Message 'BusinessHoursCallFlowOption (TransferCallToTarget) - Parameter BusinessHoursMenu cannot be used and will be omitted!' -Verbose
          $PSBoundParameters.Remove('BusinessHoursMenu')
        }
      }
      elseif ($BusinessHoursCallFlowOption -eq 'Menu') {
        # Must contain a Menu
        if (-not $PSBoundParameters.ContainsKey('BusinessHoursMenu')) {
          Write-Error -Message 'BusinessHoursCallFlowOption (Menu) - BusinessHoursMenu missing'
          break
        }
        else {
          # Testing provided Object Type
          if (($BusinessHoursMenu | Get-Member | Select-Object -First 1).TypeName -ne 'Deserialized.Microsoft.Rtc.Management.Hosted.OAA.Models.Menu') {
            Write-Error -Message "BusinessHoursCallFlowOption (Menu) - BusinessHoursMenu not of the Type 'Microsoft.Rtc.Management.Hosted.OAA.Models.Menu'" -Category InvalidType
            break
          }
        }

        # Must not contain Target
        if ($PSBoundParameters.ContainsKey('BusinessHoursCallTarget')) {
          Write-Verbose -Message "BusinessHoursCallFlowOption (Menu) - Parameter 'BusinessHoursCallTarget' cannot be used and will be omitted!" -Verbose
          $PSBoundParameters.Remove('BusinessHoursCallTarget')
        }
      }
    }
    #endregion

    #region Default Parameters VS AfterHours & HolidaySet Parameters
    $CurrentOperationID0 = 'Validating CallFlows'
    Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
    # Call Flows & Call Handling Associations
    if ($PSBoundParameters.ContainsKey('CallFlows') -or $PSBoundParameters.ContainsKey('CallHandlingAssociations')) {
      # Custom Call Flows
      Write-Information 'CallFlows - Overriding all AfterHours- & HolidaySet-Parameters'
      if ($PSBoundParameters.ContainsKey('AfterHoursGreeting')) { $PSBoundParameters.Remove('AfterHoursGreeting') }
      if ($PSBoundParameters.ContainsKey('AfterHoursCallFlowOption')) { $PSBoundParameters.Remove('AfterHoursCallFlowOption') }
      if ($PSBoundParameters.ContainsKey('AfterHoursCallTarget')) { $PSBoundParameters.Remove('AfterHoursCallTarget') }
      if ($PSBoundParameters.ContainsKey('AfterHoursSchedule')) { $PSBoundParameters.Remove('AfterHoursSchedule') }
      if ($PSBoundParameters.ContainsKey('Schedule')) { $PSBoundParameters.Remove('Schedule') }
      # Removing HolidaySet
      if ($PSBoundParameters.ContainsKey('HolidaySetGreeting')) { $PSBoundParameters.Remove('HolidaySetGreeting') }
      if ($PSBoundParameters.ContainsKey('HolidaySetCallFlowOption')) { $PSBoundParameters.Remove('HolidaySetCallFlowOption') }
      if ($PSBoundParameters.ContainsKey('HolidaySetCallTarget')) { $PSBoundParameters.Remove('HolidaySetCallTarget') }
      if ($PSBoundParameters.ContainsKey('HolidaySetSchedule')) { $PSBoundParameters.Remove('HolidaySetSchedule') }

      if ($CallFlows -and -not $CallHandlingAssociations) {
        Write-Error -Message 'CallFlows - Parameter requires CallHandlingAssociation to be specified'
        break
      }

      if ($CallHandlingAssociations -and -not $CallFlows) {
        Write-Error -Message 'CallHandlingAssociations - Parameter requires CallFlows to be specified'
        break
      }

      # Testing provided Object Type
      foreach ($Flow in $CallFlows) {
        if (($Flow | Get-Member | Select-Object -First 1).TypeName -ne 'Deserialized.Microsoft.Rtc.Management.Hosted.OAA.Models.CallFlow') {
          Write-Error -Message "CallFlows - '$($Flow.Name)' -Object not of the Type 'Microsoft.Rtc.Management.Hosted.OAA.Models.CallFlow'" -Category InvalidType
          break
        }
      }

      # Testing provided Object Type
      foreach ($CHA in $CallHandlingAssociations) {
        if (($CHA | Get-Member | Select-Object -First 1).TypeName -ne 'Deserialized.Microsoft.Rtc.Management.Hosted.OAA.Models.CallHandlingAssociation') {
          Write-Error -Message "CallHandlingAssociations - '$($CHA.Name)' -Object not of the Type 'Microsoft.Rtc.Management.Hosted.OAA.Models.CallHandlingAssociation'" -Category InvalidType
          break
        }
      }
    }
    else {
      #region Processing AfterHours Parameters
      if (-not $PSBoundParameters.ContainsKey('AfterHoursCallFlowOption')) {
        Write-Warning -Message "AfterHoursCallFlowOption - Parameter not specified. Defaulting to 'Disconnect' No other 'AfterHours'-Parameters are processed!"
        $AfterHoursCallFlowOption = 'Disconnect'
      }
      elseif ($AfterHoursCallFlowOption -eq 'TransferCallToTarget') {
        # Must contain Target
        if (-not $PSBoundParameters.ContainsKey('AfterHoursCallTarget')) {
          Write-Error -Message "AfterHoursCallFlowOption (TransferCallToTarget) - Parameter 'AfterHoursCallTarget' missing"
          break
        }

        # Must not contain a Menu
        if ($PSBoundParameters.ContainsKey('AfterHoursMenu')) {
          Write-Verbose -Message 'AfterHoursCallFlowOption (TransferCallToTarget) - Parameter AfterHoursMenu cannot be used and will be omitted!' -Verbose
          $PSBoundParameters.Remove('AfterHoursMenu')
        }
      }
      elseif ($AfterHoursCallFlowOption -eq 'Menu') {
        # Must contain a Menu
        if (-not $PSBoundParameters.ContainsKey('AfterHoursMenu')) {
          Write-Error -Message 'AfterHoursCallFlowOption (Menu) - AfterHoursMenu missing'
          break
        }
        else {
          if (($AfterHoursMenu | Get-Member | Select-Object -First 1).TypeName -ne 'Deserialized.Microsoft.Rtc.Management.Hosted.OAA.Models.Menu') {
            Write-Error -Message "AfterHoursCallFlowOption (Menu) - AfterHoursMenu not of the Type 'Microsoft.Rtc.Management.Hosted.OAA.Models.Menu'" -Category InvalidType
            break
          }
        }

        # Must not contain Target
        if ($PSBoundParameters.ContainsKey('AfterHoursCallTarget')) {
          Write-Verbose -Message "AfterHoursCallFlowOption (Menu) - Parameter 'AfterHoursCallTarget' cannot be used and will be omitted!"-Verbose
          $PSBoundParameters.Remove('AfterHoursCallTarget')
        }
      }
      #endregion

      #region Processing Schedule & AfterHoursSchedule
      if ($Schedule) {
        if ($AfterHoursSchedule) {
          Write-Information 'Schedule - Custom Schedule Object overrides AfterHoursSchedule provided'
          $PSBoundParameters.Remove('AfterHoursSchedule')
        }

        # Testing provided Object Type
        if (($Schedule | Get-Member | Select-Object TypeName -First 1).TypeName -ne 'Deserialized.Microsoft.Rtc.Management.Hosted.Online.Models.Schedule') {
          Write-Error "Schedule - Type is not of 'Microsoft.Rtc.Management.Hosted.Online.Models.Schedule'. Please provide a Schedule Object" -Category InvalidType
          break
        }
      }
      else {
        if ( $AfterHoursSchedule) {
          Write-Information "INFO:    Auto Attendant '$Name' Schedule - AfterHoursSchedule provided, Using: '$AfterHoursSchedule'"
        }
        else {
          $AfterHoursSchedule = 'MonToFri9to5'
          Write-Information "INFO:    Auto Attendant '$Name' Schedule - AfterHoursSchedule not provided, Using: '$AfterHoursSchedule'"
        }

        # Creating Schedule
        $CurrentOperationID0 = 'Business Hours Call Flow - Creating Schedule'
        Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
        $Schedule = switch ($AfterHoursSchedule) {
          'Open24x7' {
            New-TeamsAutoAttendantSchedule -Name 'Business Hours Schedule' -WeeklyRecurrentSchedule -BusinessDays MonToSun -BusinessHours AllDay -Complement
          }
          'MonToFri9to5' {
            New-TeamsAutoAttendantSchedule -Name 'Business Hours Schedule' -WeeklyRecurrentSchedule -BusinessDays MonToFri -BusinessHours 9to5 -Complement
          }
          'MonToFri8to12and13to18' {
            New-TeamsAutoAttendantSchedule -Name 'Business Hours Schedule' -WeeklyRecurrentSchedule -BusinessDays MonToFri -BusinessHours 8to12and13to18 -Complement
          }
        }
        Write-Verbose -Message "Schedule - Schedule created: '$AfterHoursSchedule'"
      }
      #endregion

      #region Processing HolidaySet Parameters
      if (-not $PSBoundParameters.ContainsKey('HolidaySetCallFlowOption')) {
        Write-Warning -Message "HolidaySetCallFlowOption - Parameter not specified. Defaulting to 'Disconnect' No other 'HolidaySet'-Parameters are processed!"
        $HolidaySetCallFlowOption = 'Disconnect'
      }
      elseif ($HolidaySetCallFlowOption -eq 'TransferCallToTarget') {
        # Must contain Target
        if (-not $PSBoundParameters.ContainsKey('HolidaySetCallTarget')) {
          Write-Error -Message "HolidaySetCallFlowOption (TransferCallToTarget) - Parameter 'HolidaySetCallTarget' missing"
          break
        }

        # Must not contain a Menu
        if ($PSBoundParameters.ContainsKey('HolidaySetMenu')) {
          Write-Verbose -Message 'HolidaySetCallFlowOption (TransferCallToTarget) - Parameter HolidaySetMenu cannot be used and will be omitted!' -Verbose
          $PSBoundParameters.Remove('HolidaySetMenu')
        }
      }
      elseif ($HolidaySetCallFlowOption -eq 'Menu') {
        # Must contain a Menu
        if (-not $PSBoundParameters.ContainsKey('HolidaySetMenu')) {
          Write-Error -Message 'HolidaySetCallFlowOption (Menu) - HolidaySetMenu missing'
          break
        }
        else {
          if (($HolidaySetMenu | Get-Member | Select-Object -First 1).TypeName -ne 'Deserialized.Microsoft.Rtc.Management.Hosted.OAA.Models.Menu') {
            Write-Error -Message "HolidaySetCallFlowOption (Menu) - HolidaySetMenu not of the Type 'Microsoft.Rtc.Management.Hosted.OAA.Models.Menu'" -Category InvalidType
            break
          }
        }

        # Must not contain Target
        if ($PSBoundParameters.ContainsKey('HolidaySetCallTarget')) {
          Write-Verbose -Message "HolidaySetCallFlowOption (Menu) - Parameter 'HolidaySetCallTarget' cannot be used and will be omitted!"-Verbose
          $PSBoundParameters.Remove('HolidaySetCallTarget')
        }
      }
      #endregion

      #region Processing HolidaySetSchedule
      if ( $HolidaySetSchedule -match '^[0-9a-f]{8}-([0-9a-f]{4}\-){3}[0-9a-f]{12}$' ) {
        # Holiday Schedule provided as ID of existing Schedule in the Tenant - Taken as is.
        $HolidaySchedule = $HolidaySetSchedule
      }
      elseif ( $HolidaySetSchedule.Id -match '^[0-9a-f]{8}-([0-9a-f]{4}\-){3}[0-9a-f]{12}$') {
        # Holiday Schedule provided as Schedule Object in the Tenant
        $HolidaySchedule = $HolidaySetSchedule.Id
      }
      elseif ( $HolidaySetSchedule -match '^[a-z][a-z]$') {
        # Holiday Schedule provided is a Country for which a Schedule Object will be created
        [int]$CurrentYear = Get-Date -Format yyyy
        $Year = $CurrentYear, $($CurrentYear + 1), $($CurrentYear + 2)
        $HolidaySchedule = New-TeamsHolidaySchedule -CountryCode $HolidaySetSchedule -Year $Year
      }
      else {
        Write-Warning -Message 'HolidaySchedule provided does not match an ID, Object or CountryCode! Creating empty Schedule'
        $HolidaySchedule = New-CsOnlineSchedule -Name "$CallFlowNamePrefix - NotInEffect" -FixedSchedule -InformationAction SilentlyContinue -ErrorAction Stop
      }
      #endregion
    }
    #endregion
    #endregion
  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    #region PREPARATION
    $StatusID0 = 'Assembling Auto Attendant Options'
    $ActivityID1 = 'Building Auto Attendant'
    $StatusID1 = 'Preparing Parameters'
    # preparing Splatting Object
    $Parameters = $null

    #region Required Parameters
    $CurrentOperationID1 = 'Name, TimeZone & Language, Voice Responses'
    Write-BetterProgress -Id 1 -Activity $ActivityID1 -Status $StatusID1 -CurrentOperation $CurrentOperationID1 -Step ($private:CountID1++) -Of $private:StepsID1
    # Normalising $Name
    $NameNormalised = Format-StringForUse -InputString $Name -As DisplayName
    Write-Verbose -Message "'$Name' DisplayName normalised to: '$NameNormalised'"
    $Parameters += @{'Name' = $NameNormalised }

    # Preparing Call Flow String (to adhere to 64 Character limit)
    if ($NameNormalised.length -gt 40) {
      Write-Verbose 'Auto Attendant Name is too long and cannot be used for Call Flow Name(s) as-is. Name will be shortened'
      $CallFlowNamePrefix = -join "$NameNormalised"[0..38]
      $RandomString = '{0:d4}' -f $(Get-Random -Minimum 000 -Maximum 9999)
      $CallFlowNamePrefix = $CallFlowNamePrefix + $RandomString
    }
    else {
      $CallFlowNamePrefix = "$NameNormalised"
    }
    Write-Verbose "Auto Attendant Call Flow Name Prefix used: '$CallFlowNamePrefix'"

    # Adding required parameters
    $Parameters += @{'LanguageId' = $Language }
    $Parameters += @{'TimeZoneId' = $TimeZoneId }

    # EnableVoiceResponse
    if ($PSBoundParameters.ContainsKey('EnableVoiceResponse')) {
      # Checking whether Voice Responses are available for the provided Language
      if ($VoiceResponsesSupported) {
        # Using As-Is
        Write-Verbose -Message "'$NameNormalised' EnableVoiceResponse - Voice Responses are supported with Language '$Language' and will be activated (Switch 'EnableVoiceResponse' will be used)"
        $Parameters += @{'EnableVoiceResponse' = $true }
      }
      else {
        Write-Warning -Message "'$NameNormalised' EnableVoiceResponse - Voice Responses are not supported for Language '$Language' and cannot be activated (Switch 'EnableVoiceResponse' will be omitted)"
      }
    }
    #endregion

    #region Operator
    $CurrentOperationID1 = 'Operator'
    Write-BetterProgress -Id 1 -Activity $ActivityID1 -Status $StatusID1 -CurrentOperation $CurrentOperationID1 -Step ($private:CountID1++) -Of $private:StepsID1
    if ($PSBoundParameters.ContainsKey('Operator')) {
      try {
        $OperatorEntity = New-TeamsCallableEntity -Identity "$Operator"
        if ($OperatorEntity) {
          $Parameters += @{'Operator' = $OperatorEntity }
        }
      }
      catch {
        Write-Warning -Message 'Operator - Error creating Call Target - skipped'
      }
    }
    #endregion


    #region Business Hours Call Flow
    $CurrentOperationID1 = 'Business Hours Call Flow - Default Call Flow & Call Flow Option'
    Write-BetterProgress -Id 1 -Activity $ActivityID1 -Status $StatusID1 -CurrentOperation $CurrentOperationID1 -Step ($private:CountID1++) -Of $private:StepsID1
    if ( $DefaultCallFlow ) {
      # Using As-Is
      Write-Information "INFO:    Auto Attendant '$NameNormalised' DefaultCallFlow - Custom Object provided. Over-riding other options (like switch 'BusinessHoursCallFlow')"
      $Parameters += @{'DefaultCallFlow' = $DefaultCallFlow }

    }
    else {
      Write-Verbose -Message "'$NameNormalised' DefaultCallFlow - No Custom Object - Processing 'BusinessHoursCallFlowOption'..."
      $BusinessHoursCallFlowParameters = @{}
      $BusinessHoursCallFlowParameters.Name = "$CallFlowNamePrefix - Business Hours CF"

      #region Processing BusinessHoursCallFlowOption
      switch ($BusinessHoursCallFlowOption) {
        'TransferCallToTarget' {
          Write-Verbose -Message "'$NameNormalised' DefaultCallFlow - Transferring to Target"

          # Process BusinessHoursCallTarget
          try {
            $BusinessHoursCallTargetEntity = New-TeamsCallableEntity "$BusinessHoursCallTarget" -ErrorAction Stop

            # Building Menu Only if Successful
            if ($BusinessHoursCallTargetEntity) {
              $BusinessHoursMenuOptionTransfer = New-CsAutoAttendantMenuOption -Action TransferCallToTarget -CallTarget $BusinessHoursCallTargetEntity -DtmfResponse Automatic
              $BusinessHoursMenuObject = New-CsAutoAttendantMenu -Name 'Business Hours Menu' -MenuOptions @($BusinessHoursMenuOptionTransfer)
              Write-Information "INFO:    Auto Attendant '$NameNormalised' Business Hours Call Flow - Menu (TransferCallToTarget) created"
              break
            }
            else {
              # Reverting to Disconnect
              Write-Warning -Message "'$NameNormalised' DefaultCallFlow - Business Hours Menu not created properly. Reverting to Disconnect"
              $BusinessHoursMenuOptionDefault = New-CsAutoAttendantMenuOption -Action DisconnectCall -DtmfResponse Automatic
              $BusinessHoursMenuObject = New-CsAutoAttendantMenu -Name 'Business Hours Menu' -MenuOptions @($BusinessHoursMenuOptionDefault)
            }
          }
          catch {
            Write-Warning -Message 'BusinessHoursCallTarget - Error creating Call Target - Defaulting to disconnect'
            $BusinessHoursMenuOptionDefault = New-CsAutoAttendantMenuOption -Action DisconnectCall -DtmfResponse Automatic
            $BusinessHoursMenuObject = New-CsAutoAttendantMenu -Name 'Business Hours Menu' -MenuOptions @($BusinessHoursMenuOptionDefault)
          }
        }

        'Menu' {
          Write-Verbose -Message "'$NameNormalised' DefaultCallFlow - Menu"
          if ($PSBoundParameters.ContainsKey('BusinessHoursMenu')) {
            # Menu is passed on as-is - $BusinessHoursMenu is defined and attached
            $BusinessHoursMenuObject = $BusinessHoursMenu
            Write-Information "INFO:    Auto Attendant '$NameNormalised' Business Hours Call Flow - Menu (BusinessHoursMenu) used"
          }
          else {
            # No custom / default Menu is currently created
            # $BusinessHoursMenu is Mandatory. If this is built out, the check against this must also be removed!
          }
        }

        default {
          # Defaulting to Disconnect
          Write-Verbose -Message "'$NameNormalised' DefaultCallFlow not provided or 'Disconnect' - Using default (Disconnect)"
          $BusinessHoursMenuOptionDefault = New-CsAutoAttendantMenuOption -Action DisconnectCall -DtmfResponse Automatic
          $BusinessHoursMenuObject = New-CsAutoAttendantMenu -Name 'Business Hours Menu' -MenuOptions @($BusinessHoursMenuOptionDefault)
        }
      }
      #endregion

      #region BusinessHoursGreeting
      #Adding optional BusinessHoursGreeting
      if ($PSBoundParameters.ContainsKey('BusinessHoursGreeting')) {
        $CurrentOperationID1 = 'Business Hours Call Flow - Greeting'
        Write-BetterProgress -Id 1 -Activity $ActivityID1 -Status $StatusID1 -CurrentOperation $CurrentOperationID1 -Step ($private:CountID1++) -Of $private:StepsID1
        try {
          $BusinessHoursGreetingObject = New-TeamsAutoAttendantPrompt -String "$BusinessHoursGreeting"
          if ($BusinessHoursGreetingObject) {
            Write-Information "INFO:    Auto Attendant '$NameNormalised' Business Hours Call Flow - Greeting created"
            $BusinessHoursCallFlowParameters.Greetings = @($BusinessHoursGreetingObject)
          }
        }
        catch {
          Write-Warning -Message "'$NameNormalised' CallFlow - BusinessHoursCallFlow - Greeting not enumerated. Omitting Greeting"
        }
      }
      #endregion

      #region Building Call Flow
      $CurrentOperationID1 = 'Business Hours Call Flow - Building Call Flow'
      Write-BetterProgress -Id 1 -Activity $ActivityID1 -Status $StatusID1 -CurrentOperation $CurrentOperationID1 -Step ($private:CountID1++) -Of $private:StepsID1
      # Adding Business Hours Call Flow
      $BusinessHoursCallFlowParameters.Menu = $BusinessHoursMenuObject
      $BusinessHoursCallFlow = New-CsAutoAttendantCallFlow @BusinessHoursCallFlowParameters
      Write-Information "INFO:    Auto Attendant '$NameNormalised' Business Hours Call Flow - Call Flow created"
      $Parameters += @{'DefaultCallFlow' = $BusinessHoursCallFlow }
      #endregion
    }
    #endregion

    #region Processing provided CallFlows and CallHandlingAssociations Objects
    if ($PSBoundParameters.ContainsKey('CallFlows')) {
      $CurrentOperationID1 = 'After Hours Call Flow - Objects'
      Write-BetterProgress -Id 1 -Activity $ActivityID1 -Status $StatusID1 -CurrentOperation $CurrentOperationID1 -Step ($private:CountID1++) -Of $private:StepsID1
      # Custom Option provided - Using As-Is
      Write-Information "INFO:    Auto Attendant '$NameNormalised' CallFlow - Custom Object provided. Over-riding other options (like switch 'AfterHoursCallFlow')"
      $Parameters += @{'CallFlows' = @($CallFlows) }
      $Parameters += @{'CallHandlingAssociations' = @($CallHandlingAssociations) }
    }
    #endregion

    # Processing custom Call Flows - creating Call Flow, Schedule & Call Handling Association manually
    #region After Hours Call Flow
    #Initialising Variables for Call Handling Association
    $AfterHoursCallHandlingAssociationParams = @{}
    $AfterHoursCallHandlingAssociationParams.Type = 'AfterHours'

    # Processing CallFlow
    if ($AfterHoursCallFlowOption -and -not $PSBoundParameters.ContainsKey('CallFlows')) {
      $CurrentOperationID1 = 'After Hours Call Flow - Call Flows & Call Flow Option'
      Write-BetterProgress -Id 1 -Activity $ActivityID1 -Status $StatusID1 -CurrentOperation $CurrentOperationID1 -Step ($private:CountID1++) -Of $private:StepsID1
      # Option Selected
      Write-Verbose -Message "'$NameNormalised' CallFlow - No Custom Object - Processing 'AfterHoursCallFlowOption'..."
      $AfterHoursCallFlowParameters = @{}
      $AfterHoursCallFlowParameters.Name = "$CallFlowNamePrefix - After Hours CF"

      #region Processing AfterHoursCallFlowOption
      switch ($AfterHoursCallFlowOption) {
        'TransferCallToTarget' {
          Write-Verbose -Message "'$NameNormalised' CallFlow - Transferring to Target"

          # Process AfterHoursCallTarget
          try {
            $AfterHoursCallTargetEntity = New-TeamsCallableEntity "$AfterHoursCallTarget" -ErrorAction Stop

            # Building Menu Only if Successful
            if ($AfterHoursCallTargetEntity) {
              $AfterHoursMenuOptionTransfer = New-CsAutoAttendantMenuOption -Action TransferCallToTarget -CallTarget $AfterHoursCallTargetEntity -DtmfResponse Automatic
              $AfterHoursMenuObject = New-CsAutoAttendantMenu -Name 'After Hours Menu' -MenuOptions @($AfterHoursMenuOptionTransfer)
              Write-Information "INFO:    Auto Attendant '$NameNormalised' After Hours Call Flow - Menu (TransferCallToTarget) created"
              break
            }
            else {
              # Reverting to Disconnect
              Write-Warning -Message "'$NameNormalised' Call Flow - After Hours Menu not created properly. Reverting to Disconnect"
              $AfterHoursMenuOptionDefault = New-CsAutoAttendantMenuOption -Action DisconnectCall -DtmfResponse Automatic
              $AfterHoursMenuObject = New-CsAutoAttendantMenu -Name 'After Hours Menu' -MenuOptions @($AfterHoursMenuOptionDefault)
            }
          }
          catch {
            Write-Warning -Message 'AfterHoursCallTarget - Error creating Call Target - Defaulting to disconnect'
            $AfterHoursMenuOptionDefault = New-CsAutoAttendantMenuOption -Action DisconnectCall -DtmfResponse Automatic
            $AfterHoursMenuObject = New-CsAutoAttendantMenu -Name 'Business Hours Menu' -MenuOptions @($AfterHoursMenuOptionDefault)
          }
        }

        'Menu' {
          Write-Verbose -Message "'$NameNormalised' CallFlow - AfterHoursCallFlow - Menu"
          if ($PSBoundParameters.ContainsKey('AfterHoursMenu')) {
            # Menu is passed on as-is - $AfterHoursMenu is defined and attached
            $AfterHoursMenuObject = $AfterHoursMenu
            Write-Information "INFO:    Auto Attendant '$NameNormalised' After Hours Call Flow - Menu (BusinessHoursMenu) used"
          }
          else {
            # No custom / default Menu is currently created
            # $AfterHoursMenu is Mandatory. If this is built out, the check against this must also be removed!
          }
        }

        default {
          # Defaulting to Disconnect
          Write-Verbose -Message "'$NameNormalised' CallFlow - AfterHoursCallFlow not provided or Disconnect. Using default (Disconnect)"
          $AfterHoursMenuOptionDefault = New-CsAutoAttendantMenuOption -Action DisconnectCall -DtmfResponse Automatic
          $AfterHoursMenuObject = New-CsAutoAttendantMenu -Name 'Business Hours Menu' -MenuOptions @($AfterHoursMenuOptionDefault)
        }
      }
      #endregion

      #region AfterHoursGreeting
      if ($PSBoundParameters.ContainsKey('AfterHoursGreeting')) {
        $CurrentOperationID1 = 'After Hours Call Flow - Greeting'
        Write-BetterProgress -Id 1 -Activity $ActivityID1 -Status $StatusID1 -CurrentOperation $CurrentOperationID1 -Step ($private:CountID1++) -Of $private:StepsID1
        try {
          $AfterHoursGreetingObject = New-TeamsAutoAttendantPrompt -String "$AfterHoursGreeting"
          if ($AfterHoursGreetingObject) {
            Write-Information "INFO:    Auto Attendant '$NameNormalised' After Hours Call Flow - Greeting created"
            $AfterHoursCallFlowParameters.Greetings = @($AfterHoursGreetingObject)
          }
        }
        catch {
          Write-Warning -Message "'$NameNormalised' CallFlow - AfterHoursCallFlow - Greeting not enumerated. Omitting Greeting"
        }
      }
      #endregion

      #region Building Call Flow
      $CurrentOperationID1 = 'After Hours Call Flow - Building Call Flow'
      Write-BetterProgress -Id 1 -Activity $ActivityID1 -Status $StatusID1 -CurrentOperation $CurrentOperationID1 -Step ($private:CountID1++) -Of $private:StepsID1
      # Adding After Hours Call Flow
      $AfterHoursCallFlowParameters.Menu = $AfterHoursMenuObject
      $AfterHoursCallFlow = New-CsAutoAttendantCallFlow @AfterHoursCallFlowParameters
      Write-Information "INFO:    Auto Attendant '$NameNormalised' After Hours Call Flow - Call Flow created"
      if ($Parameters.ContainsKey('CallFlows')) {
        $Parameters.CallFlows += $AfterHoursCallFlow
        #$Parameters.CallFlows.Add($AfterHoursCallFlow)
      }
      else {
        $Parameters += @{'CallFlows' = @($AfterHoursCallFlow) }
      }

      # Adding Call Flow ID(s) to Call handling Associations
      #$AfterHoursCallHandlingAssociationParams.CallFlowId = $AfterHoursCallFlow.Id # This works, but want to try whether arraying works too
      $AfterHoursCallHandlingAssociationParams.CallFlowId += $AfterHoursCallFlow.Id
      #endregion

      #region After Hours Schedule & Call Handling Association
      $CurrentOperationID1 = 'Schedule & Call Handling Association'
      Write-BetterProgress -Id 1 -Activity $ActivityID1 -Status $StatusID1 -CurrentOperation $CurrentOperationID1 -Step ($private:CountID1++) -Of $private:StepsID1
      $AfterHoursCallHandlingAssociationParams.ScheduleId = $Schedule.Id
      $AfterHoursCallHandlingAssociation = New-CsAutoAttendantCallHandlingAssociation @AfterHoursCallHandlingAssociationParams
      Write-Information "INFO:    Auto Attendant '$NameNormalised' After Hours Call Flow - Call Handling Association created with Schedule"
      if ($Parameters.ContainsKey('CallHandlingAssociation')) {
        $Parameters.CallHandlingAssociation += $AfterHoursCallHandlingAssociation
        #$Parameters.CallHandlingAssociation.Add($AfterHoursCallHandlingAssociation)
      }
      else {
        $Parameters += @{'CallHandlingAssociation' = @($AfterHoursCallHandlingAssociation) }
      }
      #endregion
    }
    #endregion

    #region HolidaySet Call Flow
    #Initialising Variables for Call Handling Association
    $HolidaySetCallHandlingAssociationParams = @{}
    $HolidaySetCallHandlingAssociationParams.Type = 'Holiday' # HolidaySet does not work anymore!?

    # Processing HolidaySetsCallFlowOption
    if ($HolidaySetCallFlowOption -and -not $PSBoundParameters.ContainsKey('CallFlows')) {
      $CurrentOperationID1 = 'Holiday Call Flow - Call Flows & Call Flow Option'
      Write-BetterProgress -Id 1 -Activity $ActivityID1 -Status $StatusID1 -CurrentOperation $CurrentOperationID1 -Step ($private:CountID1++) -Of $private:StepsID1
      # Option Selected
      Write-Verbose -Message "'$NameNormalised' CallFlow - No Custom Object - Processing 'HolidaySetCallFlowOption'..."
      $HolidaySetCallFlowParameters = @{}
      $HolidaySetCallFlowParameters.Name = "$CallFlowNamePrefix - Holiday CF"

      #region Processing HolidaySetCallFlowOption
      switch ($HolidaySetCallFlowOption) {
        'TransferCallToTarget' {
          Write-Verbose -Message "'$NameNormalised' CallFlow - Transferring to Target"

          # Process HolidaySetCallTarget
          try {
            $HolidaySetCallTargetEntity = New-TeamsCallableEntity "$HolidaySetCallTarget" -ErrorAction Stop

            # Building Menu Only if Successful
            if ($HolidaySetCallTargetEntity) {
              $HolidaySetMenuOptionTransfer = New-CsAutoAttendantMenuOption -Action TransferCallToTarget -CallTarget $HolidaySetCallTargetEntity -DtmfResponse Automatic
              $HolidaySetMenuObject = New-CsAutoAttendantMenu -Name 'Holiday Set Menu' -MenuOptions @($HolidaySetMenuOptionTransfer)
              Write-Information "INFO:    Auto Attendant '$NameNormalised' Holiday Set Call Flow - Menu (TransferCallToTarget) created"
              break
            }
            else {
              # Reverting to Disconnect
              Write-Warning -Message "'$NameNormalised' Call Flow - Holiday Set Menu not created properly. Reverting to Disconnect"
              $HolidaySetMenuOptionDefault = New-CsAutoAttendantMenuOption -Action DisconnectCall -DtmfResponse Automatic
              $HolidaySetMenuObject = New-CsAutoAttendantMenu -Name 'Holiday Set Menu' -MenuOptions @($HolidaySetMenuOptionDefault)
            }
          }
          catch {
            Write-Warning -Message 'HolidaySetCallTarget - Error creating Call Target - Defaulting to disconnect'
            $HolidaySetMenuOptionDefault = New-CsAutoAttendantMenuOption -Action DisconnectCall -DtmfResponse Automatic
            $HolidaySetMenuObject = New-CsAutoAttendantMenu -Name 'Business Hours Menu' -MenuOptions @($HolidaySetMenuOptionDefault)
          }
        }

        'Menu' {
          Write-Verbose -Message "'$NameNormalised' CallFlow - HolidaySetCallFlow - Menu"
          if ($PSBoundParameters.ContainsKey('HolidaySetMenu')) {
            # Menu is passed on as-is - $HolidaySetMenu is defined and attached
            $HolidaySetMenuObject = $HolidaySetMenu
            Write-Information "INFO:    Auto Attendant '$NameNormalised' Holiday Set Call Flow - Menu (BusinessHoursMenu) used"
          }
          else {
            # No custom / default Menu is currently created
            # $HolidaySetMenu is Mandatory. If this is built out, the check against this must also be removed!
          }
        }

        default {
          # Defaulting to Disconnect
          Write-Verbose -Message "'$NameNormalised' CallFlow - HolidaySetCallFlow not provided or Disconnect. Using default (Disconnect)"
          $HolidaySetMenuOptionDefault = New-CsAutoAttendantMenuOption -Action DisconnectCall -DtmfResponse Automatic
          $HolidaySetMenuObject = New-CsAutoAttendantMenu -Name 'Business Hours Menu' -MenuOptions @($HolidaySetMenuOptionDefault)
        }
      }
      #endregion

      #region HolidaySetGreeting
      if ($PSBoundParameters.ContainsKey('HolidaySetGreeting')) {
        $CurrentOperationID1 = 'Holiday Call Flow - Greeting'
        Write-BetterProgress -Id 1 -Activity $ActivityID1 -Status $StatusID1 -CurrentOperation $CurrentOperationID1 -Step ($private:CountID1++) -Of $private:StepsID1
        try {
          $HolidaySetGreetingObject = New-TeamsAutoAttendantPrompt -String "$HolidaySetGreeting"
          if ($HolidaySetGreetingObject) {
            Write-Information "INFO:    Auto Attendant '$NameNormalised' Holiday Set Call Flow - Greeting created"
            $HolidaySetCallFlowParameters.Greetings = @($HolidaySetGreetingObject)
          }
        }
        catch {
          Write-Warning -Message "'$NameNormalised' CallFlow - HolidaySetCallFlow - Greeting not enumerated. Omitting Greeting"
        }
      }
      #endregion

      #region Building Call Flow
      $CurrentOperationID1 = 'Holiday Call Flow - Building Call Flow'
      Write-BetterProgress -Id 1 -Activity $ActivityID1 -Status $StatusID1 -CurrentOperation $CurrentOperationID1 -Step ($private:CountID1++) -Of $private:StepsID1
      # Adding Holiday Set Call Flow
      $HolidaySetCallFlowParameters.Menu = $HolidaySetMenuObject
      $HolidaySetCallFlow = New-CsAutoAttendantCallFlow @HolidaySetCallFlowParameters
      Write-Information "INFO:    Auto Attendant '$NameNormalised' Holiday Set Call Flow - Call Flow created"
      if ($Parameters.ContainsKey('CallFlows')) {
        $Parameters.CallFlows += $HolidaySetCallFlow
        #$Parameters.CallFlows.Add($HolidaySetCallFlow)
      }
      else {
        $Parameters += @{'CallFlows' = @($HolidaySetCallFlow) }
      }

      # Adding Call Flow ID(s) to Call handling Associations
      #$HolidaySetCallHandlingAssociationParams.CallFlowId = $HolidaySetCallFlow.Id # This works, but want to try whether arraying works too
      $HolidaySetCallHandlingAssociationParams.CallFlowId += $HolidaySetCallFlow.Id
      #endregion

      #region Holiday Set Schedule & Call Handling Association
      $CurrentOperationID1 = 'Holiday Call Flow - Schedule & Call Handling Association'
      Write-BetterProgress -Id 1 -Activity $ActivityID1 -Status $StatusID1 -CurrentOperation $CurrentOperationID1 -Step ($private:CountID1++) -Of $private:StepsID1
      $HolidaySetCallHandlingAssociationParams.ScheduleId = $HolidaySchedule.Id
      $HolidaySetCallHandlingAssociation = New-CsAutoAttendantCallHandlingAssociation @HolidaySetCallHandlingAssociationParams
      Write-Information "INFO:    Auto Attendant '$NameNormalised' Holiday Set Call Flow - Call Handling Association created with Holiday Schedule"
      if ($Parameters.ContainsKey('CallHandlingAssociation')) {
        $Parameters.CallHandlingAssociation += $HolidaySetCallHandlingAssociation
        #$Parameters.CallHandlingAssociation.Add($HolidaySetCallHandlingAssociation)
      }
      else {
        $Parameters += @{'CallHandlingAssociation' = @($HolidaySetCallHandlingAssociation) }
      }
      #endregion
    }
    #endregion


    #region Inclusion and Exclusion Scope
    $CurrentOperationID1 = 'Dial Scopes - Inclusion & Exclusion Scope'
    Write-BetterProgress -Id 1 -Activity $ActivityID1 -Status $StatusID1 -CurrentOperation $CurrentOperationID1 -Step ($private:CountID1++) -Of $private:StepsID1
    # Inclusion Scope
    if ($PSBoundParameters.ContainsKey('InclusionScope')) {
      Write-Verbose -Message "'$NameNormalised' InclusionScope provided. Using as-is"
      $Parameters += @{'InclusionScope' = $InclusionScope }

    }
    else {
      #Scope is optional
      Write-Verbose -Message "'$NameNormalised' InclusionScope not defined. To create one, please run New-TeamsAutoAttendantDialScope or New-CsAutoAttendantDialScope"
    }

    # Exclusion Scope
    if ($PSBoundParameters.ContainsKey('ExclusionScope')) {
      Write-Verbose -Message "'$NameNormalised' ExclusionScope provided. Using as-is"
      $Parameters += @{'ExclusionScope' = $ExclusionScope }

    }
    else {
      #Scope is optional
      Write-Verbose -Message "'$NameNormalised' ExclusionScope not defined. To create one, please run New-TeamsAutoAttendantDialScope or New-CsAutoAttendantDialScope"
    }
    #endregion

    #region Common parameters
    $Parameters += @{'WarningAction' = 'Continue' }
    $Parameters += @{'ErrorAction' = 'Stop' }
    #endregion

    Write-Progress -Id 1 -Activity $ActivityID1 -Completed
    #endregion


    #region ACTION
    Write-Verbose -Message '[PROCESS] Creating Auto Attendant'
    if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
      "  Function: $($MyInvocation.MyCommand.Name) - Parameters:", ($Parameters | Format-Table -AutoSize | Out-String).Trim() | Write-Debug
    }

    # Create AA (New-CsAutoAttendant)
    $StatusID0 = 'Creating Auto Attendant'
    $CurrentOperationID0 = "'$NameNormalised'"
    Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
    if ($PSCmdlet.ShouldProcess("$NameNormalised", 'New-CsAutoAttendant')) {
      try {
        # Create the Auto Attendant with all enumerated Parameters passed through splatting
        $null = (New-CsAutoAttendant @Parameters)
        Write-Information "INFO:    Auto Attendant '$NameNormalised' created with all Parameters"
      }
      catch {
        Write-Error -Message "Error creating the Auto Attendant: $($_.Exception.Message)" -Category InvalidResult
        return
      }
    }
    else {
      return
    }
    #endregion


    #region OUTPUT
    $StatusID0 = 'Validation'
    $CurrentOperationID0 = 'Querying Object'
    Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
    $AAFinal = Get-TeamsAutoAttendant -Name "$NameNormalised" -WarningAction SilentlyContinue
    Write-Progress -Id 0 -Activity $ActivityID0 -Completed
    Write-Output $AAFinal
    #endregion

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"

  } #end
} #New-TeamsAutoAttendant
