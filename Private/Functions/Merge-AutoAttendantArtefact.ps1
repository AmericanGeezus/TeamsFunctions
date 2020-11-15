﻿# Module:     TeamsFunctions
# Function:   Teams Auto Attendant
# Author:     David Eberhardt
# Updated:    01-NOV-2020
# Status:     PreLive




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
    Deserialized.Microsoft.Rtc.Management.Hosted.OAA.Models.Schedule
    Deserialized.Microsoft.Rtc.Management.Hosted.OAA.Models.Prompt
  .OUTPUTS
    PSCustomObject
  .NOTES
    Schedule requires the queried Object from Get-CsOnlineSchedule
    All other parmeter work with the nested Object from the Auto Attendant Object
  .LINK
    Get-TeamsAutoAttendant

	#>

  [CmdletBinding(DefaultParameterSetName = "Prompt")]
  [OutputType([PSCustomObject])]
  param(
    [Parameter(Mandatory, HelpMessage = 'Deserialized Object for the AA')]
    [object[]]$Object,

    [Parameter(Mandatory, HelpMessage = "Type of Object presented. Determines Output")]
    [ValidateSet('Prompt', 'MenuOption', 'Menu', 'CallFlow', 'Schedule', 'CallHandlingAssociation')]
    [string]$Type,

    [Parameter(Mandatory, ParameterSetName = "Menu", HelpMessage = "Merged Object of 'Prompts' to be added to Call Flows or Menus")]
    [Parameter(Mandatory, ParameterSetName = "CallFlow", HelpMessage = "Merged Object of 'Prompts' to be added to Call Flows or Menus")]
    [AllowNull()]
    [object[]]$Prompts,

    [Parameter(Mandatory, ParameterSetName = "Menu", HelpMessage = "Merged Object of 'MenuOptions' to be added to Menus")]
    [object[]]$MenuOptions,

    [Parameter(Mandatory, ParameterSetName = "CallFlow", HelpMessage = "Merged Object of 'Menu' to be added to Call Flows")]
    [object]$Menu,

    [Parameter(Mandatory, ParameterSetName = "CallHandlingAssociation", HelpMessage = "CallHandling Association only: Name of the Call Flow")]
    [object]$CallFlowName
  ) #param

  begin {
    #Show-FunctionStatus -Level PreLive
    #Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

  } #begin

  process {
    #Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    $MergedObject = @()
    switch ($Type) {
      "Prompt" {
        foreach ($O in $Object) {
          $SingleObject = @()
          $SingleObject = [PsCustomObject][ordered]@{
            'ActiveType'         = $O.ActiveType
            'TextToSpeechPrompt' = $O.TextToSpeechPrompt
            'AudioFilePrompt'    = $O.AudioFilePrompt
            # More boolean parameters are available with | FL *:
            # HasTextToSpeechPromptData, HasAudioFilePromptData, IsAudioFileAlreadyUploaded, IsDisabled, HasDualPromptData
          }

          Add-Member -Force -InputObject $SingleObject -MemberType ScriptMethod -Name ToString -Value {
            [System.Environment]::NewLine + (($this | Format-List * | Out-String) -replace '^\s+|\s+$')
          }

          $MergedObject += Add-Member -InputObject $SingleObject -TypeName TeamsFunctions.AA.DisplayPrompt -PassThru
        }

        return $MergedObject
      }

      "MenuOption" {
        foreach ($O in $Object) {
          # Enumerating Call Target
          #TODO - Align Get-TeamsAutoAttendantCallableEntity with this one? Maybe extend by searching by type
          if ($O.CallTarget.Identity) {
            $CallTargetEntity = switch ($O.CallTarget.Type) {
              'User' { $(Get-AzureADUser -ObjectId $O.CallTarget.Identity).UserPrincipalName }
              'ExternalPstn' { $O.CallTarget.Identity }
              'ApplicationEndpoint ' { $(Get-AzureADUser -ObjectId $O.CallTarget.Identity).UserPrincipalName }
              'SharedVoicemail' { $(Get-AzureADGroup -ObjectId $O.CallTarget.Identity).DisplayName }
              'HuntGroup' { $O.CallTarget.Identity }
              'OrganizationalAutoAttendant' { $O.CallTarget.Identity }
            }

            $CallTarget = @()
            $CallTarget = [PsCustomObject][ordered]@{
              'Entity'   = $CallTargetEntity
              'Identity' = $O.CallTarget.Identity
              'Type'     = $O.CallTarget.Type
            }

            Add-Member -Force -InputObject $CallTarget -MemberType ScriptMethod -Name ToString -Value {
              [System.Environment]::NewLine + (($this | Format-List * | Out-String) -replace '^\s+|\s+$')
            }
          }
          else {
            $CallTarget = $null
          }

          # Creating Object
          $SingleObject = @()
          $SingleObject = [PsCustomObject][ordered]@{
            'Action'         = $O.Action
            'DtmfResponse'   = $O.DtmfResponse
            'VoiceResponses' = $O.VoiceResponses
            'CallTarget'     = $CallTarget
            'Prompt'         = $O.Prompt
          }

          Add-Member -Force -InputObject $SingleObject -MemberType ScriptMethod -Name ToString -Value {
            [System.Environment]::NewLine + (($this | Format-List * | Out-String) -replace '^\s+|\s+$')
          }

          $MergedObject += Add-Member -InputObject $SingleObject -TypeName TeamsFunctions.AA.MenuOption -PassThru
        }

        return $MergedObject
      }

      "Menu" {
        foreach ($O in $Object) {
          $SingleObject = @()
          $SingleObject = [PsCustomObject][ordered]@{
            'Name'                  = $O.Name
            'Prompts'               = $Prompts
            'MenuOptions'           = $MenuOptions
            'DialByNameEnabled'     = $O.DialByNameEnabled
            'DirectorySearchMethod' = $O.DirectorySearchMethod
          }

          Add-Member -Force -InputObject $SingleObject -MemberType ScriptMethod -Name ToString -Value {
            [System.Environment]::NewLine + (($this | Format-List * | Out-String) -replace '^\s+|\s+$')
          }

          $MergedObject += Add-Member -InputObject $SingleObject -TypeName TeamsFunctions.AA.Menu -PassThru
        }

        return $MergedObject
      }

      "CallFlow" {
        foreach ($O in $Object) {
          $SingleObject = @()
          $SingleObject = [PsCustomObject][ordered]@{
            'Name'      = $O.Name
            'Id'        = $O.Id
            'Greetings' = $Prompts
            'Menu'      = $Menu
          }

          Add-Member -Force -InputObject $SingleObject -MemberType ScriptMethod -Name ToString -Value {
            [System.Environment]::NewLine + (($this | Format-List * | Out-String) -replace '^\s+|\s+$')
          }

          $MergedObject += Add-Member -InputObject $SingleObject -TypeName TeamsFunctions.AA.CallFlow -PassThru
        }

        return $MergedObject
      }

      "Schedule" {
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
                [System.Environment]::NewLine + (($this | Format-List * | Out-String) -replace '^\s+|\s+$')
              }
            }

            1 {
              # Schedule Type is Fixed
              $WeeklyRecurrentSchedule = $null
              #CHECK whether multiple Fixed ones require a ForEach
              <# Alt: Broken out into individual Start/End blocks
                $FixedSchedule = @()
                foreach ($Range in $Schedule.FixedSchedule) {
                  $FixedScheduleRange = @()
                  $FixedScheduleRange = [PsCustomObject][ordered]@{
                    'Start' = $Range.DateTimeRanges.Start
                    'End'   = $Range.DateTimeRanges.End
                  }
                  Add-Member -Force -InputObject $FixedScheduleRange -MemberType ScriptMethod -Name ToString -Value {
                    [System.Environment]::NewLine + (($this | Format-List * | Out-String) -replace '^\s+|\s+$')
                  }
                  $FixedSchedule += Add-Member -InputObject $FixedScheduleRange -TypeName My.CallHandlingAssociation -PassThru
                }
              #>
              $FixedSchedule = $Schedule.FixedSchedule.DisplayDateTimeRanges
            }
          }

          $SingleObject = @()
          $SingleObject = [PsCustomObject][ordered]@{
            'Name'                    = $O.Name
            'Type'                    = $O.Type
            'WeeklyRecurrentSchedule' = $WeeklyRecurrentSchedule
            'FixedSchedule'           = $FixedSchedule
            'Id'                      = $O.Id
          }

          Add-Member -Force -InputObject $SingleObject -MemberType ScriptMethod -Name ToString -Value {
            [System.Environment]::NewLine + (($this | Format-List * | Out-String) -replace '^\s+|\s+$')
          }
          $MergedObject += Add-Member -InputObject $SingleObject -TypeName TeamsFunctions.AA.Schedule -PassThru
        }

        return $MergedObject
      }

      "CallHandlingAssociation" {
        foreach ($O in $Object) {
          <# INFO Alternatively, this Object can be drilled down further (but would be duplicate)
          $AACallHandlingAssociationsSchedule = @()
          foreach ($ScheduleId in $item.ScheduleId) {
            $Schedule = Get-CsOnlineSchedule -Id $ScheduleId
            $CHASchedule = [PsCustomObject][ordered]@{
              'Name' = $Schedule.Name
              'Type' = $Schedule.Type
              'Id'   = $Schedule.Id
            }
            Add-Member -Force -InputObject $CHASchedule -MemberType ScriptMethod -Name ToString -Value {
              [System.Environment]::NewLine + (($this | Format-List * | Out-String) -replace '^\s+|\s+$')
            }
            $AACallHandlingAssociationsSchedule += Add-Member -InputObject $CHASchedule -TypeName My.CallHandlingAssociation -PassThru
          }
          #>
          $SingleObject = @()
          $SingleObject = [PsCustomObject][ordered]@{
            'Type'     = $O.Type
            'Enabled'  = $O.Enabled
            'Schedule' = $(Get-CsOnlineSchedule -Id $O.ScheduleId).Name
            'CallFlow' = $CallFlowName
          }

          Add-Member -Force -InputObject $SingleObject -MemberType ScriptMethod -Name ToString -Value {
            [System.Environment]::NewLine + (($this | Format-List * | Out-String) -replace '^\s+|\s+$')
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