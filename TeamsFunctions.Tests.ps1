# Module:   TeamsFunctions
# Function: Test
# Author:		David Eberhardt
# Updated:  11-OCT-2020

Describe -Tags ('Unit', 'Acceptance') -Name 'TeamsFunctions Module Tests' {
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

    It "has the a manifest file of '$PSScriptRoot\$($Module.Name).psd1'" {
      "$PSScriptRoot\$($Module.Name).psd1" | Should -Exist
      "$PSScriptRoot\$($Module.Name).psd1" | Should -FileContentMatch "$($Module.Name).psm1"
    } -TestCases { Module = $module }

    It "$module has folder for Functions" {
      "$PSScriptRoot\Public\Functions" | Should -Exist
      "$PSScriptRoot\Private\Functions" | Should -Exist
    }

    It "$module has folder for Tests" {
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
  #endregion

  #region Function Testing
  $Allfunctions = Get-ChildItem "$PSScriptRoot\Public", "$PSScriptRoot\Private" -Include '*.ps1' -Exclude '*.Tests.ps1' -Recurse #| Select-Object -First 1
  $PublicFunctions = Get-ChildItem "$PSScriptRoot\Public" -Include '*.ps1' -Exclude '*.Tests.ps1' -Recurse #| Select-Object -First 1
  $PrivateFunctions = Get-ChildItem "$PSScriptRoot\Private" -Include '*.ps1' -Exclude '*.Tests.ps1' -Recurse #| Select-Object -First 1
  $PublicDocs = Get-ChildItem "$PSScriptRoot\docs" -Include '*.md' -Recurse #| Select-Object -First 1

  Context 'Testing Module ALL Functions' -Foreach $AllFunctions {

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

  Context 'Testing Module PUBLIC Functions' -ForEach $PublicFunctions {

    It "'$($_.BaseName)' should have a SYNOPSIS section in the help block" {
      "$($_.FullName)" | Should -FileContentMatch '.SYNOPSIS'
    }

    It "'$($_.BaseName)' should have a DESCRIPTION section in the help block" {
      "$($_.FullName)" | Should -FileContentMatch '.DESCRIPTION'
    }

    It "'$_' should have a EXAMPLE section in the help block" {
      "$($_.FullName)" | Should -FileContentMatch '.EXAMPLE'
    }

    It "'$_' should have a LINK to the docs folder in the master branch" {
      "$($_.FullName)" | Should -FileContentMatch 'https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/'
    }

    # not all will have the full begin, process, end model
    It "'$($_.BaseName)' should have a BEGIN, PROCESS and END block" {
      "$($_.FullName)" | Should -FileContentMatch 'begin {'
      "$($_.FullName)" | Should -FileContentMatch 'process {'
      "$($_.FullName)" | Should -FileContentMatch 'end {'
    }

    # not all will have advanced functions
    It "'$($_.BaseName)' should be an advanced function" {
      "$($_.FullName)" | Should -FileContentMatch 'cmdletbinding'
      "$($_.FullName)" | Should -FileContentMatch 'param'
    }

    It "'$($_.BaseName)' should have an OUTPUTTYPE set" {
      "$($_.FullName)" | Should -FileContentMatch '[OutputType([*)]'
    }

    It "'$($_.BaseName)' should contain Write-Verbose blocks" {
      "$($_.FullName)" | Should -FileContentMatch 'Write-Verbose'
    }

  } # Context "Testing Module PUBLIC Functions"


  Context 'Testing Module PRIVATE Functions' -Foreach $PrivateFunctions {

    # currently no special tests for private functions

  } # Context "Testing Module PRIVATE Functions"
  #endregion

  <# Commenting out as there aren't any tests files for individual files yet.
  Context "Testing FUNCTION has tests" -ForEach $AllFunctions {
    #$functionTests = Get-ChildItem "$($_.BaseName).Tests.ps1" -Recurse

    It "'$($_.BaseName).Tests.ps1' should exist" {
      "$($_.BaseName).Tests.ps1" | Should -Exist
    }
  }
  #>

  Context 'Testing Module PUBLIC Documentation' -ForEach $PublicDocs {

    It "'$_' should NOT have empty documentation in the MD file" {
      "$($_.FullName)" | Should -Not -FileContentMatch ([regex]::Escape('{{'))
    }
  } # Context "Testing Module DOCS"

}

<#
# Code from F-X Cat https://vexx32.github.io/2020/07/08/Verify-Module-Help-Pester/
#region Discovery

$ModuleName = 'TeamsFunctions'

#endregion Discovery

BeforeAll {
  $ModuleName = 'TeamsFunctions'
  #Import-Module $ModuleName
  swop 1

  #Add-Type -Name Microsoft.Rtc.Management.Hosted.Online.Models.AudioFile # Doesn't work...
}

Describe "$ModuleName Sanity Tests - Help Content" -Tags 'Module' {

  #region Discovery

  # The module will need to be imported during Discovery since we're using it to generate test cases / Context blocks
  #Import-Module $ModuleName
  swop 1

  $ShouldProcessParameters = 'WhatIf', 'Confirm'

  # Generate command list for generating Context / TestCases
  $Module = Get-Module $ModuleName
  $CommandList = @(
    $Module.ExportedFunctions.Keys
    $Module.ExportedCmdlets.Keys
  )

  #endregion Discovery

 r}ach ($Command in $CommandList) {
}    Context "$Command - Help Content" {

      #region Discovery

      $Help = @{ Help = Get-Help -Name $Command -Full | Select-Object -Property * }
      $Parameters = Get-Help -Name $Command -Parameter * -ErrorAction Ignore |
      Where-Object { $_.Name -and $_.Name -notin $ShouldProcessParameters } |
      ForEach-Object {
        @{
          Name        = $_.name
          Description = $_.Description.Text
        }
      }
      $Ast = @{
        # Ast will be $null if the command is a compiled cmdlet
        Ast        = (Get-Content -Path "function:/$Command" -ErrorAction Ignore).Ast
        Parameters = $Parameters
      }
      $Examples = $Help.Help.Examples.Example | ForEach-Object { @{ Example = $_ } }

      #endregion Discovery

      It "has help content for $Command" -TestCases $Help {
        $Help | Should -Not -BeNullOrEmpty
      }

      It "contains a synopsis for $Command" -TestCases $Help {
        $Help.Synopsis | Should -Not -BeNullOrEmpty
      }

      It "contains a description for $Command" -TestCases $Help {
        $Help.Description | Should -Not -BeNullOrEmpty
      }

      It "lists the function author in the Notes section for $Command" -TestCases $Help {
        $Notes = $Help.AlertSet.Alert.Text -split '\n'
        $Notes[0].Trim() | Should -BeLike "Author: *"
      }

      # This will be skipped for compiled commands ($Ast.Ast will be $null)
      It "has a help entry for all parameters of $Command" -TestCases $Ast -Skip:(-not ($Parameters -and $Ast.Ast)) {
        @($Parameters).Count | Should -Be $Ast.Body.ParamBlock.Parameters.Count -Because 'the number of parameters in the help should match the number in the function script'
      }

      It "has a description for $Command parameter -<Name>" -TestCases $Parameters -Skip:(-not $Parameters) {
        $Description | Should -Not -BeNullOrEmpty -Because "parameter $Name should have a description"
      }

      It "has at least one usage example for $Command" -TestCases $Help {
        $Help.Examples.Example.Code.Count | Should -BeGreaterOrEqual 1
      }

      It "lists a description for $Command example: <Title>" -TestCases $Examples {
        $Example.Remarks | Should -Not -BeNullOrEmpty -Because "example $($Example.Title) should have a description!"
      }
    }
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
