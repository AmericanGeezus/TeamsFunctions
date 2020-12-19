# Module:     TeamsFunctions
# Function:   UserAdmin
# Author:     David Eberhardt
# Updated:    20-DEC-2020
# Status:     Alpha



# User & Reason
$Username = "a98001157_adm@atlascopco.com"

$SubjectId = (Get-AzureADUser -ObjectId $Username).ObjectId
$Reason = "Admin"


# Ids for Assignment
$ProviderId = 'aadRoles'
$ResourceId = (Get-AzureADCurrentSessionInfo).TenantId


# Importing all Roles
$Roles = Get-AzureADMSPrivilegedRoleDefinition -ProviderId $ProviderId -ResourceId $ResourceId

# Eligibil Roles
$MyEligibleRoles = Get-AzureADMSPrivilegedRoleAssignment -ProviderId $ProviderId -ResourceId $ResourceId -Filter "subjectId eq '$SubjectId'"
if ($MyEligibleRoles.Count -eq 0) {
  #Capture no eligible Roles - Navigate Groups here?
}


# Defining Schedule
$Date = Get-Date
$start = $Date.ToUniversalTime()
$end = $Date.AddHours(4).ToUniversalTime()

$schedule = New-Object Microsoft.Open.MSGraph.Model.AzureADMSPrivilegedSchedule
$schedule.Type = "Once"
$schedule.StartDateTime = $start.ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
$schedule.endDateTime = $end.ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
Write-Debug $schedule

# Activating Role
foreach ($R in $MyEligibleRoles) {
  $RoleName = $Roles | Where-Object { $_.Id -eq $R.RoleDefinitionId } | Select-Object -ExpandProperty DisplayName
  Write-Host "Activating Role: '$RoleName'"
  Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId $ProviderId -ResourceId $ResourceId -RoleDefinitionId $R.RoleDefinitionId -SubjectId $SubjectId -Type 'UserAdd' -AssignmentState 'Active' -Schedule $schedule -Reason $Reason

}


#re-requry? (untested)
# Query first to see if Teams Service or Comms Admin and Lync Admin are already active...!
$MyRoles = Get-AzureADMSPrivilegedRoleAssignment -ProviderId $ProviderId -ResourceId $ResourceId
#$MyRoles.Count
$MyRoles = $MyRoles | Where-Object AssignmentState -EQ "Active"
