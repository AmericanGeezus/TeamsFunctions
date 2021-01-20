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
    To quickly find Online Pstn Gateways to assign, combining Lookup and Search
  .PARAMETER Identity
    String. Name or part of the Pstn Gateways. Can be omitted to list Names of all Media Gateways.
    If provided without a '*' in the name, an exact match is sought.
  .EXAMPLE
    Get-TeamsMGW
    Lists Identities (Names) of all Online Pstn Gateways
    Behaviour like: Get-CsOnlinePstnGateway, if more than 3 results are found, only names are returned
  .EXAMPLE
    Get-TeamsMGW [-Identity] PstnGateway1.domain.com
    Lists Online Pstn Gateways as Get-CsOnlinePstnGateway does (provided it exists).
    Behaviour like: Get-CsOnlinePstnGateway -Identity "PstnGateway1.domain.com"
  .EXAMPLE
    Get-TeamsMGW -Identity PstnGateway*
    Lists Online Pstn Gateway with "PstnGateway" in the Name
    Behaviour like: Get-CsOnlinePstnGateway -Filter "*PstnGateway*"
  .NOTES
    This script is indulging the lazy admin. It behaves like Get-CsOnlinePstnGateway with a twist:
    If more than 3 results are found, behaves like Get-CsOnlinePstnGateway | Select Identity
    Without any parameters, it lists names only:
    Get-CsOnlinePstnGateway | Select-Object Identity
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
    [Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = 'Name of the Online Pstn Gateway')]
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
      Write-Verbose -Message "Finding Online Voice Routes with Identity '$Identity'"
      if ($Identity -match [regex]::Escape('*')) {
        $Filtered = Get-CsOnlinePstnGateway -Filter "*$Identity*"
      }
      else {
        $Filtered = Get-CsOnlinePstnGateway -Identity "$Identity"
      }

      if ( $Filtered.Count -gt 3) {
        $Filtered | Select-Object Identity
      }
      else {
        $Filtered
      }
    }
    else {
      Write-Verbose -Message 'Finding Online Pstn Gateway Names'
      Get-CsOnlinePstnGateway | Select-Object Identity
    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} # Get-TeamsMGW