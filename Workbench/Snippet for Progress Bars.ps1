# 1 Progress for while loop
$i = 0
$iMax = 600
Write-Warning -Message "Applying a License may take longer than provisioned for ($($iMax/60) mins) in this Script - If so, please apply PhoneNumber manually with Set-TeamsResourceAccount"
Write-Verbose -Message "Waiting for Get-AzureAdUserLicenseDetail to return a Result..."
while (-not (Test-TeamsUserLicense -Identity $UserPrincipalName -ServicePlan $ServicePlanName)) {
  if ($i -gt $iMax) {
    Write-Error -Message "Could not find Successful Provisioning Status of the License '$ServicePlanName' in AzureAD in the last $iMax Seconds" -Category LimitsExceeded -RecommendedAction "Please verify License has been applied correctly (Get-TeamsResourceAccount); Continue with Set-TeamsResourceAccount" -ErrorAction Stop
  }
  Write-Progress -Activity "'$Name' Azure Active Directory is applying License. Please wait" `
    -PercentComplete (($i * 100) / $iMax) `
    -Status "$(([math]::Round((($i)/$iMax * 100),0))) %"

  Start-Sleep -Milliseconds 1000
  $i++
}

# 2 Progress with Hash tables

$progParam = @{
  Activity         = $MyInvocation.MyCommand
  Status           = "Gathering $($EntryType -join ",") entries from $logname after $after."
  CurrentOperation = $null
}
Write-Progress @progParam

# 3 Progress for incremental steps
$Scope = "All"
$DisableEV = $true

[int]$step = 0
[int]$sMax = switch ($Scope) {
  "All" { 8 }
  "CallingPlans" { 4 }
  "DirectRouting" { 4 }
}
if ( $DisableEV ) { $sMax++ }

Write-Progress -Activity "Query User" -PercentComplete ($step / $sMax * 100) -Status "$(([math]::Round((($step)/$sMax * 100),0))) %"
Start-Sleep -Seconds 3

$step++
Write-Progress -Activity "Query User Licenses" -PercentComplete ($step / $sMax * 100) -Status "$(([math]::Round((($step)/$sMax * 100),0))) %"
Start-Sleep -Seconds 3

$step++
Write-Progress -Activity "Removing Calling Plan Licenses" -PercentComplete ($step / $sMax * 100) -Status "$(([math]::Round((($step)/$sMax * 100),0))) %"
Start-Sleep -Seconds 3

$step++
Write-Progress -Activity "Removing Telephone Number" -PercentComplete ($step / $sMax * 100) -Status "$(([math]::Round((($step)/$sMax * 100),0))) %"
Start-Sleep -Seconds 3

$step++
Write-Progress -Activity "Removing OnPremLineURI" -PercentComplete ($step / $sMax * 100) -Status "$(([math]::Round((($step)/$sMax * 100),0))) %"
Start-Sleep -Seconds 3

$step++
Write-Progress -Activity "Removing Online Voice Routing Policy" -PercentComplete ($step / $sMax * 100) -Status "$(([math]::Round((($step)/$sMax * 100),0))) %"
Start-Sleep -Seconds 3

$step++
Write-Progress -Activity "Removing Tenant Dial Plan" -PercentComplete ($step / $sMax * 100) -Status "$(([math]::Round((($step)/$sMax * 100),0))) %"
Start-Sleep -Seconds 3

$step++
Write-Progress -Activity "Disabling EnterpriseVoice" -PercentComplete ($step / $sMax * 100) -Status "$(([math]::Round((($step)/$sMax * 100),0))) %"
Start-Sleep -Seconds 3

$step++
Write-Progress -Activity "Complete" -PercentComplete ($step / $sMax * 100) -Status "$(([math]::Round((($step)/$sMax * 100),0))) %"
