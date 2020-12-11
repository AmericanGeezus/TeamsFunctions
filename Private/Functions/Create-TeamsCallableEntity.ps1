# Module:   TeamsFunctions
# Function: Support
# Author:	David Eberhardt
# Updated:  11-DEC-2020
# Status:   BETA




function Create-TeamsCallableEntity {
    # Used in Auto Attendants
    param(
        [string]$CallableEntity
    )
    # Creating Callable Entity with or without Transcription
    try {
        $CEObject = Get-TeamsCallableEntity $CallableEntity
        #TODO Test Parameter EnableTranscription - Try with Catch and retry? Activate for all type where needed?
        if ($CEObject.Type -eq "SharedVoicemail" -and $EnableTranscription) {
            $CEEntity = New-TeamsAutoAttendantCallableEntity -Type $CEObject.Type -Identity "$CallableEntity" -EnableTranscription
        }
        else {
            if ($EnableTranscription) {
                Write-Verbose -Message "EnableTranscription - Transcription can only be activated for SharedVoicemail." -Verbose
            }
            $CEEntity = New-TeamsAutoAttendantCallableEntity -Type $CEObject.Type -Identity "$CallableEntity"
        }

        $CallTargetEntity = New-TeamsAutoAttendantCallableEntity -Type $CEObject.Type -Identity "$CEEntity"
        return $CallTargetEntity
    }
    catch [System.IO.IOException] {
        Write-Warning -Message "'$NameNormalised' Call Target '$CallableEntity' not enumerated. Omitting Object"
        return $null
    }
    catch {
        Write-Warning -Message "'$NameNormalised' Call Target '$CallableEntity' not enumerated. Omitting Object"
        Write-Host "$($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}