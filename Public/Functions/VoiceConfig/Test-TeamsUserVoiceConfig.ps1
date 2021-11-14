# Module:   TeamsFunctions
# Function: VoiceConfig
# Author:   David Eberhardt
# Updated:  15-MAY-2021
# Status:   Live




function Test-TeamsUserVoiceConfig {
  <#
  .SYNOPSIS
    Tests whether any Voice Configuration has been applied to one or more Users
  .DESCRIPTION
    For Microsoft Call Plans: Tests for EnterpriseVoice enablement, License AND Phone Number
    For Direct Routing: Tests for EnterpriseVoice enablement, Online Voice Routing Policy AND Phone Number
  .PARAMETER UserPrincipalName
    Required for Parameterset UserPrincipalName. UserPrincipalName or ObjectId of the Object
  .PARAMETER Object
    Required for Parameterset Object. CsOnlineUser Object passed to the function to reduce query time.
  .PARAMETER Partial
    Optional. By default, returns TRUE only if all required Parameters are configured (User is fully provisioned)
    Using this switch, returns TRUE if some of the voice Parameters are configured (User has some or full configuration)
  .PARAMETER IncludeTenantDialPlan
    Optional. By default, only the core requirements for Voice Routing are verified.
    This extends the requirements to also include the Tenant Dial Plan.
    Returns FALSE if no or only a TenantDialPlan is assigned
  .PARAMETER ExtensionState
    Optional. For DirectRouting, enforces the presence (or absence) of an Extension. Default: NotMeasured
    No effect for Microsoft Calling Plans
  .EXAMPLE
    Test-TeamsUserVoiceConfig -Object $CsOnlineUser
    Tests a Users Voice Configuration (Direct Routing or Calling Plans) and returns TRUE if ANY configuration is found
    To reduce query time, the CsOnlineUser Object can be passed to this function
  .EXAMPLE
    Test-TeamsUserVoiceConfig -UserPrincipalName $UserPrincipalName
    Tests a Users Voice Configuration (Direct Routing or Calling Plans) and returns TRUE if FULL configuration is found
  .EXAMPLE
    Test-TeamsUserVoiceConfig -UserPrincipalName $UserPrincipalName -Partial
    Tests a Users Voice Configuration (Direct Routing or Calling Plans) and returns TRUE if ANY configuration is found
  .EXAMPLE
    Test-TeamsUserVoiceConfig -UserPrincipalName $UserPrincipalName -IncludeTenantDialPlan
    Tests a Users Voice Configuration (Direct Routing or Calling Plans) and returns TRUE if FULL configuration is found
    This requires a Tenant Dial Plan to be assigned as well.
  .EXAMPLE
    Test-TeamsUserVoiceConfig -UserPrincipalName $UserPrincipalName -Partial -IncludeTenantDialPlan
    Tests a Users Voice Configuration (Direct Routing or Calling Plans) and returns TRUE if ANY configuration is found
    This will treat any Object that only has a Tenant Dial Plan also as partially configured
  .INPUTS
    System.String
  .OUTPUTS
    Boolean
  .NOTES
    Can be used providing either the UserPrincipalName or the already queried CsOnlineUser Object
    All conditions require EnterpriseVoiceEnabled to be TRUE (disabled Users will always return FALSE)
    Partial configuration provides insight for incorrectly provisioned configuration.
    Tested Parameters for DirectRouting: EnterpriseVoiceEnabled, VoicePolicy, OnlineVoiceRoutingPolicy, OnPremLineURI
    Tested Parameters for CallPlans: EnterpriseVoiceEnabled, VoicePolicy, User License (Domestic or International Calling Plan), TelephoneNumber
    Tested Parameters for SkypeHybridPSTN: EnterpriseVoiceEnabled, VoicePolicy, VoiceRoutingPolicy, OnlineVoiceRoutingPolicy
  .COMPONENT
    VoiceConfiguration
  .FUNCTIONALITY
    Testing Users Voice Configuration
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Test-TeamsUserVoiceConfig.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_VoiceConfiguration.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  .LINK
    https://docs.microsoft.com/en-us/microsoftteams/direct-routing-migrating
  #>

  [CmdletBinding(DefaultParameterSetName = 'UserPrincipalName')]
  [Alias('Test-TeamsUVC')]
  [OutputType([Boolean])]
  param(
    [Parameter(Mandatory, Position = 0, ParameterSetName = 'Object', ValueFromPipeline)]
    [Object[]]$Object,

    [Parameter(Mandatory, Position = 0, ParameterSetName = 'UserPrincipalName', ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [Alias('ObjectId', 'Identity')]
    [string[]]$UserPrincipalName,

    [Parameter(Helpmessage = 'Queries a partial implementation')]
    [switch]$Partial,

    [Parameter(HelpMessage = 'Extends requirements to include Tenant Dial Plan assignment')]
    [switch]$IncludeTenantDialPlan,

    [Parameter(HelpMessage = 'Extends requirements to validate the status of the Extension')]
    [ValidateSet('MustBePopulated', 'MustNotBePopulated', 'NotMeasured')]
    [string]$ExtensionState = 'NotMeasured'
  ) #param

  begin {
    Show-FunctionStatus -Level Live
    $Stack = Get-PSCallStack
    $Called = ($stack.length -ge 3)
    $CalledByAssertTUVC = ($Stack.Command -Contains 'Assert-TeamsUserVoiceConfig')

    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

    # Asserting AzureAD Connection
    if ( -not $script:TFPSSA) { $script:TFPSSA = Assert-AzureADConnection; if ( -not $script:TFPSSA ) { break } }

    # Asserting MicrosoftTeams Connection
    if ( -not $script:TFPSST) { $script:TFPSST = Assert-MicrosoftTeamsConnection; if ( -not $script:TFPSST ) { break } }

    # Setting Preference Variables according to Upstream settings
    if (-not $PSBoundParameters.ContainsKey('Verbose')) { $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference') }
    if (-not $PSBoundParameters.ContainsKey('Confirm')) { $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference') }
    if (-not $PSBoundParameters.ContainsKey('WhatIf')) { $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference') }
    if (-not $PSBoundParameters.ContainsKey('Debug')) { $DebugPreference = $PSCmdlet.SessionState.PSVariable.GetValue('DebugPreference') } else { $DebugPreference = 'Continue' }
    if ( $PSBoundParameters.ContainsKey('InformationAction')) { $InformationPreference = $PSCmdlet.SessionState.PSVariable.GetValue('InformationAction') } else { $InformationPreference = 'Continue' }

    # Preparing Splatting Object
    $parameters = $null
    $Parameters = @{
      'IncludeTDP'         = if ($IncludeTenantDialPlan.IsPresent) { $true } else { $false }
      'Partial'            = if ($Partial.IsPresent) { $true } else { $false }
      'ExtensionState'     = "$ExtensionState"
      'Called'             = $Called
      'CalledByAssertTUVC' = $CalledByAssertTUVC
    }

    function TestUser ($CsUser, $IncludeTDP, $Partial, $ExtensionState, $Called, $CalledByAssertTUVC) {
      if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
        Write-Debug "Parameter validation - Test for Tenant Dial Plan performed: $IncludeTDP"
        Write-Debug "Parameter validation - Test for partial configuration performed: $Partial"
        Write-Debug "Parameter validation - Test for Extension: $ExtensionState"
      }

      #region Testing Interpreted UserType
      $IUT = $CsUser.InterpretedUserType
      $TestObject = 'Interpreted User Type'
      $IUTMisconfigured = ($IUT -match 'Disabled|OnPrem|NotLicensedForService|WithNoService|WithMCOValidationError|NotInPDL|Failed|PendingDeletionFromAD' -or `
        ($IUT -match 'SfB' -and -not $IUT -match 'Teams'))
      if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
        Write-Debug "General - UserType: $IUT"
      }
      if ( -not $IUTMisconfigured) {
        Write-Verbose -Message "User '$User' - $TestObject - Value looks OK, no immediate error-states found"
        if ( -not $Called) {
          Write-Information "INFO:    User '$User' - $TestObject is '$IUT'"
        }
      }
      else {
        Write-Warning -Message "User '$User' - $TestObject is '$IUT'"
        Write-Verbose -Message "Potential misconfiguration detected - Contains 'Disabled', 'OnPrem', 'Failed' or any other error-state. Please investigate!"
        if ( $IUT -match 'WithMCOValidationError' ) {
          $ErrorCode = (($CsUser.MCOValidationError -split '<ErrorCode>')[1] -split [regex]::Escape('</ErrorCode>'))[0]
          $ErrorDescription = (($CsUser.MCOValidationError -split '<ErrorDescription>')[1] -split [regex]::Escape('</ErrorDescription>'))[0]
          Write-Warning "User '$User' - MCOValidationError encountered: '$ErrorCode'"
          Write-Information "INFO:    MCO Validation Error description: '$ErrorDescription'"
        }
      }
      #endregion

      #region SIP Address
      $TestObject = 'SIP Address'
      if ( -not $CsUser.SipAddress ) {
        Write-Warning -Message "User '$User' - $TestObject is not present. User is not able to consume Teams or able to be provisioned for Teams Voice"
      }
      #endregion

      #region Testing EV Enablement as hard requirement
      $TestObject = 'Enterprise Voice Enabled'
      $EVenabled = $CsUser.EnterpriseVoiceEnabled
      if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
        Write-Debug "General - EVenabled: $EVenabled"
      }
      if ($EVenabled) {
        Write-Verbose -Message "User '$User' - $TestObject - OK"
        if ( -not $Called) {
          Write-Information "INFO:    User '$User' - $TestObject - OK"
        }
      }
      else {
        Write-Warning -Message "User '$User' - $TestObject - Not enabled"
      }
      #endregion

      #region Testing Tenant Dial Plan Enablement
      $TestObject = 'Tenant Dial Plan'
      $TDPPresent = ('' -ne $CsUser.TenantDialPlan)
      if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
        Write-Debug "General - TDPPresent: $TDPPresent"
      }
      if ($IncludeTDP) {
        if ($TDPPresent) {
          Write-Verbose -Message "User '$User' - $TestObject - OK"
          if ( -not $Called) {
            Write-Information "INFO:    User '$User' - $TestObject - OK"
          }
        }
        else {
          Write-Warning -Message "User '$User' - $TestObject - Not assigned"
        }
      }
      #endregion

      #VALIDATE This does not work for v2.5.0 - Parameter VoicePolicy seems to be removed?
      #region Testing Voice Configuration for Calling Plans (BusinessVoice) and Direct Routing (HybridVoice)
      if ($CsUser.VoicePolicy -eq 'BusinessVoice') {
        Write-Verbose -Message "InterpretedVoiceConfigType is 'CallingPlans' (VoicePolicy found as 'BusinessVoice')"
        $TestObject = 'BusinessVoice - Calling Plan License'
        $CallPlanPresent = Test-TeamsUserHasCallPlan $User
        if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
          Write-Debug "BusinessVoice - CallPlanPresent: $CallPlanPresent"
        }
        if ($CallPlanPresent) {
          Write-Verbose -Message "User '$User' - $TestObject - OK"
          if ( -not $Called) {
            Write-Information "INFO:    User '$User' - $TestObject - OK"
          }
        }
        else {
          Write-Warning -Message "User '$User' - $TestObject - Not assigned"
        }

        $TestObject = 'BusinessVoice - Phone Number (TelephoneNumber)'
        $TelPresent = ('' -ne $CsUser.TelephoneNumber)
        if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
          Write-Debug "BusinessVoice - TelPresent: $TelPresent"
        }
        if ($TelPresent) {
          if ($ExtensionState -ne 'NotMeasured') {
            Write-Warning -Message 'ExtensionState: Parameter is not usable for BusinessVoice - CallingPlans do not support Extensions'
          }
          Write-Verbose -Message "User '$User' - $TestObject - OK"
          if ( -not $Called) {
            Write-Information "INFO:    User '$User' - $TestObject - OK"
          }
        }
        else {
          Write-Warning -Message "User '$User' - $TestObject - Not assigned"
        }

        #Defining Fully Configured
        $FullyConfigured = ($CallPlanPresent -and $EVenabled -and $TelPresent `
            -and $(if ($IncludeTDP) { $TDPPresent } else { $true }))
        if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
          Write-Debug "BusinessVoice - FullyConfigured: $FullyConfigured"
        }

        if ($Partial) {
          $PartiallyConfigured = (($CallPlanPresent -or $EVenabled -or $TelPresent `
                -or $(if ($IncludeTDP) { $TDPPresent } else { $false })) -and -not $FullyConfigured)
          if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
            Write-Debug "BusinessVoice - PartiallyConfigured: $PartiallyConfigured"
          }
          return $PartiallyConfigured
        }
        else {
          return $FullyConfigured
        }
      }
      elseif ($CsUser.VoicePolicy -eq 'HybridVoice') {
        Write-Verbose -Message "VoicePolicy found as 'HybridVoice'"
        $TestObject = 'HybridVoice - Voice Routing'

        $VRPPresent = ($null -ne $CsUser.VoiceRoutingPolicy)
        $OVPPresent = ($null -ne $CsUser.OnlineVoiceRoutingPolicy)
        if ($VRPPresent) {
          Write-Verbose -Message "InterpretedVoiceConfigType is 'SkypeHybridPSTN' (VoiceRoutingPolicy assigned and no OnlineVoiceRoutingPolicy found)"
          if ( -not $Called) {
            Write-Information "INFO:    User '$User' - $TestObject - Voice Routing Policy - Assigned"
          }
        }
        else {
          Write-Verbose -Message "User '$User' - $TestObject - Voice Routing Policy - Not assigned"
        }
        if ($OVPPresent) {
          Write-Verbose -Message "InterpretedVoiceConfigType is 'DirectRouting' (VoiceRoutingPolicy not assigned)"
          if ( -not $Called) {
            Write-Information "INFO:    User '$User' - $TestObject - Online Voice Routing Policy - Assigned"
          }
        }
        else {
          Write-Verbose -Message "User '$User' - $TestObject - Online Voice Routing Policy - Not Assigned"
        }
        if (-not $VRPPresent -and -not $OVPPresent) {
          Write-Warning -Message "User '$User' - $TestObject - Neither VoiceRoutingPolicy nor OnlineVoiceRoutingPolicy assigned"
        }

        $Routing = ($VRPPresent -or $OVPPresent)
        if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
          Write-Debug "HybridVoice - Routing: $Routing (OVPPresent: $OVPPresent, VRPPresent: $VRPPresent)"
        }

        $TestObject = 'HybridVoice - Phone Number (OnPremLineUri)'
        $TelPresent = ('' -ne $CsUser.OnPremLineURI)
        if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
          Write-Debug "HybridVoice - TelPresent: $TelPresent"
        }
        if ($TelPresent) {
          Write-Verbose -Message "User '$User' - $TestObject - OK"
          if ( -not $Called) {
            Write-Information "INFO:    User '$User' - $TestObject - OK"
          }
        }
        else {
          Write-Warning -Message "User '$User' - $TestObject - Not assigned"
        }

        # Testing Extension State
        if ($ExtensionState -eq 'NotMeasured') {
          $EXTState = $True
        }
        else {
          $TestObject = "HybridVoice - Extension State '$ExtensionState'"
          Write-Verbose -Message "ExtensionState: Validating Extension '$ExtensionState' for HybridVoice"
          switch ($ExtState) {
            'MustBePopulated' {
              $EXTState = $($CsUser.LineUri -contains ';ext=')
            }
            'MustNotBePopulated' {
              $EXTState = $($CsUser.LineUri -notcontains ';ext=')
            }
          }
          if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
            Write-Debug "HybridVoice - EXTState: $EXTState"
          }

          if ($EXTState) {
            Write-Verbose -Message "User '$User' - $TestObject - OK"
            if ( -not $Called) {
              Write-Information "INFO:    User '$User' - $TestObject - OK"
            }
          }
          else {
            Write-Warning -Message "User '$User' - $TestObject - NOT OK"
          }
        }

        #Defining Fully Configured
        $FullyConfigured = ($Routing -and $EVenabled -and $TelPresent -and $EXTState `
            -and $(if ($IncludeTDP) { $TDPPresent } else { $true }))
        if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
          Write-Debug "HybridVoice - FullyConfigured: $FullyConfigured"
        }

        if ($Partial) {
          $PartiallyConfigured = (($Routing -or $EVenabled -or $TelPresent `
                -or $(if ($IncludeTDP) { $TDPPresent } else { $false }) `
                -or $(if ($ExtensionState -ne 'NotMeasured') { $EXTState } else { $false })) -and -not $FullyConfigured)
          if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
            Write-Debug "HybridVoice - PartiallyConfigured: $PartiallyConfigured"
          }
          return $PartiallyConfigured
        }
        else {
          return $FullyConfigured
        }
      }
      else {
        if ( $CalledByAssertTUVC -or -not $Called ) {
          Write-Warning -Message "User '$User' - InterpretedVoiceConfigType is 'Unknown' (undetermined) - No tests can be performed."
          return $false
        }
      }
      #endregion
    }
  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    switch ($PSCmdlet.ParameterSetName) {
      'UserprincipalName' {
        foreach ($User in $UserPrincipalName) {
          Write-Verbose -Message "[PROCESS] Processing '$User'"
          try {
            #NOTE Call placed without the Identity Switch to make remoting call and receive object in tested format (v2.5.0 and higher)
            #$CsUser = Get-CsOnlineUser -Identity "$User" -WarningAction SilentlyContinue -ErrorAction Stop
            $CsUser = Get-CsOnlineUser "$User" -WarningAction SilentlyContinue -ErrorAction Stop
          }
          catch {
            Write-Error "User '$User' not found" -Category ObjectNotFound
            continue
          }
          #$Parameters += @{ 'CsUser' =  }
          TestUser -CsUser $CsUser @Parameters
        }
      }
      'Object' {
        foreach ($O in $Object) {
          Write-Verbose -Message "[PROCESS] Processing provided CsOnlineUser Object for '$($O.UserPrincipalName)'"
          #$Parameters += @{ 'CsUser' = $O }
          TestUser -CsUser $O @Parameters
        }
      }
    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Test-TeamsUserVoiceConfig
