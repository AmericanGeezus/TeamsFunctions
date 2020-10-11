# Module:     TeamsFunctions
# Function:   Support, CallQueue, AutoAttendant
# Author:     David Eberhardt
# Updated:    01-SEP-2020
# Status:     PreLive


function Import-TeamsAudioFile {
  <#
	.SYNOPSIS
		Imports an AudioFile for CallQueues or AutoAttendants
	.DESCRIPTION
		Imports an AudioFile for CallQueues or AutoAttendants with Import-CsOnlineAudioFile
	.PARAMETER File
		File to be imported
	.PARAMETER ApplicationType
    ApplicationType of the entity it is for
  .EXAMPLE
    Import-TeamsAudioFile -File C:\Temp\MyMusicOnHold.wav -ApplicationType CallQueue
    Imports MyMusicOnHold.wav into Teams, assigns it the type CallQueue and returns the imported Object for further use.
  .INPUTS
    System.String
  .OUTPUTS
    Microsoft.Rtc.Management.Hosted.Online.Models.AudioFile
	.NOTES
    Translation of Import-CsOnlineAudioFile to process with New/Set-TeamsResourceAccount
    Simplifies the ApplicationType input for friendly names
    Captures different behavior of Get-Content (ByteStream syntax) in PowerShell 6 and above VS PowerShell 5 and below
	.FUNCTIONALITY
		Imports an AudioFile for CallQueues or AutoAttendants with Import-CsOnlineAudioFile
	.LINK
		New-TeamsCallQueue
		Set-TeamsCallQueue
	#>

  [CmdletBinding()]
  [OutputType([Microsoft.Rtc.Management.Hosted.Online.Models.AudioFile])]
  param(
    [Parameter(Mandatory = $true)]
    [string]$File,

    [Parameter(Mandatory = $true)]
    [ValidateSet('CallQueue', 'AutoAttendant')]
    [string]$ApplicationType

  ) #param

  begin {
    Show-FunctionStatus -Level PreLive
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.Mycommand)"

    # Asserting SkypeOnline Connection
    if (-not (Assert-SkypeOnlineConnection)) { break }

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.Mycommand)"
    # Testing File
    if (-not (Test-Path $File)) {
      Write-Error -Message "File not found!" -ErrorAction Stop
    }

    $FileName = Split-Path $File -Leaf

    # remodelling ApplicationType to ApplicationId
    $ApplicationId = switch ($ApplicationType) {
      'CallQueue' { Return 'HuntGroup' }
      'AutoAttendant' { Return 'OrgAutoAttendant' }
    }

    try {
      # Importing Content
      if ($PSVersionTable.PSVersion.Major -ge 6) {
        $content = Get-Content $File -AsByteStream -ReadCount 0 -ErrorAction STOP
      }
      else {
        $content = Get-Content $File -Encoding byte -ReadCount 0 -ErrorAction STOP
      }

      # Importing file
      $AudioFile = Import-CsOnlineAudioFile -ApplicationId $ApplicationId -FileName $FileName -Content $content -ErrorAction STOP
      return $AudioFile
    }
    catch {
      Write-Host "Error importing file - Please check file size and compression ratio. If in doubt, provide WAV "
      # Writing Error Record in human readable format. Prepend with Custom message
      Write-ErrorRecord $_
      return
    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.Mycommand)"
  } #end
} #Import-TeamsAudioFile
