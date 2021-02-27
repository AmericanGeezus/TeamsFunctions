# Module:   TeamsFunctions
# Function: VoiceConfig
# Author:		David Eberhardt
# Updated:  01-DEC-2020
# Status:   RC




function Get-TeamsCommonAreaPhone {
  <#
	.SYNOPSIS
		Returns Common Area Phones from AzureAD
	.DESCRIPTION
    Returns one or more AzureAdUser Accounts that are Common Area Phones
    Accounts returned are strictly limited to having to have the Common Area Phone License assigned.
  .PARAMETER Identity
    Default and positional. One or more UserPrincipalNames to be queried
  .PARAMETER DisplayName
		Optional. Search parameter.
		Use Find-TeamsUserVoiceConfig for more search options
  .PARAMETER PhoneNumber
		Optional. Returns all Common Area Phones with a specific string in the PhoneNumber
	.EXAMPLE
		Get-TeamsCommonAreaPhone
		Returns all Common Area Phones.
		NOTE: Depending on size of the Tenant, this might take a while.
	.EXAMPLE
		Get-TeamsCommonAreaPhone -Identity MyCAP@TenantName.onmicrosoft.com
		Returns the Common Area Phone with the Identity specified, if found.
	.EXAMPLE
		Get-TeamsCommonAreaPhone -DisplayName "Lobby"
		Returns all Common Area Phones with "Lobby" as part of their Display Name.
	.EXAMPLE
		Get-TeamsCommonAreaPhone -PhoneNumber +1555123456
		Returns the Resource Account with the Phone Number specified, if found.
  .INPUTS
    System.String
  .OUTPUTS
    System.Object
	.NOTES
    Displays similar output as Get-TeamsUserVoiceConfig, but more tailored to Common Area Phones
	.FUNCTIONALITY
		Queries a Common Area Phone in AzureAD for use in Teams
  .COMPONENT
		TeamsUserVoiceConfig
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  .LINK
    Get-TeamsCommonAreaPhone
  .LINK
    New-TeamsCommonAreaPhone
  .LINK
    Set-TeamsCommonAreaPhone
  .LINK
    Remove-TeamsCommonAreaPhone
  .LINK
    Find-TeamsUserVoiceConfig
  .LINK
    Get-TeamsUserVoiceConfig
  .LINK
    Set-TeamsUserVoiceConfig
	#>

  [CmdletBinding(ConfirmImpact = 'Low', DefaultParameterSetName = 'Identity')]
  [Alias('Get-TeamsCAP')]
  [OutputType([System.Object])]
  param(
    [Parameter(Position = 0, ParameterSetName = 'Identity', ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = 'UserPrincipalName of the User')]
    [Alias('UserPrincipalName')]
    [string[]]$Identity,

    [Parameter(ParameterSetName = 'DisplayName', ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = 'Searches for AzureAD Object with this Name')]
    [ValidateLength(3, 255)]
    [string]$DisplayName,

    [Parameter(ParameterSetName = 'Number', ValueFromPipelineByPropertyName, HelpMessage = 'Telephone Number of the Object')]
    [ValidateScript( {
        If ($_ -match '^(tel:)?\+?(([0-9]( |-)?)?(\(?[0-9]{3}\)?)( |-)?([0-9]{3}( |-)?[0-9]{4})|([0-9]{4,15}))?((;( |-)?ext=[0-9]{3,8}))?$') {
          $True
        }
        else {
          Write-Host 'Not a valid phone number. E.164 format expected, min 4 digits, but multiple formats accepted.' -ForegroundColor Red
          $false
        }
      })]
    [Alias('Tel', 'Number', 'TelephoneNumber')]
    [string]$PhoneNumber
  ) #param

  begin {
    Show-FunctionStatus -Level RC
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"
    Write-Verbose -Message "Need help? Online: $global:TeamsFunctionsHelpURLBase$($MyInvocation.MyCommand)`.md"

    # Asserting AzureAD Connection
    if (-not (Assert-AzureADConnection)) { break }

    # Asserting SkypeOnline Connection
    if (-not (Assert-SkypeOnlineConnection)) { break }

    # Setting Preference Variables according to Upstream settings
    if (-not $PSBoundParameters.ContainsKey('Verbose')) { $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference') }
    if (-not $PSBoundParameters.ContainsKey('Debug')) { $DebugPreference = $PSCmdlet.SessionState.PSVariable.GetValue('DebugPreference') } else { $DebugPreference = 'Continue' }
    if ( $PSBoundParameters.ContainsKey('InformationAction')) { $InformationPreference = $PSCmdlet.SessionState.PSVariable.GetValue('InformationAction') } else { $InformationPreference = 'Continue' }

    # Initialising counters for Progress bars
    [int]$step = 0
    [int]$sMax = 4

    # Loading all Microsoft Telephone Numbers
    $Operation = 'Gathering Phone Numbers from the Tenant'
    Write-Progress -Id 0 -Status 'Information Gathering' -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
    Write-Verbose -Message $Operation
    if (-not $global:TeamsFunctionsMSTelephoneNumbers) {
      $global:TeamsFunctionsMSTelephoneNumbers = Get-CsOnlineTelephoneNumber -WarningAction SilentlyContinue
    }

    # Querying Global Policies
    $Operation = 'Querying Global Policies'
    $step++
    Write-Progress -Id 0 -Status 'Information Gathering' -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
    Write-Verbose -Message $Operation
    $GlobalIPPhonePolicy = Get-CsTeamsIpPhonePolicy 'Global'
    $GlobalCallingPolicy = Get-CsTeamsCallingPolicy 'Global'
    $GlobalCallParkPolicy = Get-CsTeamsCallParkPolicy 'Global'

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    $CommonAreaPhones = $null

    #region Data gathering
    $Operation = 'Querying Common Area Phones'
    $step++
    Write-Progress -Id 0 -Status 'Information Gathering' -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
    Write-Verbose -Message $Operation
    if ($PSBoundParameters.ContainsKey('Identity')) {
      # Default Parameterset
      [System.Collections.ArrayList]$CommonAreaPhones = @()
      foreach ($I in $Identity) {
        Write-Verbose -Message "Querying Resource Account with UserPrincipalName '$I'"
        try {
          $CAP = $null
          $CAP = Get-CsOnlineUser -Identity "$I" -ErrorAction Stop
          [void]$CommonAreaPhones.Add($CAP)
        }
        catch {
          Write-Verbose -Message "Not found: '$I'" -Verbose
          continue
        }
      }
    }
    elseif ($PSBoundParameters.ContainsKey('DisplayName')) {
      # Minimum Character length is 3
      Write-Verbose -Message "DisplayName - Searching for Accounts with DisplayName '$DisplayName'"
      $Filter = 'DisplayName -like "*{0}*"' -f $DisplayName
      $CommonAreaPhones = Get-CsOnlineUser -Filter $Filter -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
      #$CommonAreaPhones = Get-CsOnlineUser -WarningAction SilentlyContinue | Where-Object -Property DisplayName -Like -Value "*$DisplayName*"
    }
    elseif ($PSBoundParameters.ContainsKey('PhoneNumber')) {
      $SearchString = Format-StringRemoveSpecialCharacter "$PhoneNumber" | Format-StringForUse -SpecialChars 'tel'
      Write-Verbose -Message "PhoneNumber - Searching for normalised PhoneNumber '$SearchString'"
      $Filter = 'LineURI -like "*{0}*"' -f $SearchString
      $CommonAreaPhones = Get-CsOnlineUser -Filter $Filter -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
    }
    else {
      Write-Warning -Message 'No parameters provided. Please provide at least one UserPrincipalName with Identity a DisplayName or a PhoneNumber'
      return
    }

    # Stop script if no data has been determined
    if ($CommonAreaPhones.Count -eq 0) {
      Write-Verbose -Message 'No Data found.'
      return
    }
    #endregion


    #region OUTPUT
    # Creating new PS Object
    $Operation = "Parsing Information for $($CommonAreaPhones.Count) Common Area Phones"
    $step++
    Write-Progress -Id 0 -Status 'Information Gathering' -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
    Write-Verbose -Message $Operation
    foreach ($CommonAreaPhone in $CommonAreaPhones) {
      # Initialising counters for Progress bars
      [int]$step = 0
      [int]$sMax = 3

      #region Parsing Policies
      $Operation = 'Parsing Policies'
      Write-Progress -Id 1 -Status "'$($CommonAreaPhone.DisplayName)'" -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message $Operation

      # TeamsIPPhonePolicy and CommonAreaPhoneSignIn
      if ( -not $CommonAreaPhone.TeamsIPPhonePolicy ) {
        $UserSignInMode = $GlobalIPPhonePolicy.SignInMode
        if ( $GlobalIPPhonePolicy.SignInMode -ne 'CommonAreaPhoneSignIn' ) {
          Write-Warning -Message "Phone '$($CommonAreaPhone.UserPrincipalName)' - TeamsIpPhonePolicy is not set. The Global policy does not have the Sign-in mode set to 'CommonAreaPhoneSignIn'. To enable Common Area phones to sign in with the best experience, please assign a TeamsIpPhonePolicy or change the Global Policy!"
        }
        else {
          Write-Verbose -Message "Phone '$($CommonAreaPhone.UserPrincipalName)' - TeamsIpPhonePolicy is not set, but Global policy has set the Sign-in mode set to 'CommonAreaPhoneSignIn'."
        }
      }
      else {
        $UserIpPhonePolicy = $null
        $UserIpPhonePolicy = Get-CsTeamsIPPhonePolicy $CommonAreaPhone.TeamsIPPhonePolicy -WarningAction SilentlyContinue
        $UserSignInMode = $UserIpPhonePolicy.SignInMode
        if ( $UserIpPhonePolicy.SignInMode -ne 'CommonAreaPhoneSignIn' ) {
          Write-Warning -Message "Phone '$($CommonAreaPhone.UserPrincipalName)' - TeamsIpPhonePolicy '$($CommonAreaPhone.TeamsIPPhonePolicy)' is set, but the Sign-in mode set not set to 'CommonAreaPhoneSignIn'. To enable Common Area phones to sign in with the best experience, please change the TeamsIpPhonePolicy!"
        }
        else {
          Write-Verbose -Message "Phone '$($CommonAreaPhone.UserPrincipalName)' - TeamsIpPhonePolicy '$($CommonAreaPhone.TeamsIPPhonePolicy)' is set and Sign-In Mode is set to 'CommonAreaPhoneSignIn'"
        }
      }

      # TeamsCallingPolicy and AllowPrivateCalling
      if ( -not $CommonAreaPhone.TeamsCallingPolicy ) {
        $UserAllowPrivateCalling = $GlobalCallingPolicy.AllowPrivateCalling
        if ( -not $GlobalCallingPolicy.AllowPrivateCalling ) {
          Write-Warning -Message "Phone '$($CommonAreaPhone.UserPrincipalName)' - TeamsCallingPolicy is not set. The Global policy does not Allow Private Calling. To enable ANY calling functionality for this phone, please assign a TeamsCallingPolicy or change the Global Policy!"
        }
        else {
          Write-Verbose -Message "Phone '$($CommonAreaPhone.UserPrincipalName)' - TeamsCallingPolicy is not set, but Global policy does Allow Private Calling."
        }
      }
      else {
        $UserTeamsCallingPolicy = $null
        $UserTeamsCallingPolicy = Get-CsTeamsCallingPolicy $CommonAreaPhone.TeamsCallingPolicy -WarningAction SilentlyContinue
        $UserAllowPrivateCalling = $UserTeamsCallingPolicy.AllowPrivateCalling
        if ( -not $UserTeamsCallingPolicy.AllowPrivateCalling ) {
          Write-Warning -Message "Phone '$($CommonAreaPhone.UserPrincipalName)' - TeamsCallingPolicy '$($CommonAreaPhone.TeamsCallingPolicy)' is set, but does not Allow Private Calling. To enable ANY calling functionality for this phone, please change the TeamsCallingPolicy!"
        }
        else {
          Write-Verbose -Message "Phone '$($CommonAreaPhone.UserPrincipalName)' - TeamsCallingPolicy '$($CommonAreaPhone.TeamsCallingPolicy)' is set and does Allow Private Calling"
        }
      }

      # TeamsCallParkPolicy and AllowCallPark
      if ( -not $CommonAreaPhone.TeamsCallParkPolicy ) {
        $UserAllowCallPark = $GlobalCallParkPolicy.AllowCallPark
        if ( -not $GlobalCallParkPolicy.AllowCallPark ) {
          Write-Warning -Message "Phone '$($CommonAreaPhone.UserPrincipalName)' - TeamsCallParkPolicy is not set. The Global policy does not allow Call Parking. To enable Call Parking for Common Area phones, please assign a TeamsCallParkPolicy or change the Global Policy!"
        }
        else {
          Write-Verbose -Message "Phone '$($CommonAreaPhone.UserPrincipalName)' - TeamsCallParkPolicy is not set, but Global policy does allow Call Parking."
        }
      }
      else {
        $UserCallParkPolicy = $null
        $UserCallParkPolicy = Get-CsTeamsCallParkPolicy $CommonAreaPhone.TeamsCallParkPolicy -WarningAction SilentlyContinue
        $UserAllowCallPark = $UserTeamsCallingPolicy.AllowCallPark
        if ( -not $UserCallParkPolicy.AllowCallPark ) {
          Write-Warning -Message "Phone '$($CommonAreaPhone.UserPrincipalName)' - TeamsCallParkPolicy '$($CommonAreaPhone.TeamsCallParkPolicy)' is set, but does not allow Call Parking. To enable Call Parking, please change the TeamsCallParkPolicy!"
        }
        else {
          Write-Verbose -Message "Phone '$($CommonAreaPhone.UserPrincipalName)' - TeamsCallParkPolicy '$($CommonAreaPhone.TeamsCallParkPolicy)' is set and does allow Call Parking"
        }
      }
      #endregion

      # Parsing TeamsUserLicense
      $Operation = 'Parsing License Assignments'
      $step++
      Write-Progress -Id 1 -Status "'$($CommonAreaPhone.DisplayName)'" -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message $Operation
      $CommonAreaPhoneLicense = Get-TeamsUserLicense -Identity "$($CommonAreaPhone.UserPrincipalName)"

      # Phone Number Type
      $Operation = 'Parsing PhoneNumber'
      $step++
      Write-Progress -Id 1 -Status "'$($CommonAreaPhone.DisplayName)'" -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message $Operation
      if ( $CommonAreaPhone.LineURI ) {
        $MSNumber = $null
        $MSNumber = ((Format-StringForUse -InputString "$($CommonAreaPhone.LineURI)" -SpecialChars 'tel:+') -split ';')[0]
        if ($MSNumber -in $global:TeamsFunctionsMSTelephoneNumbers.Id) {
          $CommonAreaPhonePhoneNumberType = 'Microsoft Number'
        }
        else {
          $CommonAreaPhonePhoneNumberType = 'Direct Routing Number'
        }
      }
      else {
        $CommonAreaPhonePhoneNumberType = $null
      }

      # creating new PS Object (synchronous with Get and Set)
      $CommonAreaPhoneObject = [PSCustomObject][ordered]@{
        ObjectId                     = $CommonAreaPhone.ObjectId
        UserPrincipalName            = $CommonAreaPhone.UserPrincipalName
        DisplayName                  = $CommonAreaPhone.DisplayName
        Description                  = $CommonAreaPhone.Description
        UsageLocation                = $CommonAreaPhoneLicense.UsageLocation
        InterpretedUserType          = $CommonAreaPhone.InterpretedUserType
        License                      = $CommonAreaPhoneLicense.Licenses
        PhoneSystem                  = $CommonAreaPhoneLicense.PhoneSystem
        PhoneSystemStatus            = $CommonAreaPhoneLicense.PhoneSystemStatus
        EnterpriseVoiceEnabled       = $CommonAreaPhone.EnterpriseVoiceEnabled
        PhoneNumberType              = $CommonAreaPhonePhoneNumberType
        PhoneNumber                  = $CommonAreaPhone.LineURI
        TenantDialPlan               = $CommonAreaPhone.TenantDialPlan
        OnlineVoiceRoutingPolicy     = $CommonAreaPhone.OnlineVoiceRoutingPolicy
        TeamsIPPhonePolicy           = $CommonAreaPhone.TeamsIPPhonePolicy
        TeamsCallingPolicy           = $CommonAreaPhone.TeamsCallingPolicy
        TeamsCallParkPolicy          = $CommonAreaPhone.TeamsCallParkPolicy
        EffectiveSignInMode          = $UserSignInMode
        EffectiveAllowPrivateCalling = $UserAllowPrivateCalling
        EffectiveAllowCallPark       = $UserAllowCallPark
      }

      Write-Progress -Id 1 -Status "Processing '$($CommonAreaPhone.UserPrincipalName)'" -Activity $MyInvocation.MyCommand -Completed
      Write-Output $CommonAreaPhoneObject
    }

    #endregion
    Write-Progress -Id 0 -Status 'Complete' -Activity $MyInvocation.MyCommand -Completed

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} # Get-TeamsCommonAreaPhone
