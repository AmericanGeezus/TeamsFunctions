# Module:   TeamsFunctions
# Function: Test
# Author:		David Eberhardt
# Updated:  11-OCT-2020

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$here
$target = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\\Tests\\', '\\Functions\\' -replace '\.Tests\.', '.'
$target
$Function = $target -Replace '.ps1.', ''
$Function
#. "$here\$target"

Describe -Tags ('Unit', 'Acceptance') "$Function" {

  It 'Calls with no switch parameter set' {
    { "$Function" } | Should -BeFalse

  }
}