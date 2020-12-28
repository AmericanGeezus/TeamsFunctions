# Module:   TeamsFunctions
# Function: VoiceConfig
# Author:		David Eberhardt
# Updated:  01-JAN-2021
# Status:   ALPHA

#TODO Build Idea Get-TeamsVoiceRoutingConfig
#List All Voice Routing Policies, their Usages - Routes connected to these usages and Gateways linked in the routes as one object
# Cascade with the .ToString method for better view
#Input OVP Name (optional)
#Output Custom Object displaying chain
function Get-TeamsVoiceRoutingConfig {


  param()

  begin {
    Show-FunctionStatus -Level ALPHA
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

    # Asserting SkypeOnline Connection
    if (-not (Assert-SkypeOnlineConnection)) { break }
  }

  process {
    Write-Host "Gateways" -ForegroundColor Magenta
    Get-TeamsMGW

    Write-Host "Routes" -ForegroundColor Magenta
    Get-TeamsOVR

    Write-Host "Usages" -ForegroundColor Magenta
    Get-TeamsOPU

    Write-Host "Policies" -ForegroundColor Magenta
    Get-TeamsOVP


  }

  end {

  }
}