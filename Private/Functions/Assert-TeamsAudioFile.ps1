# Module:     TeamsFunctions
# Function:   Support, CallQueue, AutoAttendant
# Author:     David Eberhardt
# Updated:    06-JUN-2021
# Status:     Live




function Assert-TeamsAudioFile {
  <#
	.SYNOPSIS
		Validates an audio file exists and can be used for CallQueues or AutoAttendants
	.DESCRIPTION
		Tests whether the File exists and fulfils all requirements for a Teams Audio File
    Returns $true if the file exists and adheres to size, format requirements.
    Returns $false and visible errors if the file does not exist or is out of bounds for import.
    Used with Import-CsOnlineAudioFile
	.PARAMETER File
		File to be tested
  .EXAMPLE
    Assert-TeamsAudioFile -File C:\Temp\MyMusicOnHold.wav
    Returns $true if the file exists and adheres to size, format requirements.
  .INPUTS
    System.String
  .OUTPUTS
    System.Boolean
	.NOTES
    Used for Call Queues & Auto Attendants to validate the file is ready to import
  .COMPONENT
    TeamsCallQueue
    TeamsAutoAttendant
	.FUNCTIONALITY
		Validates requirements for a AudioFile for use in CallQueues or AutoAttendants
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  .LINK
    about_TeamsAutoAttendant
  .LINK
    about_TeamsCallQueue
	.LINK
		Assert-TeamsAudioFile
	.LINK
		Import-TeamsAudioFile
	.LINK
		New-TeamsCallQueue
	.LINK
		Set-TeamsCallQueue
	#>

  [CmdletBinding()]
  [OutputType([System.Boolean])]
  param(
    [Parameter(Mandatory)]
    [ArgumentCompleter( { 'C:\Temp\' })]
    [string]$File

  ) #param

  begin {
    #Show-FunctionStatus -Level Live
    #Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"
    #Write-Verbose -Message "Need help? Online:  $global:TeamsFunctionsHelpURLBase$($MyInvocation.MyCommand)`.md"

  } #begin

  process {
    #Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    # Testing File
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand) - Processing AudioFile: '$File'"
    if (-not (Test-Path $File)) {
      Write-Error -Message "AudioFile: '$File': not found!"
      return $false
    }
    elseif ( -not ((Get-Item $File).length -le 5242880 -and ($File -match '.mp3' -or $File -match '.wav' -or $File -match '.wma'))) {
      Write-Error -Message "AudioFile: '$File': Format check not passed. Provide MP3/WAV/WMA with max 5MB in size!"
      return $false
    }
    else {
      return $true
    }
  } #process

  end {
    #Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Assert-TeamsAudioFile
