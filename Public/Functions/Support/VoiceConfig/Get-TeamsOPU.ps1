# Module:   TeamsFunctions
# Function: VoiceConfig
# Author:   David Eberhardt
# Updated:  01-JAN-2021
# Status:   Live




function Get-TeamsOPU {
  <#
  .SYNOPSIS
    Lists all Online PSTN Usages by Name
  .DESCRIPTION
    To quickly find Online PSTN Usages, an Alias-Function to Get-CsOnlinePstnUsage
  .PARAMETER Usage
    String. Name or part of the Online Pstn Usage. Can be omitted to list Names of all Usages.
    Searches for Usages with Get-CsOnlinePstnUsage, listing all that match.
  .EXAMPLE
    Get-TeamsOPU
    Lists Identities (Names) of all Online Pstn Usages
  .EXAMPLE
    Get-TeamsOPU "PstnUsageName"
    Lists all PstnUsages with the String 'PstnUsageName' in the name of the Online Pstn Usage
  .NOTES
    This script is indulging the lazy admin. It behaves like (Get-CsOnlinePstnUsage).Usage
    This CmdLet behaves slightly different than the others, due to the nature of Pstn Usages.
  .INPUTS
    None
    System.String
  .OUTPUTS
    System.Object
  .COMPONENT
    SupportingFunction
    VoiceConfiguration
  .FUNCTIONALITY
    Queries Online Pstn Usages by Name
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-TeamsOPU.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_VoiceConfiguration.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_Supporting_Functions.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  #>

  [CmdletBinding()]
  param (
    [Parameter(Position = 0, HelpMessage = 'Name of the Voice Routing Policy')]
    [string]$Usage
  )

  begin {
    Show-FunctionStatus -Level Live
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

    # Asserting MicrosoftTeams Connection
    if ( -not (Assert-MicrosoftTeamsConnection) ) { break }

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    $Filtered = Get-CsOnlinePstnUsage Global
    if ($PSBoundParameters.ContainsKey('Usage')) {
      Write-Verbose -Message "Finding Online Pstn Usages with Usage '$Usage'"
      $Filtered = $Filtered | Where-Object Usage -Like "*$Usage*"
    }

    return $Filtered | Sort-Object Usage | Select-Object Usage -ExpandProperty Usage

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} # Get-TeamsOPU
