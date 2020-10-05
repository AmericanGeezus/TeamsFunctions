#$here = Split-Path -Parent $MyInvocation.MyCommand.Path

$module = 'TeamsFunctions'
$here = Get-Location

Describe -Tags ('Unit', 'Acceptance') "$module Module Tests"  {

  Context 'Module Setup' {
    It "has the root module $module.psm1" {
      "$here\$module.psm1" | Should -Exist
    }

    It "has the a manifest file of $module.psd1" {
      "$here\$module.psd1" | Should -Exist
      "$here\$module.psd1" | Should -FileContentMatch "$module.psm1"
    }

    It "$module folder has functions" {
      "$here\Public\Functions" | Should -Exist
      "$here\Private\Functions" | Should -Exist
    }

    It "$module is valid PowerShell code" {
      $psFile = Get-Content -Path "$here\$module.psm1" -ErrorAction Stop
      $errors = $null
      $null = [System.Management.Automation.PSParser]::Tokenize($psFile, [ref]$errors)
      $errors.Count | Should -Be 0
    }

  } # Context 'Module Setup'

  $functions = (Get-ChildItem "$here\Public", "$here\Private" -Include "*.ps1" -ExClude "*.Tests.ps1" -Recurse | Select-Object -First 1).BaseName

  foreach ($function in $functions) {

    Context "$Name - Function" {

      It "should exist" {
        $function | Should -Exist
      }

      <#
      It "should have a valid header" {
        $function | Should -FileContentMatch 'Module:'
        $function | Should -FileContentMatch 'Function:'
        $function | Should -FileContentMatch 'Author:'
        $function | Should -FileContentMatch 'Updated:'
        $function | Should -FileContentMatch 'Status:'
      }

      It "should have help block" {
        $function | Should -FileContentMatch '`<`#'
        $function | Should -FileContentMatch '` #`>'
      }

      It "should have a SYNOPSIS section in the help block" {
        $function | Should -FileContentMatch '.SYNOPSIS'
      }

      It "should have a DESCRIPTION section in the help block" {
        $function | Should -FileContentMatch '.DESCRIPTION'
      }

      It "should have a EXAMPLE section in the help block" {
        $function | Should -FileContentMatch '.EXAMPLE'
      }

      # Add more checks for !

      # Evaluate use - not all Functions are advanced yet!

      It "should be an advanced function" {
        $function | Should -FileContentMatch 'function'
        $function | Should -FileContentMatch 'cmdletbinding'
        $function | Should -FileContentMatch 'param'
        #Add: OutputType, Return
      }

      It "should contain Write-Verbose blocks" {
        $function | Should -FileContentMatch 'Write-Verbose'
      }

      It "is valid PowerShell code" {
        $psFile = Get-Content -Path $function -ErrorAction Stop
        $errors = $null
        $null = [System.Management.Automation.PSParser]::Tokenize($psFile, [ref]$errors)
        $errors.Count | Should -Be 0
      }
#>

    } # Context "Test Function $function"

    <# Commenting out as there aren't any tests files for individual files yet.
    Context "$function has tests" {
      $functionTests = (Get-ChildItem "$Function.Tests.ps1" -Recurse).FullName

      It "$($function).Tests.ps1 should exist" {
        $functionTests | Should -Exist
      }
    }
    #>
  } # foreach ($function in $functions)

}