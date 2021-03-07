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
    Format-StringForUse -InputString 'Test' | Should -BeOfType System.String

  }

  It 'Should return correct String manipulations' {
    Format-StringForUse -InputString 'Test' | Should -BeExactly 'Test'
    Format-StringForUse -InputString '[Test]' | Should -BeExactly 'Test'
    Format-StringForUse -InputString '(Test)' | Should -BeExactly 'Test'
    Format-StringForUse -InputString '{Test}' | Should -BeExactly 'Test'
    Format-StringForUse -InputString 'Test?' | Should -BeExactly 'Test'

  }

  It 'Should return correct String manipulations for -As UserPrincipalName' {
    Format-StringForUse -InputString '\%&*+/=?{}|<>();:,[]"' -As UserPrincipalName | Should -BeExactly ''
    Format-StringForUse -InputString "'´" -As UserPrincipalName | Should -BeExactly ''

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
    Format-StringForUse -InputString "'´" -As UserPrincipalName | Should -Not -Contain '´'

  }

  It 'Should return correct String manipulations for -As DisplayName' {
    Format-StringForUse -InputString '\%*+/=?{}|<>[]"' -As DisplayName | Should -BeExactly ''
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

  It 'Should return correct String manipulations for -As LineURI' {
    Format-StringForUse -InputString '\%*/-()?{}|<>[]" abcdfghijkmnopqrsuvwyz' -As LineURI | Should -BeExactly ''
    Format-StringForUse -InputString '\%*/-()?{}|<>[]" abcdfghijkmnopqrsuvwyz' -As LineURI | Should -Not -Contain '\'
    Format-StringForUse -InputString '\%*/-()?{}|<>[]" abcdfghijkmnopqrsuvwyz' -As LineURI | Should -Not -Contain '%'
    Format-StringForUse -InputString '\%*/-()?{}|<>[]" abcdfghijkmnopqrsuvwyz' -As LineURI | Should -Not -Contain '*'
    Format-StringForUse -InputString '\%*/-()?{}|<>[]" abcdfghijkmnopqrsuvwyz' -As LineURI | Should -Not -Contain '+'
    Format-StringForUse -InputString '\%*/-()?{}|<>[]" abcdfghijkmnopqrsuvwyz' -As LineURI | Should -Not -Contain '/'
    Format-StringForUse -InputString '\%*/-()?{}|<>[]" abcdfghijkmnopqrsuvwyz' -As LineURI | Should -Not -Contain '='
    Format-StringForUse -InputString '\%*/-()?{}|<>[]" abcdfghijkmnopqrsuvwyz' -As LineURI | Should -Not -Contain '?'
    Format-StringForUse -InputString '\%*/-()?{}|<>[]" abcdfghijkmnopqrsuvwyz' -As LineURI | Should -Not -Contain '?'
    Format-StringForUse -InputString '\%*/-()?{}|<>[]" abcdfghijkmnopqrsuvwyz' -As LineURI | Should -Not -Contain '{'
    Format-StringForUse -InputString '\%*/-()?{}|<>[]" abcdfghijkmnopqrsuvwyz' -As LineURI | Should -Not -Contain '}'
    Format-StringForUse -InputString '\%*/-()?{}|<>[]" abcdfghijkmnopqrsuvwyz' -As LineURI | Should -Not -Contain '|'
    Format-StringForUse -InputString '\%*/-()?{}|<>[]" abcdfghijkmnopqrsuvwyz' -As LineURI | Should -Not -Contain '<'
    Format-StringForUse -InputString '\%*/-()?{}|<>[]" abcdfghijkmnopqrsuvwyz' -As LineURI | Should -Not -Contain '>'
    Format-StringForUse -InputString '\%*/-()?{}|<>[]" abcdfghijkmnopqrsuvwyz' -As LineURI | Should -Not -Contain '['
    Format-StringForUse -InputString '\%*/-()?{}|<>[]" abcdfghijkmnopqrsuvwyz' -As LineURI | Should -Not -Contain ']'
    Format-StringForUse -InputString '\%*/-()?{}|<>[]" abcdfghijkmnopqrsuvwyz' -As LineURI | Should -Not -Contain '"'

    Format-StringForUse -InputString '\%*/-()?{}|<>[]" abcdfghijkmnopqrsuvwyz' -As LineURI | Should -Not -Contain ' '
    Format-StringForUse -InputString '\%*/-()?{}|<>[]" abcdfghijkmnopqrsuvwyz' -As LineURI | Should -Not -Contain 'a'
    Format-StringForUse -InputString '\%*/-()?{}|<>[]" abcdfghijkmnopqrsuvwyz' -As LineURI | Should -Not -Contain 'b'
    Format-StringForUse -InputString '\%*/-()?{}|<>[]" abcdfghijkmnopqrsuvwyz' -As LineURI | Should -Not -Contain 'c'
    Format-StringForUse -InputString '\%*/-()?{}|<>[]" abcdfghijkmnopqrsuvwyz' -As LineURI | Should -Not -Contain 'd'
    Format-StringForUse -InputString '\%*/-()?{}|<>[]" abcdfghijkmnopqrsuvwyz' -As LineURI | Should -Not -Contain 'f'
    Format-StringForUse -InputString '\%*/-()?{}|<>[]" abcdfghijkmnopqrsuvwyz' -As LineURI | Should -Not -Contain 'g'
    Format-StringForUse -InputString '\%*/-()?{}|<>[]" abcdfghijkmnopqrsuvwyz' -As LineURI | Should -Not -Contain 'h'
    Format-StringForUse -InputString '\%*/-()?{}|<>[]" abcdfghijkmnopqrsuvwyz' -As LineURI | Should -Not -Contain 'i'
    Format-StringForUse -InputString '\%*/-()?{}|<>[]" abcdfghijkmnopqrsuvwyz' -As LineURI | Should -Not -Contain 'j'
    Format-StringForUse -InputString '\%*/-()?{}|<>[]" abcdfghijkmnopqrsuvwyz' -As LineURI | Should -Not -Contain 'k'
    Format-StringForUse -InputString '\%*/-()?{}|<>[]" abcdfghijkmnopqrsuvwyz' -As LineURI | Should -Not -Contain 'm'
    Format-StringForUse -InputString '\%*/-()?{}|<>[]" abcdfghijkmnopqrsuvwyz' -As LineURI | Should -Not -Contain 'n'
    Format-StringForUse -InputString '\%*/-()?{}|<>[]" abcdfghijkmnopqrsuvwyz' -As LineURI | Should -Not -Contain 'o'
    Format-StringForUse -InputString '\%*/-()?{}|<>[]" abcdfghijkmnopqrsuvwyz' -As LineURI | Should -Not -Contain 'p'
    Format-StringForUse -InputString '\%*/-()?{}|<>[]" abcdfghijkmnopqrsuvwyz' -As LineURI | Should -Not -Contain 'q'
    Format-StringForUse -InputString '\%*/-()?{}|<>[]" abcdfghijkmnopqrsuvwyz' -As LineURI | Should -Not -Contain 'r'
    Format-StringForUse -InputString '\%*/-()?{}|<>[]" abcdfghijkmnopqrsuvwyz' -As LineURI | Should -Not -Contain 's'
    Format-StringForUse -InputString '\%*/-()?{}|<>[]" abcdfghijkmnopqrsuvwyz' -As LineURI | Should -Not -Contain 'u'
    Format-StringForUse -InputString '\%*/-()?{}|<>[]" abcdfghijkmnopqrsuvwyz' -As LineURI | Should -Not -Contain 'v'
    Format-StringForUse -InputString '\%*/-()?{}|<>[]" abcdfghijkmnopqrsuvwyz' -As LineURI | Should -Not -Contain 'x'
    Format-StringForUse -InputString '\%*/-()?{}|<>[]" abcdfghijkmnopqrsuvwyz' -As LineURI | Should -Not -Contain 'y'
    Format-StringForUse -InputString '\%*/-()?{}|<>[]" abcdfghijkmnopqrsuvwyz' -As LineURI | Should -Not -Contain 'z'
  }

  It 'Should return correct String manipulations for -As E164' {
    Format-StringForUse -InputString '\%*/@:=-()?{}|<>[]" abcdefghijklmnopqrstuvwxyz;' -As E164 | Should -BeExactly ''
    Format-StringForUse -InputString '\%*/@:=-()?{}|<>[]" abcdefghijklmnopqrstuvwxyz;' -As E164 | Should -Not -Contain '\'
    Format-StringForUse -InputString '\%*/@:=-()?{}|<>[]" abcdefghijklmnopqrstuvwxyz;' -As E164 | Should -Not -Contain '%'
    Format-StringForUse -InputString '\%*/@:=-()?{}|<>[]" abcdefghijklmnopqrstuvwxyz;' -As E164 | Should -Not -Contain '*'
    Format-StringForUse -InputString '\%*/@:=-()?{}|<>[]" abcdefghijklmnopqrstuvwxyz;' -As E164 | Should -Not -Contain '+'
    Format-StringForUse -InputString '\%*/@:=-()?{}|<>[]" abcdefghijklmnopqrstuvwxyz;' -As E164 | Should -Not -Contain '/'
    Format-StringForUse -InputString '\%*/@:=-()?{}|<>[]" abcdefghijklmnopqrstuvwxyz;' -As E164 | Should -Not -Contain '='
    Format-StringForUse -InputString '\%*/@:=-()?{}|<>[]" abcdefghijklmnopqrstuvwxyz;' -As E164 | Should -Not -Contain '?'
    Format-StringForUse -InputString '\%*/@:=-()?{}|<>[]" abcdefghijklmnopqrstuvwxyz;' -As E164 | Should -Not -Contain '?'
    Format-StringForUse -InputString '\%*/@:=-()?{}|<>[]" abcdefghijklmnopqrstuvwxyz;' -As E164 | Should -Not -Contain '{'
    Format-StringForUse -InputString '\%*/@:=-()?{}|<>[]" abcdefghijklmnopqrstuvwxyz;' -As E164 | Should -Not -Contain '}'
    Format-StringForUse -InputString '\%*/@:=-()?{}|<>[]" abcdefghijklmnopqrstuvwxyz;' -As E164 | Should -Not -Contain '|'
    Format-StringForUse -InputString '\%*/@:=-()?{}|<>[]" abcdefghijklmnopqrstuvwxyz;' -As E164 | Should -Not -Contain '<'
    Format-StringForUse -InputString '\%*/@:=-()?{}|<>[]" abcdefghijklmnopqrstuvwxyz;' -As E164 | Should -Not -Contain '>'
    Format-StringForUse -InputString '\%*/@:=-()?{}|<>[]" abcdefghijklmnopqrstuvwxyz;' -As E164 | Should -Not -Contain '['
    Format-StringForUse -InputString '\%*/@:=-()?{}|<>[]" abcdefghijklmnopqrstuvwxyz;' -As E164 | Should -Not -Contain ']'
    Format-StringForUse -InputString '\%*/@:=-()?{}|<>[]" abcdefghijklmnopqrstuvwxyz;' -As E164 | Should -Not -Contain '"'
    Format-StringForUse -InputString '\%*/@:=-()?{}|<>[]" abcdefghijklmnopqrstuvwxyz;' -As E164 | Should -Not -Contain ' '

    Format-StringForUse -InputString '\%*/@:=-()?{}|<>[]" abcdefghijklmnopqrstuvwxyz;' -As E164 | Should -Not -Contain 'a'
    Format-StringForUse -InputString '\%*/@:=-()?{}|<>[]" abcdefghijklmnopqrstuvwxyz;' -As E164 | Should -Not -Contain 'b'
    Format-StringForUse -InputString '\%*/@:=-()?{}|<>[]" abcdefghijklmnopqrstuvwxyz;' -As E164 | Should -Not -Contain 'c'
    Format-StringForUse -InputString '\%*/@:=-()?{}|<>[]" abcdefghijklmnopqrstuvwxyz;' -As E164 | Should -Not -Contain 'd'
    Format-StringForUse -InputString '\%*/@:=-()?{}|<>[]" abcdefghijklmnopqrstuvwxyz;' -As E164 | Should -Not -Contain 'e'
    Format-StringForUse -InputString '\%*/@:=-()?{}|<>[]" abcdefghijklmnopqrstuvwxyz;' -As E164 | Should -Not -Contain 'f'
    Format-StringForUse -InputString '\%*/@:=-()?{}|<>[]" abcdefghijklmnopqrstuvwxyz;' -As E164 | Should -Not -Contain 'g'
    Format-StringForUse -InputString '\%*/@:=-()?{}|<>[]" abcdefghijklmnopqrstuvwxyz;' -As E164 | Should -Not -Contain 'h'
    Format-StringForUse -InputString '\%*/@:=-()?{}|<>[]" abcdefghijklmnopqrstuvwxyz;' -As E164 | Should -Not -Contain 'i'
    Format-StringForUse -InputString '\%*/@:=-()?{}|<>[]" abcdefghijklmnopqrstuvwxyz;' -As E164 | Should -Not -Contain 'j'
    Format-StringForUse -InputString '\%*/@:=-()?{}|<>[]" abcdefghijklmnopqrstuvwxyz;' -As E164 | Should -Not -Contain 'k'
    Format-StringForUse -InputString '\%*/@:=-()?{}|<>[]" abcdefghijklmnopqrstuvwxyz;' -As E164 | Should -Not -Contain 'l'
    Format-StringForUse -InputString '\%*/@:=-()?{}|<>[]" abcdefghijklmnopqrstuvwxyz;' -As E164 | Should -Not -Contain 'm'
    Format-StringForUse -InputString '\%*/@:=-()?{}|<>[]" abcdefghijklmnopqrstuvwxyz;' -As E164 | Should -Not -Contain 'n'
    Format-StringForUse -InputString '\%*/@:=-()?{}|<>[]" abcdefghijklmnopqrstuvwxyz;' -As E164 | Should -Not -Contain 'o'
    Format-StringForUse -InputString '\%*/@:=-()?{}|<>[]" abcdefghijklmnopqrstuvwxyz;' -As E164 | Should -Not -Contain 'p'
    Format-StringForUse -InputString '\%*/@:=-()?{}|<>[]" abcdefghijklmnopqrstuvwxyz;' -As E164 | Should -Not -Contain 'q'
    Format-StringForUse -InputString '\%*/@:=-()?{}|<>[]" abcdefghijklmnopqrstuvwxyz;' -As E164 | Should -Not -Contain 'r'
    Format-StringForUse -InputString '\%*/@:=-()?{}|<>[]" abcdefghijklmnopqrstuvwxyz;' -As E164 | Should -Not -Contain 's'
    Format-StringForUse -InputString '\%*/@:=-()?{}|<>[]" abcdefghijklmnopqrstuvwxyz;' -As E164 | Should -Not -Contain 't'
    Format-StringForUse -InputString '\%*/@:=-()?{}|<>[]" abcdefghijklmnopqrstuvwxyz;' -As E164 | Should -Not -Contain 'u'
    Format-StringForUse -InputString '\%*/@:=-()?{}|<>[]" abcdefghijklmnopqrstuvwxyz;' -As E164 | Should -Not -Contain 'v'
    Format-StringForUse -InputString '\%*/@:=-()?{}|<>[]" abcdefghijklmnopqrstuvwxyz;' -As E164 | Should -Not -Contain 'x'
    Format-StringForUse -InputString '\%*/@:=-()?{}|<>[]" abcdefghijklmnopqrstuvwxyz;' -As E164 | Should -Not -Contain 'y'
    Format-StringForUse -InputString '\%*/@:=-()?{}|<>[]" abcdefghijklmnopqrstuvwxyz;' -As E164 | Should -Not -Contain 'z'

  }

  It 'Should return correct String manipulations for -Replacement "-"' {
    Format-StringForUse -InputString '\%&*+/=?{}|<>();:,[]"' -Replacement '-' -As UserPrincipalName | Should -Not -BeExactly ''
    Format-StringForUse -InputString "'´" -Replacement '-' -As UserPrincipalName | Should -Not -BeExactly ''
    Format-StringForUse -InputString '\%*+/=?{}|<>[]"' -Replacement '-' -As DisplayName | Should -Not -BeExactly ''

    Format-StringForUse -InputString '\%&*+/=?{}|<>();:,[]"' -Replacement '-' -As UserPrincipalName | Should -BeExactly '---------------------'
    Format-StringForUse -InputString "'´" -Replacement '-' -As UserPrincipalName | Should -BeExactly '--'
    Format-StringForUse -InputString '\%*+/=?{}|<>[]"' -Replacement '-' -As DisplayName | Should -BeExactly '---------------'

    Format-StringForUse -InputString '\%*/@:=-()?{}|<>[]" abcdefghijklmnopqrstuvwxyz;' -As E164 | Should -BeExactly ''
    Format-StringForUse -InputString '\%*/-()?{}|<>[]" abcdfghijkmnopqrsuvwyz' -As LineUri | Should -BeExactly ''

  }

  It 'Should normalise E.164 numbers correctly' {
    Format-StringForUse -InputString 'TEL: +1 (555) 1234-567' -As E164 | Should -BeExactly '+15551234567'
    Format-StringForUse -InputString 'TEL:+1 (555) 1234-567' -As E164 | Should -BeExactly '+15551234567'
    Format-StringForUse -InputString 'TEL: 1 (555) 1234-567' -As E164 | Should -BeExactly '+15551234567'
    Format-StringForUse -InputString '+1 (555) 1234-567' -As E164 | Should -BeExactly '+15551234567'
    Format-StringForUse -InputString '1 (555) 1234-567' -As E164 | Should -BeExactly '+15551234567'
    Format-StringForUse -InputString '1 (555) 1234-567 ;EXT=1234' -As E164 | Should -BeExactly '+15551234567'

    Format-StringForUse -InputString 'tel: +1 (555) 1234-567' -As E164 | Should -BeExactly '+15551234567'
    Format-StringForUse -InputString 'tel:+1 (555) 1234-567' -As E164 | Should -BeExactly '+15551234567'
    Format-StringForUse -InputString 'tel: 1 (555) 1234-567' -As E164 | Should -BeExactly '+15551234567'
    Format-StringForUse -InputString '+1 (555) 1234-567' -As E164 | Should -BeExactly '+15551234567'
    Format-StringForUse -InputString '1 (555) 1234-567' -As E164 | Should -BeExactly '+15551234567'
    Format-StringForUse -InputString '1 (555) 1234-567 ;ext=1234' -As E164 | Should -BeExactly '+15551234567'
  }

  It 'Should normalise LineURIs correctly' {
    Format-StringForUse -InputString 'TEL: +1 (555) 1234-567' -As LineURI | Should -BeExactly 'TEL:+15551234567'
    Format-StringForUse -InputString 'TEL:+1 (555) 1234-567' -As LineURI | Should -BeExactly 'TEL:+15551234567'
    Format-StringForUse -InputString 'TEL: 1 (555) 1234-567' -As LineURI | Should -BeExactly 'tel:+15551234567'

    Format-StringForUse -InputString 'tel: +1 (555) 1234-567' -As LineURI | Should -BeExactly 'tel:+15551234567'
    Format-StringForUse -InputString 'tel:+1 (555) 1234-567' -As LineURI | Should -BeExactly 'tel:+15551234567'
    Format-StringForUse -InputString 'tel: 1 (555) 1234-567' -As LineURI | Should -BeExactly 'tel:+15551234567'

    Format-StringForUse -InputString '+1 (555) 1234-567' -As LineURI | Should -BeExactly 'tel:+15551234567'
    Format-StringForUse -InputString '1 (555) 1234-567' -As LineURI | Should -BeExactly 'tel:+15551234567'

    Format-StringForUse -InputString '1 (555) 1234-567 ;ext=1234' -As LineURI | Should -BeExactly 'tel:+15551234567;ext=1234'
    Format-StringForUse -InputString '1 (555) 1234-567 ;EXT=1234' -As LineURI | Should -BeExactly 'tel:+15551234567;EXT=1234'
  }

  It 'Should return correct String manipulations for -SpecialChars "[]"' {
    Format-StringForUse -InputString 'Test' -SpecialChars '[]' | Should -BeExactly 'Test'
    Format-StringForUse -InputString '[Test]' -SpecialChars '[]' | Should -BeExactly 'Test'
    Format-StringForUse -InputString '(Test)' -SpecialChars '[]' | Should -BeExactly '(Test)'
    Format-StringForUse -InputString '{Test}' -SpecialChars '[]' | Should -BeExactly '{Test}'
    Format-StringForUse -InputString 'Test?' -SpecialChars '[]' | Should -BeExactly 'Test?'

  }


}
