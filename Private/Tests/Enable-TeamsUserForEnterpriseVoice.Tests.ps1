# Module:   TeamsFunctions
# Function: Test
# Author:		David Eberhardt
# Updated:  11-OCT-2020

#$Scope = "Private"
#$FunctionPath = "$PSScriptRoot\$Scope\Functions\$($MyInvocation.MyCommand.Name -Replace '.tests.ps1', 'ps1')"
$Function = $MyInvocation.MyCommand.Name -Replace '.tests.ps1', ''

Describe -Tags ('Unit', 'Acceptance') "Function '$Function'" {

  It 'Calls with no switch parameter set' {
    { $Function } | Should -BeFalse

  }
}
