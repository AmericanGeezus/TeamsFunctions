# Module:     TeamsFunctions
# Function:   AzureAd Licensing
# Author: Jeff Brown
# Updated:    17-APR-2020
# Status:     Unmanaged




function GetActionOutputObject3 {
  <#
    .SYNOPSIS
    Tests whether a valid PS Session exists for SkypeOnline (Teams)
    .DESCRIPTION
    Helper function for Output with 3 Parameters
    .PARAMETER Name
    Name of account being modified
    .PARAMETER Property
    Object/property that is being modified
    .PARAMETER Result
    Result of action being performed
	#>

  [CmdletBinding()]
  [OutputType([PSCustomObject])]
  param(
    [Parameter(Mandatory = $true, HelpMessage = "Name of account being modified")]
    [string]$Name,

    [Parameter(Mandatory = $true, HelpMessage = "Object/property that is being modified")]
    [string]$Property,

    [Parameter(Mandatory = $true, HelpMessage = "Result of action being performed")]
    [string]$Result
  )

  begin {
    Show-FunctionStatus -Level Unmanaged
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.Mycommand)"

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.Mycommand)"


    $outputReturn = [PSCustomObject][ordered]@{
      User     = $Name
      Property = $Property
      Result   = $Result
    }

    return $outputReturn
  }

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.Mycommand)"
  } #end

} #GetActionOutputObject3
