# Module:   TeamsFunctions
# Function: Session
# Author:   David Eberhardt
# Updated:  01-OCT-2020
# Status:   Live


function Disconnect-Me {
  <#
  .SYNOPSIS
    Disconnects all sessions for AzureAD & MicrosoftTeams
  .DESCRIPTION
    Helper function to disconnect from AzureAD & MicrosoftTeams
    By default Office 365 allows two (!) concurrent sessions per User.
    Session exhaustion may occur if sessions hang or incorrectly closed.
    Avoid this by cleanly disconnecting the sessions with this function before timeout
  .PARAMETER DisableAdminRoles
    Disables activated Admin roles before disconnecting from Azure Ad
  .EXAMPLE
    Disconnect-Me
    Disconnects from AzureAD, MicrosoftTeams
    Errors and Warnings are suppressed as no verification of existing sessions is undertaken
  .INPUTS
    None
  .OUTPUTS
    System.Void
  .NOTES
    Helper function to disconnect from AzureAD & MicrosoftTeams
    To disconnect from ExchangeOnline, please run Disconnect-ExchangeOnline
    By default Office 365 allows two (!) concurrent sessions per User.
    If sessions hang or are incorrectly closed (not properly disconnected),
    this can lead to session exhaustion which results in not being able to connect again.
    An admin can sign-out this user from all Sessions through the Office 365 Admin Center
    This process may take up to 15 mins and is best avoided, through proper disconnect after use
    An Alias is available for this function: dis
  .COMPONENT
    TeamsSession
  .FUNCTIONALITY
    Disconnects existing connections to AzureAd and MicrosoftTeams
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Disconnect-Me.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsSession.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  #>

  [CmdletBinding()]
  [Alias('dis')]
  param(
    [Parameter(HelpMessage = 'Disables active AzureAd Admin Roles')]
    [switch]$DisableAdminRoles
  ) #param

  begin {
    Show-FunctionStatus -Level Live
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

    $WarningPreference = 'SilentlyContinue'
    $ErrorActionPreference = 'SilentlyContinue'
    $InformationPreference = 'Continue'

    # Cleanup of global Variables set
    #Remove-TeamsFunctionsGlobalVariable # Removed as dynamic replacement is working as intended
    $null = (Remove-Variable -Name TeamsFunctions* -Scope Global -ErrorAction SilentlyContinue)

    [bool]$sessionFound = $false

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    # Querying Azure Ad Connection
    $SessionInfo = Get-CurrentConnectionInfo
    if ( $SessionInfo ) {
      Write-Information "Disconnecting from Tenant: $($SessionInfo.Tenant)"
    }

    try {
      Write-Verbose -Message 'Disconnecting Session from MicrosoftTeams'
      $null = (Disconnect-MicrosoftTeams)

      if ($DisableAdminRoles) {
        Write-Verbose -Message 'Disabling activated Admin Roles'
        $null = (Disable-MyAzureAdAdminRole)
      }

      Write-Verbose -Message 'Disconnecting Session from AzureAd'
      $null = (Disconnect-AzureAD)
    }
    catch [NullReferenceException] {
      # Disconnecting from AzureAD results in a duplicated error which the ERRORACTION only suppresses one of.
      # This is to capture the second
      Write-Verbose -Message 'AzureAD: Caught NullReferenceException. Not to worry'
    }
    catch {
      throw $_
    }

    Write-Verbose -Message 'Cleaning up PowerShell Sessions'
    $PSSessions = Get-PSSession -WarningAction SilentlyContinue

    foreach ($session in $PSSessions) {
      if ($session.ComputerName -like '*.online.lync.com' -or $session.ComputerName -eq 'api.interfaces.records.teams.microsoft.com') {
        $sessionFound = $true
        Remove-PSSession $session
      }
    }

    if ( $sessionFound ) {
      Get-Module | Where-Object { $_.Description -like '*.online.lync.com*' } | Remove-Module
    }
    else {
      Write-Verbose -Message 'No remote PowerShell sessions currently exist'
    }

    Set-PowerShellWindowTitle 'Windows PowerShell'

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Disconnect-Me
