# Module:   TeamsFunctions
# Function: VoiceConfig
# Author:		David Eberhardt
# Updated:  01-JAN-2021
# Status:   Live




function Get-TeamsOVP {
  <#
  .SYNOPSIS
    Lists all Online Voice Routing Policies by Name
  .DESCRIPTION
    To quickly find Online Voice Routing Policies to assign, an Alias-Function to Get-CsOnlineVoiceRoutingPolicy
  .PARAMETER Identity
    If provided, acts as an Alias to Get-CsOnlineVoiceRoutingPolicy, listing one Policy
    If not provided, lists Identities of all Online Voice Routing Policies (except "Global")
  .EXAMPLE
    Get-TeamsOVP
    Lists Identities (Names) of all Online Voice Routing Policies (except "Global")
  .EXAMPLE
    Get-TeamsOVP -Identity OVP-EMEA-National
    Lists Online Voice Routing Policy "OVP-EMEA-National" as Get-CsOnlineVoiceRoutingPolicy does (provided it exists).
  .NOTES
    Without parameters, it executes the following string:
    Get-CsOnlineVoiceRoutingPolicy | Where-Object Identity -NE "Global" | Select-Object Identity -ExpandProperty Identity
  #>

  [CmdletBinding()]
  param (
    [Parameter(Position = 0, HelpMessage = "Name of the Voice Routing Policy")]
    [string]$Identity
  )

  begin {
    Show-FunctionStatus -Level Live
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

    # Asserting SkypeOnline Connection
    if (-not (Assert-SkypeOnlineConnection)) { break }

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    if ($PSBoundParameters.ContainsKey('Identity')) {
      Write-Verbose -Message "Finding Online Voice Routing Policy with Identity '$Identity'"
      $Policies = Get-CsOnlineVoiceRoutingPolicy -WarningAction SilentlyContinue
      $Filtered = $Policies | Where-Object Identity -Like "*$Identity*"
      if ( $Filtered.Count -gt 2) {
        $Filtered | Select-Object Identity
      }
      else {
        $Filtered
      }
    }
    else {
      Write-Verbose -Message "Finding Online Voice Routing Policy Names"
      Get-CsOnlineVoiceRoutingPolicy | Where-Object Identity -NE "Global" | Select-Object Identity -ExpandProperty Identity
    }

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Get-TeamsOVP