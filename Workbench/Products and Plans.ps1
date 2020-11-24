$products = @()
$plans = @()
 
$planIDs = @{}
 
#read the content of the Microsoft web page and extract the first table
$url = "https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/licensing-service-plan-reference"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$content = (Invoke-WebRequest $url -UseBasicParsing).Content
$content = $content.SubString($content.IndexOf("<tbody>"))
$content = $content.Substring(0, $content.IndexOf("</tbody>"))
 
#eliminate line feeds so that we can use regular expression to get the table rows...
$content = $content -replace "`r?`n", ''
$rows = (Select-String -InputObject $content -Pattern "<tr>(.*?)</tr>" -AllMatches).Matches | % {
    $_.Groups[1].Value
}
 
#on each table row, get the column cell content
#   1st cell contains the product display name
#   2nd cell contains the Sku ID (called 'string ID' here)
#   3rd cell contains the included service plans (with string IDs)
#   3rd cell contains the included service plans (with display names)
$rows | % {
    $cells = (Select-String -InputObject $_ -Pattern "<td>(.*?)</td>" -AllMatches).Matches | % {
        $_.Groups[1].Value
    }
 
    $productName = $cells[0]
    $productStringID = $cells[1]
    $productGUID = $cells[2]
    $plansWithString = $cells[3]
    $plansWithName = $cells[4]
 
    #build an object for the product
    $product = New-Object -TypeName psobject
    $product | Add-Member -MemberType NoteProperty -Name Name -Value $productName
    $product | Add-Member -MemberType NoteProperty -Name SkuID -Value $productStringID
    $product | Add-Member -MemberType NoteProperty -Name GUID -Value $productGUID
    $product | Add-Member -MemberType NoteProperty -Name Plans -Value @()
 
    if (($plansWithString.Trim() -ne '') -and ($plansWithName.Trim() -ne '')) {
 
        #store the service plan string IDs for later match
            $plansWithString -split "<br.?>" | % {
            $planStringID =  ($_.SubString(0, $_.LastIndexOf("("))).Trim()
            $planGUID = $_.SubString($_.LastIndexOf("(") + 1)
            if ($planGUID.Contains(")")) {
                $planGUID = $planGUID.SubString(0, $planGUID.IndexOf(")"))
            }
 
            if (-not $planIDs.ContainsKey($planGUID)) {
                $planIDs.Add($planGUID, $planStringID)
            }
        }
 
        #get te included service plans
        $plansWithName -split "<br.?>" | % {
            $planName = ($_.SubString(0, $_.LastIndexOf("("))).Trim()
            $planGUID = $_.SubString($_.LastIndexOF("(") + 1)
            if ($planGUID.Contains(")")) {
                $planGUID = $planGUID.SubString(0, $planGUID.IndexOf(")"))
            }
 
            #build an object for the service plan
            $plan = New-Object -TypeName psobject
            $plan | Add-Member -MemberType NoteProperty -Name Name -Value $planName
            $plan | Add-Member -MemberType NoteProperty -Name StringID -Value $planIDs[$planGUID]
            $plan | Add-Member -MemberType NoteProperty -Name GUID -Value $planGUID
 
            if ($plans.GUID -notcontains $planGUID) {
                $plans += $plan
            }
 
            $product.Plans += $plan
        }
    }
 
    $products += $product
}
 
Write-Host "`nYou can use `$products and `$plans now...." -ForegroundColor Cyan