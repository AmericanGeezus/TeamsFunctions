# Module:   TeamsFunctions
# Function: Session
# Author:		David Eberhardt
# Updated:  01-OCT-2020
# Status:   Live


function Disconnect-Me {
  <#
	.SYNOPSIS
		Disconnects all sessions for SkypeOnline, AzureAD & MicrosoftTeams
	.DESCRIPTION
    Helper function to disconnect from SkypeOnline, AzureAD & MicrosoftTeams
    By default Office 365 allows two (!) concurrent sessions per User.
    Session exhaustion may occur if sessions hang or incorrectly closed.
    Avoid this by cleanly disconnecting the sessions with this function before timeout
  .EXAMPLE
    Disconnect-Me
    Disconnects from SkypeOnline, AzureAD, MicrosoftTeams
    Errors and Warnings are suppressed as no verification of existing sessions is undertaken
	.NOTES
    Helper function to disconnect from SkypeOnline, AzureAD & MicrosoftTeams
    To disconnect from ExchangeOnline, please run Disconnect-ExchangeOnline
    By default Office 365 allows two (!) concurrent sessions per User.
    If sessions hang or are incorrectly closed (not properly disconnected),
    this can lead to session exhaustion which results in not being able to connect again.
    An admin can sign-out this user from all Sessions through the Office 365 Admin Center
    This process may take up to 15 mins and is best avoided, through proper disconnect after use
    An Alias is available for this function: dis
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
  [Alias('dis')]
  param() #param

  begin {
    Show-FunctionStatus -Level Live
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

    $WarningPreference = "SilentlyContinue"
    $ErrorActionPreference = "SilentlyContinue"

    Import-Module SkypeOnlineConnector
    Import-Module MicrosoftTeams -Force -Global # Must import Forcefully as the command otherwise fails (not available)
    Import-Module AzureAD
  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    try {
      Write-Verbose -Message "Disconnecting Session from SkypeOnline"
      $null = (Disconnect-SkypeOnline)
      Write-Verbose -Message "Disconnecting Session from MicrosoftTeams"
      $null = (Disconnect-MicrosoftTeams)
      Write-Verbose -Message "Disconnecting Session from AzureAd"
      $null = (Disconnect-AzureAD)
    }
    catch [NullReferenceException] {
      # Disconnecting from AzureAD results in a duplicated error which the ERRORACTION only suppresses one of.
      # This is to capture the second
      Write-Verbose -Message "AzureAD: Caught NullReferenceException. Not to worry"
    }
    catch {
      Write-ErrorRecord $_
    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Disconnect-Me
