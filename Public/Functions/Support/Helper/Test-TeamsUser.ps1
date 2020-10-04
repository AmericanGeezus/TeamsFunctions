# Module:   TeamsFunctions
# Function: Support
# Author:		David Eberhardt
# Updated:  01-JUL-2020
# Status:   PreLive

function Test-TeamsUser {
  <#
	.SYNOPSIS
		Tests whether an Object exists in Teams (record found)
	.DESCRIPTION
		Simple lookup - does the Object exist - to avoid TRY/CATCH statements for processing
	.PARAMETER Identity
		Mandatory. The sign-in address or User Principal Name of the user account to modify.
	.EXAMPLE
		Test-TeamsUser -Identity $UPN
		Will Return $TRUE only if the object $UPN is found.
		Will Return $FALSE in any other case, including if there is no Connection to SkypeOnline!
  #>

  [CmdletBinding()]
  [OutputType([Boolean])]
  param(
    [Parameter(Mandatory = $true, ValueFromPipeline, HelpMessage = "This is the UserID (UPN)")]
    [string]$Identity
  ) #param

  begin {
    Show-FunctionStatus -Level PreLive
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.Mycommand)"

    # Asserting SkypeOnline Connection
    if (-not (Assert-SkypeOnlineConnection)) { break }

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.Mycommand)"
    try {
      $null = Get-CsOnlineUser -Identity $Identity -WarningAction SilentlyContinue -ErrorAction STOP
      return $true
    }
    catch [System.Exception] {
      return $False
    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.Mycommand)"
  } #end
} #Test-TeamsUser
