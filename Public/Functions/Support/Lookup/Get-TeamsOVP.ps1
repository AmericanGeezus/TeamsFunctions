# Module:   TeamsFunctions
# Function: VoiceConfig
# Author:		David Eberhardt
# Updated:  01-NOV-2020
# Status:   RC




function Get-TeamsOVP {
  param (
    [string]$Identity
  )

  if ($PSBoundParameters.ContainsKey('Identity')) {
    Write-Verbose -Message "Switch Identity: Acting as alias to 'Get-CsOnlineVoiceRoutingPolicy'"
    Get-CsOnlineVoiceRoutingPolicy $Identity

  }
  else {
    Write-Verbose -Message "Finding Names for all Online Voice Routing Policies"
    Get-CsOnlineVoiceRoutingPolicy | Where-Object Identity -NE "Global" | Select-Object Identity -ExpandProperty Identity

  }
}
