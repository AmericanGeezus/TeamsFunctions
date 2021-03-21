#Idea: Assert-TeamsUserLicense
# Input: UPN, type of Service (DirectRouting/CallingPlans)
# Input: Enable Pipeline for UPN
# Set: Default to DirectRouting?
# Add: Switch "CallingPlans": Checking against any DOM/INT calling plan (Add Switch for CommunicationCredits?)
# Add: Switch "DirectRouting": https://docs.microsoft.com/en-us/microsoftteams/direct-routing-migrating (Licenses)
# Add: Switch to output Object/Table with all tests preformed everything (seeing what is assigned)
# Add: Verbose output for every step (each tested Plan)
# Output: BOOLEAN: True/False Output: Pass/Fail

$UPNs = @('...')
foreach ($U in $UPNs) {
  $Output = [PSCustomObject][ordered]@{
    UserPrincipalName = $U
    MCOSTANDARD       = $(Test-TeamsUserLicense -Identity $U -ServicePlan MCOSTANDARD)
    MCOPROFESSIONAL   = $(Test-TeamsUserLicense -Identity $U -ServicePlan MCOPROFESSIONAL)
    MCOEV             = $(Test-TeamsUserLicense -Identity $U -ServicePlan MCOEV)
    TEAMS1            = $(Test-TeamsUserLicense -Identity $U -ServicePlan TEAMS1)
  }
  $Output | Export-Csv C:\Temp\CHNusers.csv -Append
}


#Idea: Assert-TeamsUserVoiceConfig
# Input: UPN, type of Service (DirectRouting/CallingPlans)
# Input: Enable Pipeline for UPN
# Set: DirectRouting only
# Add: Switch to output Object/Table with all tests preformed everything (seeing what is assigned)
# Add: Test to verify PhoneNumber w/o OVP
# Add: Swtich to validate TDP is assigned?
# Add: Verbose output for every step (each tested Plan)
# Output: BOOLEAN: True/False Output: Pass/Fail

function Assert-TeamsUserVoiceConfig {
  [CmdletBinding()]
  param(
    $Identity
  )
  foreach ($I in $Identity) {
    try {
      $CsOnlineUser = Get-CsOnlineUser -Identity $I -WarningAction SilentlyContinue -ErrorAction STOP
    }
    catch {
      Write-Error -Message "User '$I' not found"
      continue
    }
    if (-not $CsOnlineUser.EnterpriseVoiceEnabled ) {
      Write-Information "User '$I' not enabled for Enterprise Voice"
      continue
    }
    else {
      $TestFull = Test-TeamsUserVoiceConfig -Identity $I -Scope DirectRouting

      if ($TestFull) {
        #FIX if Called, Return boolean, otherwise, information!
        Write-Information "User '$I' is correctly configured"
        #return $True
      }
      else {
        $TestPart = Test-TeamsUserVoiceConfig -Identity $I -Scope DirectRouting -Partial
        if ($TestPart) {
          #FIX if Called, Return boolean, otherwise, information!
          Write-Warning "User '$I' is partially configured! Please investigate"
          #return $false
        }
      }
    }
  }
}

$UPNs = @('...')
foreach ($U in $UPNs) {
  $Output = [PSCustomObject][ordered]@{
    UserPrincipalName = $U
    MCOSTANDARD       = $(Test-TeamsUserLicense -Identity $U -ServicePlan MCOSTANDARD)
    MCOPROFESSIONAL   = $(Test-TeamsUserLicense -Identity $U -ServicePlan MCOPROFESSIONAL)
    MCOEV             = $(Test-TeamsUserLicense -Identity $U -ServicePlan MCOEV)
    TEAMS1            = $(Test-TeamsUserLicense -Identity $U -ServicePlan TEAMS1)
  }
  $Output | Export-Csv C:\Temp\CHNusers.csv -Append
}