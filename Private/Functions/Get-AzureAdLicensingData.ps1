﻿# Module:   TeamsFunctions
# Function: Licensing
# Author:		Philipp, Scripting.up-in-the.cloud
# Updated:  01-DEC-2020
# Status:   PreLive




function Get-AzureAdLicensingData {
  <#
	.SYNOPSIS
    License information for AzureAD Service Plans related to Teams
  .DESCRIPTION
    Returns an Object containing all Teams related License Service Plans
  .EXAMPLE
    Get-TeamsLicense
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
  .LINK
    Get-TeamsLicense
    Get-TeamsLicenseServicePlan
    Get-TeamsTenantLicense
    Get-TeamsUserLicense
    Set-TeamsUserLicense
    Test-TeamsUserLicense
    Add-TeamsUserLicense (deprecated)
  #>

  [CmdletBinding()]
  [OutputType([Object[]])]
  param(
  ) #param

  begin {
    Show-FunctionStatus -Level PreLive
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

    [System.Collections.ArrayList]$products = @()
    [System.Collections.ArrayList]$plans = @()

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

      $srcProductName = $cells[0]
      $srcStringId = $cells[1]
      $srcGUID = $cells[2]
      $srcServicePlan = $cells[3]
      $srcServicePlanName = $cells[4]

      #build an object for the product
      $product = New-Object -TypeName PsObject
      $product | Add-Member -MemberType NoteProperty -Name Name -Value $srcProductName
      $product | Add-Member -MemberType NoteProperty -Name SkuPartNumber -Value $srcStringId
      $product | Add-Member -MemberType NoteProperty -Name SkuId -Value $srcGUID
      $product | Add-Member -MemberType NoteProperty -Name ServicePlans -Value @()

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

          #build an object for the service plan
          $plan = New-Object -TypeName PsObject
          $plan | Add-Member -MemberType NoteProperty -Name ProductName -Value $planProductName
          $plan | Add-Member -MemberType NoteProperty -Name ServicePlanName -Value $planServicePlanNames[$planServicePlanId]
          $plan | Add-Member -MemberType NoteProperty -Name ServicePlanId -Value $planServicePlanId

          if ($plans.ServicePlanId -notcontains $planServicePlanId) {
            $plans += $plan
          }

          $product.ServicePlans += $plan
        }
      }

      $products += $product
    }

    return $Products

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"

  } #end
} #Get-AzureAdLicensingData
