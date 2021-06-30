# Module:   TeamsFunctions
# Function: TeamManagement
# Author:   David Eberhardt
# Updated:  08-MAY-2021
# Status:   RC




function Get-TeamsTeamChannel {
  <#
  .SYNOPSIS
    Returns a Channel Object from Team & Channel Names or IDs
  .DESCRIPTION
    Combining lookup for Team (Get-Team) and Channel (Get-TeamChannel) into one function to return the channel object.
  .PARAMETER Team
    Required. Name or GroupId (Guid). As the name might not be unique, validation is performed for unique matches.
    If the input matches a 36-digit GUID, lookup is performed via GroupId, otherwise via DisplayName
  .PARAMETER Channel
    Required. Name or Id (Guid). If multiple Teams have been discovered, all Channels with this name in each team are returned.
    If the input matches a GUID (starting with "19:"), lookup is performed via Id, otherwise via DisplayName
  .EXAMPLE
    Get-TeamsTeamChannel -Team "My Team" -Channel "CallQueue"
    Searches for Teams with the DisplayName of "My Team".
    If found, looking for a channel with the DisplayName "CallQueue"
    If found, the Channel Object will be returned
    Multiple Objects could be returned if multiple Teams called "My Team" with Channels called "CallQueue" exist.
  .EXAMPLE
    Get-TeamsTeamChannel -Team 1234abcd-1234-1234-1234abcd5678 -Channel "CallQueue"
    Searches for Teams with the GroupId of 1234abcd-1234-1234-1234abcd5678.
    If found, looking for a channel with the DisplayName "CallQueue"
    If found, the Channel Object will be returned
  .EXAMPLE
    Get-TeamsTeamChannel -Team "My Team" -Channel 19:1234abcd567890ef1234abcd567890ef@thread.skype
    Searches for Teams with the DisplayName of "My Team".
    If found, looking for a channel with the ID "19:1234abcd567890ef1234abcd567890ef@thread.skype"
    If found, the Channel Object will be returned
  .EXAMPLE
    Get-TeamsTeamChannel -Team 1234abcd-1234-1234-1234abcd5678 -Channel 19:1234abcd567890ef1234abcd567890ef@thread.skype
    If a Team with the GroupId 1234abcd-1234-1234-1234abcd5678 is found and this team has a channel with the ID "19:1234abcd567890ef1234abcd567890ef@thread.skype", the Channel Object will be returned
    This is the safest option as it will always find a correct result provided the entities exist.
  .INPUTS
    System.String
  .OUTPUTS
    System.Object
  .NOTES
    This CmdLet combines two lookups in order to find a valid channel by Name(s).
    It is used to determine usability for Call Queues (Forward to Channel)
  .COMPONENT
    TeamsCallQueue
  .FUNCTIONALITY
    The idea is to simplify lookup of Teams and Channels and provide one CmdLet to find a unique match.
    When used with DisplayNames it executes the following command:
    Get-Team -DisplayName "$Team" | Get-TeamChannel | Where-Object Id -eq "$Channel"
    The CmdLet also supports providing the GUID for the Team or Channel to allow for more sturdy lookup.
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-TeamsTeamChannel.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsCallQueue.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  #>

  [CmdletBinding()]
  [Alias('Get-Channel')]
  [OutputType([System.Object[]])]

  param (
    [Parameter(Mandatory, Position = 0, ValueFromPipelineByPropertyName, HelpMessage = 'DisplayName (or GroupId) of the Team')]
    [string]$Team,

    [Parameter(Mandatory, Position = 1, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = 'DisplayName (or Id) of the Channel')]
    [string]$Channel
  )

  begin {
    Show-FunctionStatus -Level RC
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"
    Write-Verbose -Message "Need help? Online:  $global:TeamsFunctionsHelpURLBase$($MyInvocation.MyCommand)`.md"

    # Asserting MicrosoftTeams Connection
    if (-not (Assert-MicrosoftTeamsConnection)) { break }

    # Setting Preference Variables according to Upstream settings
    if (-not $PSBoundParameters.ContainsKey('Verbose')) { $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference') }
    if (-not $PSBoundParameters.ContainsKey('Confirm')) { $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference') }
    if (-not $PSBoundParameters.ContainsKey('WhatIf')) { $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference') }
    if (-not $PSBoundParameters.ContainsKey('Debug')) { $DebugPreference = $PSCmdlet.SessionState.PSVariable.GetValue('DebugPreference') } else { $DebugPreference = 'Continue' }
    if ( $PSBoundParameters.ContainsKey('InformationAction')) { $InformationPreference = $PSCmdlet.SessionState.PSVariable.GetValue('InformationAction') } else { $InformationPreference = 'Continue' }

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    #Looking up Team
    try {
      Write-Verbose -Message "[PROCESS] Processing '$Team'"
      if ($Team -match '^[0-9a-f]{8}-([0-9a-f]{4}\-){3}[0-9a-f]{12}$') {
        $TeamObject = Get-Team -GroupId $Team -ErrorAction Stop
      }
      else {
        $TeamObject = Get-Team -DisplayName "$Team" -ErrorAction Stop
        Write-Verbose -Message "Team '$Team' - $($TeamObject.Count) Objects Found with '$Team' in the DisplayName"
        $TeamObject = $TeamObject | Where-Object DisplayName -EQ "$Team"
        Write-Verbose -Message "Team '$Team' - $($TeamObject.Count) Objects Found with '$Team' as the exact DisplayName"

        if ($null -eq $TeamObject) {
          Write-Error "No Object found for '$Team'!" -Category ParserError -RecommendedAction "Please check 'Name' provided" -ErrorAction Stop
          return $null, $null # Stopping operation as no Team was found
        }
      }
    }
    catch {
      throw "Error looking up Teams Team '$Team': $($_.Exception.Message)"
    }

    if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
      "Function: $($MyInvocation.MyCommand.Name): TeamObject:", ($TeamObject | Format-Table -AutoSize | Out-String).Trim() | Write-Debug
    }

    if ($TeamObject.GetType().BaseType.Name -eq 'Array') {
      Write-Warning -Message "Multiple Results found for '$Team' ($($TeamObject.Count)) - Searching for a unique match for the Channel '$Channel' within each team to determine a match! - First match is returned" -Verbose
    }
    else {
      Write-Verbose -Message "Unique result found for '$Team' - Id: '$($TeamObject.GroupId)'"
    }

    foreach ($TeamObj in $TeamObject) {
      #Looking up Channel within the Team
      Write-Verbose -Message "[PROCESS] Processing found object: '$($TeamObj.DisplayName)' - Channel '$Channel'"
      try {
        if ($Channel -match '^(19:)[0-9a-f]{32}(@thread.)(skype|tacv2|([0-9a-z]{5}))$') {
          $ChannelObj = $TeamObj | Get-TeamChannel | Where-Object Id -EQ "$Channel" -ErrorAction Stop
        }
        else {
          $ChannelObj = $TeamObj | Get-TeamChannel | Where-Object DisplayName -EQ "$Channel" -ErrorAction Stop
        }
        if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
          "Function: $($MyInvocation.MyCommand.Name): Channel:", ($ChannelObj | Format-Table -AutoSize | Out-String).Trim() | Write-Debug
        }

        # Output
        if ( $ChannelObj ) {
          Write-Verbose -Message "Team '$($TeamObj.DisplayName)' - '$Channel' found"
          return $TeamObj, $ChannelObj
        }
        else {
          Write-Verbose -Message "Team '$($TeamObj.DisplayName)' - Channel '$Channel': No Channel found in Team with this Name ID"
        }
      }
      catch {
        Write-Error "Team '$($TeamObj.DisplayName)' - Channel '$Channel': $($_.Exception.Message)"
      }
    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"

  } #end
} #Get-TeamsTeamChannel
