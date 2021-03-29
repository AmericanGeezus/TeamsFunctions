# Module:     TeamsFunctions
# Function:   Lookup
# Author:     David Eberhardt
# Updated:    24-JAN-2021
# Status:     Live




function Find-AzureAdUser {
  <#
	.SYNOPSIS
		Returns User Objects from Azure AD based on a search string or UserPrincipalName
	.DESCRIPTION
    Simplifies lookups with Get-AzureAdUser by using and combining -SearchString and -ObjectId Parameters.
    CmdLet can find uses by either query, if nothing is found with the Searchstring, another search is done via the ObjectId
    This simplifies the query without having to rely multiple queries with Get-AzureAdUser
	.PARAMETER SearchString
    Required. A 3-255 digit string to be found on any Object.
    Performs multiple searches against the Searches against this sting and parts thereof.
    Uses Get-AzureAd-User -SearchString and Get-AzureAdUser -Filter and subsequently Get-AzureAdUser -ObjectType
	.EXAMPLE
		Find-AzureAdUser [-Search] "John"
    Will search for the string "John" and return all Azure AD Objects found
    If nothing has been found, will try to search for by identity
	.EXAMPLE
		Find-AzureAdUser [-Search] "John@domain.com"
		Will search for the string "John@domain.com" and return all Azure AD Objects found
    If nothing has been found, will try to search for by identity
	.EXAMPLE
		Find-AzureAdUser -Identity John@domain.com,Mary@domain.com
		Will search for the string "John@domain.com" and return all Azure AD Objects found
  .INPUTS
    System.String
  .OUTPUTS
    Microsoft.Open.AzureAD.Model.User
  .NOTES
    None
  .COMPONENT
    UserManagement
	.FUNCTIONALITY
    Queries User Objects in Azure Ad with different mechanics
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  .LINK
    about_UserManagement
  .LINK
    Find-AzureAdGroup
  .LINK
    Get-AzureAdUser
  #>

  [CmdletBinding()]
  [OutputType([Microsoft.Open.AzureAD.Model.User])]
  param(
    [Parameter(Mandatory, Position = 0, ParameterSetName = 'SearchString', ValueFromPipeline, HelpMessage = 'Search string')]
    [ValidateLength(3, 255)]
    [string[]]$SearchString
  ) #param

  begin {
    Show-FunctionStatus -Level Live
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"
    Write-Verbose -Message "Need help? Online:  $global:TeamsFunctionsHelpURLBase$($MyInvocation.MyCommand)`.md"

    # Asserting AzureAD Connection
    if (-not (Assert-AzureADConnection)) { break }

    # Setting Preference Variables according to Upstream settings
    if (-not $PSBoundParameters.ContainsKey('Verbose')) { $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference') }
    if (-not $PSBoundParameters.ContainsKey('Debug')) { $DebugPreference = $PSCmdlet.SessionState.PSVariable.GetValue('DebugPreference') } else { $DebugPreference = 'Continue' }
    if ( $PSBoundParameters.ContainsKey('InformationAction')) { $InformationPreference = $PSCmdlet.SessionState.PSVariable.GetValue('InformationAction') } else { $InformationPreference = 'Continue' }

    # Adding Types
    Add-Type -AssemblyName Microsoft.Open.AzureAD16.Graph.Client
    Add-Type -AssemblyName Microsoft.Open.Azure.AD.CommonLibrary

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    [System.Collections.ArrayList]$Users = @()
    foreach ($String in $SearchString) {

      try {
        # ObjectId
        Write-Verbose -Message "Searching for Objects with String '$String' in ObjectId"
        $Result = Get-AzureADUser -All:$true -ObjectId "$String" -WarningAction SilentlyContinue -ErrorAction STOP
        if ( $Result ) {
          $Users += $Result
        }
        else {
          throw
        }
      }
      catch {
        # SearchString as-is
        $Result = $null
        Write-Verbose -Message "Searching for Objects with String '$String' in SearchString"
        $Result = Get-AzureADUser -All:$true -SearchString "$String" -WarningAction SilentlyContinue -ErrorAction STOP
        if ( $Result ) {
          Write-Verbose -Message "Found $($Result.Count) Objects with String '$String' in SearchString"
          $Users += $Result
        }

        # Filter Surname as-is
        $Result = $null
        Write-Verbose -Message "Searching for Objects with String '$String' in Filter (Surname)"
        $Result = Get-AzureADUser -All:$true -Filter "Surname eq '$String'" -WarningAction SilentlyContinue -ErrorAction STOP
        if ( $Result ) {
          Write-Verbose -Message "Found $($Result.Count) Objects with String '$String' in Filter (Surname)"
          $Users += $Result
        }

        if ($String.Contains('@')) {
          # SearchString SubString split after @
          $Result = $null
          $SubString = $String.split('@') | Select-Object -First 1
          Write-Verbose -Message "Searching for Objects with SubString '$SubString' in Filter (MailNickName)"
          $Result = Get-AzureADUser -All:$true -Filter "MailNickName eq '$SubString'" -WarningAction SilentlyContinue -ErrorAction STOP
          if ( $Result ) {
            Write-Verbose -Message "Found $($Result.Count) Objects with SubString '$SubString' in Filter (MailNickName)"
            $Users += $Result
          }
        }

        if ($String.Contains(' ')) {
          # SearchString SubString split after space
          $Result = $null
          $SubString = $String.split(' ') | Select-Object -Last 1
          Write-Verbose -Message "Searching for Objects with SubString '$SubString' in SearchString"
          $Result = Get-AzureADUser -All:$true -SearchString "$SubString" -WarningAction SilentlyContinue -ErrorAction STOP
          if ( $Result ) {
            Write-Verbose -Message "Found $($Result.Count) Objects with SubString '$SubString' in SearchString"
            $Users += $Result
          }

          # Filter Surname SubString split after space
          $Result = $null
          $SubString = $String.split(' ') | Select-Object -Last 1
          Write-Verbose -Message "Searching for Objects with SubString '$SubString' in Filter (Surname)"
          $Result = Get-AzureADUser -All:$true -Filter "Surname eq '$SubString'" -WarningAction SilentlyContinue -ErrorAction STOP
          if ( $Result ) {
            Write-Verbose -Message "Found $($Result.Count) Objects with SubString '$SubString' in Filter (Surname)"
            $Users += $Result
          }
        }

        if ($String.Contains('.')) {
          # SearchString SubString split after dot
          $Result = $null
          $SubString = $($String.split('@') | Select-Object -First 1).split('.') | Select-Object -Last 1
          Write-Verbose -Message "Searching for Objects with SubString '$SubString' in SearchString"
          $Result = Get-AzureADUser -All:$true -SearchString "$SubString" -WarningAction SilentlyContinue -ErrorAction STOP
          if ( $Result ) {
            Write-Verbose -Message "Found $($Result.Count) Objects with SubString '$SubString' in SearchString"
            $Users += $Result
          }

          # Filter Surname SubString split after dot
          $Result = $null
          $SubString = $($String.split('@') | Select-Object -First 1).split('.') | Select-Object -Last 1
          Write-Verbose -Message "Searching for Objects with SubString '$SubString' in Filter (Surname)"
          $Result = Get-AzureADUser -All:$true -Filter "Surname eq '$SubString'" -WarningAction SilentlyContinue -ErrorAction STOP
          if ( $Result ) {
            Write-Verbose -Message "Found $($Result.Count) Objects with SubString '$SubString' in Filter (Surname)"
            $Users += $Result
          }
        }
      }
    }

    # Output - Filtering objects
    if ( $Users ) {
      $Users | Sort-Object -Unique -Property ObjectId | Get-Unique | Sort-Object DisplayName
    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} # Find-AzureAdUser
