﻿# Module:   TeamsFunctions
# Function: Licensing
# Author:   Philipp, Scripting.up-in-the.cloud
# Updated:  01-DEC-2020
# Status:   Live




function Get-AzureAdLicenseServicePlan {
  <#
  .SYNOPSIS
    License information for AzureAD Service Plans related to Teams
  .DESCRIPTION
    Returns an Object containing all Teams related License Service Plans
  .PARAMETER SearchString
    Optional. Filters output for String found in Parameters ProductName or ServicePlanName
  .PARAMETER FilterRelevantForTeams
    Optional. By default, shows all 365 License Service Plans
    Using this switch, shows only Service Plans relevant for Teams
  .EXAMPLE
    Get-AzureAdLicenseServicePlan
    Returns Azure AD Licenses that relate to Teams for use in other commands
  .NOTES
    Source
    https://scripting.up-in-the.cloud/licensing/o365-license-names-its-a-mess.html
    With very special thanks to Philip
    Reads
    https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/licensing-service-plan-reference
  .INPUTS
    System.String
  .OUTPUTS
    System.Object
  .COMPONENT
    Licensing
  .FUNCTIONALITY
    Returns a list of published License Service Plans
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-AzureAdLicenseServicePlan.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_Licensing.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_UserManagement.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  #>

  [CmdletBinding()]
  [OutputType([Object[]])]
  param(
    [Parameter()]
    [String]$SearchString,

    [Parameter()]
    [switch]$FilterRelevantForTeams
  ) #param

  begin {
    Show-FunctionStatus -Level Live
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

    # Setting Preference Variables according to Upstream settings
    if (-not $PSBoundParameters.ContainsKey('Verbose')) { $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference') }
    if (-not $PSBoundParameters.ContainsKey('Debug')) { $DebugPreference = $PSCmdlet.SessionState.PSVariable.GetValue('DebugPreference') } else { $DebugPreference = 'Continue' }
    if ( $PSBoundParameters.ContainsKey('InformationAction')) { $InformationPreference = $PSCmdlet.SessionState.PSVariable.GetValue('InformationAction') } else { $InformationPreference = 'Continue' }

    [System.Collections.ArrayList]$Plans = @()
    [System.Collections.ArrayList]$PlansNotAdded = @()

    $planServicePlanNames = @{}

  } #begin

  process {
    #read the content of the Microsoft web page and extract the first table
    $url = 'https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/licensing-service-plan-reference'
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $content = (Invoke-WebRequest $url -UseBasicParsing).Content
    $content = $content.SubString($content.IndexOf('<tbody>'))
    $content = $content.Substring(0, $content.IndexOf('</tbody>'))

    #eliminate line feeds so that we can use regular expression to get the table rows...
    $content = $content -replace "`r?`n", ''
    $rows = (Select-String -InputObject $content -Pattern '<tr>(.*?)</tr>' -AllMatches).Matches | ForEach-Object {
      $_.Groups[1].Value
    }

    #on each table row, get the column cell content
    #   1st cell contains the product display name
    #   2nd cell contains the Sku ID (called 'string ID' here)
    #   3rd cell contains the included service plans (with string IDs)
    #   3rd cell contains the included service plans (with display names)
    $rows | ForEach-Object {
      $cells = (Select-String -InputObject $_ -Pattern '<td>(.*?)</td>' -AllMatches).Matches | ForEach-Object {
        $_.Groups[1].Value
      }

      $srcServicePlan = $cells[3]
      $srcServicePlanName = $cells[4]

      if (($srcServicePlan.Trim() -ne '') -and ($srcServicePlanName.Trim() -ne '')) {

        #store the service plan string IDs for later match
        if ($PSBoundParameters.ContainsKey('Debug')) {
          "  Function: $($MyInvocation.MyCommand.Name) - This ServicePlan: $srcServicePlan" | Write-Debug
        }
        $srcServicePlan -split '<br.?>' | ForEach-Object {
          if ($PSBoundParameters.ContainsKey('Debug')) {
            "  Function: $($MyInvocation.MyCommand.Name) - Splitting at '<br/>': $_" | Write-Debug
          }
          try {
            if ($_ -eq '') {
              Write-Verbose -Message "Entry '$srcServicePlan' has a trailing '<br/>', omitting entry"
            }
            else {
              $planServicePlanName = ($_.SubString(0, $_.LastIndexOf('('))).Trim()
              $planServicePlanId = $_.SubString($_.LastIndexOf('(') + 1)
              if ($planServicePlanId.Contains(')')) {
                $planServicePlanId = $planServicePlanId.SubString(0, $planServicePlanId.IndexOf(')'))
              }
            }
          }
          catch {
            Write-Warning -Message "Cannot read Entry '$srcServicePlan' (Service Plan) - malformed string. Reading this requires open and close parenthesis around ServicePlanId - please open issue against Documentation: https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/licensing-service-plan-reference"
          }

          if (-not $planServicePlanNames.ContainsKey($planServicePlanId)) {
            $planServicePlanNames.Add($planServicePlanId, $planServicePlanName)
          }
        }

        #get te included service plans
        $srcServicePlanName -split '<br.?>' | ForEach-Object {
          try {
            if ($_ -eq '') {
              Write-Verbose -Message "Entry '$srcServicePlanName' has a trailing '<br/>', omitting entry"
            }
            else {
              $planProductName = ($_.SubString(0, $_.LastIndexOf('('))).Trim()
              $planServicePlanId = $_.SubString($_.LastIndexOF('(') + 1)
              if ($planServicePlanId.Contains(')')) {
                $planServicePlanId = $planServicePlanId.SubString(0, $planServicePlanId.IndexOf(')'))
              }
            }
          }
          catch {
            Write-Warning -Message "Cannot read Entry '$srcServicePlanName' (Service Plan Name) - malformed string. Reading this requires open and close parenthesis around ServicePlanId - please open issue against Documentation: https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/licensing-service-plan-reference"
          }

          # Add RelevantForTeams
          if ( $planServicePlanNames[$planServicePlanId] ) {
            if ( $planServicePlanNames[$planServicePlanId].Contains('TEAMS') -or $planServicePlanNames[$planServicePlanId].Contains('MCO') ) {
              $Relevant = $true
            }
            else {
              $Relevant = $false
            }
          }
          else {
            $Relevant = $false
          }

          # reworking ProductName into TitleCase
          $VerbosePreference = 'SilentlyContinue'
          $TextInfo = (Get-Culture).TextInfo
          $planProductName = $TextInfo.ToTitleCase($planProductName.ToLower())
          $planProductName = Format-StringRemoveSpecialCharacter -String "$planProductName" -SpecialCharacterToKeep '()+ -'

          # Building Object
          if ($Plans.ServicePlanId -notcontains $planServicePlanId) {
            try {
              [void]$Plans.Add([TFTeamsServicePlan]::new($planProductName, "$($planServicePlanNames[$planServicePlanId])", "$planServicePlanId", $Relevant))
            }
            catch {
              Write-Debug "[TFTeamsServicePlan] Couldn't add entry for '$planProductName'"
              if ( $planProductName -ne 'Powerapps For Office 365 K1') {
                $PlansNotAdded += $planProductName
              }
            }
          }
        }
      }
      #>
    }

    # Output
    if ( $PlansNotAdded.Count -gt 0 ) {
      Write-Warning -Message "The following Products could not be added: $PlansNotAdded"
    }

    $PlansSorted = $Plans | Sort-Object ProductName
    if ($FilterRelevantForTeams) {
      $PlansSorted = $PlansSorted | Where-Object RelevantForTeams -EQ $TRUE
    }

    if ( $PSBoundParameters.ContainsKey('SearchString') ) {
      $PlansSorted = $PlansSorted | Where-Object { $_.ProductName -like "*$SearchString*" -or $_.ServicePlanName -like "*$SearchString*" }
    }

    return $PlansSorted
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"

  } #end
} #Get-AzureAdLicenseServicePlan