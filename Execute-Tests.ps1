# Module:   TeamsFunctions
# Function: Test
# Author:		David Eberhardt
# Updated:  11-OCT-2020

# Pester

[CmdletBinding(DefaultParameterSetName = "full")]
param (
  [Parameter(ParameterSetName = "full")]
  [switch]$full,

  [Parameter(ParameterSetName = "individual")]
  [switch]$private,

  [Parameter(ParameterSetName = "individual")]
  [switch]$public

)

begin {
  if (($PSBoundParameters.ContainsKey('private') -or $PSBoundParameters.ContainsKey('public')) -and -not $PSBoundParameters.ContainsKey('full')) {
    $all = $false
  }
  elseif ($PSBoundParameters.ContainsKey('full')) {
    $all = $true
  }
  elseif ($PSBoundParameters.Keys.Count -eq 0) {
    $all = $true
  }

  Import-Module Pester

}

process {
  if ($all) {
    # Run the structure tests
    Write-Verbose -Message "$($MyInvocation.MyCommand.Name) - Running Tests against MODULE (Integrity check)" -Verbose
    Invoke-Pester "$PSScriptRoot\TeamsFunctions.Tests.ps1"

  }

  if ($all -or $private) {
    # Run Functional Tests for Private functions
    Write-Verbose -Message "$($MyInvocation.MyCommand.Name) - Running Tests against PRIVATE Functions" -Verbose
    $PrivateTests = Get-ChildItem "$PSScriptRoot\Private\Tests" -Include "*.Tests.ps1" -Recurse #| Select-Object -First 1
    Invoke-Pester $PrivateTests.FullName

  }

  if ($all -or $public) {
    # Run Functional Tests for Public functions
    Write-Verbose -Message "$($MyInvocation.MyCommand.Name) - Running Tests against PUBLIC Functions" -Verbose
    $PublicTests = Get-ChildItem "$PSScriptRoot\Public\Tests" -Include "*.Tests.ps1" -Recurse #| Select-Object -First 1
    Invoke-Pester $PublicTests.FullName

  }

}

end {

}

# SIG # Begin signature block
# MIIECAYJKoZIhvcNAQcCoIID+TCCA/UCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUL8dKCySeIWLPBAt0Pn9Fuf5o
# ksOgggIZMIICFTCCAX6gAwIBAgIQa3i9Sh/NdbhOjG+ewKFPfjANBgkqhkiG9w0B
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
# CQQxFgQUJjoiVleNxZxyXcm7YGP/OiWl8C0wDQYJKoZIhvcNAQEBBQAEgYB55leO
# 7b9G/pbXTJva+g5dq3jdOCesEN1Vctf1adZGP7EiK8BQzO+tlRcPbG9aNUA28hnv
# D3uz4g/hut/kGuhqzNqkUNQF3oO45tGmQFjQ8/as2F5VGB7cMi6DwXAGp/Cz2w7y
# 6xPX0zvkr1qJHgiJkCJebRqKNYfJoY+C5UjCEw==
# SIG # End signature block
