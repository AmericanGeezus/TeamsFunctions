# Module:   TeamsFunctions
# Function: VoiceConfig
# Author:   David Eberhardt
# Updated:  05-NOV-2021
# Status:   Live




function Get-TeamsCLI {
  <#
  .SYNOPSIS
    Lists all Calling Line Identities by Name
  .DESCRIPTION
    To quickly find Calling Line Identities to assign, an Alias-Function to Get-CsCallingLineIdentity
  .PARAMETER Identity
    String. Name or part of the Calling Line Identity. Can be omitted to list Names of all Policies (including "Global").
    If provided without a '*' in the name, an exact match is sought.
  .EXAMPLE
    Get-TeamsCLI
    Returns the Object for all Calling Line Identities (including "Global")
    Behaviour like: Get-CsCallingLineIdentity, showing only a few Parameters
  .EXAMPLE
    Get-TeamsCLI -Identity ResourceAccount@domain.com
    Returns the Object for the Online Voice Route "ResourceAccount@domain.com" (provided it exists).
    Behaviour like: Get-CsCallingLineIdentity -Identity "ResourceAccount@domain.com"
  .EXAMPLE
    Get-TeamsCLI -Identity ResourceAccount*
    Lists Online Voice Routes with "ResourceAccount" in the Name
    Behaviour like: Get-CsCallingLineIdentity -Filter "*ResourceAccount*"
  .INPUTS
    None
    System.String
  .OUTPUTS
    System.Object
  .NOTES
    This script is indulging the lazy admin. It behaves like Get-CsCallingLineIdentity with a twist:
    If more than three results are found, a reduced set of Parameters are shown for better visibility:
    Get-CsCallingLineIdentity | Select-Object Identity, Description, SignInMode, HotDeskingIdleTimeoutInMinutes
  .COMPONENT
    SupportingFunction
    VoiceConfiguration
  .FUNCTIONALITY
    Queries Calling Line Identities by Name
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-TeamsCLI.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_VoiceConfiguration.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_Supporting_Functions.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  #>

  [CmdletBinding()]
  param (
    [Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = 'Name of the Calling Line Identity')]
    [string]$Identity
  )

  begin {
    Show-FunctionStatus -Level Live
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

    # Asserting MicrosoftTeams Connection
    if ( -not $script:TFPSST) { $script:TFPSST = Assert-MicrosoftTeamsConnection; if ( -not $script:TFPSST ) { break } }

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    if ($PSBoundParameters.ContainsKey('Identity')) {
      Write-Verbose -Message "Finding Calling Line Identity with Identity '$Identity'"
      if ($Identity -match [regex]::Escape('*')) {
        $Filtered = Get-CsCallingLineIdentity -Filter "*$Identity*"
      }
      else {
        $Filtered = Get-CsCallingLineIdentity -Identity "$Identity"
      }
    }
    else {
      Write-Verbose -Message 'Finding Calling Line Identity Names'
      $Filtered = Get-CsCallingLineIdentity #| Where-Object Identity -NE 'Global'
    }

    if ( $Filtered.Count -gt 3) {
      $Filtered = $Filtered | Select-Object Identity, Description, EnableUserOverride, BlockIncomingPstnCallerID, CompanyName
    }
    return $Filtered | Sort-Object Identity
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} # Get-TeamsCLI
