# Module:   TeamsFunctions
# Function: Support
# Author:  David Eberhardt
# Updated:  01-JUL-2020
# Status:   Live




function Test-TeamsResourceAccount {
  <#
  .SYNOPSIS
    Tests whether an Application Instance exists in Azure AD (record found)
  .DESCRIPTION
    Simple lookup - does the User Object exist - to avoid TRY/CATCH statements for processing
  .PARAMETER UserPrincipalName
    Mandatory. The sign-in address or User Principal Name of the user account to test.
  .PARAMETER Quick
    Optional. By default, this command queries the CsOnlineApplicationInstance which takes a while.
    A cursory check can be performed against the AzureAdUser (Department "Microsoft Communication Application Instance" indicates ResourceAccounts)
  .EXAMPLE
    Test-TeamsResourceAccount -UserPrincipalName "$UPN"
    Will Return $TRUE only if an CsOnlineApplicationInstance Object with the $UPN is found.
    Will Return $FALSE in any other case, including if there is no Connection to AzureAD!
  .EXAMPLE
    Test-TeamsResourceAccount -UserPrincipalName "$UPN" -Quick
    Will Return $TRUE only if an AzureAdObject with the $UPN is found with the Department "Microsoft Communication Application Instance" set)
    Will Return $FALSE in any other case, including if there is no Connection to AzureAD!
  .INPUTS
    System.String
  .OUTPUTS
    Boolean
  .NOTES
    None
  .COMPONENT
    SupportingFunction
    TeamsResourceAccount
  .FUNCTIONALITY
    Tests whether a Resource Account exists in AzureAd
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Test-TeamsResourceAccount.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsResourceAccount.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  #>

  [CmdletBinding()]
  [OutputType([Boolean])]
  param(
    [Parameter(Mandatory, Position = 0, ValueFromPipeline, HelpMessage = 'This is the UserID (UPN)')]
    [Alias('ObjectId', 'Identity')]
    [string]$UserPrincipalName,

    [Parameter(HelpMessage = 'Quick test against AzureAdUser Department')]
    [switch]$Quick

  ) #param

  begin {
    Show-FunctionStatus -Level Live
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

    # Asserting MicrosoftTeams Connection
    if (-not (Assert-MicrosoftTeamsConnection)) { break }

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    foreach ($User in $UserPrincipalName) {
      if ( $Quick ) {
        Write-Verbose -Message 'Querying AzureAdUser (Quick search and fast, but may not be 100% accurate!)'
        try {
          $User = Get-AzureADUser -ObjectId "$User" -WarningAction SilentlyContinue -ErrorAction Stop
        }
        catch {
          $Message = $_ | Get-ErrorMessageFromErrorString
          Write-Warning -Message "User '$User': GetUser$($Message.Split(':')[1])"
        }

        if ( $User.Department -eq 'Microsoft Communication Application Instance') {
          return $true
        }
        else {
          return $false
        }
      }
      else {
        Write-Verbose -Message 'Querying CsOnlineApplicationInstance (Thorough search, but slower)'
        $RA = Find-CsOnlineApplicationInstance -SearchQuery "$User" -WarningAction SilentlyContinue
        if ( $RA ) {
          return $true
        }
        else {
          return $false
        }
      }
    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Test-TeamsResourceAccount
