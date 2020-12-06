[System.Collections.ArrayList]$products = @()
[System.Collections.ArrayList]$plans = @()

$planServicePlanNames = @{}

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
  $product | Add-Member -MemberType NoteProperty -Name ProductName -Value $srcProductName
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
