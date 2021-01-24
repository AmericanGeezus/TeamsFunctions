# Module:   TeamsFunctions
# Function: Session
# Author:		David Eberhardt
# Updated:  01-OCT-2020
# Status:   Live

function Disconnect-SkypeOnline {
  <#
  .SYNOPSIS
    Disconnects Sessions established to SkypeOnline
  .DESCRIPTION
    Disconnects any current Skype for Business Online remote PowerShell sessions and removes any imported modules.
    By default Office 365 allows two (!) concurrent sessions per User.
    Session exhaustion may occur if sessions hang or incorrectly closed.
    Avoid this by cleanly disconnecting the sessions with this function before timeout
  .EXAMPLE
    Disconnect-SkypeOnline
    Removes any current Skype for Business Online remote PowerShell sessions and removes any imported modules.
  .NOTES
    Helper function to disconnect from SkypeOnline
    By default Office 365 allows two (!) concurrent sessions per User.
    If sessions hang or are incorrectly closed (not properly disconnected),
    this can lead to session exhaustion which results in not being able to connect again.
    An admin can sign-out this user from all Sessions through the Office 365 Admin Center
    This process may take up to 15 mins and is best avoided, through proper disconnect after use
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  .LINK
    Connect-Me
  .LINK
    Connect-SkypeOnline
  .LINK
    Connect-AzureAD
  .LINK
    Connect-MicrosoftTeams
  .LINK
    Disconnect-Me
  .LINK
    Disconnect-SkypeOnline
  .LINK
    Disconnect-AzureAD
  .LINK
    Disconnect-MicrosoftTeams
  #>

  [CmdletBinding()]
  param() #param

  begin {
    Show-FunctionStatus -Level Live
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"
    Write-Verbose -Message "Need help? Online:  $global:TeamsFunctionsHelpURLBase$($MyInvocation.MyCommand)`.md"

    [bool]$sessionFound = $false

    # Cleanup of global Variables set
    Remove-TeamsFunctionsGlobalVariable

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    $PSSessions = Get-PSSession -WarningAction SilentlyContinue

    foreach ($session in $PSSessions) {
      if ($session.ComputerName -like '*.online.lync.com' -or $session.ComputerName -eq 'api.interfaces.records.teams.microsoft.com') {
        $sessionFound = $true
        <# try {
          Write-Verbose -Message "Disconnecting Session to: $($session.ComputerName)"
          Disconnect-PSSession $session -ErrorAction Stop
        }
        catch {
          Write-Verbose -Message "Session failed to disconnect: $($_.Exception.Message)"
        }
        Write-Verbose -Message "Removing Session to: $($session.ComputerName)"
        #>
        Remove-PSSession $session
      }
    }

    if ( $sessionFound ) {
      Get-Module | Where-Object { $_.Description -like '*.online.lync.com*' } | Remove-Module
    }
    else {
      Write-Verbose -Message 'No remote PowerShell sessions to Skype Online currently exist'
    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Disconnect-SkypeOnline
