# Module:   TeamsFunctions
# Function: Test
# Author:		David Eberhardt
# Updated:  11-OCT-2020

#$Scope = "Private"
#$FunctionPath = "$PSScriptRoot\$Scope\Functions\$($MyInvocation.MyCommand.Name -Replace '.tests.ps1', 'ps1')"
$Function = $MyInvocation.MyCommand.Name -Replace '.tests.ps1', ''

InModuleScope TeamsFunctions {
  Describe -Tags ('Unit', 'Acceptance') "Function '$Function'" {

    It 'Should be false' {
      Mock Set-CsUser { return $false }
      Enable-TeamsUserForEnterpriseVoice -Identity Test@domain.com | Should -BeFalse

    }

    It 'Should be true' {
      Mock Set-CsUser { return $true }
      Enable-TeamsUserForEnterpriseVoice -Identity Test@domain.com | Should -BeTrue

    }
  }
}
