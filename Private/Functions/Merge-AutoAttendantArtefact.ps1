# Module:     TeamsFunctions
# Function:   Teams Auto Attendant
# Author:     David Eberhardt
# Updated:    01-DEC-2020
# Status:     Live




function Merge-AutoAttendantArtefact {
  <#
	.SYNOPSIS
		Merges multiple Artefacts of an Auto Attendant into one Object for display
	.DESCRIPTION
    Helper function to prepare a nested Object of an Auto Attendant for display
    Used in Get-TeamsAutoAttendant
  .PARAMETER Object
    The input Object to transform
  .PARAMETER Type
    Type of Object (will determine Output)
  .PARAMETER Prompts
    Only valid for Type Call Flow and Menu - Object representing the Call Prompts
  .PARAMETER MenuOptions
    Only valid for Type Menu - Object representing the Menu Options
  .PARAMETER Menu
    Only valid for Type Call Flow - Object representing the Menu
  .INPUTS
    Deserialized.Microsoft.Rtc.Management.Hosted.OAA.Models.CallFlow
    Deserialized.Microsoft.Rtc.Management.Hosted.OAA.Models.Menu
    Deserialized.Microsoft.Rtc.Management.Hosted.OAA.Models.MenuOption
    Deserialized.Microsoft.Rtc.Management.Hosted.OAA.Models.CallHandlingAssociation
    Deserialized.Microsoft.Rtc.Management.Hosted.Online.Models.Schedule
    Deserialized.Microsoft.Rtc.Management.Hosted.OAA.Models.Prompt
  .OUTPUTS
    PSCustomObject
  .NOTES
    Schedule requires the queried Object from Get-CsOnlineSchedule
    All other parmeter work with the nested Object from the Auto Attendant Object
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  .LINK
    Get-TeamsAutoAttendant

	#>

  [CmdletBinding(DefaultParameterSetName = 'Prompt')]
  [OutputType([PSCustomObject])]
  param(
    [Parameter(Mandatory, HelpMessage = 'Deserialized Object for the AA')]
    [object[]]$Object,

    [Parameter(Mandatory, HelpMessage = 'Type of Object presented. Determines Output')]
    [ValidateSet('Prompt', 'MenuOption', 'Menu', 'CallFlow', 'Schedule', 'CallHandlingAssociation')]
    [string]$Type,

    [Parameter(Mandatory, ParameterSetName = 'CallFlow', HelpMessage = "Merged Object of 'Prompts' to be added to Call Flows or Menus")]
    [Parameter(Mandatory, ParameterSetName = 'Menu', HelpMessage = "Merged Object of 'Prompts' to be added to Call Flows or Menus")]
    [Parameter(ParameterSetName = 'MenuOption', HelpMessage = "Merged Object of 'Prompts' to be added to Menu Options")]
    [AllowNull()]
    [object[]]$Prompts,

    [Parameter(Mandatory, ParameterSetName = 'Menu', HelpMessage = "Merged Object of 'MenuOptions' to be added to Menus")]
    [AllowNull()]
    [object[]]$MenuOptions,

    [Parameter(Mandatory, ParameterSetName = 'CallFlow', HelpMessage = "Merged Object of 'Menu' to be added to Call Flows")]
    [AllowNull()]
    [object]$Menu,

    [Parameter(Mandatory, ParameterSetName = 'CallHandlingAssociation', HelpMessage = 'CallHandling Association only: Name of the Call Flow')]
    [object]$CallFlowName
  ) #param

  begin {
    #Show-FunctionStatus -Level Live
    #Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

    $OFS = ''
  } #begin

  process {
    #Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    $MergedObject = @()
    switch ($Type) {
      'Prompt' {
        foreach ($O in $Object) {
          if ( $O.HasAudioFilePromptData ) {
            $AudioFilePrompt = @()
            $AudioFilePrompt = [PsCustomObject][ordered]@{
              'Id'                = $O.AudioFilePrompt.Id
              'FileName'          = $O.AudioFilePrompt.FileName
              'DownloadUri'       = $O.AudioFilePrompt.DownloadUri
              'MarkedForDeletion' = $O.AudioFilePrompt.MarkedForDeletion
            }
            Add-Member -Force -InputObject $AudioFilePrompt -MemberType ScriptMethod -Name ToString -Value {
              [System.Environment]::NewLine + (($this | Format-List * | Out-String) -replace '^\s+|\s+$') + [System.Environment]::NewLine
            }
          }
          $SingleObject = @()
          $SingleObject = [PsCustomObject][ordered]@{
            'ActiveType'         = $O.ActiveType
            'TextToSpeechPrompt' = $O.TextToSpeechPrompt
            'AudioFilePrompt'    = $AudioFilePrompt
            # More boolean parameters are available with | FL *:
            # HasTextToSpeechPromptData, HasAudioFilePromptData, IsAudioFileAlreadyUploaded, IsDisabled, HasDualPromptData
          }

          Add-Member -Force -InputObject $SingleObject -MemberType ScriptMethod -Name ToString -Value {
            [System.Environment]::NewLine + (($this | Format-List * | Out-String) -replace '^\s+|\s+$') + [System.Environment]::NewLine
          }

          $MergedObject += Add-Member -InputObject $SingleObject -TypeName TeamsFunctions.AA.DisplayPrompt -PassThru
        }

        return $MergedObject
      }

      'MenuOption' {
        foreach ($O in $Object) {
          # Enumerating Call Target
          if ($O.CallTarget.Id) {
            $CallTargetEntity = Get-TeamsCallableEntity $O.CallTarget.Id

            $CallTarget = @()
            $CallTarget = [PsCustomObject][ordered]@{
              'Entity'   = $CallTargetEntity.Entity
              'Identity' = $O.CallTarget.Id
              'Type'     = $O.CallTarget.Type
            }

            Add-Member -Force -InputObject $CallTarget -MemberType ScriptMethod -Name ToString -Value {
              #[System.Environment]::NewLine +
              (($this | Format-List * | Out-String) -replace '^\s+|\s+$') + [System.Environment]::NewLine
            }
          }
          else {
            $CallTarget = $null
          }

          # Creating Object
          $SingleObject = @()
          $SingleObject = [PsCustomObject][ordered]@{
            'DtmfResponse'   = $O.DtmfResponse
            'VoiceResponses' = $O.VoiceResponses
            'Prompt'         = if ( $Prompts ) { $Prompts } else { $O.Prompt }
            'Action'         = $O.Action
            'CallTarget'     = if ( $CallTarget ) { $CallTarget } else { $O.Prompt } # $CallTarget
          }

          Add-Member -Force -InputObject $SingleObject -MemberType ScriptMethod -Name ToString -Value {
            ([System.Environment]::NewLine + (($this | Format-List * | Out-String) -replace '^\s+|\s+$') + [System.Environment]::NewLine).replace(',', [System.Environment]::NewLine)
          }

          $MergedObject += Add-Member -InputObject $SingleObject -TypeName TeamsFunctions.AA.MenuOption -PassThru
        }

        return $MergedObject
      }

      'Menu' {
        foreach ($O in $Object) {
          $SingleObject = @()
          $SingleObject = [PsCustomObject][ordered]@{
            'Name'                  = $O.Name
            'Prompts'               = if ( $Prompts ) { $Prompts } else { $O.Prompt } # $Prompts
            'MenuOptions'           = if ( $MenuOptions ) { $MenuOptions } else { $O.MenuOptions } # $MenuOptions
            'DialByNameEnabled'     = $O.DialByNameEnabled
            'DirectorySearchMethod' = $O.DirectorySearchMethod
          }

          Add-Member -Force -InputObject $SingleObject -MemberType ScriptMethod -Name ToString -Value {
            [System.Environment]::NewLine + (($this | Format-List * | Out-String) -replace '^\s+|\s+$') + [System.Environment]::NewLine
          }

          $MergedObject += Add-Member -InputObject $SingleObject -TypeName TeamsFunctions.AA.Menu -PassThru
        }

        return $MergedObject
      }

      'CallFlow' {
        foreach ($O in $Object) {
          $SingleObject = @()
          $SingleObject = [PsCustomObject][ordered]@{
            'Name'      = $O.Name
            'Id'        = $O.Id
            'Greetings' = if ( $Prompts ) { $Prompts } else { $O.Greetings } # $Prompts
            'Menu'      = $Menu
          }

          Add-Member -Force -InputObject $SingleObject -MemberType ScriptMethod -Name ToString -Value {
            [System.Environment]::NewLine + (($this | Format-List * | Out-String) -replace '^\s+|\s+$') + [System.Environment]::NewLine
          }

          $MergedObject += Add-Member -InputObject $SingleObject -TypeName TeamsFunctions.AA.CallFlow -PassThru
        }

        return $MergedObject
      }

      'Schedule' {
        foreach ($O in $Object) {
          switch ($O.Type) {
            0 {
              # Schedule Type is WeeklyRecurrence
              $FixedSchedule = $null
              $WeeklyRecurrentSchedule = @()
              $WeeklyRecurrentSchedule = [PsCustomObject][ordered]@{
                'ComplementEnabled' = $O.WeeklyRecurrentSchedule.ComplementEnabled
                'MondayHours'       = $O.WeeklyRecurrentSchedule.DisplayMondayHours
                'TuesdayHours'      = $O.WeeklyRecurrentSchedule.DisplayTuesdayHours
                'WednesdayHours'    = $O.WeeklyRecurrentSchedule.DisplayWednesdayHours
                'ThursdayHours'     = $O.WeeklyRecurrentSchedule.DisplayThursdayHours
                'FridayHours'       = $O.WeeklyRecurrentSchedule.DisplayFridayHours
                'SaturdayHours'     = $O.WeeklyRecurrentSchedule.DisplaySaturdayHours
                'SundayHours'       = $O.WeeklyRecurrentSchedule.DisplaySundayHours
              }
              Add-Member -Force -InputObject $WeeklyRecurrentSchedule -MemberType ScriptMethod -Name ToString -Value {
                [System.Environment]::NewLine + (($this | Format-List * | Out-String) -replace '^\s+|\s+$') + [System.Environment]::NewLine
              }
            }

            1 {
              # Schedule Type is Fixed
              $WeeklyRecurrentSchedule = $null
              $FixedSchedule = $Schedule.FixedSchedule.DisplayDateTimeRanges
            }
          }

          $SingleObject = @()
          $SingleObject = [PsCustomObject][ordered]@{
            'Name'                    = $O.Name
            'Type'                    = $O.Type
            'WeeklyRecurrentSchedule' = if ( $WeeklyRecurrentSchedule ) { $WeeklyRecurrentSchedule } else { $O.WeeklyRecurrentSchedule } # $WeeklyRecurrentSchedule
            'FixedSchedule'           = if ( $FixedSchedule ) { $FixedSchedule } else { $O.FixedSchedule } # $FixedSchedule
            'Id'                      = $O.Id
          }

          Add-Member -Force -InputObject $SingleObject -MemberType ScriptMethod -Name ToString -Value {
            [System.Environment]::NewLine + (($this | Format-List * | Out-String) -replace '^\s+|\s+$') + [System.Environment]::NewLine
          }
          $MergedObject += Add-Member -InputObject $SingleObject -TypeName TeamsFunctions.AA.Schedule -PassThru
        }

        return $MergedObject
      }

      'CallHandlingAssociation' {
        foreach ($O in $Object) {
          $SingleObject = @()
          $SingleObject = [PsCustomObject][ordered]@{
            'Type'     = $O.Type
            'Enabled'  = $O.Enabled
            'Schedule' = $(Get-CsOnlineSchedule -Id $O.ScheduleId).Name
            'CallFlow' = $CallFlowName
          }

          Add-Member -Force -InputObject $SingleObject -MemberType ScriptMethod -Name ToString -Value {
            [System.Environment]::NewLine + (($this | Format-List * | Out-String) -replace '^\s+|\s+$') + [System.Environment]::NewLine
          }
          $MergedObject += Add-Member -InputObject $SingleObject -TypeName TeamsFunctions.AA.CallHandlingAssociation -PassThru
        }

        return $MergedObject
      }
    }

  } #process

  end {
    #Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end

} # Merge-AutoAttendantArtefact
