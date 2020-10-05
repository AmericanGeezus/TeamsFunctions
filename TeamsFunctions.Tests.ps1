$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$module = 'TeamsFunctions'

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

  $functions = Get-ChildItem "$here\Public", "$here\Private" -Include "*.ps1" -ExClude "*.Tests.ps1" -Recurse | Select-Object -First 1

  foreach ($function in $functions) {

    Context "$($function.BaseName) - Function" {

      It "should exist" {
        Should $($function.FullName) -Exist
      }

      It "should have a valid header" {
        Should $($function.FullName) -FileContentMatch 'Module:'
        Should $($function.FullName) -FileContentMatch 'Function:'
        Should $($function.FullName) -FileContentMatch 'Author:'
        Should $($function.FullName) -FileContentMatch 'Updated:'
        Should $($function.FullName) -FileContentMatch 'Status:'
      }

      It "should have help block" {
        Should $($function.FullName) -FileContentMatch '<#'
        Should $($function.FullName) -FileContentMatch '#>'
      }

      It "should have a SYNOPSIS section in the help block" {
        Should $($function.FullName) -FileContentMatch '.SYNOPSIS'
      }

      It "should have a DESCRIPTION section in the help block" {
        Should $($function.FullName) -FileContentMatch '.DESCRIPTION'
      }

      It "should have a EXAMPLE section in the help block" {
        Should $($function.FullName) -FileContentMatch '.EXAMPLE'
      }

      # Add more checks for !

      # Evaluate use - not all Functions are advanced yet!

      It "should be an advanced function" {
        Should $($function.FullName) -FileContentMatch 'function'
        Should $($function.FullName) -FileContentMatch 'cmdletbinding'
        Should $($function.FullName) -FileContentMatch 'param'
        #Add: OutputType, Return
      }

      It "should contain Write-Verbose blocks" {
        Should "$($function.FullName)" -FileContentMatch 'Write-Verbose'
      }

      It "is valid PowerShell code" {
        $psFile = Get-Content -Path "$($local:function.FullName)" #-ErrorAction Stop
        $errors = $null
        $null = [System.Management.Automation.PSParser]::Tokenize($psFile, [ref]$errors)
        $errors.Count | Should -Be 0
      }


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