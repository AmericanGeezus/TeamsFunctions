# Module:   TeamsFunctions
# Function: Test
# Author:   David Eberhardt
# Updated:  18-JUL-2021

#$Scope = "Private"
#$FunctionPath = "$PSScriptRoot\$Scope\Functions\$($MyInvocation.MyCommand.Name -Replace '.tests.ps1', 'ps1')"
$Function = $MyInvocation.MyCommand.Name -Replace '.tests.ps1', ''

InModuleScope TeamsFunctions {
  Describe -Tags ('Unit', 'Acceptance') "Function '$Function'" {

    It 'Should be false' {
      #Mock Set-CsUser { return $false }
      Test-AzureAdLicenseContainsServicePlan -License Office365E3 -ServicePlan MCOEV | Should -BeFalse
      Test-AzureAdLicenseContainsServicePlan -License Office365E5 -ServicePlan MCOEV_VIRTUALUSER | Should -BeFalse
    }

    It 'Should be true' {
      #Mock Set-CsUser { return $true }
      Test-AzureAdLicenseContainsServicePlan -License Office365E5 -ServicePlan MCOEV | Should -BeTrue
      Test-AzureAdLicenseContainsServicePlan -License PhoneSystemVirtualUser -ServicePlan MCOEV_VIRTUALUSER | Should -BeTrue
    }
  }
}
