# Module:   TeamsFunctions
# Function: Session
# Author:		David Eberhardtt
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
      Connect-Me
      Connect-SkypeOnline
      Connect-AzureAD
      Connect-MicrosoftTeams
      Disconnect-Me
      Disconnect-SkypeOnline
      Disconnect-AzureAD
      Disconnect-MicrosoftTeams
    #>

  [CmdletBinding()]
  param() #param

  begin {
    Show-FunctionStatus -Level Live
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.Mycommand)"

    [bool]$sessionFound = $false

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.Mycommand)"
    $PSSessions = Get-PSSession -WarningAction SilentlyContinue

    foreach ($session in $PSSessions) {
      if ($session.ComputerName -like "*.online.lync.com") {
        $sessionFound = $true
        Remove-PSSession $session
      }
    }

    if ($sessionFound -eq $false) {
      Get-Module | Where-Object { $_.Description -like "*.online.lync.com*" } | Remove-Module
    }
    else {
      Write-Verbose -Message "No remote PowerShell sessions to Skype Online currently exist"
    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.Mycommand)"
  } #end
} #Disconnect-SkypeOnline
