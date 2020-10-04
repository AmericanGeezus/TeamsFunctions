# Module:     TeamsFunctions
# Function:   AzureAd Licensing
# Created by: Jeff Brown
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
  param(
    [Parameter(Mandatory = $true, HelpMessage = "Name of account being modified")]
    [string]$Name,

    [Parameter(Mandatory = $true, HelpMessage = "Object/property that is being modified")]
    [string]$Property,

    [Parameter(Mandatory = $true, HelpMessage = "Result of action being performed")]
    [string]$Result
  )

  $outputReturn = [PSCustomObject][ordered]@{
    User     = $Name
    Property = $Property
    Result   = $Result
  }

  return $outputReturn
} #GetActionOutputObject3
