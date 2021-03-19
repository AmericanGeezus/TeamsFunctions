# Module:   TeamsFunctions
# Function: VoiceConfig
# Author:		David Eberhardt
# Updated:  01-OCT-2020
# Status:   RC




function Test-TeamsUserVoiceConfig {
  <#
	.SYNOPSIS
		Tests whether any Voice Configuration has been applied to one or more Users
	.DESCRIPTION
    For Microsoft Call Plans: Tests for EnterpriseVoice enablement, License AND Phone Number
    For Direct Routing: Tests for EnterpriseVoice enablement, Online Voice Routing Policy AND Phone Number
	.PARAMETER Identity
    Required. UserPrincipalName of the User to be tested
  .PARAMETER Partial
    Optional. By default, returns TRUE only if all required Parameters for the Scope are configured (User is fully provisioned)
    Using this switch, returns TRUE if some of the voice Parameters are configured (User has some or full configuration)
	.EXAMPLE
    Test-TeamsUserVoiceConfig -Identity $UserPrincipalName -Config DirectRouting [-Scope Full]
    Tests for Direct Routing and returns TRUE if FULL configuration is found
	.EXAMPLE
    Test-TeamsUserVoiceConfig -Identity $UserPrincipalName -Config DirectRouting -Scope Partial
    Tests for Direct Routing and returns TRUE if ANY configuration is found
	.EXAMPLE
    Test-TeamsUserVoiceConfig -Identity $UserPrincipalName -Config CallPlans [-Scope Full]
    Tests for Call Plans and returns TRUE if FULL configuration is found
	.EXAMPLE
    Test-TeamsUserVoiceConfig -Identity $UserPrincipalName -Config CallPlans -Scope Partial
    Tests for Call Plans but returns TRUE if ANY configuration is found
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
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  .LINK
    https://docs.microsoft.com/en-us/microsoftteams/direct-routing-migrating
	.LINK
    Find-TeamsUserVoiceConfig
	.LINK
    Get-TeamsTenantVoiceConfig
	.LINK
    Get-TeamsUserVoiceConfig
	.LINK
    Set-TeamsUserVoiceConfig
	.LINK
    Remove-TeamsUserVoiceConfig
	.LINK
    Test-TeamsUserVoiceConfig
	#>

  [CmdletBinding()]
  [Alias('Test-TeamsUVC')]
  [OutputType([Boolean])]
  param(
    [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [Alias('UserPrincipalName')]
    [string[]]$Identity,

    [Parameter(Helpmessage = 'Queries a partial implementation')]
    [switch]$Partial
  ) #param

  begin {
    Show-FunctionStatus -Level RC
    $Stack = Get-PSCallStack
    $Called = ($stack.length -ge 3)

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
    foreach ($User in $Identity) {
      Write-Verbose -Message "[PROCESS] Processing '$User'"
      try {
        $CsUser = Get-CsOnlineUser -Identity "$User" -WarningAction SilentlyContinue -ErrorAction Stop
      }
      catch {
        Write-Error "User '$User' not found" -Category ObjectNotFound
        continue
      }

      # Testing EV Enablement as hard requirement
      $EVenabled = $CsUser.EnterpriseVoiceEnabled
      if ( $Verbose -or -not $Called ) {
        if ($EVenabled) {
          Write-Verbose -Message "User '$User' - Enterprise Voice - OK"
        }
        else {
          Write-Warning -Message "User '$User'- Enterprise Voice - Not enabled"
        }
      }

      if ($CsUser.VoicePolicy -eq 'BusinessVoice') {
        Write-Verbose -Message "InterpretedVoiceConfigType is 'CallingPlans' (VoicePolicy found as 'BusinessVoice')"
        $CallPlanPresent = Test-TeamsUserHasCallPlan $User
        if ( $Verbose -or -not $Called ) {
          if ($CallPlanPresent) {
            Write-Verbose -Message "User '$User' - Calling Plan - OK"
          }
          else {
            Write-Warning -Message "User '$User' - Calling Plan - Not assigned"
          }
        }

        $TelPresent = ('' -ne $CsUser.TelephoneNumber)
        if ( $Verbose -or -not $Called ) {
          if ($TelPresent) {
            Write-Verbose -Message "User '$User' - Phone Number - OK"
          }
          else {
            Write-Warning -Message "User '$User' - Phone Number - Not assigned"
          }
        }

        $FullyConfigured = ($CallPlanPresent -and $EVenabled -and $TelPresent)
        if ($PSBoundParameters.ContainsKey('Partial')) {
          $PartiallyConfigured = (($CallPlanPresent -or $EVenabled -or $TelPresent) -and -not $FullyConfigured)
          return $PartiallyConfigured
        }
        else {
          return $FullyConfigured
        }
      }
      elseif ($CsUser.VoicePolicy -eq 'HybridVoice') {
        Write-Verbose -Message "VoicePolicy found as 'HybridVoice'"

        $VRPPresent = ($null -ne $CsUser.VoiceRoutingPolicy)
        $OVPPresent = ($null -ne $CsUser.OnlineVoiceRoutingPolicy)
        if ( $Verbose -or -not $Called ) {
          if ($VRPPresent) {
            Write-Verbose -Message "InterpretedVoiceConfigType is 'SkypeHybridPSTN' (VoiceRoutingPolicy assigned and no OnlineVoiceRoutingPolicy found)"
            Write-Verbose -Message "User '$User' - Voice Routing - Voice Routing Policy - Assigned"
          }
          else {
            Write-Verbose -Message "User '$User' - Voice Routing - Voice Routing Policy - Not assigned"
          }
          if ($OVPPresent) {
            Write-Verbose -Message "InterpretedVoiceConfigType is 'DirectRouting' (VoiceRoutingPolicy not assigned)"
            Write-Verbose -Message "User '$User' - Voice Routing - Online Voice Routing Policy - Assigned"
          }
          else {
            Write-Verbose -Message "User '$User' - Voice Routing - Online Voice Routing Policy - Not Assigned"
          }
          if (-not $VRPPresent -and -not $OVPPresent) {
            Write-Warning -Message "User '$User' - Voice Routing - Neither VoiceRoutingPolicy nor OnlineVoiceRoutingPolicy assigned"
          }
        }
        $Routing = ($VRPPresent -or $OVPPresent)
        $TelPresent = ('' -ne $CsUser.OnPremLineURI)
        if ( $Verbose -or -not $Called ) {
          if ($TelPresent) {
            Write-Verbose -Message "User '$User' - Phone Number - OK"
          }
          else {
            Write-Warning -Message "User '$User' - Phone Number - Not assigned"
          }
        }

        $FullyConfigured = ($Routing -and $EVenabled -and $TelPresent)
        if ($PSBoundParameters.ContainsKey('Partial')) {
          $PartiallyConfigured = (($Routing -or $EVenabled -or $TelPresent) -and -not $FullyConfigured)
          return $PartiallyConfigured
        }
        else {
          return $FullyConfigured
        }
      }
      else {
        Write-Verbose -Message "InterpretedVoiceConfigType is 'Unknown' (undetermined)"
        return $false
      }

    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Test-TeamsUserVoiceConfig
