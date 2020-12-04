# Module:   TeamsFunctions
# Function: Lookup
# Author:	David Eberhardt
# Updated:  11-NOV-2020
# Status:   PreLive


#TODO - put better controls around it ($1/$2...!)

function Test-TeamsTDP {
    param(
        [string]$TDP,
        [string]$DialString
    )
    $Rules = (Get-TeamsTDP $TDP).NormalizationRules

    foreach ($R in $Rules) {
        if ($DialString -match "$($R.Pattern)") {
            Write-Output "'$DialString' is matching Rule: '$($R.Name)' | Translation: $($R.Translation.Replace('$1',$DialString))"
        }
    }
}

Test-TeamsTDP -TDP "DP-IT" -DialString "6512"