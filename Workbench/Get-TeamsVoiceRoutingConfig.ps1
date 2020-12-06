#Idea Get-TeamsVoiceRoutingConfig

Write-Host "Gateways" -ForegroundColor Magenta
Get-TeamsMGW
Write-Host "Routes" -ForegroundColor Magenta
Get-TeamsOVR
Write-Host "Usages" -ForegroundColor Magenta
Get-TeamsOPU
Write-Host "Policies" -ForegroundColor Magenta
Get-TeamsOVP


#List All Voice Routing Policies, their Usages - Routes connected to these usages and Gateways linked in the routes as one object
# Cascade with the .ToString method for better view