# Module:     TeamsFunctions
# Function:   Session
# Author:     David Eberhardt
# Updated:    01-OCT-2020
# Status:     Live




function Assert-MicrosoftTeamsConnection {
  <#
	.SYNOPSIS
		Asserts an established Connection to MicrosoftTeams
	.DESCRIPTION
		Tests a connection to MicrosoftTeams is established.
	.EXAMPLE
		Assert-MicrosoftTeamsConnection
    Will run Test-MicrosoftTeamsConnection and, if successful, stops.
    If unsuccessful, displays request to create a new session and stops.
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  #>

  [CmdletBinding()]
  [Alias('pol')]
  [OutputType([Boolean])]
  param() #param

  begin {
    Show-FunctionStatus -Level Live
    $Stack = Get-PSCallStack
    $Called = ($stack.length -ge 3)

  } #begin

  process {

    if (Test-MicrosoftTeamsConnection) {
      if ($stack.length -lt 3) {
        Write-Verbose -Message '[ASSERT] MicrosoftTeams Session Connected'
      }
      return $(if ($Called) { $true })
    }
    else {
      try {
        $null = Connect-MicrosoftTeams -ErrorAction Stop
      }
      catch {
        if ($PSBoundParameters.ContainsKey('Debug')) {
          "Function: $($MyInvocation.MyCommand.Name) - Exception message", ( $_.Exception.Message | Format-Table -AutoSize | Out-String).Trim() | Write-Debug
        }
        if ($_.Exception.Message -contains 'The WinRM client received an HTTP status code of 403 from the remote WS-Management service') {
          Write-Host '[ASSERT] ERROR: Connect-MicrosoftTeams failed. Please validate your Admin roles, disconnect and reconnect' -ForegroundColor Red
        }
        <# Commented out to avoid having two authentication popups
        else {
          $null = Connect-MicrosoftTeams -ErrorAction SilentlyContinue
        }
        #>
      }
      if (Test-MicrosoftTeamsConnection) {
        if ($stack.length -lt 3) {
          Write-Verbose -Message '[ASSERT] MicrosoftTeams Session Connected'
        }
        return $(if ($Called) { $true })
      }
      else {
        Write-Host '[ASSERT] ERROR: You must call the Connect-MicrosoftTeams cmdlet before calling any other cmdlets. (Connect-Me can be used for multiple connections) ' -ForegroundColor Red
        return $(if ($Called) { $false })
      }
    }

  } #process

  end {

  } #end


} #Assert-MicrosoftTeamsConnection
