$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$name = 'TeamsFunctions'

BeforeAll {
  $module = @{
    Name     = 'TeamsFunctions'
    Path     = $PSScriptRoot
    Manifest = "$PSScriptRoot\TeamsFunctions.psd1"
    FileName = "$PSScriptRoot\TeamsFunctions.psm1"
  }
  Write-Host "Testing '$($Module.name)' in path '$($module.path)'"
}

Describe -Tags ('Unit', 'Acceptance') "'$Name' Module Tests"  {
  BeforeAll {

  }

  Context 'Module Setup' {
    It "has the root module '$PSScriptRoot\$Name.psm1'" {
      "$PSScriptRoot\$($Module.Name).psm1" | Should -Exist
    } -TestCases { Module = $module }

    It "has the a manifest file of '$PSScriptRoot\$name.psd1'" {
      "$PSScriptRoot\$($Module.Name).psd1" | Should -Exist
      "$PSScriptRoot\$($Module.Name).psd1" | Should -FileContentMatch "$($Module.Name).psm1"
    } -TestCases { Module = $module }

    It "$module folder has functions" {
      "$PSScriptRoot\Public\Functions" | Should -Exist
      "$PSScriptRoot\Private\Functions" | Should -Exist
    }

    It "$module is valid PowerShell code" {
      $psFile = Get-Content -Path "$PSScriptRoot\$name.psm1" -ErrorAction Stop
      $errors = $null
      $null = [System.Management.Automation.PSParser]::Tokenize($psFile, [ref]$errors)
      $errors.Count | Should -Be 0
    }

  } # Context 'Module Setup'


  $functions = Get-ChildItem "$here\Public", "$here\Private" -Include "*.ps1" -Exclude "*.Tests.ps1" -Recurse #| Select-Object -First 1
  #$functions = @('Enable-TeamsUserForEnterpriseVoice')

  Context "Testing Module Functions" -ForEach $functions {
    It "'$_' should exist" {
      "$($_.FullName)" | Should -Exist
    }

    It "should have a valid header" {
      "$($_.FullName)" | Should -FileContentMatch 'Module:'
      "$($_.FullName)" | Should -FileContentMatch 'Function:'
      "$($_.FullName)" | Should -FileContentMatch 'Author:'
      "$($_.FullName)" | Should -FileContentMatch 'Updated:'
      "$($_.FullName)" | Should -FileContentMatch 'Status:'
    }

    It "should have a function" {
      "$($_.FullName)" | Should -FileContentMatch 'function'
    }

    It "should have a SYNOPSIS section in the help block" {
      "$($_.FullName)" | Should -FileContentMatch '.SYNOPSIS'
    }

    It "should have a DESCRIPTION section in the help block" {
      "$($_.FullName)" | Should -FileContentMatch '.DESCRIPTION'
    }

    It "should have a EXAMPLE section in the help block" {
      "$($_.FullName)" | Should -FileContentMatch '.EXAMPLE'
    }

    # not all will have the full begin, process, end model
    It "should have a BEGIN, PROCESS and END block" {
      "$($_.FullName)" | Should -FileContentMatch 'begin {'
      "$($_.FullName)" | Should -FileContentMatch 'process {'
      "$($_.FullName)" | Should -FileContentMatch 'end {'
    }

    # not all will have advanced funtions
    It "should be an advanced function" {
      "$($_.FullName)" | Should -FileContentMatch 'function'
      "$($_.FullName)" | Should -FileContentMatch 'cmdletbinding'
      "$($_.FullName)" | Should -FileContentMatch 'param'
    }

    It "should have an OUTPUTTYPE set" {
      "$($_.FullName)" | Should -FileContentMatch "[OutputType([*)]"
    }

    It "should contain Write-Verbose blocks" {
      "$($_.FullName)" | Should FileContentMatch "Write-Verbose"
    }

    It "is valid PowerShell code" {
      $psFile = Get-Content -Path $_.FullName -ErrorAction Stop
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

}