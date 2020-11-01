# Module:   TeamsFunctions
# Function: VoiceConfig
# Author:		David Eberhardt
# Updated:  01-NOV-2020
# Status:   RC




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
    [Parameter(HelpMessage = "Name of the Tenant Dial Plan")]
    [string]$Identity
  )

  begin {
    Show-FunctionStatus -Level RC
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

    # Asserting SkypeOnline Connection
    if (-not (Assert-SkypeOnlineConnection)) { break }

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    if ($PSBoundParameters.ContainsKey('Identity')) {
      Write-Verbose -Message "Switch Identity: Acting as alias to 'Get-CsOnlineVoiceRoutingPolicy'"
      Get-CsOnlineVoiceRoutingPolicy $Identity

    }
    else {
      Write-Verbose -Message "Finding Names for all Online Voice Routing Policies"
      Get-CsOnlineVoiceRoutingPolicy | Where-Object Identity -NE "Global" | Select-Object Identity -ExpandProperty Identity

    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Get-TeamsOVP