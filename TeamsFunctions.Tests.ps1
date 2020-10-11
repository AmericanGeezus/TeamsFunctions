# Module:   TeamsFunctions
# Function: Test
# Author:		David Eberhardt
# Updated:  11-OCT-2020

BeforeAll {
  $Module = @{
    Name     = 'TeamsFunctions'
    Path     = $PSScriptRoot
    Manifest = "$PSScriptRoot\TeamsFunctions.psd1"
    FileName = "$PSScriptRoot\TeamsFunctions.psm1"
  }
  Write-Host "Testing '$($Module.Name)' in path '$($module.path)'"
}

Describe -Tags ('Unit', 'Acceptance') "'$($Module.Name)' Module Tests" {
  BeforeAll {

  }

  Context 'Module Setup' {
    It "has the root module '$PSScriptRoot\$($Module.Name).psm1'" {
      "$PSScriptRoot\$($Module.Name).psm1" | Should -Exist
    } -TestCases { Module = $module }

    It "has the a manifest file of '$PSScriptRoot\$($Module.Name).psd1'" {
      "$PSScriptRoot\$($Module.Name).psd1" | Should -Exist
      "$PSScriptRoot\$($Module.Name).psd1" | Should -FileContentMatch "$($Module.Name).psm1"
    } -TestCases { Module = $module }

    It "$module folder has functions" {
      "$PSScriptRoot\Public\Functions" | Should -Exist
      "$PSScriptRoot\Private\Functions" | Should -Exist
    }

    It "$module is valid PowerShell code" {
      $psFile = Get-Content -Path "$PSScriptRoot\$($Module.Name).psm1" -ErrorAction Stop
      $errors = $null
      $null = [System.Management.Automation.PSParser]::Tokenize($psFile, [ref]$errors)
      $errors.Count | Should -Be 0
    }

  } # Context 'Module Setup'


  $Allfunctions = Get-ChildItem "$PSScriptRoot\Public", "$PSScriptRoot\Private" -Include "*.ps1" -Exclude "*.Tests.ps1" -Recurse #| Select-Object -First 1
  $PublicFunctions = Get-ChildItem "$PSScriptRoot\Public" -Include "*.ps1" -Exclude "*.Tests.ps1" -Recurse #| Select-Object -First 1
  $PrivateFunctions = Get-ChildItem "$PSScriptRoot\Private" -Include "*.ps1" -Exclude "*.Tests.ps1" -Recurse #| Select-Object -First 1

  Context "Testing Module ALL Functions" -Foreach $AllFunctions {

    It "'$($_.BaseName)' should exist" {
      "$($_.FullName)" | Should -Exist
    }

    It "'$_' should have a valid header" {
      "$($_.FullName)" | Should -FileContentMatch 'Module:'
      "$($_.FullName)" | Should -FileContentMatch 'Function:'
      "$($_.FullName)" | Should -FileContentMatch 'Author:'
      "$($_.FullName)" | Should -FileContentMatch 'Updated:'
      "$($_.FullName)" | Should -FileContentMatch 'Status:'
    }

    It "'$($_.BaseName)' should have a function" {
      "$($_.FullName)" | Should -FileContentMatch 'function'
    }

    It "'$($_.BaseName)' is valid PowerShell code" {
      $psFile = Get-Content -Path $_.FullName -ErrorAction Stop
      $errors = $null
      $null = [System.Management.Automation.PSParser]::Tokenize($psFile, [ref]$errors)
      $errors.Count | Should -Be 0
    }

  } # Context "Testing Module ALL Functions"

  Context "Testing Module PUBLIC Functions" -ForEach $PublicFunctions {

    It "'$($_.BaseName)' should have a SYNOPSIS section in the help block" {
      "$($_.FullName)" | Should -FileContentMatch '.SYNOPSIS'
    }

    It "'$($_.BaseName)' should have a DESCRIPTION section in the help block" {
      "$($_.FullName)" | Should -FileContentMatch '.DESCRIPTION'
    }

    It "'$_' should have a EXAMPLE section in the help block" {
      "$($_.FullName)" | Should -FileContentMatch '.EXAMPLE'
    }

    # not all will have the full begin, process, end model
    It "'$($_.BaseName)' should have a BEGIN, PROCESS and END block" {
      "$($_.FullName)" | Should -FileContentMatch 'begin {'
      "$($_.FullName)" | Should -FileContentMatch 'process {'
      "$($_.FullName)" | Should -FileContentMatch 'end {'
    }

    # not all will have advanced funtions
    It "'$($_.BaseName)' should be an advanced function" {
      "$($_.FullName)" | Should -FileContentMatch 'function'
      "$($_.FullName)" | Should -FileContentMatch 'cmdletbinding'
      "$($_.FullName)" | Should -FileContentMatch 'param'
    }

    It "'$($_.BaseName)' should have an OUTPUTTYPE set" {
      "$($_.FullName)" | Should -FileContentMatch "[OutputType([*)]"
    }

    It "'$($_.BaseName)' should contain Write-Verbose blocks" {
      "$($_.FullName)" | Should -FileContentMatch "Write-Verbose"
    }

  } # Context "Testing Module PUBLIC Functions"


  Context "Testing Module PRIVATE Functions" -Foreach $PrivateFunctions {

    # currently no special tests for private functions

  } # Context "Testing Module PRIVATE Functions"


  <# Commenting out as there aren't any tests files for individual files yet.
  Context "Testing FUNCTION has tests" -ForEach $AllFunctions {
    #$functionTests = Get-ChildItem "$($_.BaseName).Tests.ps1" -Recurse

    It "'$($_.BaseName).Tests.ps1' should exist" {
      "$($_.BaseName).Tests.ps1" | Should -Exist
    }
  }
  #>

}