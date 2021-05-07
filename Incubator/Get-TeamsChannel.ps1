#IDEA:
#Get-Team & Get-TeamChannel with friendly names
# Use for CQs and AAs when Forward to Channel is used
#REGEX -match "^(19:)[0-9a-f]{32}(@thread.)(skype|tacv2|([0-9a-z]{5}))$" Alternative to name to pinpoint channel!

function Get-TeamsChannel {

  param (
    [Parameter(Mandatory, Position = 0, HelpMessage = 'DisplayName of the Team')]
    [string]$Team

    [Parameter(Mandatory, Position = 1, HelpMessage = 'DisplayName of the Channel')]
    [string]$Channel
  )

  Get-Team -DisplayName "$Team" | Get-TeamChannel | Where DisplayName -eq "$DisplayName"
}
