Connect-AzureAD
 
$users = Get-AzureADUser -All:$true | ? {$_.AssignedLicenses}
$SKUs = Get-AzureADSubscribedSku

# Disable individual plans
$plansToDisable = @("57ff2da0-773e-42df-b2af-ffb7a2317929","EXCHANGE_S_ENTERPRISE")
 
foreach ($user in $users) {
    $userLicenses = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
    foreach ($license in $user.AssignedLicenses) {
        $SKU =  $SKUs | ? {$_.SkuId -eq $license.SkuId}
        foreach ($planToDisable in $plansToDisable) {
            if ($planToDisable -notmatch "^[{(]?[0-9A-F]{8}[-]?([0-9A-F]{4}[-]?){3}[0-9A-F]{12}[)}]?$") { $planToDisable = ($SKU.ServicePlans | ? {$_.ServicePlanName -eq "$planToDisable"}).ServicePlanId }
            if ($planToDisable -in $SKU.ServicePlans.ServicePlanId) {
                $license.DisabledPlans = ($license.DisabledPlans + $planToDisable | sort -Unique)
                Write-Host "Removed plan $planToDisable from license $($license.SkuId)"
            }
        }
        $userLicenses.AddLicenses += $license
    }
    Set-AzureADUserLicense -ObjectId $user.ObjectId -AssignedLicenses $userLicenses
}


#Enable individual Plans
$plansToEnable = @("MICROSOFTBOOKINGS","b737dad2-2f6c-4c65-90e3-ca563267e8b9")
 
foreach ($user in $users) {
    $userLicenses = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
    foreach ($license in $user.AssignedLicenses) {
        $SKU =  $SKUs | ? {$_.SkuId -eq $license.SkuId}
        foreach ($planToEnable in $plansToEnable) {
            if ($planToEnable -notmatch "^[{(]?[0-9A-F]{8}[-]?([0-9A-F]{4}[-]?){3}[0-9A-F]{12}[)}]?$") { $planToEnable = ($SKU.ServicePlans | ? {$_.ServicePlanName -eq "$planToEnable"}).ServicePlanId }
            if (($planToEnable -in $SKU.ServicePlans.ServicePlanId) -and ($planToEnable -in $license.DisabledPlans)) {
                $license.DisabledPlans = ($license.DisabledPlans | ? {$_ -ne $planToEnable}| sort -Unique)
                Write-Host "Added plan $planToEnable from license $($license.SkuId)"
            }
        }
        $userLicenses.AddLicenses += $license
    }
    Set-AzureADUserLicense -ObjectId $user.ObjectId -AssignedLicenses $userLicenses
}

# Apply to Set-TeamsUserLicense with -DisablePlan and -EnablePlan?
#Create separate function:
Enable-AzureAdUserLicenseServicePlan
Disable-AzureAdUserLicenseServicePlan