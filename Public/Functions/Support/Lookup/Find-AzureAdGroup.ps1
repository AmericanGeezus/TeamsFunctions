# Module:   TeamsFunctions
# Function: Support
# Author:		David Eberhardt
# Updated:  14-NOV-2020
# Status:   PreLive




function Find-AzureAdGroup {
  <#
	.SYNOPSIS
		Returns an Object if an AzureAd Group has been found
	.DESCRIPTION
		Simple lookup - does the Group Object exist - to avoid TRY/CATCH statements for processing
	.PARAMETER Identity
		Mandatory. The Name or User Principal Name (MailNickName) of the Group to test.
	.EXAMPLE
		Test-AzureAdGroup -Identity $UPN
		Will Return $TRUE only if the object $UPN is found.
    Will Return $FALSE in any other case, including if there is no Connection to AzureAD!
  .LINK
    Find-AzureAdGroup
    Find-AzureAdUser
    Test-AzureAdGroup
    Test-AzureAdUser
    Test-TeamsUser
	#>

  [CmdletBinding()]
  [OutputType([System.Object])]
  param(
    [Parameter(Mandatory, Position = 0, ValueFromPipeline = $true, HelpMessage = "This is the Name or UserPrincipalName of the Group")]
    [Alias('GroupName', 'Name')]
    [string]$Identity
  ) #param

  begin {
    Show-FunctionStatus -Level PreLive
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

    # Asserting AzureAD Connection
    if (-not (Assert-AzureADConnection)) { break }

    # Adding Types
    Add-Type -AssemblyName Microsoft.Open.AzureAD16.Graph.Client
    Add-Type -AssemblyName Microsoft.Open.Azure.AD.CommonLibrary
  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    # Query
    Write-Verbose -Message "Querying Groups..."
    $AllGroups = Get-AzureADGroup -All $true -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
    [System.Collections.ArrayList]$Groups = @()
    $Groups += $AllGroups | Where-Object DisplayName -Like "*$Identity*"
    $Groups += $AllGroups | Where-Object Description -Like "*$Identity*"
    $Groups += $AllGroups | Where-Object ObjectId -Like "*$Identity*"
    $Groups += $AllGroups | Where-Object Mail -Like "*$Identity*"

    $MailNickName = $Identity.Split('@')[0]
    $Groups += $AllGroups | Where-Object Mailnickname -Like "*$MailNickName*"

    if ( $Groups ) {
      $Groups | Get-Unique
    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Find-AzureAdGroup
