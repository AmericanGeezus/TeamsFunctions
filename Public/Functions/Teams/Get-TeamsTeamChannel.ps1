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
  .LINK
    about_TeamsCallQueue
  .LINK
    New-TeamsCallQueue
  .LINK
    Get-TeamsCallQueue
  .LINK
    Set-TeamsCallQueue
  .LINK
    Assert-TeamsTeamChannel
  .LINK
    Get-TeamsTeamChannel
  .LINK
    Test-TeamsTeamChannel
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
      if ($Team -match '^[0-9a-f]{8}-([0-9a-f]{4}\-){3}[0-9a-f]{12}$') {
        $TeamObj = Get-Team -GroupId $Team -ErrorAction Stop
      }
      else {
        #TODO This does not yet account for multiple Teams with this name
        #TEST output for multiple teams with this name
        #VALIDATE Breakout as Test-TeamsTeam and Assert-TeamsTeam too? #Spike with object input $Team.GroupId matches
        $TeamObj = Get-Team -DisplayName "$Team" -ErrorAction Stop

        if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
          "Function: $($MyInvocation.MyCommand.Name): Team:", ($TeamObj | Format-Table -AutoSize | Out-String).Trim() | Write-Debug
        }
      }
    }
    catch {
      throw "Error looking up Teams Team '$Team': $($_.Exception.Message)"
    }

    #Feedback for multiple Teams found
    if ($TeamObj.Count -gt 1) {
      Write-Verbose -Message "$($MyInvocation.MyCommand) - No unique result found for Team '$Team'. Looking for Channel '$Channel'" -Verbose
      Write-Debug 'BETA: Result is piped to Get-TeamChannel. Script might not return a proper result yet. Handle with Care!' -Debug
    }

    #Looking up Channel within the Team
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
      return $ChannelObj
    }
    catch {
      throw "Error looking up Channel '$Channel' in Teams Team '$Team': $($_.Exception.Message)"
    }
    <#
    switch ($TeamObj) {
      {$PSItem.Count -le 1} {
        Write-Verbose -Message "$($MyInvocation.MyCommand) - No Team found for '$Team'" -Verbose
        return
      }
      {$PSItem.Count -eq 1} {

      }
      {$PSItem.Count -gt 1} {
        Write-Verbose -Message "$($MyInvocation.MyCommand) - No unique result found for Team '$Team'. Looking for Channel '$Channel'" -Verbose

      }
    }

    foreach ($Obj in $TeamObj) {
      # Build Test-TeamsTeam and Test-TeamsTeamChannel & Assert-TeamsTeam and Assert-TeamsTeamChannel and feed them into this one?
      if ($Channel -match "^(19:)[0-9a-f]{32}(@thread.)(skype|tacv2|([0-9a-z]{5}))$") {
        $ChannelObj = $Obj | Get-TeamChannel | Where-Object Id -eq "$Channel" -ErrorAction Stop
      }
      else {
        $ChannelObj = $Obj | Get-TeamChannel | Where-Object DisplayName -eq "$Channel" -ErrorAction Stop
    $ChannelsObj = @()
        $ChannelsObj += $ChannelObj
      }
    }

    if ($ChannelsObj.Count -gt 1) { # Can't use .isArray() as we have defined it as an array at the start.
      Write-Warning -Message "No unique result found for the Team Channel"
      return $ChannelsObj
    }
#>

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"

  } #end
} #Get-TeamsTeamChannel
