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
  This Module follows the Versioning Convention to show the Release Date in the Version number
  Major v20 is the the first one published in 2020, followed by Minor version for the Month.
  Subsequent Minor versions include the Day and are released as PreReleases
  Revisions are planned quarterly, but are currently on a monthly schedule until mature. PreReleases as required.

  # Version History
  Please see VERSION.md

.LINK
  https://github.com/DEberhardt/TeamsFunctions/tree/master/docs

#>

#Requires -Version 5.1
#Req#uires -Modules MicrosoftTeams

# Addressing Limitations
function Get-StrictMode {
  # returns the currently set StrictMode version 1, 2, 3
  # or 0 if StrictMode is off.
  try { $xyz = @(1); $null = ($null -eq $xyz[2]) }
  catch { return 3 }

  try { 'Not-a-Date'.Year }
  catch { return 2 }

  try { $null = ($undefined -gt 1) }
  catch { return 1 }

  return 0
}

if ((Get-StrictMode) -gt 0) {
  Write-Verbose 'TeamsFunctions: Strict Mode interferes with Script execution. Switching Strict Mode off - Please refer to https://github.com/DEberhardt/TeamsFunctions/issues/64 for details'
  Set-StrictMode -Off
}

# Defining Help URL Base string:
$global:TeamsFunctionsHelpURLBase = 'https://github.com/DEberhardt/TeamsFunctions/blob/master/docs/'

#region Classes
class TFTeamsServicePlan {
  [string]$ProductName
  [string]$ServicePlanName
  [ValidatePattern('^(\{{0,1}([0-9a-fA-F]){8}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){12}\}{0,1})$')]
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
  [ValidatePattern('^(\{{0,1}([0-9a-fA-F]){8}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){12}\}{0,1})$')]
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

class TFCallableEntity {
  [string]$Entity
  [string]$Identity
  [string]$ObjectType
  [string]$Type

  TFCallableEntity(
    [string]$Entity,
    [string]$Identity,
    [string]$ObjectType,
    [string]$Type
  ) {
    $this.Entity = $Entity
    $this.Identity = $Identity
    $this.ObjectType = $ObjectType
    $this.Type = $Type
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
Set-Alias -Name New-TeamsAutoAttendantCallHandlingAssociation -Value New-CsAutoAttendantCallHandlingAssociation
Set-Alias -Name Set-TeamsAutoAttendant -Value Set-CsAutoAttendant
Set-Alias -Name Set-TeamsAA -Value Set-CsAutoAttendant

Set-Alias -Name Remove-TeamsAutoAttendantSchedule -Value Remove-CsOnlineSchedule
Set-Alias -Name Remove-TeamsAASchedule -Value Remove-CsOnlineSchedule

# Exporting Module Members (Functions)
Export-ModuleMember -Function $(Get-ChildItem -Include *.ps1 -Path $PSScriptRoot\Public\Functions -Recurse).BaseName

# Exporting Module Members (Aliases)
Export-ModuleMember -Alias con, dis, pol, ear, dar, gar, cur, Enable-Ev, Set-ServicePlan, #Connect-SkypeOnline, `
New-TeamsUVC, Set-TeamsUVC, Find-TeamsUVC, Find-TeamsUVR, Find-TeamsECR, Get-TeamsUVC, Remove-TeamsUVC, Test-TeamsUVC, Assert-TeamsUVC, `
  Get-TeamsCAP, New-TeamsCAP, Remove-TeamsCAP, Set-TeamsCAP, `
  Grant-TeamsEA, `
  Find-TeamsRA, Get-TeamsRA, New-TeamsRA, Remove-TeamsRA, Set-TeamsRA, New-TeamsRAIdentity, New-TeamsRACLI, `
  Get-TeamsRAA, New-TeamsRAA, Remove-TeamsRAA, Remove-CsOnlineApplicationInstance, `
  Get-TeamsCQ, New-TeamsCQ, Remove-TeamsCQ, Set-TeamsCQ, `
  Get-TeamsAA, New-TeamsAA, Remove-TeamsAA, Set-TeamsAA, Set-TeamsAutoAttendant, `
  New-TeamsAAMenu, New-TeamsAAOption, New-TeamsAAFlow, New-TeamsAAPrompt, New-TeamsAAScope, New-TeamsAASchedule, `
  New-TeamsAAEntity, New-TeamsAutoAttendantCallHandlingAssociation , `
  Get-TeamsAASchedule, Remove-TeamsAASchedule, Remove-TeamsAutoAttendantSchedule, `
  Get-Channel


# SIG # Begin signature block
# MIIECAYJKoZIhvcNAQcCoIID+TCCA/UCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQULhdfuaAsvc7/5h2SkTPhuZMf
# EcagggIZMIICFTCCAX6gAwIBAgIQa3i9Sh/NdbhOjG+ewKFPfjANBgkqhkiG9w0B
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
# CQQxFgQUrhg6KQGo2IN8Yv1cCuPzSksdqHMwDQYJKoZIhvcNAQEBBQAEgYCQdAhR
# ipw06x7mZWI05mrfBRopROKbneVjVb5+kfpPdR9GJmJloc1ZU63nIpOvB4Zus8U6
# JDp07ADdejBBhbeRmbs6umCCo1a1cOERacM8xWcFFCZn0hu+NW+Foqi6wqwFsZZg
# A1q1TqTe7f4n8mhUvsvnBvUpiMOe/M/ybkhtmA==
# SIG # End signature block
