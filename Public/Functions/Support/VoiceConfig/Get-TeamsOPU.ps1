# Module:   TeamsFunctions
# Function: VoiceConfig
# Author:		David Eberhardt
# Updated:  01-JAN-2021
# Status:   Live




function Get-TeamsOPU {
  <#
  .SYNOPSIS
    Lists all Online PSTN Usages by Name
  .DESCRIPTION
    To quickly find Online PSTN Usages, an Alias-Function to Get-CsOnlinePstnUsage
  .PARAMETER Usage
    If provided, acts as an Alias to Get-CsOnlineVoiceRoutingPolicy, listing one Policy
    If not provided, lists Identities of all Online Voice Routing Policies (except "Global")
  .EXAMPLE
    Get-TeamsOPU
    Lists Identities (Names) of all Online Pstn Usages
  .EXAMPLE
    Get-TeamsOPU "PstnUsageName"
    Lists all PstnUsages with the String PstnUsageName of all Online Pstn Usages
  .NOTES
    It executes the following string:
    Get-CsOnlinePstnUsage Global | Select-Object Usage -ExpandProperty Usage
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
    [Parameter(Position = 0, HelpMessage = "Name of the Voice Routing Policy")]
    [string]$Usage
  )

  begin {
    Show-FunctionStatus -Level Live
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

    # Asserting SkypeOnline Connection
    if (-not (Assert-SkypeOnlineConnection)) { break }

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    if ($PSBoundParameters.ContainsKey('Usage')) {
      Write-Verbose -Message "Finding Online Pstn Usages with Usage '$Usage'"
      $Usages = Get-CsOnlinePstnUsage Global | Select-Object Usage -ExpandProperty Usage
      $Usages | Where-Object { $_ -Like "*$Usage*" }

    }
    else {
      Write-Verbose -Message "Finding Online Pstn Usage Names"
      Get-CsOnlinePstnUsage Global | Select-Object Usage -ExpandProperty Usage

    }

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Get-TeamsOPU
