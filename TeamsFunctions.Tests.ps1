# Module:   TeamsFunctions
# Function: Test
# Author:		David Eberhardt
# Updated:  11-OCT-2020

$TestName = 'TeamsFunctions'

Describe -Tags ('Unit', 'Acceptance') -Name 'TeamsFunctions Module Tests' {
  BeforeAll {

    Describe -Tags ('Unit', 'Acceptance') "$TestName" {

      BeforeAll {
        $Module = @{
          Name     = 'TeamsFunctions'
          Path     = $PSScriptRoot
          Manifest = "$PSScriptRoot\TeamsFunctions.psd1"
          FileName = "$PSScriptRoot\TeamsFunctions.psm1"
        }
        Write-Host "Testing '$($Module.Name)' in path '$($module.path)'"
      }

      #region Module Test
      Context 'Module' {
        It "has the root module '$PSScriptRoot\$($Module.Name).psm1'" {
          "$PSScriptRoot\$($Module.Name).psm1" | Should -Exist
        } -TestCases { Module = $module }

        It "Manifest file '$($Module.Manifest)'" {
          "$($Module.Manifest)" | Should -Exist
          "$($Module.Manifest)" | Should -FileContentMatch '$($Module.FileName)'
        } -TestCases $Module

        It 'Folders for FUNCTIONS' {
          "$PSScriptRoot\Public\Functions" | Should -Exist
          "$PSScriptRoot\Private\Functions" | Should -Exist
        }

        It 'Folders for TESTS' {
          "$PSScriptRoot\Public\Tests" | Should -Exist
          "$PSScriptRoot\Private\Tests" | Should -Exist
        }

        It "'$($Module.FileName)' is valid PowerShell code" {
          $psFile = Get-Content -Path "$($Module.FileName)" -ErrorAction Stop
          $errors = $null
          $null = [System.Management.Automation.PSParser]::Tokenize($psFile, [ref]$errors)
          $errors.Count | Should -Be 0
        } -TestCases $Module

        It "'$($Module.Manifest)' is valid PowerShell code" {
          $psFile = Get-Content -Path "$($Module.Manifest)" -ErrorAction Stop
          $errors = $null
          $null = [System.Management.Automation.PSParser]::Tokenize($psFile, [ref]$errors)
          $errors.Count | Should -Be 0
        } -TestCases $Module

      } # Context 'Module Setup'
      #endregion

      #region Function Testing
      $Allfunctions = Get-ChildItem "$PSScriptRoot\Public", "$PSScriptRoot\Private" -Include '*.ps1' -Exclude '*.Tests.ps1' -Recurse #| Select-Object -First 1
      $PublicFunctions = Get-ChildItem "$PSScriptRoot\Public" -Include '*.ps1' -Exclude '*.Tests.ps1' -Recurse #| Select-Object -First 1
      $PrivateFunctions = Get-ChildItem "$PSScriptRoot\Private" -Include '*.ps1' -Exclude '*.Tests.ps1' -Recurse #| Select-Object -First 1
      $PublicDocs = Get-ChildItem "$PSScriptRoot\docs" -Include '*.md' -Recurse #| Select-Object -First 1

      Context 'Functions (ALL)' -Foreach $AllFunctions {

        It "File '$($_.BaseName)' should exist" {
          "$($_.FullName)" | Should -Exist
        }

        It "File '$($_.BaseName)' should have a valid header" {
          "$($_.FullName)" | Should -FileContentMatch 'Module:'
          "$($_.FullName)" | Should -FileContentMatch 'Function:'
          "$($_.FullName)" | Should -FileContentMatch 'Author:'
          "$($_.FullName)" | Should -FileContentMatch 'Updated:'
          "$($_.FullName)" | Should -FileContentMatch 'Status:'
        }

        It "File '$($_.BaseName)' should have a function" {
          "$($_.FullName)" | Should -FileContentMatch 'function'
        }

        It "File '$($_.BaseName)' is valid PowerShell code" {
          $psFile = Get-Content -Path $_.FullName -ErrorAction Stop
          $errors = $null
          $null = [System.Management.Automation.PSParser]::Tokenize($psFile, [ref]$errors)
          $errors.Count | Should -Be 0
        }

      } # Context "Functions (ALL)"

      Context 'Functions (PUBLIC)' -Foreach $PublicFunctions {

        It "Function '$($_.BaseName)' should have a SYNOPSIS section in the help block" {
          "$($_.FullName)" | Should -FileContentMatch '.SYNOPSIS'
        }

        It "Function '$($_.BaseName)' should have a DESCRIPTION section in the help block" {
          "$($_.FullName)" | Should -FileContentMatch '.DESCRIPTION'
        }

        It "Function '$($_.BaseName)' should have a EXAMPLE section in the help block" {
          "$($_.FullName)" | Should -FileContentMatch '.EXAMPLE'
        }

        It "'$_' should have a LINK to the docs folder in the master branch" {
          "$($_.FullName)" | Should -FileContentMatch 'https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/'
        }

        # not all will have the full begin, process, end model
        It "Function '$($_.BaseName)' should have BEGIN, PROCESS and END blocks" {
          "$($_.FullName)" | Should -FileContentMatch 'begin {'
          "$($_.FullName)" | Should -FileContentMatch 'process {'
          "$($_.FullName)" | Should -FileContentMatch 'end {'
        }

        # not all will have advanced functions
        It "'$($_.BaseName)' should be an advanced function" {
          "$($_.FullName)" | Should -FileContentMatch 'cmdletbinding'
          "$($_.FullName)" | Should -FileContentMatch 'param'
        }

        It "Function '$($_.BaseName)' should have an OUTPUTTYPE set" {
          "$($_.FullName)" | Should -FileContentMatch '[OutputType([*)]'
        }

        It "Function '$($_.BaseName)' should contain 'Write-Verbose'" {
          "$($_.FullName)" | Should -FileContentMatch 'Write-Verbose'
        }

      } # Context "Functions (PUBLIC)"


      Context 'Functions (PRIVATE)' -Foreach $PrivateFunctions {

        # currently no special tests for private functions

      } # Context "Testing Module PRIVATE Functions"
      #endregion

      <# Commenting out as there aren't any tests files for individual files yet.
  Context "Functions (PUBLIC) have tests" -Foreach $PublicFunctions {

    It "File '$($_.BaseName).Tests.ps1' should exist" {
      "Public\Tests\$($_.BaseName).Tests.ps1" | Should -Exist
    }
  }
  #>

      Context 'Testing Module PUBLIC Documentation' -Foreach $PublicDocs {

        It "'$_' should NOT have empty documentation in the MD file" {
          "$($_.FullName)" | Should -Not -FileContentMatch ([regex]::Escape('{{'))
        }
      } # Context "Testing Module DOCS"

    }

    It "File '$($_.BaseName).Tests.ps1' is valid PowerShell code" {
      $psFile = Get-Content -Path "Public\Tests\$($_.BaseName).Tests.ps1" -ErrorAction Stop
      $errors = $null
      $null = [System.Management.Automation.PSParser]::Tokenize($psFile, [ref]$errors)
      $errors.Count | Should -Be 0
    }

    BeforeAll {
      #$ModuleName = 'TeamsFunctions'
      #Import-Module $ModuleName
      swop 1

      #Add-Type -Name Microsoft.Rtc.Management.Hosted.Online.Models.AudioFile # Doesn't work...
    }

    It "File '$($_.BaseName).Tests.ps1' should exist" {
      "Private\Tests\$($_.BaseName).Tests.ps1" | Should -Exist
    }

    It "File '$($_.BaseName).Tests.ps1' is valid PowerShell code" {
      $psFile = Get-Content -Path "Private\Tests\$($_.BaseName).Tests.ps1" -ErrorAction Stop
      $errors = $null
      $null = [System.Management.Automation.PSParser]::Tokenize($psFile, [ref]$errors)
      $errors.Count | Should -Be 0
    }

    # The module will need to be imported during Discovery since we're using it to generate test cases / Context blocks
    #Import-Module $ModuleName
    swop 1

  }
}
#>

# SIG # Begin signature block
# MIIECAYJKoZIhvcNAQcCoIID+TCCA/UCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUgB032a/v6YE/hmec+9jnEV7r
# E7+gggIZMIICFTCCAX6gAwIBAgIQa3i9Sh/NdbhOjG+ewKFPfjANBgkqhkiG9w0B
# AQUFADAlMSMwIQYDVQQDDBpEYXZpZCBFYmVyaGFyZHQgLSBDb2RlU2lnbjAeFw0y
# MDA2MTMxMTA4NTNaFw0yNDA2MTMwMDAwMDBaMCUxIzAhBgNVBAMMGkRhdmlkIEVi
# ZXJoYXJkdCAtIENvZGVTaWduMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC3
# m6z32wDOJ/ZnUYR5tJaujtCN2MVrOYs/ZwSVJvralxDUKHSLAGdmKmO1H5hH4Nmv
# NBe1/L95AVDugTaoH9UK/snN9pcYJ7E7UqLH4ySqJuqE10VmpD2sRi3I2RDL1/eh
# weUut8B3G4bwrA3o2Iy4Y6Kd7IMUAZzUVWwl01jsPQIDAQABo0YwRDATBgNVHSUE
# DDAKBggrBgEFBQcDAzAdBgNVHQ4EFgQUO8DeqyD0FHkF6JO8JT7syAeXJXAwDgYD
# VR0PAQH/BAQDAgeAMA0GCSqGSIb3DQEBBQUAA4GBAFCN2PtWoAvowM+pcxIV/gp2
# RB2rFyPfjLWjfAeKPfXmcfsMAPIoevTrKj3VAzzoF32wZRvdHk7jLssrhT0nmF7L
# 20n7K7RxJ3lccZ0MEdIHsmiklqbV+f9moVtXmgwwJzYkWekjIfrDUSdJeu0BYzR0
# H+8/FVd9YHgogHQN9t3hMYIBWTCCAVUCAQEwOTAlMSMwIQYDVQQDDBpEYXZpZCBF
# YmVyaGFyZHQgLSBDb2RlU2lnbgIQa3i9Sh/NdbhOjG+ewKFPfjAJBgUrDgMCGgUA
# oHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYB
# BAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0B
# CQQxFgQUy5FAWQJSQptHCd2HP/lAluqLEkQwDQYJKoZIhvcNAQEBBQAEgYA77Lj6
# YqZo46YgoUQ+COuFjouZtvxwhMmv/QWPuXFmsYgynwNzc/zokxE7wm9GdkW6bLNm
# 5l7QTgCc3LJM5G96g2J9ddKnIaEj2NQ7xuVGVWcaNb20z+BUv6eCgRFvh1WXzTEb
# GDF71uu8cYJYiLAaFd8BuqE3tv2Nmb67BgOJlQ==
# SIG # End signature block
