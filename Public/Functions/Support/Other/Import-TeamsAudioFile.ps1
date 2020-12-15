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
  #CHECK Output Type: https://docs.microsoft.com/en-us/powershell/module/skype/import-csonlineaudiofile?view=skype-ps
  # What does Import-CsOnlineAudioFile return exactly? Raise issue on above if different? Does it have to be Deserialized?
  #[OutputType([Microsoft.Rtc.Management.Hosted.Online.Models.AudioFile])]
  #[OutputType([Deserialized.Microsoft.Rtc.Management.Hosted.Online.Models.AudioFile])]
  [OutputType([System.Object])]
  param(
    [Parameter(Mandatory = $true)]
    [string]$File,

    [Parameter(Mandatory = $true)]
    [ValidateSet('CallQueue', 'AutoAttendant')]
    [string]$ApplicationType

  ) #param

  begin {
    Show-FunctionStatus -Level PreLive
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

    # Asserting SkypeOnline Connection
    if (-not (Assert-SkypeOnlineConnection)) { break }

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    # Testing File
    if (-not (Test-Path $File)) {
      Write-Error -Message "File not found!" -ErrorAction Stop
    }

    $FileName = Split-Path $File -Leaf

    # remodelling ApplicationType to ApplicationId
    $ApplicationId = switch ($ApplicationType) {
      'CallQueue' { 'HuntGroup' }
      'AutoAttendant' { 'OrgAutoAttendant' }
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
      $parameters = $null
      $Parameters += @{ 'ApplicationId' = $ApplicationId }
      $Parameters += @{ 'FileName' = "$FileName"  }
      $Parameters += @{ 'Content' = $Content  }
      $Parameters += @{ 'ErrorAction' = 'STOP'  }

      if ($PSBoundParameters.ContainsKey('Debug')) {
        "Function: $($MyInvocation.MyCommand.Name)", ($Parameters | Format-Table -AutoSize | Out-String).Trim() | Write-Debug
      }
      $AudioFile = Import-CsOnlineAudioFile @Parameters

      #$AudioFile = Import-CsOnlineAudioFile -ApplicationId $ApplicationId -FileName "$FileName" -Content $content -ErrorAction STOP
      return $AudioFile
    }
    catch {
      Write-Error "Importing file failed - Please check file size and compression ratio. If in doubt, provide in WAV Format: $($_.Exception.Message)" -ErrorAction Stop
      ($_ | Format-Table -AutoSize | Out-String).Trim() | Write-Debug
    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Import-TeamsAudioFile
