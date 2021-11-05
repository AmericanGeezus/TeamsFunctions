# Module:   TeamsFunctions
# Function: VoiceConfig
# Author:   David Eberhardt
# Updated:  01-APR-2021
# Status:   Live




function Get-TeamsIPP {
  <#
  .SYNOPSIS
    Lists all IP Phone Policies by Name
  .DESCRIPTION
    To quickly find IP Phone Policies to assign, an Alias-Function to Get-CsTeamsIPPhonePolicy
  .PARAMETER Identity
    String. Name or part of the IP Phone Policy. Can be omitted to list Names of all Policies (including "Global").
    If provided without a '*' in the name, an exact match is sought.
  .EXAMPLE
    Get-TeamsIPP
    Returns the Object for all IP Phone Policies (including "Global")
    Behaviour like: Get-CsTeamsIPPhonePolicy, showing only a few Parameters
  .EXAMPLE
    Get-TeamsIPP -Identity CommonAreaPhone
    Returns the Object for the Online Voice Route "CommonAreaPhone" (provided it exists).
    Behaviour like: Get-CsTeamsIPPhonePolicy -Identity "CommonAreaPhone"
  .EXAMPLE
    Get-TeamsIPP -Identity CommonAreaPhone-*
    Lists Online Voice Routes with "CommonAreaPhone" in the Name
    Behaviour like: Get-CsTeamsIPPhonePolicy -Filter "*CommonAreaPhone*"
  .INPUTS
    None
    System.String
  .OUTPUTS
    System.Object
  .NOTES
    This script is indulging the lazy admin. It behaves like Get-CsTeamsIPPhonePolicy with a twist:
    If more than three results are found, a reduced set of Parameters are shown for better visibility:
    Get-CsTeamsIPPhonePolicy | Select-Object Identity, Description, SignInMode, HotDeskingIdleTimeoutInMinutes
  .COMPONENT
    SupportingFunction
    VoiceConfiguration
  .FUNCTIONALITY
    Queries IP Phone Policies by Name
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-TeamsIPP.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_VoiceConfiguration.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_Supporting_Functions.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  #>

  [CmdletBinding()]
  param (
    [Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = 'Name of the IP Phone Policy')]
    [string]$Identity
  )

  begin {
    Show-FunctionStatus -Level Live
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"
    Write-Verbose -Message "Need help? Online:  $global:TeamsFunctionsHelpURLBase$($MyInvocation.MyCommand)`.md"

    # Asserting MicrosoftTeams Connection
    if (-not (Assert-MicrosoftTeamsConnection)) { break }

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    if ($PSBoundParameters.ContainsKey('Identity')) {
      Write-Verbose -Message "Finding IP Phone Policy with Identity '$Identity'"
      if ($Identity -match [regex]::Escape('*')) {
        $Filtered = Get-CsTeamsIPPhonePolicy -Filter "*$Identity*"
      }
      else {
        $Filtered = Get-CsTeamsIPPhonePolicy -Identity "$Identity"
      }
    }
    else {
      Write-Verbose -Message 'Finding IP Phone Policy Names'
      $Filtered = Get-CsTeamsIPPhonePolicy #| Where-Object Identity -NE 'Global'
    }

    if ( $Filtered.Count -gt 3) {
      $Filtered = $Filtered | Select-Object Identity, Description, SignInMode, HotDeskingIdleTimeoutInMinutes
    }
    return $Filtered | Sort-Object Identity
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} # Get-TeamsIPP
