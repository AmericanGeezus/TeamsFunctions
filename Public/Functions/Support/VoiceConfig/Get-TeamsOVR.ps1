# Module:   TeamsFunctions
# Function: VoiceConfig
# Author:		David Eberhardt
# Updated:  01-JAN-2021
# Status:   Live




function Get-TeamsOVR {
  <#
  .SYNOPSIS
    Lists all Online Voice Routes by Name
  .DESCRIPTION
    To quickly find Online Voice Routes to troubleshoot, an Alias-Function to Get-CsOnlineVoiceRoute
  .PARAMETER Identity
    If provided, acts as an Alias to Get-CsOnlineVoiceRoute, listing one Route
    If not provided, lists Identities of all Online Voice Route (except "LocalRoute")
  .PARAMETER Filter
    Searches for all Online Voice Routes that contains the string in the Name.
  .EXAMPLE
    Get-TeamsOVR
    Lists Identities (Names) of all Online Voice Route (except "LocalRoute")
  .EXAMPLE
    Get-TeamsOVP -Identity OVR-EMEA-National
    Lists Online Voice Route "OVR-EMEA-National" as Get-CsOnlineVoiceRoute does (provided it exists).
  .NOTES
    Without parameters, it executes the following string:
    Get-CsOnlineVoiceRoute | Where-Object Identity -NE "LocalRoute"  | Select-Object Name -ExpandProperty Name
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

  [CmdletBinding(DefaultParameterSetName = "Identity")]
  param (
    [Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = "Identity", HelpMessage = "Name of the Online Voice Route")]
    [string]$Identity,

    [Parameter(ParameterSetName = "Filter", HelpMessage = "Name of the Online Voice Route to search")]
    [string]$Filter
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
      $Result = Get-CsOnlineVoiceRoute -WarningAction SilentlyContinue
      switch ($PSCmdlet.ParameterSetName) {
        "Identity" {
          $Filtered = $Result | Where-Object Identity -EQ "Tag:$Identity"
        }
        "Filter" {
          $Filtered = $Result | Where-Object Identity -Like "*$Identity*"
        }
      }

      if ( $Filtered.Count -gt 3) {
        $Filtered | Select-Object Identity
      }
      else {
        $Filtered
      }
    }
    else {
      Write-Verbose -Message "Finding Voice Route Names"
      Get-CsOnlineVoiceRoute | Where-Object Identity -NE "LocalRoute" | Select-Object Name
    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Get-TeamsOVR