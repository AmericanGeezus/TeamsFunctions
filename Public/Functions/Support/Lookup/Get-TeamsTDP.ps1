# Module:   TeamsFunctions
# Function: VoiceConfig
# Author:		David Eberhardt
# Updated:  01-NOV-2020
# Status:   RC




function Get-TeamsTDP {
  param (
    [string]$Identity
  )

  if ($PSBoundParameters.ContainsKey('Identity')) {
    Write-Verbose -Message "Switch Identity: Acting as alias to 'Get-CsTenantDialPlan'"
    Get-CsTenantDialPlan $Identity

  }
  else {
    Write-Verbose -Message "Finding Names for all Tenant Dial Plans"
    Get-CsTenantDialPlan | Where-Object Identity -NE "Global" | Select-Object Identity -ExpandProperty Identity

  }
}
