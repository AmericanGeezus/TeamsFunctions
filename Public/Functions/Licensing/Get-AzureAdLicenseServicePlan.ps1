# Module:   TeamsFunctions
# Function: Licensing
# Author:		Philipp, Scripting.up-in-the.cloud
# Updated:  01-DEC-2020
# Status:   PreLive




function Get-AzureAdLicenseServicePlan {
  <#
  .SYNOPSIS
    License information for AzureAD Service Plans related to Teams
  .DESCRIPTION
    Returns an Object containing all Teams related License Service Plans
  .PARAMETER FilterRelevantForTeams
    Optional. By default, shows all 365 License Service Plans
    Using this switch, shows only Service Plans relevant for Teams
  .EXAMPLE
    Get-AzureAdLicenseServicePlan
    Returns 39 Azure AD Licenses that relate to Teams for use in other commands
  .NOTES
    Source
    https://scripting.up-in-the.cloud/licensing/o365-license-names-its-a-mess.html
    With very special thanks to Philip
    Reads
    https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/licensing-service-plan-reference
  .COMPONENT
    Teams Migration and Enablement. License Assignment
  .ROLE
    Licensing
  .FUNCTIONALITY
    Returns a list of License Service Plans
  .EXTERNALHELP
    https://raw.githubusercontent.com/DEberhardt/TeamsFunctions/master/docs/TeamsFunctions-help.xml
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  .LINK
    Get-TeamsTenantLicense
  .LINK
    Get-TeamsUserLicense
  .LINK
    Set-TeamsUserLicense
  .LINK
    Test-TeamsUserLicense
  .LINK
    Get-AzureAdLicense
  .LINK
    Get-AzureAdLicenseServicePlan
  #>

  [CmdletBinding()]
  [OutputType([Object[]])]
  param(
    [Parameter()]
    [switch]$FilterRelevantForTeams
  ) #param

  begin {
    Show-FunctionStatus -Level PreLive
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

    [System.Collections.ArrayList]$Plans = @()
    [System.Collections.ArrayList]$PlansNotAdded = @()

    $planServicePlanNames = @{}

  } #begin

  process {
    #read the content of the Microsoft web page and extract the first table
    $url = "https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/licensing-service-plan-reference"
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $content = (Invoke-WebRequest $url -UseBasicParsing).Content
    $content = $content.SubString($content.IndexOf("<tbody>"))
    $content = $content.Substring(0, $content.IndexOf("</tbody>"))

    #eliminate line feeds so that we can use regular expression to get the table rows...
    $content = $content -replace "`r?`n", ''
    $rows = (Select-String -InputObject $content -Pattern "<tr>(.*?)</tr>" -AllMatches).Matches | ForEach-Object {
      $_.Groups[1].Value
    }

    #on each table row, get the column cell content
    #   1st cell contains the product display name
    #   2nd cell contains the Sku ID (called 'string ID' here)
    #   3rd cell contains the included service plans (with string IDs)
    #   3rd cell contains the included service plans (with display names)
    $rows | ForEach-Object {
      $cells = (Select-String -InputObject $_ -Pattern "<td>(.*?)</td>" -AllMatches).Matches | ForEach-Object {
        $_.Groups[1].Value
      }

      $srcServicePlan = $cells[3]
      $srcServicePlanName = $cells[4]

      if (($srcServicePlan.Trim() -ne '') -and ($srcServicePlanName.Trim() -ne '')) {

        #store the service plan string IDs for later match
        $srcServicePlan -split "<br.?>" | ForEach-Object {
          $planServicePlanName = ($_.SubString(0, $_.LastIndexOf("("))).Trim()
          $planServicePlanId = $_.SubString($_.LastIndexOf("(") + 1)
          if ($planServicePlanId.Contains(")")) {
            $planServicePlanId = $planServicePlanId.SubString(0, $planServicePlanId.IndexOf(")"))
          }

          if (-not $planServicePlanNames.ContainsKey($planServicePlanId)) {
            $planServicePlanNames.Add($planServicePlanId, $planServicePlanName)
          }
        }

        #get te included service plans
        $srcServicePlanName -split "<br.?>" | ForEach-Object {
          $planProductName = ($_.SubString(0, $_.LastIndexOf("("))).Trim()
          $planServicePlanId = $_.SubString($_.LastIndexOF("(") + 1)
          if ($planServicePlanId.Contains(")")) {
            $planServicePlanId = $planServicePlanId.SubString(0, $planServicePlanId.IndexOf(")"))
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
          $TextInfo = (Get-Culture).TextInfo
          $planProductName = $TextInfo.ToTitleCase($planProductName.ToLower())
          $planProductName = Format-StringRemoveSpecialCharacter -String $planProductName -SpecialCharacterToKeep "()+ -"

          # Building Object
          if ($Plans.ServicePlanId -notcontains $planServicePlanId) {
            try {
              [void]$Plans.Add([TFTeamsServicePlan]::new($planProductName, "$($planServicePlanNames[$planServicePlanId])", "$planServicePlanId", $Relevant))
            }
            catch {
              Write-Verbose "[TFTeamsServicePlan] Couldn't add entry for $planProductName"
              if ( $planProductName -ne "Powerapps For Office 365 K1") {
                $PlansNotAdded += $planProductName
              }

            }
          }
        }
      }
    }

    # Manually Adding to List of $Plans
    [void]$Plans.Add([TFTeamsServicePlan]::new("Communications Credits", "MCOPSTNC", "505e180f-f7e0-4b65-91d4-00d670bbd18c", $true))
    [void]$Plans.Add([TFTeamsServicePlan]::new("Phone System - Virtual User", "MCOEV_VIRTUALUSER", "f47330e9-c134-43b3-9993-e7f004506889", $true))

    # Output
    if ( $PlansNotAdded.Count -gt 0 ) {
      Write-Warning -Message "The following Products could not be added: $PlansNotAdded"
    }

    $PlansSorted = $Plans | Sort-Object ProductName
    if ($FilterRelevantForTeams) {
      $PlansSorted = $PlansSorted | Where-Object RelevantForTeams -EQ $TRUE
    }

    return $PlansSorted
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"

  } #end
} #Get-AzureAdLicenseServicePlan