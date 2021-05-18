# IDEA:
# Grant-TeamsEmergencyLocation
# Queries existing Location by Name "Get-CsOnlineLisLocation -Location "3rd Floor Cafe" and determines $LocationId
# Applies ID with "Set-CsOnlineVoiceUser -Identity $ObjectId -LocationId $LocationId" # Does this also _need_ a TelephoneNumber?

# https://docs.microsoft.com/en-us/powershell/module/skype/get-csonlinelislocation?view=skype-ps
# https://docs.microsoft.com/en-us/powershell/module/skype/set-csonlinevoiceuser?view=skype-ps


#SupportsConfirm: MID

try {
  $CsOnlineLisLocation = if ($ELname -match <GUID>) {
    Get-CsOnlineLisLocation -LocationId $Elname
  }
  else {
    Get-CsOnlineLisLocation -Location "3rd Floor Cafe"
  }
}
catch {
  throw "Location not found!"
}

#shouldprocess
try {
  Set-CsOnlineVoiceUser -Identity $Identity -LocationID $CsOnlineLisLocation.LocationId
}
catch {
  throw "Error applying Location to CsOnlineVoiceUser. Exception: $($_.Exception.Message)"
}
