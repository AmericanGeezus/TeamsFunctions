# Module:     TeamsFunctions
# Function:   Support
# Author: David Eberhardtt
# Updated:    29-JUN-2020
# Status:     Live

function Write-ErrorRecord ($ErrorRecord) {
  <#
	.SYNOPSIS
		Returns the provided Error-Record as an Object
	.DESCRIPTION
		Helper Function for Troubleshooting
  .EXAMPLE
    Write-ErrorRecord $_
    In a catch block, the Function should be called like this to write the Error Record in this format.
  .NOTES
		get error record (this is $_ from the parent function)
		This function must be called with 'Write-ErrorRecord $_'
	#>

  [Management.Automation.ErrorRecord]$e = $ErrorRecord

  # retrieve Info about runtime error
  $info = $null
  $info = [PSCustomObject]@{
    Exception = $e.Exception.Message
    Reason    = $e.CategoryInfo.Reason
    Target    = $e.CategoryInfo.TargetName
    Script    = $e.InvocationInfo.ScriptName
    Line      = $e.InvocationInfo.ScriptLineNumber
    Column    = $e.InvocationInfo.OffsetInLine
  }
  $info
} #Write-ErrorRecord
