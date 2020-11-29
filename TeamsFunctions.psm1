﻿#Requires -Version 5.1
<#
  TeamsFunctions
  Module for Management of Teams Voice Configuration for Tenant and Users
  User Configuration for Voice, Creation and connection of Resource Accounts,
  Licensing of Objects for Calling Plans & Direct Routing,
  Creation and Management of Call Queues and Auto Attendants

  by David Eberhardt
  david@davideberhardt.at
  @MightyOrmus
  www.davideberhardt.at
  https://github.com/DEberhardt
  https://davideberhardt.wordpress.com/

  This Module is a Fork of the Module SkypeFunctions and built on the work of Jeff Brown.
  Jeff@JeffBrown.tech / @JeffWBrown / www.jeffbrown.tech / https://github.com/JeffBrownTech
  Individual Scripts incorporated into this Module are taken with the express permission of the original Author

  Any and all technical advice, scripts, and documentation are provided as is with no guarantee.
  Always review any code and steps before applying to a production system to understand their full impact.

  # Versioning
  This Module follows the Versioning Convention Microsoft uses to show the Release Date in the Version number
  Major v20 is the the first one published in 2020, followed by Minor version for the Month.
  Subsequent Minor versions include the Day and are released as PreReleases
  Revisions are planned quarterly, but are currently on a monthly schedule until mature. PreReleases weekly.

  # Version History (abbreviated)
  1.0         Initial Version (as SkypeFunctions) - 02-OCT-2017
  20.04.17.1  Initial Version (as TeamsFunctions)
  20.05.03.1  MAY 2020 Release - First Publication - Refresh for Teams
  20.06.09.1  JUN 2020 Release - Added Session Connection & TeamsCallQueue Functions
  20.06.29.1  JUL 2020 Release - Added TeamsResourceAccount & TeamsResourceAccountAssociation Functions
  20.08       AUG 2020 Release - Added new License Functions, Shared Voicemail Support for TeamsCalLQueue
  20.09       SEP 2020 Release - Bugfixes
  20.10       OCT 2020 Release - Added TeamsUserVoiceConfig & TeamsAutoAttendant Functions
  20.11       NOV 2020 Release - Restructuring, Bugfixes and general overhaul. Also more Pester-Testing
  20.12       DEC 2020 Release - Added more Licensing & CallableEntity Functions, Progress bars, Performance improvements and bugfixes

#>

#region Classes
class TFTeamsServicePlan {
  [string]$ProductName
  [string]$ServicePlanName
  [ValidatePattern("^(\{{0,1}([0-9a-fA-F]){8}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){12}\}{0,1})$")]
  [string]$ServicePlanId
  [bool]$RelevantForTeams

  TFTeamsServicePlan(
    [string]$ProductName,
    [string]$ServicePlanName,
    [string]$ServicePlanId,
    [bool]$RelevantForTeams
  ) {
    $this.ProductName = $ProductName
    $this.ServicePlanName = $ServicePlanName
    $this.ServicePlanId = $ServicePlanId
    $this.RelevantForTeams = $RelevantForTeams
  }
}


class TFTeamsLicense {
  [string]$ProductName
  [string]$SkuPartNumber
  [string]$LicenseType
  [string]$ParameterName
  [bool]$IncludesTeams
  [bool]$IncludesPhoneSystem
  [ValidatePattern("^(\{{0,1}([0-9a-fA-F]){8}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){12}\}{0,1})$")]
  [string]$SkuId
  [object]$ServicePlans

  TFTeamsLicense(
    [string]$ProductName,
    [string]$SkuPartNumber,
    [string]$LicenseType,
    [string]$ParameterName,
    [bool]$IncludesTeams,
    [bool]$IncludesPhoneSystem,
    [string]$SkuId,
    [object]$ServicePlans
  ) {
    $this.ProductName = $ProductName
    $this.SkuPartNumber = $SkuPartNumber
    $this.LicenseType = $LicenseType
    $this.ParameterName = $ParameterName
    $this.IncludesTeams = $IncludesTeams
    $this.IncludesPhoneSystem = $IncludesPhoneSystem
    $this.SkuId = $SkuId
    $this.ServicePlans = $ServicePlans
  }
}

class TFCallableEntityConnection {
  [string]$Identity
  [string]$LinkedAs
  [string]$Type
  [string]$Name
  [string]$ObjectId

  TFCallableEntityConnection(
    [string]$Identity,
    [string]$LinkedAs,
    [string]$Type,
    [string]$Name,
    [string]$ObjectId
  ) {
    $this.Identity = $Identity
    $this.LinkedAs = $LinkedAs
    $this.Type = $Type
    $this.Name = $Name
    $this.ObjectId = $ObjectId
  }
}
#endregion

# DotSourcing PS1 Files
Get-ChildItem -Filter *.ps1 -Path $PSScriptRoot\Public\Functions, $PSScriptRoot\Private\Functions -Recurse | ForEach-Object {
  . $_.FullName
}

# Adding manual Aliases (not recorded in Functions)
Set-Alias -Name Set-TeamsAutoAttendant -Value Set-CsAutoAttendant
Set-Alias -Name Set-TeamsAA -Value Set-CsAutoAttendant


# Exporting Module Members (Functions)
Export-ModuleMember -Function $(Get-ChildItem -Include *.ps1 -Path $PSScriptRoot\Public\Functions -Recurse).BaseName

# Exporting Module Members (Aliases)
Export-ModuleMember -Alias con, dis, pol, New-TeamsUVC, Set-TeamsUVC, Get-TeamsUVC, Find-TeamsUVC, Remove-TeamsUVC, Test-TeamsUVC, `
  New-TeamsRA, Set-TeamsRA, Get-TeamsRA, Find-TeamsRA, Remove-TeamsRA, New-TeamsRAassoc, Get-TeamsRAassoc, Remove-TeamsRAassoc, Remove-CsOnlineApplicationInstance, `
  New-TeamsCQ, Set-TeamsCQ, Get-TeamsCQ, Remove-TeamsCQ, New-TeamsAA, Set-TeamsAA, Set-TeamsAutoAttendant, Get-TeamsAA, Remove-TeamsAA, `
  New-TeamsAAPrompt, New-TeamsAASchedule, New-TeamsAAEntity, New-TeamsAAScope


# SIG # Begin signature block
# MIIECAYJKoZIhvcNAQcCoIID+TCCA/UCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQULd+hnHTwr/fAvfh/7bTaWJV2
# qzCgggIZMIICFTCCAX6gAwIBAgIQa3i9Sh/NdbhOjG+ewKFPfjANBgkqhkiG9w0B
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
# CQQxFgQURQxzgfgGfXHvpGs06jzjJFcKCwYwDQYJKoZIhvcNAQEBBQAEgYBt2/9H
# Sp6WVW56xFX26VBPg6EhI4dCKKY5VpiipN4/3CAcJ8u9owgfoPY+SejJXNLDml2S
# pslhMopY7CPa3O9aG4tejz6EhjvoiUnAu/3LQODoZKQl1BEllVI8hKt4Dr1rF6qt
# qJpqVVlCAuCR/0IduwtpdgAk+CRr3WvumG+BEg==
# SIG # End signature block
