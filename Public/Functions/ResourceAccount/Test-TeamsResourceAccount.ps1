# Module:   TeamsFunctions
# Function: Support
# Author:	David Eberhardt
# Updated:  01-JUL-2020
# Status:   PreLive




function Test-TeamsResourceAccount {
    <#
	.SYNOPSIS
		Tests whether an Application Instance exists in Azure AD (record found)
	.DESCRIPTION
		Simple lookup - does the User Object exist - to avoid TRY/CATCH statements for processing
	.PARAMETER Identity
		Mandatory. The sign-in address or User Principal Name of the user account to test.
	.EXAMPLE
		Test-TeamsResourceAccount -Identity $UPN
		Will Return $TRUE only if the object $UPN is found.
		Will Return $FALSE in any other case, including if there is no Connection to AzureAD!
  #>

    [CmdletBinding()]
    [OutputType([Boolean])]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, HelpMessage = "This is the UserID (UPN)")]
        [string]$Identity
    ) #param

    begin {
        Show-FunctionStatus -Level PreLive
        Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

        # Asserting SkypeOnline Connection
        if (-not (Assert-SkypeOnlineConnection)) { break }

    } #begin

    process {
        Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
        try {
            $null = Get-CsOnlineApplicationInstance -Identity "$Identity" -WarningAction SilentlyContinue -ErrorAction STOP
            return $true
        }
        catch {
            return $False
        }
    } #process

    end {
        Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
    } #end
} #Test-TeamsResourceAccount
