# Module:   TeamsFunctions
# Function: VoiceConfig
# Author:		David Eberhardt
# Updated:  01-OCT-2020
# Status:   BETA

function Test-TeamsUserVoiceConfig {
  <#
	.SYNOPSIS
		Tests whether any Voice Configuration has been applied to one or more Users
	.DESCRIPTION
    For Microsoft Call Plans: Tests for EnterpriseVoice enablement, License AND Phone Number
    For Direct Routing: Tests for EnterpriseVoice enablement, Online Voice Routing Policy AND Phone Number
	.PARAMETER Identity
    Required. UserPrincipalName of the User to be tested
	.PARAMETER Scope
    Required. Value to focus the Script on. Allowed Values are DirectRouting,CallingPlans,SkypeHybridPSTN
    Tested Parameters for DirectRouting: EnterpriseVoiceEnabled, VoicePolicy, OnlineVoiceRoutingPolicy, OnPremLineURI
    Tested Parameters for CallPlans: EnterpriseVoiceEnabled, VoicePolicy, User License (Domestic or International Calling Plan), TelephoneNumber
    Tested Parameters for SkypeHybridPSTN: EnterpriseVoiceEnabled, VoicePolicy, VoiceRoutingPolicy, OnlineVoiceRoutingPolicy
  .PARAMETER Partial
    Optional. By default, returns TRUE only if all required Parameters for the Scope are configured (User is fully provisioned)
    Using this switch, returns TRUE if some of the voice Parameters are configured (User has some or full configuration)
	.EXAMPLE
    Test-TeamsUserVoiceConfig -Identity $UserPrincipalName -Scope DirectRouting
    Tests for Direct Routing and returns TRUE if FULL configuration is found
	.EXAMPLE
    Test-TeamsUserVoiceConfig -Identity $UserPrincipalName -Scope DirectRouting -Partial
    Tests for Direct Routing and returns TRUE if ANY configuration is found
	.EXAMPLE
    Test-TeamsUserVoiceConfig -Identity $UserPrincipalName -Scope CallPlans
    Tests for Call Plans and returns TRUE if FULL configuration is found
	.EXAMPLE
    Test-TeamsUserVoiceConfig -Identity $UserPrincipalName -Scope CallPlans -Partial
    Tests for Call Plans but returns TRUE if ANY configuration is found
  .INPUTS
    System.String
  .OUTPUTS
    Boolean
  .NOTES
    All conditions require EnterpriseVoiceEnabled to be TRUE (disabled Users will always return FALSE)
    Partial configuration provides insight for incorrectly de-provisioned configuration that could block configuration for the other.
    For Example: Set-CsUser -Identity $UserPrincipalName -OnPremLineURI
      This will fail if a Domestic Call Plan is assigned OR a TelephoneNumber is remaining assigned to the Object.
      "Remove-TeamsUserVoiceConfig -Force" can help
	.LINK
    Find-TeamsUserVoiceConfig
    Get-TeamsTenantVoiceConfig
    Get-TeamsUserVoiceConfig
    Set-TeamsUserVoiceConfig
    Remove-TeamsUserVoiceConfig
    Test-TeamsUserVoiceConfig
	#>

  [CmdletBinding()]
  [Alias('Test-TeamsUVC')]
  [OutputType([Boolean])]
  param(
    [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [string[]]$Identity,

    [Parameter(Mandatory, HelpMessage = "Defines Scope to remove Voice Configuration")]
    [ValidateSet('DirectRouting', 'CallingPlans', 'SkypeHybridPSTN')]
    [string]$Scope,

    [Parameter(Helpmessage = 'Queries a partial implementation')]
    [switch]$Partial

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
  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    foreach ($User in $Identity) {
      # Querying Identity
      try {
        $CsUser = Get-CsOnlineUser $User -WarningAction SilentlyContinue -ErrorAction Stop
      }
      catch {
        Write-Error "User '$User' not found" -Category ObjectNotFound -ErrorAction Stop
      }

      switch ($Scope) {
        "DirectRouting" {
          if ($PSBoundParameters.ContainsKey('Partial')) {
            if ($CsUser.VoicePolicy -eq "HybridVoice" -and $null -eq $CsUser.VoiceRoutingPolicy -and ($null -ne $CsUser.OnPremLineURI -or $null -ne $CsUser.OnlineVoiceRoutingPolicy)) {
              return $true
            }
            else {
              return $false
            }
          }
          else {
            if ($CsUser.VoicePolicy -eq "HybridVoice" -and $true -eq $CsUser.EnterpriseVoiceEnabled -and $null -eq $CsUser.VoiceRoutingPolicy -and $null -ne $CsUser.OnlineVoiceRoutingPolicy -and $null -ne $CsUser.OnPremLineURI) {
              return $true
            }
            else {
              return $false
            }
          }
        }

        "SkypeHybridPSTN" {
          if ($PSBoundParameters.ContainsKey('Partial')) {
            if ($CsUser.VoicePolicy -eq "HybridVoice" -and $null -eq $CsUser.OnlineVoiceRoutingPolicy -and ($null -ne $CsUser.OnPremLineURI -or $null -ne $CsUser.VoiceRoutingPolicy)) {
              return $true
            }
            else {
              return $false
            }
            else {
              if ($CsUser.VoicePolicy -eq "HybridVoice" -and $true -eq $CsUser.EnterpriseVoiceEnabled -and $null -eq $CsUser.OnlineVoiceRoutingPolicy -and $null -ne $CsUser.VoiceRoutingPolicy -and $null -ne $CsUser.OnPremLineURI) {
                return $true
              }
              else {
                return $false
              }
            }
          }
        }

        "CallingPlans" {
          if ($PSBoundParameters.ContainsKey('Partial')) {
            if ($CsUser.VoicePolicy -eq "BusinessVoice" -or (Test-TeamsUserHasCallPlan $User) -or $null -ne $CsUser.TelephoneNumber) {
              return $true
            }
            else {
              return $false
            }
          }
          else {
            if ($CsUser.VoicePolicy -eq "BusinessVoice" -and (Test-TeamsUserHasCallPlan $User) -and $true -eq $CsUser.EnterpriseVoiceEnabled -and $null -ne $CsUser.TelephoneNumber) {
              return $true
            }
            else {
              return $false
            }
          }
          else {
            return $false
          }
        }
      }
    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Test-TeamsUserVoiceConfig
