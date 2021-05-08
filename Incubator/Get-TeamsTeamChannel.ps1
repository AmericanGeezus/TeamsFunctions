#IDEA:
#Get-Team & Get-TeamChannel with friendly names
# Use for CQs and AAs when Forward to Channel is used
#REGEX -match "^(19:)[0-9a-f]{32}(@thread.)(skype|tacv2|([0-9a-z]{5}))$" Alternative to name to pinpoint channel!

function Get-TeamsTeamChannel {

  param (
    [Parameter(Mandatory, Position = 0, HelpMessage = 'DisplayName of the Team')]
    [string]$Team,

    [Parameter(Mandatory, Position = 1, HelpMessage = 'DisplayName of the Channel')]
    [string]$Channel
  )

  #Breakout as Test-Team and Assert-TeamsTeam too! #Spike with object input $Team.GroupId matches
  if ($Team -match "^[0-9a-f]{8}-([0-9a-f]{4}\-){3}[0-9a-f]{12}$") {
    $TeamObj = Get-Team -GroupId $Team
  }
  else {
    $TeamObj = Get-Team -DisplayName "$Team"
    if ($TeamObj.isArray()) {
      Write-Warning -Message "No unique result found for the Team"
      return $TeamObj
    }
  }


  # Build Test-TeamsTeam and Test-TeamsTeamChannel & Assert-TeamsTeam and Assert-TeamsTeamChannel and feed them into this one?
  if ($Channel -match "^(19:)[0-9a-f]{32}(@thread.)(skype|tacv2|([0-9a-z]{5}))$") {
    $ChannelObj = $TeamObj | Get-TeamChannel | Where-Object Id -eq "$Channel" -ErrorAction Stop
  }
  else {
    $ChannelObj = $TeamObj | Get-TeamChannel | Where-Object DisplayName -eq "$Channel" -ErrorAction Stop
  }

  if ($ChannelObj.isArray()) {
    Write-Warning -Message "No unique result found for the Team Channel"
    return $ChannelObj
  }


}
