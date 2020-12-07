# Module:   TeamsFunctions
# Function: VoiceConfig
# Author:		David Eberhardt
# Updated:  01-DEC-2020
# Status:   PreLive




function Get-TeamsOVR {
  <#
  .SYNOPSIS
    Lists all Online Voice Routes by Name
  .DESCRIPTION
    To quickly find Online Voice Routes to troubleshoot, an Alias-Function to Get-CsOnlineVoiceRoute
  .PARAMETER Identity
    If provided, acts as an Alias to Get-CsOnlineVoiceRoute, listing one Route
    If not provided, lists Identities of all Online Voice Route (except "LocalRoute")
  .EXAMPLE
    Get-TeamsOVR
    Lists Identities (Names) of all Online Voice Route (except "LocalRoute")
  .EXAMPLE
    Get-TeamsOVP -Identity OVR-EMEA-National
    Lists Online Voice Route "OVR-EMEA-National" as Get-CsOnlineVoiceRoute does (provided it exists).
  .NOTES
    Without parameters, it executes the following string:
    Get-CsOnlineVoiceRoute | Where-Object Identity -NE "LocalRoute"  | Select-Object Name -ExpandProperty Name
  #>

  [CmdletBinding()]
  param (
    [Parameter(Position = 0, HelpMessage = "Name of the Voice Route")]
    [string]$Identity
  )

  begin {
    Show-FunctionStatus -Level PreLive
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

    # Asserting SkypeOnline Connection
    if (-not (Assert-SkypeOnlineConnection)) { break }

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    if ($PSBoundParameters.ContainsKey('Identity')) {
      Write-Verbose -Message "Finding Online Voice Routes with Identity '$Identity'"
      $Routes = Get-CsOnlineVoiceRoute -WarningAction SilentlyContinue
      $Filtered = $Routes | Where-Object Identity -Like "*$Identity*"
      if ( $Filtered.Count -gt 2) {
        $Filtered.Identity
      }
      else {
        $Filtered
      }
    }
    else {
      Write-Verbose -Message "Finding Voice Route Names"
      Get-CsOnlineVoiceRoute | Where-Object Identity -NE "LocalRoute" | Select-Object Name -ExpandProperty Name
    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Get-TeamsOVR