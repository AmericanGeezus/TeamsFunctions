# Module:   TeamsFunctions
# Function: Support
# Author:	David Eberhardt
# Updated:  11-DEC-2020
# Status:   BETA





function Get-UniqueAzureAdGroup {
  # Determines a Unique Group for Shared Voicemail
  # Throws an error otherwise (this needs catching!)
  param (
    [String]$Id
  )

  try {
    $CallTarget = $null
    $CallTarget = Get-AzureADGroup -SearchString "$Id" -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
    if (-not $CallTarget ) {
      try {
        $CallTarget = Get-AzureADGroup -ObjectId "$Id" -WarningAction SilentlyContinue -ErrorAction Stop
      }
      catch {
        $CallTarget = Get-AzureADGroup | Where-Object Mail -eq "$Id" -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
      }
    }

    # dealing with potential duplicates
    if ( $CallTarget.Count -gt 1 ) {
      $CallTarget = $CallTarget | Where-Object DisplayName -EQ "$Id"
    }
    if ( $CallTarget.Count -gt 1 ) {
      throw [System.Reflection.AmbiguousMatchException]::New('Multiple Targets found - Result not unique')
    }
    else {
      return $CallTarget
    }

  }
  catch [System.Reflection.AmbiguousMatchException] {
    Write-Warning -Message "Call Target - SharedVoicemail - No Unique Target found for '$Id'. Omitting Group"
    throw
  }
  catch {
    Write-Debug -Message "Call Target - SharedVoicemail - Error querying Call Target: $($_.Exception.Message)"
    throw
  }
}