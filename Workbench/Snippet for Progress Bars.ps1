# 1 Progress for while loop
$i = 0
$iMax = 600
Write-Warning -Message "Applying a License may take longer than provisioned for ($($iMax/60) mins) in this Script - If so, please apply PhoneNumber manually with Set-TeamsResourceAccount"

$Status = "Applying License"
$Operation = "Waiting for Get-AzureAdUserLicenseDetail to return a Result"
Write-Verbose -Message "$Status - $Operation"
while (-not (Test-TeamsUserLicense -Identity $UserPrincipalName -ServicePlan $ServicePlanName)) {
  if ($i -gt $iMax) {
    Write-Error -Message "Could not find Successful Provisioning Status of the License '$ServicePlanName' in AzureAD in the last $iMax Seconds" -Category LimitsExceeded -RecommendedAction "Please verify License has been applied correctly (Get-TeamsResourceAccount); Continue with Set-TeamsResourceAccount" -ErrorAction Stop
  }
  Write-Progress -Id 1 -Activity "Azure Active Directory is applying License. Please wait" `
    -Status $Status -SecondsRemaining $($iMax - $i) -CurrentOperation $Operation -PercentComplete (($i * 100) / $iMax)

  Start-Sleep -Milliseconds 1000
  $i++
}

#ALT:  -Status "$(([math]::Round((($i)/$iMax * 100),0))) %"

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

#Optimised empty sample -- First one doesn't have $step++
Write-Progress -Id 0 -Status "User '$User'" -CurrentOperation "" -Activity $MyInvocation.MyCommand -PercentComplete ($UserCounter / $($Identity.Count) * 100)

$Operation = ""
$step++
Write-Progress -Id 1 -Status "User '$User'" -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
Write-Verbose -Message $Operation



#Empty sample -- First one doesn't have $step++
$step++
Write-Progress -Id 0 -Status "" -CurrentOperation "" -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
Write-Progress -Id 0 -Status "" -Activity $MyInvocation.MyCommand -Completed

Write-Progress -Id 0 -Activity "" -PercentComplete ($step / $sMax * 100) -Status "$(([math]::Round((($step)/$sMax * 100),0))) %"
Write-Progress -Id 0 -Status "" -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100) -CurrentOperation "$(([math]::Round((($step)/$sMax * 100),0))) %"


# Testing
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
