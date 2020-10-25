# Module:   TeamsFunctions
# Function: Test
# Author:		David Eberhardt
# Updated:  11-OCT-2020

#$Scope = "Public"
#$FunctionPath = "$PSScriptRoot\$Scope\Functions\$($MyInvocation.MyCommand.Name -Replace '.tests.ps1', 'ps1')"
$Function = $MyInvocation.MyCommand.Name -Replace '.tests.ps1', ''

Describe -Tags ('Unit', 'Acceptance') "Function '$Function'" {

  It 'Should have String parameters defined' {
    Get-Command Format-StringForUse | Should -HaveParameter InputString -Type string
    Get-Command Format-StringForUse | Should -HaveParameter Replacement -Type string
    Get-Command Format-StringForUse | Should -HaveParameter As -Type string
    Get-Command Format-StringForUse | Should -HaveParameter SpecialChars -Type string

  }

  It 'Should be of type System.String' {
    Format-StringForUse -InputString "Test" | Should -BeOfType System.String

  }

  It 'Should return correct String manipulations' {
    Format-StringForUse -InputString "Test" | Should -BeExactly "Test"
    Format-StringForUse -InputString "[Test]" | Should -BeExactly "Test"
    Format-StringForUse -InputString "(Test)" | Should -BeExactly "Test"
    Format-StringForUse -InputString "{Test}" | Should -BeExactly "Test"
    Format-StringForUse -InputString "Test?" | Should -BeExactly "Test"

  }

  It 'Should return correct String manipulations for -As UserPrincipalName' {
    Format-StringForUse -InputString '\%&*+/=?{}|<>();:,[]"' -As UserPrincipalName | Should -BeExactly ""
    Format-StringForUse -InputString "'´" -As UserPrincipalName | Should -BeExactly ""

    Format-StringForUse -InputString '\%*+/=?{}|<>[]"' -As UserPrincipalName | Should -Not -Contain '\'
    Format-StringForUse -InputString '\%*+/=?{}|<>[]"' -As UserPrincipalName | Should -Not -Contain '%'
    Format-StringForUse -InputString '\%*+/=?{}|<>[]"' -As UserPrincipalName | Should -Not -Contain '*'
    Format-StringForUse -InputString '\%*+/=?{}|<>[]"' -As UserPrincipalName | Should -Not -Contain '+'
    Format-StringForUse -InputString '\%*+/=?{}|<>[]"' -As UserPrincipalName | Should -Not -Contain '/'
    Format-StringForUse -InputString '\%*+/=?{}|<>[]"' -As UserPrincipalName | Should -Not -Contain '='
    Format-StringForUse -InputString '\%*+/=?{}|<>[]"' -As UserPrincipalName | Should -Not -Contain '?'
    Format-StringForUse -InputString '\%*+/=?{}|<>[]"' -As UserPrincipalName | Should -Not -Contain '?'
    Format-StringForUse -InputString '\%*+/=?{}|<>[]"' -As UserPrincipalName | Should -Not -Contain '{'
    Format-StringForUse -InputString '\%*+/=?{}|<>[]"' -As UserPrincipalName | Should -Not -Contain '}'
    Format-StringForUse -InputString '\%*+/=?{}|<>[]"' -As UserPrincipalName | Should -Not -Contain '|'
    Format-StringForUse -InputString '\%*+/=?{}|<>[]"' -As UserPrincipalName | Should -Not -Contain '<'
    Format-StringForUse -InputString '\%*+/=?{}|<>[]"' -As UserPrincipalName | Should -Not -Contain '>'
    Format-StringForUse -InputString '\%*+/=?{}|<>[]"' -As UserPrincipalName | Should -Not -Contain '['
    Format-StringForUse -InputString '\%*+/=?{}|<>[]"' -As UserPrincipalName | Should -Not -Contain ']'
    Format-StringForUse -InputString '\%*+/=?{}|<>[]"' -As UserPrincipalName | Should -Not -Contain '"'

    Format-StringForUse -InputString "'´" -As UserPrincipalName | Should -Not -Contain "'"
    Format-StringForUse -InputString "'´" -As UserPrincipalName | Should -Not -Contain "´"

  }

  It 'Should return correct String manipulations for -As DisplayName' {
    Format-StringForUse -InputString '\%*+/=?{}|<>[]"' -As DisplayName | Should -BeExactly ""
    Format-StringForUse -InputString '\%*+/=?{}|<>[]"' -As DisplayName | Should -Not -Contain '\'
    Format-StringForUse -InputString '\%*+/=?{}|<>[]"' -As DisplayName | Should -Not -Contain '%'
    Format-StringForUse -InputString '\%*+/=?{}|<>[]"' -As DisplayName | Should -Not -Contain '*'
    Format-StringForUse -InputString '\%*+/=?{}|<>[]"' -As DisplayName | Should -Not -Contain '+'
    Format-StringForUse -InputString '\%*+/=?{}|<>[]"' -As DisplayName | Should -Not -Contain '/'
    Format-StringForUse -InputString '\%*+/=?{}|<>[]"' -As DisplayName | Should -Not -Contain '='
    Format-StringForUse -InputString '\%*+/=?{}|<>[]"' -As DisplayName | Should -Not -Contain '?'
    Format-StringForUse -InputString '\%*+/=?{}|<>[]"' -As DisplayName | Should -Not -Contain '?'
    Format-StringForUse -InputString '\%*+/=?{}|<>[]"' -As DisplayName | Should -Not -Contain '{'
    Format-StringForUse -InputString '\%*+/=?{}|<>[]"' -As DisplayName | Should -Not -Contain '}'
    Format-StringForUse -InputString '\%*+/=?{}|<>[]"' -As DisplayName | Should -Not -Contain '|'
    Format-StringForUse -InputString '\%*+/=?{}|<>[]"' -As DisplayName | Should -Not -Contain '<'
    Format-StringForUse -InputString '\%*+/=?{}|<>[]"' -As DisplayName | Should -Not -Contain '>'
    Format-StringForUse -InputString '\%*+/=?{}|<>[]"' -As DisplayName | Should -Not -Contain '['
    Format-StringForUse -InputString '\%*+/=?{}|<>[]"' -As DisplayName | Should -Not -Contain ']'
    Format-StringForUse -InputString '\%*+/=?{}|<>[]"' -As DisplayName | Should -Not -Contain '"'

  }

  It 'Should return correct String manipulations for -Replacement "-"' {
    Format-StringForUse -InputString '\%&*+/=?{}|<>();:,[]"' -Replacement "-" -As UserPrincipalName | Should -Not -BeExactly ""
    Format-StringForUse -InputString "'´" -Replacement "-" -As UserPrincipalName | Should -Not -BeExactly ""
    Format-StringForUse -InputString '\%*+/=?{}|<>[]"' -Replacement "-" -As DisplayName | Should -Not -BeExactly ""

    Format-StringForUse -InputString '\%&*+/=?{}|<>();:,[]"' -Replacement "-" -As UserPrincipalName | Should -BeExactly "---------------------"
    Format-StringForUse -InputString "'´" -Replacement "-" -As UserPrincipalName | Should -BeExactly "--"
    Format-StringForUse -InputString '\%*+/=?{}|<>[]"' -Replacement "-" -As DisplayName | Should -BeExactly "---------------"

  }

  It 'Should return correct String manipulations for -SpecialChars "[]"' {
    Format-StringForUse -InputString "Test" -SpecialChars "[]" | Should -BeExactly "Test"
    Format-StringForUse -InputString "[Test]" -SpecialChars "[]" | Should -BeExactly "Test"
    Format-StringForUse -InputString "(Test)" -SpecialChars "[]" | Should -BeExactly "(Test)"
    Format-StringForUse -InputString "{Test}" -SpecialChars "[]" | Should -BeExactly "{Test}"
    Format-StringForUse -InputString "Test?" -SpecialChars "[]" | Should -BeExactly "Test?"

  }


}
