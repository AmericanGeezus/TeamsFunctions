# Module:   TeamsFunctions
# Function: VoiceConfig
# Author:		David Eberhardt
# Updated:  01-APR-2020
# Status:   RC

#CHECK Pipeline with UPN instead of Identity
#TODO Evaluate whether to integrate Find-TeamsUVC (Phone Number unique!) as a test

function Assert-TeamsUserVoiceConfig {
  <#
  .SYNOPSIS
    Tests the validity of the Voice Configuration for one or more Users
  .DESCRIPTION
    Validates Object Type, enablement for Enterprise Voice, and optionally also the Tenant Dial Plan
    For Calling Plans, validates Calling Plan License and presence of Telephone Number
    For Direct Routing, validates Online Voice Routing Policy and OnPremLineUri
    For Skype Hybrid PSTN, validate Voice Routing Policy and OnPremLineUri
    Configuration is always done on the assumption that a full configuration is desired.
    Any partial configuration is fed back on screen.
  .PARAMETER Identity
    Required. UserPrincipalName of the User to be tested
  .PARAMETER IncludeTenantDialPlan
    Optional. By default, only the core requirements for Voice Routing are verified.
    This extends the requirements to also include the Tenant Dial Plan.
  .EXAMPLE
    Assert-TeamsUserVoiceConfig -Identity John@domain.com
    If incorrect/missing, writes information output about every tested parameter
    Returns output of Get-TeamsUserVoiceConfig for all Objects that have an incorrectly configured Voice Configuration
  .EXAMPLE
    Assert-TeamsUserVoiceConfig -Identity John@domain.com -IncludeTenantDialPlan
    If incorrect/missing, writes information output about every tested parameter including the Tenant Dial Plan
    Returns output of Get-TeamsUserVoiceConfig for all Objects that have an incorrectly configured Voice Configuration
  .INPUTS
    System.String
  .OUTPUTS
    System.Object
  .NOTES
    Verbose output is available, though all required information is fed back directly to the User.
    If no objections are found, nothing is returned.
    Piping the Output to Export-Csv can give the best result for investigation into misconfigured users.
  .COMPONENT
    VoiceConfig
  .ROLE
    TeamsUserVoiceConfig
	.FUNCTIONALITY
    Finding Users with a incorrectly set up Voice Configuration
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  .LINK
    https://docs.microsoft.com/en-us/microsoftteams/direct-routing-migrating
  .LINK
    Assert-TeamsUserVoiceConfig
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
  [Alias('Assert-TeamsUVC')]
  #[OutputType([Boolean])]
  param (
    [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = 'Username(s)')]
    [Alias('UserPrincipalName', 'UPN')]
    [string[]]$Identity,

    [Parameter(HelpMessage = 'Extends requirements to include Tenant Dial Plan assignment')]
    [switch]$IncludeTenantDialPlan
  )

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

    foreach ($Id in $Identity) {
      Write-Verbose -Message "[PROCESS] Processing '$Id'"

      try {
        $CsOnlineUser = Get-CsOnlineUser -Identity "$Id" -WarningAction SilentlyContinue -ErrorAction STOP
        $User = $CsOnlineUser.UserPrincipalName
      }
      catch {
        Write-Error -Message "User '$Id' not found"
        continue
      }
      if ($CsOnlineUser.InterpretedUserType -notlike '*User*') {
        Write-Information "User '$User' not a User"
        continue
      }
      if (-not $CsOnlineUser.EnterpriseVoiceEnabled ) {
        Write-Information "User '$User' not enabled for Enterprise Voice"
        continue
      }
      else {
        Write-Verbose -Message "User '$User' - User Voice Configuration (Full)"
        $TestFull = Test-TeamsUserVoiceConfig -Identity "$User"

        if ($TestFull) {
          if (-not $CsOnlineUser.TenantDialPlan -and $IncludeTenantDialPlan ) {
            Write-Information "User '$User' does not have a Tenant Dial Plan assigned"
            continue
          }
          if ($Called) {
            Write-Output $TestFull
          }
          else {
            Write-Information "User '$User' is correctly configured"
            continue
          }
        }
        else {
          Write-Verbose -Message "User '$User' - User Voice Configuration (Partial)"
          #TEST IncludeTenantDialPlan
          if ($IncludeTenantDialPlan) {
            $TestPart = Test-TeamsUserVoiceConfig -Identity "$User" -Partial -IncludeTenantDialPlan
          }
          else {
            $TestPart = Test-TeamsUserVoiceConfig -Identity "$User" -Partial
          }
          if ($TestPart) {
            if ($Called) {
              Write-Output $TestPart
            }
            else {
              Write-Warning "User '$User' is partially configured! Please investigate"
              # Output with Switch (faster with values already queried!)
              Get-TeamsUserVoiceConfig "$User" -SkipLicenseCheck -DiagnosticLevel 1
              #$CsOnlineUser | Select-Object UserPrincipalName, InterpretedUserType, EnterpriseVoiceEnabled, VoiceRoutingPolicy, OnlineVoiceRoutingPolicy, TelephoneNumber, LineUri, OnPremLineURI
            }
          }
        }
      }

    } #foreach Identity

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Assert-TeamsUserVoiceConfig