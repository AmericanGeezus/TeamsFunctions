# Module:     TeamsFunctions
# Function:   Assertion
# Author:     David Eberhardt
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
  #Show-FunctionStatus -Level Live
  #Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
  [CmdletBinding()]
  PARAM($Title)
  try {
    $Host.UI.RawUI.WindowTitle = $Title
  }
  catch {
    $PSCmdlet.ThrowTerminatingError($_)
  }
}