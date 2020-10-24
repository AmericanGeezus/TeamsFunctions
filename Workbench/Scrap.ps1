

[System.Collections.ArrayList]$AddSkuIds = @()
[System.Collections.ArrayList]$RemoveSkuIds = @()
$AddSkuIds.Add("6fd2c87f-b296-42f0-b197-1e91e994b900")
$AddSkuIds.Add("e43b5b99-8dfb-405f-9987-dc307f34bcbd")

$RemoveSkuIds.Add("440eaaa8-b3e0-484b-a8be-62870b9ba70a")

$Obj1 = New-AzureAdLicenseObject -SkuId $AddSkuIds -RemoveSkuId $RemoveSkuIds
$Obj1 | Format-List

[System.Collections.ArrayList]$AddSkuIds = @()
[System.Collections.ArrayList]$RemoveSkuIds = @()
$AddSkuIds.Add("440eaaa8-b3e0-484b-a8be-62870b9ba70a")

$RemoveSkuIds.Add("6fd2c87f-b296-42f0-b197-1e91e994b900")
$RemoveSkuIds.Add("e43b5b99-8dfb-405f-9987-dc307f34bcbd")


$Obj2 = New-AzureAdLicenseObject -SkuId $AddSkuIds -RemoveSkuId $RemoveSkuIds
$Obj2 | Format-List


$NewLicenseObjParameters = $null
$NewLicenseObjParameters += @{'SkuId' = $AddSkuIds }
$NewLicenseObjParameters += @{'RemoveSkuId' = $RemoveSkuIds }
if ($PSBoundParameters.ContainsKey('RemoveAllLicenses')) {
  $NewLicenseObjParameters += @{'RemoveSkuId' = $RemoveAllSkuIds }
}

$LicenseObject = New-AzureAdLicenseObject @NewLicenseObjParameters
$LicenseObject | Format-List

$Object3 = New-AzureAdLicenseObject -SkuId 6fd2c87f-b296-42f0-b197-1e91e994b900, e43b5b99-8dfb-405f-9987-dc307f34bcbd -RemoveSkuId 440eaaa8-b3e0-484b-a8be-62870b9ba70a
$Object4 = New-AzureAdLicenseObject -RemoveSkuId 440eaaa8-b3e0-484b-a8be-62870b9ba70a

$Object3 | Format-List *
$Object4 | Format-List *


(Get-AzureADUserLicenseDetail -ObjectId $Acc).SkuId

$Acc = "TestAAAccount7@arkadinplatform.onmicrosoft.com"
$Acc = "tdr.ameraa@arkadinplatform.com"
$ADuser = Get-AzureADUser -ObjectId $ACC

Set-AzureADUserLicense -ObjectId $ADuser.ObjectId -AssignedLicenses $Object3
Set-AzureADUserLicense -ObjectId $ADuser.ObjectId -AssignedLicenses $Object4

Set-TeamsUserLicense -Identity $Acc -Add Office365E3
Set-TeamsUserLicense -Identity $Acc -Add PhoneSystem
Set-TeamsUserLicense -Identity $Acc -Remove Office365E3, PhoneSystem
Set-TeamsUserLicense -Identity $Acc -Add Office365E5 -RemoveAll -Verbose -Debug

Set-TeamsUserLicense -Identity $Acc -RemoveAll -Verbose -Debug
Get-TeamsUserLicense -Identity $acc

Set-TeamsUserLicense -Identity $Acc -Remove Office365E3



$userUPN = "<user sign-in name (UPN)>"
$licensePlanList = Get-AzureADSubscribedSku
$userList = Get-AzureADUser -ObjectId $userUPN | Select-Object -ExpandProperty AssignedLicenses | Select-Object SkuID
if ($userList.Count -ne 0) {
  if ($userList -is [array]) {
    for ($i = 0; $i -lt $userList.Count; $i++) {
      $license = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
      $licenses = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
      $license.SkuId = $userList[$i].SkuId
      $licenses.AddLicenses = $license
      Set-AzureADUserLicense -ObjectId $userUPN -AssignedLicenses $licenses
      $Licenses.AddLicenses = @()
      $Licenses.RemoveLicenses = (Get-AzureADSubscribedSku | Where-Object -Property SkuID -Value $userList[$i].SkuId -EQ).SkuID
      Set-AzureADUserLicense -ObjectId $userUPN -AssignedLicenses $licenses
    }
  }
  else {
    $license = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
    $licenses = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
    $license.SkuId = $userList.SkuId
    $licenses.AddLicenses = $license
    Set-AzureADUserLicense -ObjectId $userUPN -AssignedLicenses $licenses
    $Licenses.AddLicenses = @()
    $Licenses.RemoveLicenses = (Get-AzureADSubscribedSku | Where-Object -Property SkuID -Value $userList.SkuId -EQ).SkuID
    Set-AzureADUserLicense -ObjectId $userUPN -AssignedLicenses $licenses
  }
}


$license = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
$licenses = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
#$license.SkuId = $userList.SkuId
#$licenses.AddLicenses = $license
#Set-AzureADUserLicense -ObjectId $userUPN -AssignedLicenses $licenses
$Licenses.AddLicenses = @()
$Licenses.RemoveLicenses = Get-SkuIDFromSkuPartNumber "ENTERPRISEPACK", "MCOEV"
$Licenses | Format-List

Set-AzureADUserLicense -ObjectId $ADuser.ObjectId -AssignedLicenses $Licenses
Get-AzureADUserLicenseDetail -ObjectId $ACC | Format-List *
(Get-AzureADUserLicenseDetail -ObjectId $ACC).SkuPartNumber