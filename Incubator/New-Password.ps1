# Source: https://github.com/Soltroy/little-PSHelpers/blob/master/Functions/New-Password.ps1
# OR better: http://woshub.com/generating-random-password-with-powershell/

function New-Password {
  <#
      .SYNOPSIS
      Generates a Userfriendly or High Secure Password.
      .DESCRIPTION
      #tba
      Userfriendly Password - vocal and consonant, no irritating characters (O0,1Il), common special characters (@?!"$#%&)
      High Secure Password - all characters, numbers and special characters
      .PARAMETER length
      Defines the length of the Password. Valid values are from 8 to 127, default value is 12.
      .PARAMETER asString
      Returns the Password as [String]
      .PARAMETER HighSecure
      Generates a High Secure Password from System.Web Assembly
      .EXAMPLE
      New-LUASPassword
      Generates a Userfriendly Password with 12 Characters and returns it as [SecureString]
      .EXAMPLE
      New-LUASPassword -HighSecure
      Generates a High Secure Password with 12 Characters and returns it as [SecureString]
      .EXAMPLE
      New-LUASPassword -length 25 -asString
      Generates a Userfriendly Password with 25 Characters and returns it as [String]
      .OUTPUTS
      Returns a generated Password as [SecureString] or [String]
      .NOTES
      SolTroys little PSHelpers

      .LINK
      https://github.com/Soltroy/little-PSHelpers
  #>

  [OutputType([SecureString], [String])]
  [Alias('npwd')]
  [CmdletBinding()]
  param(
    [ValidateRange(8, 127)]
    [int]$length = 12,
    [switch]$HighSecure,
    [switch]$asString
  )

  [char[]]$vowel1 = 'aeiou'
  [char[]]$vowel2 = 'aAeEiouU'
  [char[]]$con1 = 'BCDFGHJKLMNPQRSTVWXYZ'
  [char[]]$con2 = 'bBcCdDfFgGhHjJkKLmMnNpPqQrRstTvVwWxXyYzZ'
  [char[]]$numbers = '2346789'
  [char[]]$special = '@?!"$#%&'


  IF ($HighSecure) {
    $Assembly = Add-Type -AssemblyName System.Web
    $secPWD = ConvertTo-SecureString -String ([system.web.security.membership]::GeneratePassword($length, ($length / 8))) -AsPlainText -Force
  }
  ELSE {
    [array]$pwd = ('{0}{1}' -f ($vowel1 | Get-Random), ($con1 | Get-Random))
    FOR ($i = 1; $i -le (($length / 4) - 1); $i++) {
      [array]$pwd += ('{0}{1}' -f ($vowel2 | Get-Random), ($con2 | Get-Random))
    }
    FOR ($i = 1; $i -le ($length / 4); $i++) {
      [array]$pwd += ($numbers | Get-Random)
    }
    FOR ($i = 1; $i -le ($length / 4); $i++) {
      [array]$pwd += ($special | Get-Random)
    }
    ### if the password lenght is less than parameter (happens if length is dividable by 2) fill up with vowel2
    $pwdDiff = ($length - $($pwd -join '').Length)
    FOR ($i = 1; $i -le $pwdDiff; $i++) {
      [array]$pwd += ($vowel2 | Get-Random)
    }

    $secPWD = ConvertTo-SecureString -String (($pwd | Sort-Object -Property {
          Get-Random
        }) -join '') -AsPlainText -Force
  }

  IF ($asString) {
    RETURN [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secPWD))
  }
  ELSE {
    RETURN $secPWD
  }
}
