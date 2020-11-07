# Module:   TeamsFunctions
# Function: AutoAttendant
# Author:		David Eberhardt
# Updated:  01-OCT-2020
# Status:   BETA

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
  .PARAMETER OperatorType
    Optional. Requires Operator. Type of the CallableEntity (User, ApplicationEndpoint, ExternalPstn, SharedVoicemail)
  .PARAMETER Operator
    Optional. Requires OperatorType. Creates a Callable entity of the OperatorType specified.
    Expected are UserPrincipalName (User, ApplicationEndPoint), a TelURI (ExternalPstn), an Office 365 Group Name (SharedVoicemail)
  .PARAMETER BusinessHoursGreeting
    Optional. Creates a Greeting for the Default Call Flow (during business hours) utilising New-TeamsAutoAttendantPrompt
    A supported Audio File or a text string that is parsed by the text-to-voice engine in the Language specified
    The last 4 digits will determine the type. For an AudioFile they are expected to be the file extension: '.wav', '.wma' or 'mp3'
  .PARAMETER BusinessHoursCallFlowOption
    Optional. Disconnect, TransferCallToTarget, Menu. Default is Disconnect.
    TransferCallToTarget requires BusinessHoursCallTarget and BusinessHoursCallTargetType. Menu requires BusinessHoursMenu
  .PARAMETER BusinessHoursCallTargetType
    Optional. Requires BusinessHoursCallFlowOption to be TransferCallToTarget and a BusinessHoursCallTarget
    Type of the CallableEntity (User, ApplicationEndpoint, ExternalPstn, SharedVoicemail)
  .PARAMETER BusinessHoursCallTarget
    Optional. Requires BusinessHoursCallFlowOption to be TransferCallToTarget and a BusinessHoursCallTargetType
    Creates a Callable entity of the BusinessHoursCallTargetType specified.
    Expected are UserPrincipalName (User, ApplicationEndPoint), a TelURI (ExternalPstn), an Office 365 Group Name (SharedVoicemail)
  .PARAMETER BusinessHoursMenu
    Optional. Requires BusinessHoursCallFlowOption to be Menu and a BusinessHoursCallTarget
  .PARAMETER AfterHoursGreeting
    Optional. Creates a Greeting for the After Hours Call Flow utilising New-TeamsAutoAttendantPrompt
    A supported Audio File or a text string that is parsed by the text-to-voice engine in the Language specified
    The last 4 digits will determine the type. For an AudioFile they are expected to be the file extension: '.wav', '.wma' or 'mp3'
  .PARAMETER AfterHoursCallFlowOption
    Optional. Disconnect, TransferCallToTarget, Menu. Default is Disconnect.
    TransferCallToTarget requires AfterHoursCallTarget and AfterHoursCallTargetType. Menu requires AfterHoursMenu
  .PARAMETER AfterHoursCallTargetType
    Optional. Requires AfterHoursCallFlowOption to be TransferCallToTarget and a AfterHoursCallTarget
    Type of the CallableEntity (User, ApplicationEndpoint, ExternalPstn, SharedVoicemail)
  .PARAMETER AfterHoursCallTarget
    Optional. Requires AfterHoursCallFlowOption to be TransferCallToTarget and a AfterHoursCallTargetType
    Creates a Callable entity of the AfterHoursCallTargetType specified.
    Expected are UserPrincipalName (User, ApplicationEndPoint), a TelURI (ExternalPstn), an Office 365 Group Name (SharedVoicemail)
  .PARAMETER AfterHoursMenu
    Optional. Requires AfterHoursCallFlowOption to be Menu and a AfterHoursCallTarget

  .PARAMETER Silent
		Optional. Does not display output. Use for Bulk provisioning only.
		Will return the Output object, but not display any output on Screen.
  .PARAMETER Force
    Suppresses confirmation prompt to enable Users for Enterprise Voice, if Users are specified
    Currently no other impact
	.EXAMPLE
		New-TeamsAutoAttendant -Name "My Auto Attendant"
    Creates a new Auto Attendant "My Auto Attendant" with Defaults
    TimeZone is UTC, Language is en-US and Schedule is Mon-Fri 9to5.
    Business hours and After Hours action is Disconnect
	.EXAMPLE
		New-TeamsAutoAttendant -Name "My Auto Attendant" -TimeZone UTC-05:00 -LanguageId pt-BR -EnableVoiceResponse
    Creates a new Auto Attendant "My Auto Attendant" and sets the TimeZone to UTC-5 and the language to Portuguese (Brazil)
    The default Schedule of Mon-Fri 9to5 will be applied. Also enables VoiceResponses
	.EXAMPLE
		New-TeamsAutoAttendant -Name "My Auto Attendant" -Operator "tel:+1555123456" -OperatorType ExternalPstn -Schedule $ScheduleId
    Creates a new Auto Attendant "My Auto Attendant" with default TimeZone and Language, but defines an Operator as a Callable Entity (Forward to Pstn)
    Applies a Custom After hours Schedule Object created with New-TeamsAutoAttendantSchedule or New-CsAutoAttendantSchedule respectively.
	.EXAMPLE
    New-TeamsAutoAttendant -Name "My Auto Attendant" -BusinessHoursGreeting "Welcome to Contoso" -BusinessHoursCallFlowOption TransferCallToTarget -BusinessHoursCallTargetType ApplicationEndpoint -BusinessHoursCallTarget $UPN
    Creates a new Auto Attendant "My Auto Attendant" with defaults, but defines a Text-to-Voice Greeting, then forwards the Call to an
    ApplicationEndpoint (Call Queue or AutoAttendant) with the provided UserPrincipalname as a string in the Variable $UPN
    This example is equally applicable to AfterHours.
	.EXAMPLE
		New-TeamsAutoAttendant -Name "My Auto Attendant" -DefaultCallFlow $DefaultCallFlow -CallFlows $CallFlows -Schedule $Schedule -InclusionScope $InGroups -ExclusionScope $OutGroups
    Creates a new Auto Attendant "My Auto Attendant" and passes through all objects provided. In this example, provided Objects are
    passed on through tto New-CsAutoAttendant and override other respective Parmeters provided:
    - A DefaultCallFlow Object is passed on which overrides all "-BusinessHours"-Parmeters
    - One or more CallFlows Objects are passed on which override all "-AfterHours"-Parameters
    - One or more CallHandlingAssociation Objects are passed on which override all "-AfterHours"-Parameters
    - A Schedule is passed on which overrides the default Schedule of Mon-Fri 9-5
    - An InclusionScope and an ExclusionScope are defined. These are passed on as-is
		All other values, like Language and TimeZone are defined with their defaults and can still be defined with the Objects.
  .INPUTS
    System.String
  .OUTPUTS
    System.Object
	.NOTES
		Currently in Testing
	.FUNCTIONALITY
		Creates a Auto Attendant with custom settings and friendly names as input
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

  [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
  [Alias('New-TeamsAA')]
  [OutputType([System.Object])]
  param(
    [Parameter(ParametersetName = "Default", Mandatory = $true, ValueFromPipeline, HelpMessage = "Name of the Auto Attendant")]
    [Parameter(ParametersetName = "Operator", Mandatory = $true, HelpMessage = "Name of the Auto Attendant")]
    [string]$Name,

    [Parameter(HelpMessage = "TimeZone Identifier")]
    [ValidateSet("UTC-12:00", "UTC-11:00", "UTC-10:00", "UTC-09:00", "UTC-08:00", "UTC-07:00", "UTC-06:00", "UTC-05:00", "UTC-04:30", "UTC-04:00", "UTC-03:30", "UTC-03:00", "UTC-02:00", "UTC-01:00", "UTC", "UTC+01:00", "UTC+02:00", "UTC+03:00", "UTC+03:30", "UTC+04:00", "UTC+04:30", "UTC+05:00", "UTC+05:30", "UTC+05:45", "UTC+06:00", "UTC+06:30", "UTC+07:00", "UTC+08:00", "UTC+09:00", "UTC+09:30", "UTC+10:00", "UTC+11:00", "UTC+12:00", "UTC+13:00", "UTC+14:00")]
    [string]$TimeZone = "UTC",

    [Parameter(HelpMessage = "Language Identifier from Get-CsAutoAttendantSupportedLanguage.")]
    [ValidateScript( { $_ -in (Get-CsAutoAttendantSupportedLanguage).Id })]
    [string]$LanguageId = "en-US",

    [Parameter(ParametersetName = "Operator", Mandatory = $true, HelpMessage = "Type of target")]
    [ValidateSet('User', 'ExternalPstn', 'SharedVoicemail', 'ApplicationEndpoint')]
    [string]$OperatorType,

    [Parameter(ParametersetName = "Operator", Mandatory = $false, HelpMessage = "Target Name of the Operator")]
    [string]$Operator,

    [Parameter(HelpMessage = "Business Hours Greeting - Text String or Recording")]
    [string]$BusinessHoursGreeting,

    [Parameter(HelpMessage = "Business Hours Call Flow - Default options")]
    [ValidateSet("Disconnect", "TransferCallToTarget", "Menu")]
    [string]$BusinessHoursCallFlowOption,

    [Parameter(HelpMessage = "Business Hours Call Target - BusinessHoursCallFlowOption = TransferCallToTarget")]
    [ValidateSet('User', 'ExternalPstn', 'SharedVoicemail', 'ApplicationEndpoint')]
    [string]$BusinessHoursCallTargetType,

    [Parameter(HelpMessage = "Business Hours Call Target - BusinessHoursCallFlowOption = TransferCallToTarget")]
    [string]$BusinessHoursCallTarget,

    [Parameter(HelpMessage = "Business Hours Call Target - BusinessHoursCallFlowOption = Menu")]
    [object]$BusinessHoursMenu,

    [Parameter(HelpMessage = "After Hours Greeting - Text String or Recording")]
    [string]$AfterHoursGreeting,

    [Parameter(HelpMessage = "After Hours Call Flow - Default options")]
    [ValidateSet("Disconnect", "TransferCallToTarget", "Menu")]
    [string]$AfterHoursCallFlowOption,

    [Parameter(HelpMessage = "After Hours Call Target - AfterHoursCallFlowOption = TransferCallToTarget")]
    [ValidateSet('User', 'ExternalPstn', 'SharedVoicemail', 'ApplicationEndpoint')]
    [string]$AfterHoursCallTargetType,

    [Parameter(HelpMessage = "After Hours Call Target - AfterHoursCallFlowOption = TransferCallToTarget")]
    [string]$AfterHoursCallTarget,

    [Parameter(HelpMessage = "After Hours Call Target - AfterHoursCallFlowOption = Menu")]
    [object]$AfterHoursMenu,


    #Default Parameters of New-CsCallQueue for Pass-through application
    [Parameter(HelpMessage = "Voice Responses")]
    [switch]$EnableVoiceResponse,

    [Parameter(HelpMessage = "Default Call Flow")]
    [object]$DefaultCallFlow,

    [Parameter(HelpMessage = "Call Flows")]
    [object]$CallFlows,

    [Parameter(HelpMessage = "CallHandlingAssociations")]
    [object]$CallHandlingAssociations,

    [Parameter(HelpMessage = "Schedule")]
    [object]$Schedule,

    [Parameter(HelpMessage = "Groups defining the Inclusion Scope")]
    [object]$InclusionScope,

    [Parameter(HelpMessage = "Groups defining the Exclusion Scope")]
    [object]$ExclusionScope,


    # Additional Switches
    [Parameter(HelpMessage = "No output is written to the screen, but Object returned for processing")]
    [switch]$Silent,

    [Parameter(HelpMessage = "Suppresses confirmation prompt to enable Users for Enterprise Voice, if Users are specified")]
    [switch]$Force

  ) #param

  begin {
    # Caveat - Script in Development
    $VerbosePreference = "Continue"
    $DebugPreference = "Continue"
    Show-FunctionStatus -Level BETA
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

    # Language has to be normalised as the Id is case sensitive
    if ($PSBoundParameters.ContainsKey('LanguageId')) {
      $Language = $($LanguageId.Split("-")[0]).ToLower() + "-" + $($LanguageId.Split("-")[1]).ToUpper()
      Write-Verbose "LanguageId '$LanguageId' normalised to '$Language'"
      $VoiceResponsesSupported = (Get-CsAutoAttendantSupportedLanguage -Id $Language).VoiceResponseSupported
    }
    else {
      $Language = $LanguageId
      <# Language has been granted a default value
      # Checking for Parameters which would require LanguageId
      Write-Error "Parameter LanguageId is required and missing." -ErrorAction Stop -RecommendedAction "Add Parameter LanguageId"
      return
      #>
    }

    # TimeZoneId
    if ($TimeZone -eq "UTC") {
      $TimeZoneId = $TimeZone
    }
    else {
      Write-Verbose -Message "TimeZone - Parsing TimeZone '$TimeZone'"
      $TimeZoneId = (Get-CsAutoAttendantSupportedTimeZone | Where-Object DisplayName -Like "($TimeZone)*" | Select-Object -First 1).Id
      Write-Verbose -Message "TimeZone - Found! Using: '$TimeZoneId'"
      Write-Verbose -Message "TimeZone - This is an approximate match, please validate in Admin Center and select a more precise match if needed!" -Verbose
    }

    #region Parameter validation
    #region Operator & OperatorType
    if ($PSBoundParameters.ContainsKey('OperatorType') -and -not $PSBoundParameters.ContainsKey('Operator')) {
      Write-Error -Message "OperatorType requires Parameter Operator" -ErrorAction Stop
    }

    if ($PSBoundParameters.ContainsKey('Operator') -and -not $PSBoundParameters.ContainsKey('OperatorType')) {
      Write-Error -Message "Operator requires Parameter OperatorType" -ErrorAction Stop
    }
    #endregion

    #region BusinessHours
    #region Default Call Flow
    if ($PSBoundParameters.ContainsKey('DefaultCallFlow')) {
      Write-Verbose -Message "DefaultCallFlow - Overriding all BusinessHours-Parameters" -Verbose

      if ($PSBoundParameters.ContainsKey('BusinessHoursGreeting')) {
        Write-Verbose -Message "DefaultCallFlow - Removing 'BusinessHoursGreeting'"
        $PSBoundParameters.Remove('BusinessHoursGreeting')
      }

      if ($PSBoundParameters.ContainsKey('BusinessHoursCallFlowOption')) {
        Write-Verbose -Message "DefaultCallFlow - Removing 'BusinessHoursCallFlowOption'"
        $PSBoundParameters.Remove('BusinessHoursCallFlowOption')
      }

      if ($PSBoundParameters.ContainsKey('BusinessHoursCallTargetType')) {
        Write-Verbose -Message "DefaultCallFlow - Removing 'BusinessHoursCallTargetType'"
        $PSBoundParameters.Remove('BusinessHoursCallTargetType')
      }

      if ($PSBoundParameters.ContainsKey('BusinessHoursCallTarget')) {
        Write-Verbose -Message "DefaultCallFlow - Removing 'BusinessHoursCallTarget'"
        $PSBoundParameters.Remove('BusinessHoursCallTarget')
      }

      # Testing provided Object Type
      #CHECK application! Deserialized.Microsoft.Rtc.Management.Hosted.OAA.Models.CallFlow
      if (($DefaultCallFlow | Get-Member | Select-Object TypeName -First 1).TypeName -ne "Deserialized.Microsoft.Rtc.Management.Hosted.OAA.Models.CallFlow") {
        Write-Error "DefaultCallFlow - Type is not of 'Microsoft.Rtc.Management.Hosted.OAA.Models.CallFlow'. Please provide a Call Flow Object" -Category InvalidType -ErrorAction Stop
      }
    }
    #endregion

    #region BusinessHours Parameters
    if (-not $PSBoundParameters.ContainsKey('BusinessHoursCallFlowOption')) {
      Write-Verbose -Message "BusinessHoursCallFlowOption - Parameter not specified. Defaulting to 'Disconnect' No other 'BusinessHours'-Parameters are processed!"
      $BusinessHoursCallFlowOption = "Disconnect"
    }
    elseif ($BusinessHoursCallFlowOption -eq "TransferCallToTarget") {
      # Must contain Target and TargetType
      if (-not $PSBoundParameters.ContainsKey('BusinessHoursCallTarget')) {
        Write-Error -Message "BusinessHoursCallFlowOption (TransferCallToTarget) - Parameter 'BusinessHoursCallTarget' missing" -ErrorAction Stop
      }
      if (-not $PSBoundParameters.ContainsKey('BusinessHoursCallTargetType')) {
        Write-Error -Message "BusinessHoursCallFlowOption (TransferCallToTarget) - Parameter 'BusinessHoursCallTargetType' missing" -ErrorAction Stop
        Write-Verbose -Message "BusinessHoursMenu - Removing 'BusinessHoursCallTargetType'"
      }

      # Must not contain a Menu
      if ($PSBoundParameters.ContainsKey('BusinessHoursMenu')) {
        Write-Warning -Message "BusinessHoursCallFlowOption (TransferCallToTarget) - Parameter BusinessHoursMenu cannot be used and will be omitted!"
        $PSBoundParameters.Remove('BusinessHoursMenu')
      }
    }
    elseif ($BusinessHoursCallFlowOption -eq "Menu") {
      # Must contain a Menu
      if (-not $PSBoundParameters.ContainsKey('BusinessHoursMenu')) {
        Write-Error -Message "BusinessHoursCallFlowOption (Menu) - BusinessHoursMenu missing" -ErrorAction Stop
      }
      else {
        # Testing provided Object Type
        #CHECK application! Deserialized.Microsoft.Rtc.Management.Hosted.OAA.Models.Menu
        if (($BusinessHoursMenu | Get-Member | Select-Object -First 1).TypeName -ne "Deserialized.Microsoft.Rtc.Management.Hosted.OAA.Models.Menu") {
          Write-Error -Message "BusinessHoursCallFlowOption (Menu) - BusinessHoursMenu not of the Type 'Microsoft.Rtc.Management.Hosted.OAA.Models.Menu'" -Category InvalidType -ErrorAction Stop
        }
      }

      # Must not contain Target and TargetType
      if ($PSBoundParameters.ContainsKey('BusinessHoursCallTarget')) {
        Write-Warning -Message "BusinessHoursCallFlowOption (Menu) - Parameter 'BusinessHoursCallTarget' cannot be used and will be omitted!"
      }
      if ($PSBoundParameters.ContainsKey('BusinessHoursCallTargetType')) {
        Write-Warning -Message "BusinessHoursCallFlowOption (Menu) - Parameter 'BusinessHoursCallTargetType' cannot be used and will be omitted!"
      }

    }
    #endregion
    #endregion

    #region AfterHours
    #region Call Flows & Call Handling Associations
    if ($PSBoundParameters.ContainsKey('CallFlows') -or $PSBoundParameters.ContainsKey('CallHandlingAssociation')) {
      Write-Verbose -Message "CallFlows - Overriding all AfterHours-Parameters" -Verbose
      if ($PSBoundParameters.ContainsKey('AfterHoursGreeting')) {
        Write-Verbose -Message "CallFlows or CallHandlingAssociation - Removing 'AfterHoursGreeting'"
        $PSBoundParameters.Remove('AfterHoursGreeting')
      }

      if ($PSBoundParameters.ContainsKey('AfterHoursCallFlowOption')) {
        Write-Verbose -Message "CallFlows or CallHandlingAssociation - Removing 'AfterHoursCallFlowOption'"
        $PSBoundParameters.Remove('AfterHoursCallFlowOption')
      }

      if ($PSBoundParameters.ContainsKey('AfterHoursCallTargetType')) {
        Write-Verbose -Message "CallFlows or CallHandlingAssociation - Removing 'AfterHoursCallTargetType'"
        $PSBoundParameters.Remove('AfterHoursCallTargetType')
      }

      if ($PSBoundParameters.ContainsKey('AfterHoursCallTarget')) {
        Write-Verbose -Message "CallFlows or CallHandlingAssociation - Removing 'AfterHoursCallTarget'"
        $PSBoundParameters.Remove('AfterHoursCallTarget')
      }

      if ($PSBoundParameters.ContainsKey('CallFlows') -and -not $PSBoundParameters.ContainsKey('CallHandlingAssociation')) {
        Write-Error -Message "CallFlows requires Parameter CallHandlingAssociation" -ErrorAction Stop
      }

      if ($PSBoundParameters.ContainsKey('CallHandlingAssociation') -and -not $PSBoundParameters.ContainsKey('CallFlows')) {
        Write-Error -Message "CallHandlingAssociation requires Parameter CallFlows" -ErrorAction Stop
      }

      # Testing provided Object Type
      #CHECK application! Deserialized.Microsoft.Rtc.Management.Hosted.OAA.Models.CallFlow (Array!)
      foreach ($Flow in $CallFlows) {
        if (($Flow | Get-Member | Select-Object -First 1).TypeName -ne "Deserialized.Microsoft.Rtc.Management.Hosted.OAA.Models.CallFlow") {
          Write-Error -Message "CallFlows - '$($Flow.Name)' -Object not of the Type 'Microsoft.Rtc.Management.Hosted.OAA.Models.CallFlow'" -Category InvalidType -ErrorAction Stop
        }
      }

      # Testing provided Object Type
      #CHECK application! Deserialized.Microsoft.Rtc.Management.Hosted.OAA.Models.CallHandlingAssociation (Array!)
      foreach ($CHA in $CallHandlingAssociations) {
        if (($CHA | Get-Member | Select-Object -First 1).TypeName -ne "Deserialized.Microsoft.Rtc.Management.Hosted.OAA.Models.CallHandlingAssociation") {
          Write-Error -Message "CallHandlingAssociations - '$($CHA.Name)' -Object not of the Type 'Microsoft.Rtc.Management.Hosted.OAA.Models.CallHandlingAssociation'" -Category InvalidType -ErrorAction Stop
        }
      }
    }
    #endregion

    #region AfterHours Parameters
    if (-not $PSBoundParameters.ContainsKey('AfterHoursCallFlowOption')) {
      Write-Verbose -Message "AfterHoursCallFlowOption - Parameter not specified. Defaulting to 'Disconnect' No other 'BusinessHours'-Parameters are processed!"
      $AfterHoursCallFlowOption = "Disconnect"
    }
    elseif ($AfterHoursCallFlowOption -eq "TransferCallToTarget") {
      # Must contain Target and TargetType
      if (-not $PSBoundParameters.ContainsKey('AfterHoursCallTarget')) {
        Write-Error -Message "AfterHoursCallFlowOption (TransferCallToTarget) - Parameter 'AfterHoursCallTarget' missing" -ErrorAction Stop
      }
      if (-not $PSBoundParameters.ContainsKey('AfterHoursCallTargetType')) {
        Write-Error -Message "AfterHoursCallFlowOption (TransferCallToTarget) - Parameter 'AfterHoursCallTargetType' missing" -ErrorAction Stop
        Write-Verbose -Message "AfterHoursMenu - Removing 'AfterHoursCallTargetType'"
      }

      # Must not contain a Menu
      if ($PSBoundParameters.ContainsKey('AfterHoursMenu')) {
        Write-Warning -Message "AfterHoursCallFlowOption (TransferCallToTarget) - Parameter AfterHoursMenu cannot be used and will be omitted!"
        $PSBoundParameters.Remove('AfterHoursMenu')
      }
    }
    elseif ($AfterHoursCallFlowOption -eq "Menu") {
      # Must contain a Menu
      if (-not $PSBoundParameters.ContainsKey('AfterHoursMenu')) {
        Write-Error -Message "AfterHoursCallFlowOption (Menu) - AfterHoursMenu missing" -ErrorAction Stop
      }
      else {
        #CHECK application! Deserialized.Microsoft.Rtc.Management.Hosted.OAA.Models.Menu
        if (($AfterHoursMenu | Get-Member | Select-Object -First 1).TypeName -ne "Deserialized.Microsoft.Rtc.Management.Hosted.OAA.Models.Menu") {
          Write-Error -Message "AfterHoursCallFlowOption (Menu) - AfterHoursMenu not of the Type 'Microsoft.Rtc.Management.Hosted.OAA.Models.Menu'" -Category InvalidType -ErrorAction Stop
        }
      }

      # Must not contain Target and TargetType
      if ($PSBoundParameters.ContainsKey('AfterHoursCallTarget')) {
        Write-Warning -Message "AfterHoursCallFlowOption (Menu) - Parameter 'AfterHoursCallTarget' cannot be used and will be omitted!"
      }
      if ($PSBoundParameters.ContainsKey('AfterHoursCallTargetType')) {
        Write-Warning -Message "AfterHoursCallFlowOption (Menu) - Parameter 'AfterHoursCallTargetType' cannot be used and will be omitted!"
      }

    }
    #endregion


    #region Schedule
    if ($PSBoundParameters.ContainsKey('Schedule')) {
      Write-Verbose -Message "Schedule - Custom Schedule overrides default Schedule (Mon-Fri 9-5)" -Verbose
      #CHECK application! Deserialized.Microsoft.Rtc.Management.Hosted.OAA.Models.Schedule
      if (($AfterHoursMenu | Get-Member | Select-Object -First 1).TypeName -ne "Deserialized.Microsoft.Rtc.Management.Hosted.OAA.Models.Schedule") {
        Write-Error -Message "AfterHoursCallFlowOption (Menu) - AfterHoursMenu not of the Type 'Microsoft.Rtc.Management.Hosted.OAA.Models.Schedule'" -Category InvalidType -ErrorAction Stop
      }

    }
    #endregion

    #endregion
    #endregion

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    #region PREPARATION
    # preparing Splatting Object
    $Parameters = $null

    #region Required Parameters
    # Normalising $Name
    $NameNormalised = Format-StringForUse -InputString $Name -As DisplayName
    Write-Verbose -Message "'$Name' DisplayName normalised to: '$NameNormalised'"
    $Parameters += @{'Name' = $NameNormalised }

    # Adding required parameters
    $Parameters += @{'LanguageId' = $Language }
    $Parameters += @{'TimeZoneId' = $TimeZoneId }
    #endregion

    #region EnableVoiceResponse
    if ($PSBoundParameters.ContainsKey('EnableVoiceResponse')) {
      # Checking whether Voice Responses are available for the provided Language
      if ($VoiceResponsesSupported) {
        # Using As-Is
        Write-Verbose -Message "'$NameNormalised' EnableVoiceResponse - Voice Responses are supported with Language '$Language' and will be activated (Switch 'EnableVoiceResponse' will be used)"
        $Parameters += @{'EnableVoiceResponse' = $true }
      }
      else {
        Write-Verbose -Message "'$NameNormalised' EnableVoiceResponse - Voice Responses are not supported for Language '$Language' and cannot be activated (Switch 'EnableVoiceResponse' will be omitted)"
      }
    }
    #endregion

    #region Operator
    #TODO Insert EnableTranscription (For SharedVoiceMail only) - Replicate for other SharedVoicemail options?
    if ($PSBoundParameters.ContainsKey('Operator')) {
      try {
        $OperatorEntity = New-TeamsAutoAttendantCallableEntity -Type $OperatorType -Identity "$Operator"
        $Parameters += @{'Operator' = $OperatorEntity.ObjectId }
        Write-Warning -Message "EnableTranscription can currently not be activated. Please activate in Admin Center if needed."
      }
      catch [System.IO.IOException] {
        Write-Warning -Message "'$NameNormalised' Call Target '$Identity' not enumerated. Omitting Object"
      }
      catch {
        Write-Warning -Message "'$NameNormalised' Call Target '$Identity' not enumerated. Omitting Object"
        Write-Host "$($_.Exception.Message)" -ForegroundColor Red
      }
    }
    #endregion


    #region Business Hours Call Flow
    if ($PSBoundParameters.ContainsKey('DefaultCallFlow')) {
      # Using As-Is
      Write-Verbose -Message "'$NameNormalised' DefaultCallFlow - Custom Object provided." -Verbose
      $Parameters += @{'DefaultCallFlow' = $DefaultCallFlow }

    }
    else {
      Write-Verbose -Message "'$NameNormalised' DefaultCallFlow - No Custom Object - Processing 'BusinessHoursCallFlowOption'..." -Verbose
      $BusinessHoursCallFlowParameters = @{}
      $BusinessHoursCallFlowParameters.Name = "$Name - Business Hours Call Flow"

      #region Processing BusinessHoursCallFlowOption
      switch ($BusinessHoursCallFlowOption) {
        "TransferCallToTarget" {
          Write-Verbose -Message "'$NameNormalised' DefaultCallFlow - Transferring to Target" -Verbose

          # Process BusinessHoursCallTarget based on BusinessHoursCallTargetType
          try {
            $BusinessHoursCallTargetEntity = New-TeamsAutoAttendantCallableEntity -Type $BusinessHoursCallTargetType -Identity "$BusinessHoursCallTarget"
          }
          catch [System.IO.IOException] {
            Write-Warning -Message "'$NameNormalised' Call Target '$Identity' not enumerated. Omitting Object"
          }
          catch {
            Write-Warning -Message "'$NameNormalised' Call Target '$Identity' not enumerated. Omitting Object"
            Write-Host "$($_.Exception.Message)" -ForegroundColor Red
          }

          # Building Menu Only if Successful
          if ($BusinessHoursCallTargetIdentity) {
            $BusinessHoursMenuOptionTransfer = New-CsAutoAttendantMenuOption -Action TransferCallToTarget -CallTarget $BusinessHoursCallTargetEntity.Id -DtmfResponse Automatic
            $BusinessHoursMenuObject = New-CsAutoAttendantMenu -Name "Business Hours Menu" -MenuOptions @($BusinessHoursMenuOptionTransfer)

            break
          }
          else {
            # Reverting to Disconnect
            Write-Warning -Message "'$NameNormalised' DefaultCallFlow - Business Hours Menu not created properly. Reverting to Disconnect" -Verbose
            $BusinessHoursMenuOptionDefault = New-CsAutoAttendantMenuOption -Action DisconnectCall -DtmfResponse Automatic
            $BusinessHoursMenuObject = New-CsAutoAttendantMenu -Name "Business Hours Menu" -MenuOptions @($BusinessHoursMenuOptionDefault)
          }
        }

        "Menu" {
          Write-Verbose -Message "'$NameNormalised' DefaultCallFlow - Menu" -Verbose
          if ($PSBoundParameters.ContainsKey('BusinessHoursMenu')) {
            # Menu is passed on as-is - $BusinessHoursMenu is defined and attached
            $BusinessHoursMenuObject = $BusinessHoursMenu
          }
          else {
            # No custom / default Menu is currently created
            # $BusinessHoursMenu is Mandatory. If this is built out, the check against this must also be removed!
          }
        }

        default {
          # Defaulting to Disconnect
          Write-Verbose -Message "'$NameNormalised' DefaultCallFlow not provided or 'Disconnect' - Using default (Disconnect)" -Verbose
          $BusinessHoursMenuOptionDefault = New-CsAutoAttendantMenuOption -Action DisconnectCall -DtmfResponse Automatic
          $BusinessHoursMenuObject = New-CsAutoAttendantMenu -Name "Business Hours Menu" -MenuOptions @($BusinessHoursMenuOptionDefault)
        }
      }
      #endregion

      #region BusinessHoursGreeting
      #Adding optional BusinessHoursGreeting
      if ($PSBoundParameters.ContainsKey('BusinessHoursGreeting')) {
        try {
          $BusinessHoursGreetingObject = New-TeamsAutoAttendantPrompt -String $BusinessHoursGreeting
          if ($BusinessHoursGreetingObject) {
            $BusinessHoursCallFlowParameters.Greetings = @($BusinessHoursGreetingObject)
          }
        }
        catch {
          Write-Warning -Message "'$NameNormalised' CallFlow - BusinessHoursCallFlow - Greeting not enumerated. Omitting Greeting"
        }
      }
      #endregion

      #region Building Call Flow
      # Adding Business Hours Call Flow
      $BusinessHoursCallFlowParameters.Menu = $BusinessHoursMenuObject
      $BusinessHoursCallFlow = New-CsAutoAttendantCallFlow @BusinessHoursCallFlowParameters
      $Parameters += @{'DefaultCallFlow' = $BusinessHoursCallFlow }
      #endregion
    }
    #endregion

    #region After Hours (Call Flow, Schedule & Call Handling Association)
    #region After Hours Call Flow
    #Initialising Variables for Call Handling Association
    $AfterHoursCallHandlingAssociationParams = @{}
    $AfterHoursCallHandlingAssociationParams.Type = "AfterHours"

    # Processing CallFlow
    if ($PSBoundParameters.ContainsKey('CallFlows')) {
      # Custom Option provided - Using As-Is
      Write-Verbose -Message "'$NameNormalised' CallFlow - Custom Object provided. Over-riding other options (like switch 'AfterHoursCallFlow')" -Verbose
      #CHECK Validate Array use!
      $AfterHoursCallHandlingAssociationIDs = @{}
      foreach ($CF in $CallFlows) {
        $AfterHoursCallHandlingAssociationIDs.Add($CF.Id)
      }
      $Parameters += @{'CallFlows' = $CallFlows }
      $AfterHoursCallHandlingAssociationParams.CallFlowId = $AfterHoursCallHandlingAssociationIDs
    }
    else {
      # Option Selected
      Write-Verbose -Message "'$NameNormalised' CallFlow - No Custom Object - Processing 'AfterHoursCallFlowOption'..." -Verbose
      $AfterHoursCallFlowParameters = @{}
      $AfterHoursCallFlowParameters.Name = "$Name After Hours Call Flow"

      #region Processing AfterHoursCallFlowOption
      switch ($AfterHoursCallFlowOption) {
        "TransferCallToTarget" {
          Write-Verbose -Message "'$NameNormalised' Call Flow - Transferring to Target" -Verbose

          # Process AfterHoursCallTarget based on AfterHoursCallTargetType
          try {
            $AfterHoursCallTargetEntity = New-TeamsAutoAttendantCallableEntity -Type $AfterHoursCallTargetType -Identity "$AfterHoursCallTarget"
          }
          catch [System.IO.IOException] {
            Write-Warning -Message "'$NameNormalised' Call Target '$Identity' not enumerated. Omitting Object"
          }
          catch {
            Write-Warning -Message "'$NameNormalised' Call Target '$Identity' not enumerated. Omitting Object"
            Write-Host "$($_.Exception.Message)" -ForegroundColor Red
          }

          # Building Menu Only if Successful
          if ($AfterHoursCallTargetEntity) {
            $AfterHoursMenuOptionTransfer = New-CsAutoAttendantMenuOption -Action TransferCallToTarget -CallTarget $AfterHoursCallTargetEntity.Id -DtmfResponse Automatic
            $AfterHoursMenuObject = New-CsAutoAttendantMenu -Name "After Hours Menu" -MenuOptions @($AfterHoursMenuOptionTransfer)

            break
          }
          else {
            # Reverting to Disconnect
            Write-Warning -Message "'$NameNormalised' Call Flow - After Hours Menu not created properly. Reverting to Disconnect" -Verbose
            $AfterHoursMenuOptionDefault = New-CsAutoAttendantMenuOption -Action DisconnectCall -DtmfResponse Automatic
            $AfterHoursMenuObject = New-CsAutoAttendantMenu -Name "After Hours Menu" -MenuOptions @($AfterHoursMenuOptionDefault)
          }
        }

        "Menu" {
          Write-Verbose -Message "'$NameNormalised' CallFlow - AfterHoursCallFlow - Menu" -Verbose
          if ($PSBoundParameters.ContainsKey('AfterHoursMenu')) {
            # Menu is passed on as-is - $AfterHoursMenu is defined and attached
            $AfterHoursMenuObject = $AfterHoursMenu
          }
          else {
            # No custom / default Menu is currently created
            # $AfterHoursMenu is Mandatory. If this is built out, the check against this must also be removed!
          }
        }

        default {
          # Defaulting to Disconnect
          Write-Verbose -Message "'$NameNormalised' CallFlow - AfterHoursCallFlow not provided or Disconnect. Using default (Disconnect)" -Verbose
          $AfterHoursMenuOptionDefault = New-CsAutoAttendantMenuOption -Action DisconnectCall -DtmfResponse Automatic
          $AfterHoursMenuObject = New-CsAutoAttendantMenu -Name "Business Hours Menu" -MenuOptions @($AfterHoursMenuOptionDefault)
        }
      }
      #endregion

      #region AfterHoursGreeting
      # Adding AfterHoursGreeting
      if ($PSBoundParameters.ContainsKey('AfterHoursGreeting')) {
        try {
          $AfterHoursGreetingObject = New-TeamsAutoAttendantPrompt -String $AfterHoursGreeting
          if ($AfterHoursGreetingObject) {
            $AfterHoursCallFlowParameters.Greetings = @($AfterHoursGreetingObject)
          }
        }
        catch {
          Write-Warning -Message "'$NameNormalised' CallFlow - AfterHoursCallFlow - Greeting not enumerated. Omitting Greeting"
        }
      }
      #endregion

      #region Building Call Flow
      # Adding After Hours Call Flow
      $AfterHoursCallFlowParameters.Menu = $AfterHoursMenuObject
      $AfterHoursCallFlow = New-CsAutoAttendantCallFlow @AfterHoursCallFlowParameters
      $Parameters += @{'CallFlows' = $AfterHoursCallFlow }

      #TODO When building out Holiday Set (IF!) this needs to be array-proof (see processing of CallFlows Objects for code samples)
      #TODO Validate Call handling Associations in general!
      $AfterHoursCallHandlingAssociationParams.CallFlowId = $AfterHoursCallFlow.Id
      #endregion
    }
    #endregion

    #region After Hours Schedule & Call Handling Association
    if ($PSBoundParameters.ContainsKey('Schedule')) {
      # Custom Schedule provided - Using As-Is
      Write-Verbose -Message "'$NameNormalised' Schedule - Custom Object provided. Over-riding other options" -Verbose
      $AfterHoursCallHandlingAssociationParams.ScheduleId = $Schedule.Id
    }
    else {
      # Defaulting to Mon-Fri 9-17
      Write-Verbose -Message "'$NameNormalised' Schedule - No Custom Object - Using (Mon-Fri 09:00-17:00)" -Verbose
      $afterHoursSchedule = New-TeamsAutoAttendantSchedule -Name "Business Hours Schedule" -WeeklyRecurrentSchedule -BusinessDays MonToFri -BusinessHours 9to5 -Complement
      $AfterHoursCallHandlingAssociationParams.ScheduleId = $afterHoursSchedule.Id
    }

    $AfterHoursCallHandlingAssociation = New-CsAutoAttendantCallHandlingAssociation @AfterHoursCallHandlingAssociationParams
    $Parameters += @{'CallHandlingAssociation' = @($AfterHoursCallHandlingAssociation) }
    #endregion
    #endregion


    #region Inclusion and Exclusion Scope
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
    if ($PSBoundParameters.ContainsKey('Silent')) {
      $Parameters += @{'WarningAction' = 'SilentlyContinue' }
    }
    else {
      $Parameters += @{'WarningAction' = 'Continue' }
    }
    $Parameters += @{'ErrorAction' = 'STOP' }
    #endregion
    #endregion


    #region ACTION
    # Create AA (New-CsAutoAttendant)
    Write-Verbose -Message "'$NameNormalised' Creating Auto Attendant"
    if ($PSCmdlet.ShouldProcess("$NameNormalised", "New-CsAutoAttendant")) {
      try {
        # Create the Auto Attendant with all enumerated Parameters passed through splatting
        $Null = (New-CsAutoAttendant @Parameters)
        Write-Verbose -Message "SUCCESS: '$NameNormalised' Auto Attendant created with all Parameters"
      }
      catch {
        Write-Error -Message "Error creating the Auto Attendant" -Category InvalidOperation -Exception "errorr Creating Auto Attendant"
        Write-ErrorRecord $_ #This handles the error message in human readable format.
        return
      }
    }
    else {
      return
    }
    #endregion


    #region OUTPUT
    # Re-query output
    if (-not ($PSBoundParameters.ContainsKey('Silent'))) {
      $AAFinal = Get-TeamsAutoAttendant -Name "$NameNormalised" -WarningAction SilentlyContinue
      return $AAFinal
    }
    else {
      return
    }
    #endregion

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"

  } #end
} #New-TeamsAutoAttendant
