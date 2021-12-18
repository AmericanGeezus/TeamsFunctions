# Module:   TeamsFunctions
# Function: Testing
# Author:   David Eberhardt
# Updated:  01-OCT-2020
# Status:   Live




function Test-TeamsUserHasCallPlan {
  <#
  .SYNOPSIS
    Tests an AzureAD-Object for a CallingPlan License
  .DESCRIPTION
    Any assigned Calling Plan found on the User (with exception of the Communication Credits license, which is add-on)
    will let this function return $TRUE
  .PARAMETER Identity
    Mandatory. The sign-in address or User Principal Name of the user account to modify.
  .EXAMPLE
    Test-TeamsUserHasCallPlan -Identity User@domain.com -ServicePlan MCOEV
    Will Return $TRUE only if the ServicePlan is assigned and ProvisioningStatus is SUCCESS!
    This can be a part of a License.
  .EXAMPLE
    Test-TeamsUserHasCallPlan -Identity User@domain.com
    Will Return $TRUE only if one of the following license Packages are assigned:
    InternationalCallingPlan, DomesticCallingPlan, DomesticCallingPlan120, DomesticCallingPlan120b
  .INPUTS
    System.String
  .OUTPUTS
    Boolean
  .NOTES
    This Script is indiscriminate against the User Type, all AzureAD User Objects can be tested.
  .FUNCTIONALITY
    Returns a boolean value for when any of the Calling Plan licenses are found assigned to a specific user.
  .COMPONENT
    SupportingFunction
    Licensing
  .FUNCTIONALITY
    Tests whether the User has a Microsoft Calling Plan License
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Test-TeamsUserHasCallPlan.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_Supporting_Functions.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  #>

  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '', Justification = 'Required for performance. Removed with Disconnect-Me')]
  [CmdletBinding()]
  [OutputType([Boolean])]
  param(
    [Parameter(Mandatory, Position = 0, ValueFromPipeline, HelpMessage = 'This is the UserID (UPN)')]
    [Alias('ObjectId', 'Identity')]
    [string]$UserPrincipalName
  ) #param

  begin {
    Show-FunctionStatus -Level Live
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

    # Asserting AzureAD Connection
    if ( -not $script:TFPSSA) { $script:TFPSSA = Assert-AzureADConnection; if ( -not $script:TFPSSA ) { break } }

    # Loading License Array
    if (-not $global:TeamsFunctionsMSAzureAdLicenses) {
      $global:TeamsFunctionsMSAzureAdLicenses = Get-AzureAdLicense -WarningAction SilentlyContinue
    }

    $AllLicenses = $null
    $AllLicenses = $global:TeamsFunctionsMSAzureAdLicenses

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    foreach ($ID in $UserPrincipalName) {
      # Query User
      try {
        $UserObject = Get-AzureADUser -ObjectId "$ID" -WarningAction SilentlyContinue -ErrorAction Stop
        $UserLicenseObject = Get-AzureADUserLicenseDetail -ObjectId $($UserObject.ObjectId) -WarningAction SilentlyContinue
        $UserLicenseSKU = $UserLicenseObject.SkuPartNumber
        if ($PSBoundParameters.ContainsKey('Debug')) {
          "  Function: $($MyInvocation.MyCommand.Name) - UserLicenseSKU:", ($UserLicenseSKU | Format-Table -AutoSize | Out-String).Trim() | Write-Debug
        }
      }
      catch {
        [string]$Message = $_ | Get-ErrorMessageFromErrorString
        Write-Warning -Message "User '$ID': GetUser$($Message.Split(':')[1])"
      }

      $CallingPlanLicenses = $AllLicenses | Where-Object { $_.Serviceplans.ServicePlanName -match 'MCOPSTN' }
      if ($PSBoundParameters.ContainsKey('Debug')) {
        "  Function: $($MyInvocation.MyCommand.Name) - CallingPlanLicenses:", ($CallingPlanLicenses | Format-Table -AutoSize | Out-String).Trim() | Write-Debug
      }
      $HasCallingPlan = $userLicenseSku | Foreach-Object {
        Write-Verbose -Message "Testing '$_'"
        $_ -in $CallingPlanLicenses.Serviceplans.ServicePlanName
      }
      if ( $HasCallingPlan -contains $true ) {
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
} #Test-TeamsUserCallPlan
