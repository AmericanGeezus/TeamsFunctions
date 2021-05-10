# Module:     TeamsFunctions
# Function:   Assertion
# Author:     David Eberhardt
# Updated:    15-DEC-2020
# Status:     Live




function Get-TeamAndChannel {
  <#
	.SYNOPSIS
		Queries Team and Channel based on input
	.DESCRIPTION
    Used by Get-TeamsCallableEntity
  .PARAMETER String
    String in on of the formats:
    TeamId\ChannelId, TeamId\ChannelDisplayName, TeamDisplayName,ChannelId or TeamDisplayName\ChannelDisplayName
	.EXAMPLE
    Get-TeamAndChannel -String "00000000-0000-0000-0000-000000000000\19:abcdef1234567890abcdef1234567890@thread.tacv2"
  .NOTES
    This helper function is targeted by Get-TeamsCallQueue as well as Get-TeamsCallableEntity
    Avoids having to wait for Get-TeamsCallableEntity
  #>

  [CmdletBinding()]
  param(
    [string]$String
  ) #param

  # Setting Preference Variables according to Upstream settings
  if (-not $PSBoundParameters.ContainsKey('Verbose')) { $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference') }
  if (-not $PSBoundParameters.ContainsKey('Debug')) { $DebugPreference = $PSCmdlet.SessionState.PSVariable.GetValue('DebugPreference') } else { $DebugPreference = 'Continue' }
  if ( $PSBoundParameters.ContainsKey('InformationAction')) { $InformationPreference = $PSCmdlet.SessionState.PSVariable.GetValue('InformationAction') } else { $InformationPreference = 'Continue' }


  $TeamId,$ChannelId = $String.split('\')

  if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
    "Function: $($MyInvocation.MyCommand.Name): Team:", ($TeamId | Format-Table -AutoSize | Out-String).Trim() | Write-Debug
    "Function: $($MyInvocation.MyCommand.Name): Channel:", ($ChannelId | Format-Table -AutoSize | Out-String).Trim() | Write-Debug
  }
  try {
    if ($TeamId -match "^[0-9a-f]{8}-([0-9a-f]{4}\-){3}[0-9a-f]{12}$") {
      $Team = Get-Team -GroupId $TeamId -ErrorAction Stop
    }
    else {
      $Team = Get-Team -DisplayName "$TeamId" -ErrorAction Stop

      # dealing with potential duplicates
      if ( $Team.Count -gt 1 ) {
        Write-Verbose 'Target is a Team\Channel, but multiple Teams found'
        $Team = $Team | Where-Object DisplayName -EQ "$String"
      }
      if ( $Team.Count -gt 1 ) {
        Write-Verbose 'Target is a Team\Channel, but not unique!'
        throw [System.Reflection.AmbiguousMatchException]::New('Multiple Targets found - Result not unique (Team)')
      }
    }

    if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
      "Function: $($MyInvocation.MyCommand.Name): Team:", ($Team | Format-Table -AutoSize | Out-String).Trim() | Write-Debug
    }
  }
  catch {
    throw "$($MyInvocation.MyCommand) - Lookup for Team & Channel - Team not found. Exception: $($_.Exception.Message)"
  }

  try {
    if ($ChannelId -match "^(19:)[0-9a-f]{32}(@thread.)(skype|tacv2|([0-9a-z]{5}))$") {
      $Channel = Get-TeamChannel -GroupId $Team.GroupId | Where-Object Id -eq $ChannelId -ErrorAction Stop
    }
    else {
      $Channel = Get-TeamChannel -GroupId $Team.GroupId | Where-Object DisplayName -eq "$ChannelId" -ErrorAction Stop

      # dealing with potential duplicates
      if ( $Team.Count -gt 1 ) {
        Write-Verbose 'Target is a Team\Channel, but multiple Channels found'
        $Team = $Team | Where-Object DisplayName -EQ "$String"
      }
      if ( $Team.Count -gt 1 ) {
        Write-Verbose 'Target is a Team\Channel, but not unique!'
        throw [System.Reflection.AmbiguousMatchException]::New('Multiple Targets found - Result not unique (Channel)')
      }
    }

    if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
      "Function: $($MyInvocation.MyCommand.Name): Channel:", ($Channel | Format-Table -AutoSize | Out-String).Trim() | Write-Debug
    }
  }
  catch {
    throw "$($MyInvocation.MyCommand) - Lookup for Team & Channel - Channel not found. Exception: $($_.Exception.Message)"
  }

  if ($Channel) {
    Write-Verbose 'Target is a Teams Channel'
    return $Team,$Channel
  }

} #Get-TeamAndChannel
