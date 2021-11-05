# Module:   TeamsFunctions
# Function: VoiceConfig
# Author:   David Eberhardt
# Updated:  01-DEC-2020
# Status:   Live




function Get-TeamsCommonAreaPhone {
  <#
  .SYNOPSIS
    Returns Common Area Phones from AzureAD
  .DESCRIPTION
    Returns one or more AzureAdUser Accounts that are Common Area Phones
    Accounts returned are strictly limited to having to have the Common Area Phone License assigned.
  .PARAMETER UserPrincipalName
    Default and positional. One or more UserPrincipalNames to be queried
  .PARAMETER DisplayName
    Optional. Search parameter.
    Use Find-TeamsUserVoiceConfig for more search options
  .PARAMETER PhoneNumber
    Optional. Returns all Common Area Phones with a specific string in the PhoneNumber
  .EXAMPLE
    Get-TeamsCommonAreaPhone
    Returns all Common Area Phones.
    Depending on size of the Tenant, this might take a while.
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
    Running the CmdLet without any input might take a while, depending on size of the Tenant.
  .FUNCTIONALITY
    Queries a Common Area Phone in AzureAD for use in Teams
  .COMPONENT
    UserManagement
  .COMPONENT
    VoiceConfiguration
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-TeamsCommonAreaPhone.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_VoiceConfiguration.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_UserManagement.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  #>

  [CmdletBinding(ConfirmImpact = 'Low', DefaultParameterSetName = 'Identity')]
  [Alias('Get-TeamsCAP')]
  [OutputType([System.Object])]
  param(
    [Parameter(Position = 0, ParameterSetName = 'Identity', ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = 'UserPrincipalName of the User')]
    [Alias('ObjectId', 'Identity')]
    [string[]]$UserPrincipalName,

    [Parameter(ParameterSetName = 'DisplayName', ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = 'Searches for AzureAD Object with this Name')]
    [ValidateLength(3, 255)]
    [string]$DisplayName,

    [Parameter(ParameterSetName = 'Number', ValueFromPipelineByPropertyName, HelpMessage = 'Telephone Number of the Object')]
    [ValidateScript( {
        If ($_ -match '^(tel:\+|\+)?([0-9]?[-\s]?(\(?[0-9]{3}\)?)[-\s]?([0-9]{3}[-\s]?[0-9]{4})|([0-9][-\s]?){4,20})((x|;ext=)([0-9]{3,8}))?$') { $True } else {
          throw [System.Management.Automation.ValidationMetadataException] 'Not a valid phone number. E.164 format expected, min 4 digits, but multiple formats accepted.'
          $false
        }
      })]
    [Alias('Tel', 'Number', 'TelephoneNumber')]
    [string]$PhoneNumber
  ) #param

  begin {
    Show-FunctionStatus -Level Live
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"
    Write-Verbose -Message "Need help? Online: $global:TeamsFunctionsHelpURLBase$($MyInvocation.MyCommand)`.md"

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

    #Initialising Counters
    $script:StepsID0, $script:StepsID1 = Get-WriteBetterProgressSteps -Code $($MyInvocation.MyCommand.Definition) -MaxId 1
    $script:ActivityID0 = $($MyInvocation.MyCommand.Name)
    [int] $script:CountID0 = [int] $script:CountID1 = 1

    # Querying Global Policies
    $StatusID0 = 'Information Gathering'
    $CurrentOperationID0 = 'Querying Global Policies'
    Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($script:CountID0++) -Of $script:StepsID0
    $GlobalIPPhonePolicy = Get-CsTeamsIPPhonePolicy 'Global'
    $GlobalCallingPolicy = Get-CsTeamsCallingPolicy 'Global'
    $GlobalCallParkPolicy = Get-CsTeamsCallParkPolicy 'Global'

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    $CommonAreaPhones = $null

    #region Data gathering
    $CurrentOperationID0 = 'Querying Common Area Phones'
    Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($script:CountID0++) -Of $script:StepsID0
    switch ($PSCmdlet.ParameterSetName) {
      'Identity' {
        # Default Parameterset
        [System.Collections.ArrayList]$CommonAreaPhones = @()
        foreach ($User in $UserPrincipalName) {
          Write-Verbose -Message "Querying Resource Account with UserPrincipalName '$User'"
          try {
            $CAP = $null
            #NOTE Call placed without the Identity Switch to make remoting call and receive object in tested format (v2.5.0 and higher)
            #$CAP = Get-CsOnlineUser -Identity "$User" -WarningAction SilentlyContinue -ErrorAction Stop
            $CAP = Get-CsOnlineUser "$User" -WarningAction SilentlyContinue -ErrorAction Stop
            [void]$CommonAreaPhones.Add($CAP)
          }
          catch {
            # If CsOnlineUser not found, trying AzureAdUser
            try {
              $CAP = $null
              $CAP = Get-AzureADUser -ObjectId "$User" -WarningAction SilentlyContinue -ErrorAction Stop
              [void]$CommonAreaPhones.Add($CAP)
              Write-Warning -Message "User '$User' - found in AzureAd but not in Teams (CsOnlineUser)!"
              Write-Verbose -Message 'You receive this message if no License containing Teams is assigned or the Teams ServicePlan (TEAMS1) is disabled! Please validate the User License. No further validation is performed. The Object returned only contains data from AzureAd' -Verbose
            }
            catch [Microsoft.Open.AzureAD16.Client.ApiException] {
              Write-Error -Message "User '$User' not found in Teams (CsOnlineUser) nor in Azure Ad (AzureAdUser). Please validate UserPrincipalName. Exception message: Resource '$User' does not exist or one of its queried reference-property objects are not present." -Category ObjectNotFound
              continue
            }
            catch {
              Write-Error -Message "User '$User' not found. Error encountered: $($_.Exception.Message)" -Category ObjectNotFound
              continue
            }
          }
        }
      }
      'Displayname' {
        # Minimum Character length is 3
        Write-Verbose -Message "DisplayName - Searching for Accounts with DisplayName '$DisplayName'"
        $Filter = 'DisplayName -like "*{0}*"' -f $DisplayName
        $CommonAreaPhones = Get-CsOnlineUser -Filter $Filter -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
        #$CommonAreaPhones = Get-CsOnlineUser -WarningAction SilentlyContinue | Where-Object -Property DisplayName -Like -Value "*$DisplayName*"
      }
      'Number' {
        $SearchString = Format-StringForUse "$($PhoneNumber.split(';')[0].split('x')[0])" -SpecialChars 'telx:+() -'
        Write-Verbose -Message "PhoneNumber - Searching for normalised PhoneNumber '$SearchString'"
        $Filter = 'LineURI -like "*{0}*"' -f $SearchString
        $CommonAreaPhones = Get-CsOnlineUser -Filter $Filter -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
      }
      Default {
        Write-Warning -Message 'No parameters provided. Please provide at least one UserPrincipalName with Identity a DisplayName or a PhoneNumber'
        return
      }
    }

    # Stop script if no data has been determined
    if ($CommonAreaPhones.Count -eq 0) {
      Write-Verbose -Message 'No Data found.'
      Write-Progress -Id 0 -Activity $ActivityID0 -Completed
      return
    }
    #endregion


    #region Information Gathering
    # Creating new PS Object
    [int] $script:CountID0 = 1
    [int] $script:StepsID0 = $script:CountID0 + $CommonAreaPhones.Count
    foreach ($CommonAreaPhone in $CommonAreaPhones) {
      [int] $script:CountID1 = 1
      $StatusID0 = 'Processing found User Objects'
      $CurrentOperationID0 = $ActivityID1 = "'$($CommonAreaPhone.UserPrincipalName)'"
      Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($script:CountID0++) -Of $script:StepsID0

      $StatusID1 = 'Information Gathering'
      #region Parsing Policies
      # TeamsIPPhonePolicy and CommonAreaPhoneSignIn
      $CurrentOperationID1 = 'Parsing IP Phone Policy (CommonAreaPhoneSignIn)'
      Write-BetterProgress -Id 1 -Activity $ActivityID1 -Status $StatusID1 -CurrentOperation $CurrentOperationID1 -Step ($script:CountID1++) -Of $script:StepsID1
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
        #NOTE In MicrosoftTeams v2.5.0, policies are now nested Objects!
        try {
          $UserIpPhonePolicy = Get-CsTeamsIPPhonePolicy $CommonAreaPhone.TeamsIPPhonePolicy -WarningAction SilentlyContinue -ErrorAction Stop
          $UserSignInMode = $UserIpPhonePolicy.SignInMode
          if ( $UserIpPhonePolicy.SignInMode -ne 'CommonAreaPhoneSignIn' ) {
            Write-Warning -Message "Phone '$($CommonAreaPhone.UserPrincipalName)' - TeamsIpPhonePolicy '$($CommonAreaPhone.TeamsIPPhonePolicy)' is set, but the Sign-in mode set not set to 'CommonAreaPhoneSignIn'. To enable Common Area phones to sign in with the best experience, please change the TeamsIpPhonePolicy!"
          }
          else {
            Write-Verbose -Message "Phone '$($CommonAreaPhone.UserPrincipalName)' - TeamsIpPhonePolicy '$($CommonAreaPhone.TeamsIPPhonePolicy)' is set and Sign-In Mode is set to 'CommonAreaPhoneSignIn'"
          }
        }
        catch {
          if ($CommonAreaPhone.TeamsIPPhonePolicy.Name) {
            $UserIpPhonePolicy = Get-CsTeamsIPPhonePolicy $CommonAreaPhone.TeamsIPPhonePolicy.Name -WarningAction SilentlyContinue
            $UserSignInMode = $UserIpPhonePolicy.SignInMode
            if ( $UserIpPhonePolicy.SignInMode -ne 'CommonAreaPhoneSignIn' ) {
              Write-Warning -Message "Phone '$($CommonAreaPhone.UserPrincipalName)' - TeamsIpPhonePolicy '$($CommonAreaPhone.TeamsIPPhonePolicy.Name)' is set, but the Sign-in mode set not set to 'CommonAreaPhoneSignIn'. To enable Common Area phones to sign in with the best experience, please change the TeamsIpPhonePolicy!"
            }
            else {
              Write-Verbose -Message "Phone '$($CommonAreaPhone.UserPrincipalName)' - TeamsIpPhonePolicy '$($CommonAreaPhone.TeamsIPPhonePolicy.Name)' is set and Sign-In Mode is set to 'CommonAreaPhoneSignIn'"
            }
          }
        }
      }

      # TeamsCallingPolicy and AllowPrivateCalling
      $CurrentOperationID1 = 'Parsing Teams Calling Policy (AllowPrivateCalling)'
      Write-BetterProgress -Id 1 -Activity $ActivityID1 -Status $StatusID1 -CurrentOperation $CurrentOperationID1 -Step ($script:CountID1++) -Of $script:StepsID1
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
        #NOTE In MicrosoftTeams v2.5.0, policies are now nested Objects!
        try {
          $UserTeamsCallingPolicy = Get-CsTeamsCallingPolicy $CommonAreaPhone.TeamsCallingPolicy -WarningAction SilentlyContinue -ErrorAction Stop
          $UserAllowPrivateCalling = $UserTeamsCallingPolicy.AllowPrivateCalling
          if ( -not $UserTeamsCallingPolicy.AllowPrivateCalling ) {
            Write-Warning -Message "Phone '$($CommonAreaPhone.UserPrincipalName)' - TeamsCallingPolicy '$($CommonAreaPhone.TeamsCallingPolicy)' is set, but does not Allow Private Calling. To enable ANY calling functionality for this phone, please change the TeamsCallingPolicy!"
          }
          else {
            Write-Verbose -Message "Phone '$($CommonAreaPhone.UserPrincipalName)' - TeamsCallingPolicy '$($CommonAreaPhone.TeamsCallingPolicy)' is set and does Allow Private Calling"
          }
        }
        catch {
          if ($CommonAreaPhone.TeamsCallingPolicy.Name) {
            $UserTeamsCallingPolicy = Get-CsTeamsCallingPolicy $CommonAreaPhone.TeamsCallingPolicy.Name -WarningAction SilentlyContinue
            $UserAllowPrivateCalling = $UserTeamsCallingPolicy.AllowPrivateCalling
            if ( -not $UserTeamsCallingPolicy.AllowPrivateCalling ) {
              Write-Warning -Message "Phone '$($CommonAreaPhone.UserPrincipalName)' - TeamsCallingPolicy '$($CommonAreaPhone.TeamsCallingPolicy.Name)' is set, but does not Allow Private Calling. To enable ANY calling functionality for this phone, please change the TeamsCallingPolicy!"
            }
            else {
              Write-Verbose -Message "Phone '$($CommonAreaPhone.UserPrincipalName)' - TeamsCallingPolicy '$($CommonAreaPhone.TeamsCallingPolicy.Name)' is set and does Allow Private Calling"
            }
          }
        }
      }

      # TeamsCallParkPolicy and AllowCallPark
      $CurrentOperationID1 = 'Parsing Teams Call Park Policy (AllowCallPark)'
      Write-BetterProgress -Id 1 -Activity $ActivityID1 -Status $StatusID1 -CurrentOperation $CurrentOperationID1 -Step ($script:CountID1++) -Of $script:StepsID1
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
        #NOTE In MicrosoftTeams v2.5.0, policies are now nested Objects!
        try {
          $UserCallParkPolicy = Get-CsTeamsCallParkPolicy $CommonAreaPhone.TeamsCallParkPolicy -WarningAction SilentlyContinue -ErrorAction Stop
          $UserAllowCallPark = $UserTeamsCallingPolicy.AllowCallPark
          if ( -not $UserCallParkPolicy.AllowCallPark ) {
            Write-Warning -Message "Phone '$($CommonAreaPhone.UserPrincipalName)' - TeamsCallParkPolicy '$($CommonAreaPhone.TeamsCallParkPolicy)' is set, but does not allow Call Parking. To enable Call Parking, please change the TeamsCallParkPolicy!"
          }
          else {
            Write-Verbose -Message "Phone '$($CommonAreaPhone.UserPrincipalName)' - TeamsCallParkPolicy '$($CommonAreaPhone.TeamsCallParkPolicy)' is set and does allow Call Parking"
          }
        }
        catch {
          if ($CommonAreaPhone.TeamsCallParkPolicy.Name) {
            $UserCallParkPolicy = Get-CsTeamsCallParkPolicy $CommonAreaPhone.TeamsCallParkPolicy.Name -WarningAction SilentlyContinue
            $UserAllowCallPark = $UserTeamsCallingPolicy.AllowCallPark
            if ( -not $UserCallParkPolicy.AllowCallPark ) {
              Write-Warning -Message "Phone '$($CommonAreaPhone.UserPrincipalName)' - TeamsCallParkPolicy '$($CommonAreaPhone.TeamsCallParkPolicy.Name)' is set, but does not allow Call Parking. To enable Call Parking, please change the TeamsCallParkPolicy!"
            }
            else {
              Write-Verbose -Message "Phone '$($CommonAreaPhone.UserPrincipalName)' - TeamsCallParkPolicy '$($CommonAreaPhone.TeamsCallParkPolicy.Name)' is set and does allow Call Parking"
            }
          }
        }
      }
      #endregion

      # Parsing TeamsUserLicense
      $CurrentOperationID1 = 'Parsing License Assignments'
      Write-BetterProgress -Id 1 -Activity $ActivityID1 -Status $StatusID1 -CurrentOperation $CurrentOperationID1 -Step ($script:CountID1++) -Of $script:StepsID1
      $CommonAreaPhoneLicense = Get-AzureAdUserLicense -Identity "$($CommonAreaPhone.UserPrincipalName)"

      # Phone Number Type
      $CurrentOperationID1 = 'Parsing Online Telephone Numbers (validating Number against Microsoft Calling Plan Numbers)'
      Write-BetterProgress -Id 1 -Activity $ActivityID1 -Status $StatusID1 -CurrentOperation $CurrentOperationID1 -Step ($script:CountID1++) -Of $script:StepsID1
      if ( $CommonAreaPhone.LineURI ) {
        $MSNumber = $null
        $MSNumber = ((Format-StringForUse -InputString "$($CommonAreaPhone.LineURI)" -SpecialChars 'tel:+') -split ';')[0]
        $PhoneNumberIsMSNumber = Get-CsOnlineTelephoneNumber -TelephoneNumber $MSNumber -WarningAction SilentlyContinue
        if ($PhoneNumberIsMSNumber) {
          $CommonAreaPhonePhoneNumberType = 'Microsoft Number'
        }
        else {
          $CommonAreaPhonePhoneNumberType = 'Direct Routing Number'
        }
      }
      else {
        $CommonAreaPhonePhoneNumberType = $null
      }
      #endregion

      #region Output - Creating new PS Object (synchronous with Get and Set)
      $CurrentOperationID1 = 'Preparing Output Object'
      Write-BetterProgress -Id 1 -Activity $ActivityID1 -Status $StatusID1 -CurrentOperation $CurrentOperationID1 -Step ($script:CountID1++) -Of $script:StepsID1
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

      Write-Progress -Id 1 -Activity $ActivityID1 -Completed
      Write-Output $CommonAreaPhoneObject
    }

    #endregion
    #TEST Test Progress bars bleed-through. If not viable, close ID 0 before FOREACH
    Write-Progress -Id 0 -Activity $ActivityID0 -Completed

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} # Get-TeamsCommonAreaPhone
