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
    Required. UserPrincipalName or ObjectId of the Object
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

  [CmdletBinding()]
  [Alias('Test-TeamsUVC')]
  [OutputType([Boolean])]
  param(
    [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
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
    foreach ($User in $UserPrincipalName) {
      Write-Verbose -Message "[PROCESS] Processing '$User'"
      try {
        $CsUser = Get-CsOnlineUser -Identity "$User" -WarningAction SilentlyContinue -ErrorAction Stop
      }
      catch {
        Write-Error "User '$User' not found" -Category ObjectNotFound
        continue
      }

      # Testing Interpreted UserType
      $IUT = $CsUser.InterpretedUserType
      $TestObject = "Interpreted User Type is '$IUT'"
      $IUTMisconfigured = ($IUT -match 'Disabled|OnPrem|NotLicensedForService|WithNoService|WithMCOValidationError|NotInPDL|Failed|PendingDeletionFromAD' -or `
        ($IUT -match 'SfB' -and -not $IUT -match 'Teams'))

      if ( -not $IUTMisconfigured) {
        Write-Verbose -Message "User '$User' - $TestObject - Value looks OK, no immediate error-states found"
        if ( -not $Called) {
          Write-Information "INFO:    User '$User' - $TestObject"
        }
      }
      else {
        Write-Warning -Message "User '$User' - $TestObject"
        Write-Verbose -Message "Potential misconfiguration detected - Contains 'Disabled', 'OnPrem', 'Failed' or any other error-state. Please investigate!"
      }


      # Testing EV Enablement as hard requirement
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




      # Testing Tenant Dial Plan Enablement
      $TestObject = 'Tenant Dial Plan'
      $TDPPresent = ('' -ne $CsUser.TenantDialPlan)
      if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
        Write-Debug "General - TDPPresent: $TDPPresent"
      }
      if ($IncludeTenantDialPlan.IsPresent) {
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

      # Testing Voice Configuration for Calling Plans (BusinessVoice) and Direct Routing (HybridVoice)
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
            -and $(if ($IncludeTenantDialPlan.IsPresent) { $TDPPresent } else { $true }))
        if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
          Write-Debug "BusinessVoice - FullyConfigured: $FullyConfigured"
        }

        if ($PSBoundParameters.ContainsKey('Partial')) {
          $PartiallyConfigured = (($CallPlanPresent -or $EVenabled -or $TelPresent `
                -or $(if ($IncludeTenantDialPlan.IsPresent) { $TDPPresent } else { $false })) -and -not $FullyConfigured)
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
          switch ($ExtensionState) {
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
            -and $(if ($IncludeTenantDialPlan.IsPresent) { $TDPPresent } else { $true }))
        if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
          Write-Debug "HybridVoice - FullyConfigured: $FullyConfigured"
        }

        if ($PSBoundParameters.ContainsKey('Partial')) {
          $PartiallyConfigured = (($Routing -or $EVenabled -or $TelPresent `
                -or $(if ($IncludeTenantDialPlan.IsPresent) { $TDPPresent } else { $false }) `
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

    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Test-TeamsUserVoiceConfig
