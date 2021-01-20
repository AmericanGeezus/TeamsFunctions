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
	.PARAMETER Quick
		Optional. By default, this command queries the CsOnlineApplicationInstance which takes a while.
		A cursory check can be performed against the AzureAdUser (Department "Microsoft Communication Application Instance" indicates ResourceAccounts)
	.EXAMPLE
		Test-TeamsResourceAccount -Identity $UPN
		Will Return $TRUE only if an CsOnlineApplicationInstance Object with the $UPN is found.
		Will Return $FALSE in any other case, including if there is no Connection to AzureAD!
	.EXAMPLE
		Test-TeamsResourceAccount -Identity $UPN -Quick
		Will Return $TRUE only if an AzureAdObject with the $UPN is found with the Department "Microsoft Communication Application Instance" set)
		Will Return $FALSE in any other case, including if there is no Connection to AzureAD!
  .COMPONENT
    TeamsAutoAttendant
    TeamsCallQueue
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
	.LINK
		Get-TeamsResourceAccount
	.LINK
		Find-TeamsResourceAccount
	.LINK
		Find-AzureAdUser
	.LINK
		Test-AzureAdUser
	#>

	[CmdletBinding()]
	[OutputType([Boolean])]
	param(
		[Parameter(Mandatory, Position = 0, ValueFromPipeline, HelpMessage = 'This is the UserID (UPN)')]
		[string]$Identity,

		[Parameter(HelpMessage = 'Quick test against AzureAdUser Department')]
		[switch]$Quick

	) #param

	begin {
		Show-FunctionStatus -Level PreLive
		Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

		# Asserting SkypeOnline Connection
		if (-not (Assert-SkypeOnlineConnection)) { break }

	} #begin

	process {
		Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
		if ( $Quick ) {
			Write-Verbose -Message 'Querying AzureAdUser (Quick search and fast, but may not be 100% accurate!)'
			$User = Find-AzureAdUser $Identity
			if ( $User.Department -eq 'Microsoft Communication Application Instance') {
				return $true
			}
			else {
				return $false
			}
		}
		else {
			Write-Verbose -Message 'Querying CsOnlineApplicationInstance (Thorough search, but slower)'
			$RA = Find-CsOnlineApplicationInstance -SearchQuery "$Identity" -WarningAction SilentlyContinue
			if ( $RA ) {
				return $true
			}
			else {
				return $false
			}
		}

	} #process

	end {
		Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
	} #end
} #Test-TeamsResourceAccount
