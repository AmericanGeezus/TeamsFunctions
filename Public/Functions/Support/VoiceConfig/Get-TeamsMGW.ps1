# Module:   TeamsFunctions
# Function: VoiceConfig
# Author:		David Eberhardt
# Updated:  01-JAN-2021
# Status:   Live




function Get-TeamsMGW {
  <#
  .SYNOPSIS
    Lists all Online Pstn Gateways by Name
  .DESCRIPTION
    To quickly find Online Pstn Gateways to assign, an Alias-Function to Get-CsOnlineVoiceRoutingPolicy
  .PARAMETER Identity
    If provided, acts as an Alias to Get-CsOnlineVoiceRoutingPolicy, listing one Policy
    If not provided, lists Identities of all Online Pstn Gateways
  .EXAMPLE
    Get-TeamsMGW
    Lists Identities (Names) of all Online Pstn Gateways
  .EXAMPLE
    Get-TeamsMGW -Identity PstnGateway1.domain.com
    Lists Online Pstn Gateway as Get-CsOnlinePstnGateway does (provided it exists).
  .NOTES
    Without parameters, it executes the following string:
    Get-CsOnlinePstnGateway | Select-Object Identity -ExpandProperty Identity
  .EXTERNALHELP
    https://raw.githubusercontent.com/DEberhardt/TeamsFunctions/master/docs/TeamsFunctions-help.xml
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  .LINK
    Get-TeamsOVP
  .LINK
    Get-TeamsOPU
  .LINK
    Get-TeamsOVR
  .LINK
    Get-TeamsMGW
  .LINK
    Get-TeamsTDP
  .LINK
    Get-TeamsVNR
  #>

  [CmdletBinding()]
  param (
    [Parameter(Position = 0, ValueFromPipeline, HelpMessage = "Name of the Tenant Dial Plan")]
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
      Write-Verbose -Message "Finding Online Pstn Gateways with Identity '$Identity'"
      $Gateways = Get-CsOnlinePstnGateway -WarningAction SilentlyContinue
      $Filtered = $Gateways | Where-Object Identity -Like "*$Identity*"
      if ( $Filtered.Count -gt 2) {
        $Filtered | Select-Object Identity
      }
      else {
        $Filtered
      }
    }
    else {
      Write-Verbose -Message "Finding Online Pstn Gateway Names"
      Get-CsOnlinePstnGateway | Select-Object Identity
    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Get-TeamsOVP