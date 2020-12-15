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
    Mandatory. String to search. Depending on Search method, provide Full Name (exact),
    Part of the Name (Search, default; All) or even the UserPrincipalName (MailNickName) to find the Group.
	.PARAMETER Exact
    Optional. Utilises SearchString for DisplayName and MailNickname
    Queries ObjectId and Mail in case no result has been found for the provided string.
    Returns only exact matches
	.PARAMETER Search
    Optional (default). Utilises SearchString for DisplayName and MailNickname
    Queries ObjectId and Mail in case no result has been found for the provided string.
    Returns all Objects that have the string in the Name.
	.PARAMETER All
    Optional. Loads all Groups on the tenant to find groups matching the provided string.
    Queries Displayname, Description, ObjectId and MailNickname
    This will take some time, depending on the size of the Tenant.
	.EXAMPLE
    Find-AzureAdGroup -Identity "My Group"
    Will return all Groups that have "My Group" in the DisplayName, ObjectId or MailNickName
	.EXAMPLE
		Find-AzureAdGroup -Identity "My Group" -Search
    Will return all Groups that have "My Group" in the DisplayName, ObjectId or MailNickName
	.EXAMPLE
		Find-AzureAdGroup -Identity "My Group" -Exact
    Will return ONE Group that has "My Group" set as the DisplayName
	.EXAMPLE
		Find-AzureAdGroup -Identity $UPN -All
    Parses the whole Tenant for Groups, which may take some time, but yield complete results.
    Will return all Groups that have "My Group" in the DisplayName, ObjectId or MailNickName
  .LINK
    Find-AzureAdGroup
    Find-AzureAdUser
    Test-AzureAdGroup
    Test-AzureAdUser
    Test-TeamsUser
	#>

  [CmdletBinding(DefaultParameterSetName = "Search")]
  [OutputType([System.Object])]
  param(
    [Parameter(Mandatory, Position = 0, ValueFromPipeline, HelpMessage = "This is the Name or UserPrincipalName of the Group")]
    [Alias('GroupName', 'Name')]
    [string]$Identity,

    [Parameter(ParameterSetName = "Exact", HelpMessage = 'Narrows the search for an exact match. Writes an Error if no unique result is found')]
    [switch]$Exact,

    [Parameter(ParameterSetName = "Search", HelpMessage = 'Looks up provided String against DisplayName and Mailnickname')]
    [switch]$Search,

    [Parameter(ParameterSetName = "All", HelpMessage = 'Looks up provided String against ALL Groups on the Tenant')]
    [switch]$All
  ) #param

  begin {
    Show-FunctionStatus -Level PreLive
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

    # Asserting AzureAD Connection
    if (-not (Assert-AzureADConnection)) { break }

    # Adding Types
    Add-Type -AssemblyName Microsoft.Open.AzureAD16.Graph.Client
    Add-Type -AssemblyName Microsoft.Open.Azure.AD.CommonLibrary


    $Groups = $null

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    switch ($PSCmdlet.ParameterSetName) {
      'Exact' {
        Write-Verbose -Message "Performing exact Search..."
        $Groups = Get-AzureADGroup -SearchString "$Identity" -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
        $Groups = $Groups | Where-Object Displayname -EQ "$Identity"
        if (-not $Groups ) {
          try {
            $Groups = Get-AzureADGroup -ObjectId "$Identity" -WarningAction SilentlyContinue -ErrorAction Stop
          }
          catch {
            try {
              $MailNickName = $Identity.Split('@')[0]
              $Groups = Get-AzureADGroup -SearchString "$MailNickName" -WarningAction SilentlyContinue -ErrorAction STOP
            }
            catch {
              $Groups = Get-AzureADGroup | Where-Object Mail -EQ "$Identity" -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
            }
          }
        }
      } #Exact

      'Search' {
        Write-Verbose -Message "Performing Search..."
        $Groups = Get-AzureADGroup -SearchString "$Identity" -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
        if (-not $Groups ) {
          try {
            $Groups = Get-AzureADGroup -ObjectId "$Identity" -WarningAction SilentlyContinue -ErrorAction Stop
          }
          catch {
            try {
              $MailNickName = $Identity.Split('@')[0]
              $Groups = Get-AzureADGroup -SearchString "$MailNickName" -WarningAction SilentlyContinue -ErrorAction STOP
            }
            catch {
              $Groups = Get-AzureADGroup | Where-Object Mail -EQ "$Identity" -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
            }
          }
        }
      } #Search

      'All' {
        # Query
        Write-Verbose -Message "Performing Search... finding ALL Groups - Depending on the size of the Tenant, this will run for a while!" -Verbose
        $AllGroups = Get-AzureADGroup -All $true -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
        [System.Collections.ArrayList]$Groups = @()
        $Groups += $AllGroups | Where-Object DisplayName -Like "*$Identity*"
        $Groups += $AllGroups | Where-Object Description -Like "*$Identity*"
        $Groups += $AllGroups | Where-Object ObjectId -Like "*$Identity*"
        $Groups += $AllGroups | Where-Object Mail -Like "*$Identity*"

        $MailNickName = $Identity.Split('@')[0]
        $Groups += $AllGroups | Where-Object Mailnickname -Like "*$MailNickName*"

      } #All
    }

    # Output - Filtering objects
    if ( $Groups ) {
      $Groups | Get-Unique
    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Find-AzureAdGroup
