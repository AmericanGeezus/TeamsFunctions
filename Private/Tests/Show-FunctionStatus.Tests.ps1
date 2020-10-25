# Module:   TeamsFunctions
# Function: Test
# Author:		David Eberhardt
# Updated:  11-OCT-2020

$Function = $MyInvocation.MyCommand.Name -Replace '.tests.ps1', ''

InModuleScope TeamsFunctions {
  Describe -Tags ('Unit', 'Acceptance') "Function '$Function'" {

    It 'Should have no output' {
      Show-FunctionStatus | Should -BeNullOrEmpty

    }
  }
}
