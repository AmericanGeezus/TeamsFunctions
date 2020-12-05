# Module:   TeamsFunctions
# Function: Lookup
# Author:	David Eberhardt
# Updated:  11-NOV-2020
# Status:   PreLive


#TODO - put better controls around it ($1/$2...!)
# CHECK Get-CsOnlineEffectiveTenantDialPlan and Test-CsOnlineEffectiveTenantDialPlan

function Test-TeamsTDP {
    param(
        [string]$TDP,
        [string]$DialString
    )
    $Rules = (Get-TeamsTDP $TDP).NormalizationRules
    $match = 0
    foreach ($R in $Rules) {
        if ($DialString -match "$($R.Pattern)") {
            $match++
            $Translation = $R.Translation -Replace '$1', "$DialString"
            Write-Output "'$DialString' is matching Rule: '$($R.Name)' | Translation: $Translation"
        }
    }
    if ($match -eq 0) {
        Write-Host "'$DialString' is not matching any Rule in the Dial Plan" -ForegroundColor Red

    }
}

#Test-TeamsTDP -TDP "DP-IT" -DialString "6512"