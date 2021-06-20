# Module:     TeamsFunctions
# Function:   Helper
# Author:     Francois-Xavier Cat
# Updated:    31-MAY-2021
# Status:     Live




function Set-PowerShellWindowTitle {
  <#
    .SYNOPSIS
      Function to set the title of the PowerShell Window
    .DESCRIPTION
      Function to set the title of the PowerShell Window
    .PARAMETER Title
      Specifies the Title of the PowerShell Window
    .EXAMPLE
      PS C:\> Set-PowerShellWindowTitle -Title LazyWinAdmin.com
    .NOTES
      Francois-Xavier Cat
      lazywinadmin.com
      @lazywinadmin
  #>
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Window title is a miniscule change')]
  [CmdletBinding()]
  PARAM($Title)
  #Show-FunctionStatus -Level Live
  #Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

  try {
    $Host.UI.RawUI.WindowTitle = $Title
  }
  catch {
    $PSCmdlet.ThrowTerminatingError($_)
  }
}