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

  $functions = Get-ChildItem -Directory $here\Public,$here\Private -Include "*.ps1" -ExClude "*.Tests.ps1" -Recurse

  foreach ($function in $functions)
  {
    $FunctionName = $function.BaseName
    $FunctionPath = $function.FullName

    Context "Test Function " {

      It "$FunctionName should exist" {
        $FunctionPath | Should -Exist
      }

      It "$FunctionName should have a valid header" {
        $FunctionPath | Should -FileContentMatch 'Module:'
        $FunctionPath | Should -FileContentMatch 'Function:'
        $FunctionPath | Should -FileContentMatch 'Author:'
        $FunctionPath | Should -FileContentMatch 'Updated:'
        $FunctionPath | Should -FileContentMatch 'Status:'
      }

      It "$FunctionName should have help block" {
        $FunctionPath | Should -FileContentMatch '<`#'
        $FunctionPath | Should -FileContentMatch '`#>'
      }

      It "$FunctionName should have a SYNOPSIS section in the help block" {
        $FunctionPath | Should -FileContentMatch '.SYNOPSIS'
      }

      It "$FunctionName should have a DESCRIPTION section in the help block" {
        $FunctionPath | Should -FileContentMatch '.DESCRIPTION'
      }

      It "$FunctionName should have a EXAMPLE section in the help block" {
        $FunctionPath | Should -FileContentMatch '.EXAMPLE'
      }

      # Add more checks for !

      # Evaluate use - not all Functions are advanced yet!

      It "$FunctionName should be an advanced function" {
        $FunctionPath | Should -FileContentMatch 'function'
        $FunctionPath | Should -FileContentMatch 'cmdletbinding'
        $FunctionPath | Should -FileContentMatch 'param'
        #Add: OutputType, Return
      }

      It "$FunctionName should contain Write-Verbose blocks" {
        $FunctionPath | Should -FileContentMatch 'Write-Verbose'
      }

      It "$FunctionName is valid PowerShell code" {
        $psFile = Get-Content -Path $FunctionPath `
                              -ErrorAction Stop
        $errors = $null
        $null = [System.Management.Automation.PSParser]::Tokenize($psFile, [ref]$errors)
        $errors.Count | Should -Be 0
      }



    } # Context "Test Function $function"

    <# Commenting out as there aren't any tests files for individual files yet.
    Context "$function has tests" {
      $FunctionPathTests = (Get-ChildItem "$Function.Tests.ps1" -Recurse).FullName

      It "$($function).Tests.ps1 should exist" {
        $FunctionPathTests | Should -Exist
      }
    }
    #>
  } # foreach ($function in $functions)

}