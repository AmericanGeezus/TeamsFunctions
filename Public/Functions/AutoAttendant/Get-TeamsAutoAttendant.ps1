﻿# Module:   TeamsFunctions
# Function: AutoAttendant
# Author:		David Eberhardt
# Updated:  01-JAN-2021
# Status:   Live




function Get-TeamsAutoAttendant {
  <#
	.SYNOPSIS
		Queries Auto Attendants and displays friendly Names (UPN or DisplayName)
	.DESCRIPTION
		Same functionality as Get-CsAutoAttendant, but display reveals friendly Names,
		like UserPrincipalName or DisplayName for the following connected Objects
    Operator and ApplicationInstances (Resource Accounts)
	.PARAMETER Name
		Optional. Finds all Auto Attendants with this name (unique results).
	.PARAMETER SearchString
		Optional. Searches all Auto Attendants for this string (multiple results possible).
  .PARAMETER Detailed
    Optional Switch. Displays nested Objects for all Parameters of the Auto Attendant
    By default, only Names of nested Objects are shown.
	.EXAMPLE
		Get-TeamsAutoAttendant
		Same result as Get-CsAutoAttendant
	.EXAMPLE
		Get-TeamsAutoAttendant -Name "My AutoAttendant"
		Returns an Object for every Auto Attendant found with the String "My AutoAttendant"
		Operator and Resource Accounts are displayed with friendly name.
	.EXAMPLE
		Get-TeamsAutoAttendant -SearchString "My AutoAtt"
    Returns an Object for every Auto Attendant found with the String "My AutoAtt"
    Synonymous with Get-CsAutoAttendant -NameFilter "My AutoAtt", but output shown differently.
		Operator and Resource Accounts are displayed with friendly name.
  .INPUTS
    System.String
  .OUTPUTS
    System.Object
	.NOTES
    Without any parameters, Get-TeamsAutoAttendant will show names only.
    Main difference to Get-CsAutoAttendant (apart from the friendly names) is how the Objects are shown.
    The connected Objects DefaultCallFlow, CallFlows, Schedules, CallHandlingAssociations and DirectoryLookups
    are all shown with Name only, but can be queried with .<ObjectName>
    This also works with Get-CsAutoAttendant, but with the help of "Display" Parameters.
	.FUNCTIONALITY
		Get-CsAutoAttendant with friendly names instead of GUID-strings for connected objects
	.LINK
		Get-TeamsCallQueue
    New-TeamsAutoAttendant
    Set-TeamsAutoAttendant
    Get-TeamsCallableEntity
    Find-TeamsCallableEntity
    New-TeamsCallableEntity
    Get-TeamsResourceAccount
    Get-TeamsResourceAccountAssociation
    Remove-TeamsAutoAttendant
  #>

  [CmdletBinding()]
  [Alias('Get-TeamsAA')]
  [OutputType([System.Object[]])]
  param(
    [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = 'Full Name of the Auto Attendant')]
    [AllowNull()]
    [string[]]$Name,

    [Parameter(HelpMessage = 'Partial or full Name of the Auto Attendant to search')]
    [Alias('NameFilter')]
    [string]$SearchString,

    [switch]$Detailed
  ) #param

  begin {
    Show-FunctionStatus -Level Live
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

    # Asserting AzureAD Connection
    if (-not (Assert-AzureADConnection)) { break }

    # Asserting SkypeOnline Connection
    if (-not (Assert-SkypeOnlineConnection)) { break }

    # Setting Preference Variables according to Upstream settings
    if (-not $PSBoundParameters.ContainsKey('Verbose')) {
      $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference')
    }
    if (-not $PSBoundParameters.ContainsKey('Confirm')) {
      $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference')
    }
    if (-not $PSBoundParameters.ContainsKey('WhatIf')) {
      $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference')
    }

    if ($PSBoundParameters.ContainsKey('Detailed')) {
      Write-Verbose -Message "Parameter 'Detailed' - This may take a bit of time..." -Verbose
    }
  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    # Capturing no input
    if (-not $PSBoundParameters.ContainsKey('Name') -and -not $PSBoundParameters.ContainsKey('SearchString')) {
      Write-Verbose -Message "Listing names only. To query individual items, please provide Name or SearchString" -Verbose
      Get-CsAutoAttendant -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | Select-Object Name
    }
    else {
      #region Query objects
      [System.Collections.ArrayList]$AutoAttendants = @()

      if ($PSBoundParameters.ContainsKey('Name')) {
        # Lookup
        Write-Verbose -Message "Parameter 'Name' - Querying unique result for each provided Name"
        foreach ($DN in $Name) {
          Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand) - Name - '$DN'"
          $AAByName = Get-CsAutoAttendant -NameFilter "$DN" -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
          $AAByName = $AAByName | Where-Object Name -EQ "$DN"
          [void]$AutoAttendants.Add($AAByName)
        }
      }

      if ($PSBoundParameters.ContainsKey('SearchString')) {
        # Search
        Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand) - SearchString - '$SearchString'"
        #CHECK do I have to filter *?
        $SearchString = $SearchString -replace '*', ''
        $AAByString = Get-CsAutoAttendant -NameFilter "$SearchString" -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
        [void]$AutoAttendants.Add($AAByString)
      }
      #endregion

      # Parsing found Objects
      Write-Verbose -Message "[PROCESS] Processing found Auto Attendants: $AACount"
      $AACounter = 0
      [int]$AACount = $AutoAttendants.Count
      #CHECK Explore Workflows with Parallel parsing:
      #foreach -parallel ($DN in $Name) {
      foreach ($AA in $AutoAttendants) {
        # Initialising counters for Progress bars
        Write-Progress -Id 0 -Status "Auto Attendant '$($AA.Name)'" -Activity $MyInvocation.MyCommand -PercentComplete ($AACounter / $AACount * 100)
        $AACounter++
        [int]$step = 0
        [int]$sMax = 4
        if ( $Detailed ) { $sMax = $sMax + 5 }

        # Initialising Arrays
        [System.Collections.ArrayList]$AIObjects = @()

        #region Finding Operator
        $Operation = "Parsing Operator"
        Write-Progress -Id 1 -Status "Auto Attendant '$($AA.Name)'" -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
        Write-Verbose -Message "'$($AA.Name)' - $Operation"
        if ($null -eq $AA.Operator) {
          $AAOperator = $null
        }
        else {
          # Parsing Callable Entity
          try {
            $CallableEntity = Get-TeamsCallableEntity "$($AA.Operator.Id)"
            $Operator = $CallableEntity.Entity
          }
          catch {
            Write-Warning -Message "'$($AA.Name)' Operator: Not enumerated: $($_.Exception.Message)"
          }
        }
        # Output: $Operator, $OperatorTranscription
        #endregion

        #region Application Instance UPNs
        $Operation = "Parsing Application Instances"
        $step++
        Write-Progress -Id 1 -Status "Auto Attendant '$($AA.Name)'" -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
        Write-Verbose -Message "'$($AA.Name)' - $Operation"
        foreach ($AI in $AA.ApplicationInstances) {
          $AIObject = $null
          $AIObject = Get-CsOnlineApplicationInstance -WarningAction SilentlyContinue | Where-Object { $_.ObjectId -eq $AI } | Select-Object UserPrincipalName, DisplayName, PhoneNumber
          if ($null -ne $AIObject) {
            [void]$AIObjects.Add($AIObject)
          }
        }
        # Output: $AIObjects.UserPrincipalName
        #endregion


        #region Creating Output Object
        # Building custom Object with Friendly Names
        $Operation = "Constructing Output Object"
        $step++
        Write-Progress -Id 1 -Status "Auto Attendant '$($AA.Name)'" -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
        Write-Verbose -Message "'$($AA.Name)' - $Operation"
        $AAObject = $null
        $AAObject = [PsCustomObject][ordered]@{
          Identity                        = $AA.Identity
          Name                            = $AA.Name
          LanguageId                      = $AA.LanguageId
          TimeZoneId                      = $AA.TimeZoneId
          VoiceId                         = $AA.VoiceId
          VoiceResponseEnabled            = $AA.VoiceResponseEnabled
          OperatorName                    = $Operator
          OperatorType                    = $AA.Operator.Type
          DefaultCallFlowName             = $AA.DefaultCallFlow.Name
          CallFlowNames                   = $AA.CallFlows.Name
          ScheduleNames                   = $AA.Schedules.Name
          CallHandlingAssociationNames    = $AA.CallHandlingAssociations.Type
          DirectoryLookupScope            = $AA.DirectoryLookupScope.Name
          GreetingsSettingAuthorizedUsers = $AA.GreetingsSettingAuthorizedUsers
        }
        #endregion

        #region Extending Output Object with Switch Detailed
        if ($PSBoundParameters.ContainsKey('Detailed')) {
          #region Operator
          $Operation = "Switch Detailed - Parsing Operator"
          $step++
          Write-Progress -Id 1 -Status "Auto Attendant '$($AA.Name)'" -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
          Write-Verbose -Message "'$($AA.Name)' - $Operation"
          if ($AA.Operator) {
            $AAOperator = @()
            $AAOperator = [PsCustomObject][ordered]@{
              'Entity'              = $Operator
              'Type'                = $AA.Operator.Type
              'EnableTranscription' = $AA.Operator.EnableTranscription
              'Id'                  = $AA.Operator.Id
            }
            Add-Member -Force -InputObject $AAOperator -MemberType ScriptMethod -Name ToString -Value {
              [System.Environment]::NewLine + (($this | Format-List * | Out-String) -replace '^\s+|\s+$')
            }
          }
          else {
            $AAOperator = $null
          }
          #endregion

          #region DefaultCallFlow
          $Operation = "Switch Detailed - Parsing DefaultCallFlow"
          $step++
          Write-Progress -Id 1 -Status "Auto Attendant '$($AA.Name)'" -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
          Write-Verbose -Message "'$($AA.Name)' - $Operation"
          # Default Call Flow Menu Prompts
          if ($AA.DefaultCallFlow.Menu.Prompts) {
            $AADefaultCallFlowMenuPrompts = Merge-AutoAttendantArtefact -Type Prompt -Object $AA.DefaultCallFlow.Menu.Prompts
          }
          else {
            $AADefaultCallFlowMenuPrompts = $null
          }

          # Default Call Flow Menu Options
          $AADefaultCallFlowMenuOptions = Merge-AutoAttendantArtefact -Type MenuOption -Object $AA.DefaultCallFlow.Menu.MenuOptions

          # Default Call Flow Menu
          $AADefaultCallFlowMenu = Merge-AutoAttendantArtefact -Type Menu -Object $AA.DefaultCallFlow.Menu -Prompts $AADefaultCallFlowMenuPrompts -MenuOptions $AADefaultCallFlowMenuOptions

          # Default Call Flow Greetings
          if ($AA.DefaultCallFlow.Greetings) {
            $AADefaultCallFlowGreetings = Merge-AutoAttendantArtefact -Type Prompt -Object $AA.DefaultCallFlow.Greetings
          }
          else {
            $AADefaultCallFlowGreetings = $null
          }

          # Default Call Flow
          $AADefaultCallFlow = Merge-AutoAttendantArtefact -Type CallFlow -Object $AA.DefaultCallFlow -Prompts $AADefaultCallFlowGreetings -Menu $AADefaultCallFlowMenu
          #endregion

          #region CallFlows
          $Operation = "Switch Detailed - Parsing CallFlows"
          $step++
          Write-Progress -Id 1 -Status "Auto Attendant '$($AA.Name)'" -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
          Write-Verbose -Message "'$($AA.Name)' - $Operation"
          $AACallFlows = @()
          foreach ($Flow in $AA.CallFlows) {
            # Call Flow Prompts
            if ($Flow.Menu.Prompts) {
              $AACallFlowMenuPrompts = Merge-AutoAttendantArtefact -Type Prompt -Object $Flow.Menu.Prompts
            }
            else {
              $AACallFlowMenuPrompts = $null
            }

            # Call Flow Menu Options
            $AACallFlowMenuOptions = Merge-AutoAttendantArtefact -Type MenuOption -Object $Flow.Menu.MenuOptions

            # Call Flow Menu
            $AACallFlowMenu = Merge-AutoAttendantArtefact -Type Menu -Object $Flow.Menu -Prompts $AACallFlowMenuPrompts -MenuOptions $AACallFlowMenuOptions

            # Call Flow Greetings
            if ($Flow.Greetings) {
              $AACallFlowGreetings = Merge-AutoAttendantArtefact -Type Prompt -Object $Flow.Greetings
            }
            else {
              $AACallFlowGreetings = $null
            }

            # Call Flow
            $AACallFlows += Merge-AutoAttendantArtefact -Type CallFlow -Object $Flow -Prompts $AACallFlowGreetings -Menu $AACallFlowMenu
          }
          #endregion

          #region Schedules
          $Operation = "Switch Detailed - Parsing Schedules"
          $step++
          Write-Progress -Id 1 -Status "Auto Attendant '$($AA.Name)'" -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
          Write-Verbose -Message "'$($AA.Name)' - $Operation"
          $AASchedules = @()
          foreach ($Schedule in $AA.Schedules) {
            $AASchedule = Get-CsOnlineSchedule -Id $Schedule.Id
            $AASchedules += Merge-AutoAttendantArtefact -Type Schedule -Object $AASchedule

          }
          #endregion

          #region CallHandlingAssociations
          $Operation = "Switch Detailed - Parsing CallHandlingAssociations"
          $step++
          Write-Progress -Id 1 -Status "Auto Attendant '$($AA.Name)'" -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
          Write-Verbose -Message "'$($AA.Name)' - $Operation"
          $AACallHandlingAssociations = @()
          foreach ($item in $AA.CallHandlingAssociations) {
            # Determine Call Flow Name
            $AACallHandlingAssociationCallFlowName = ($AA.CallFlows | Where-Object Id -EQ $item.CallFlowId).Name

            # CallHandlingAssociations
            $AACallHandlingAssociations += Merge-AutoAttendantArtefact -Type CallHandlingAssociation -Object $item -CallFlowName $AACallHandlingAssociationCallFlowName
          }
          #endregion

          # Adding nested Objects
          $AAObject | Add-Member -MemberType NoteProperty -Name Operator -Value $AAOperator
          $AAObject | Add-Member -MemberType NoteProperty -Name DefaultCallFlow -Value $AADefaultCallFlow
          $AAObject | Add-Member -MemberType NoteProperty -Name CallFlows -Value $AACallFlows
          $AAObject | Add-Member -MemberType NoteProperty -Name Schedules -Value $AASchedules
          $AAObject | Add-Member -MemberType NoteProperty -Name CallHandlingAssociations -Value $AACallHandlingAssociations
        }

        # Adding Resource Accounts
        $AAObject | Add-Member -MemberType NoteProperty -Name ApplicationInstances -Value $AIObjects.UserPrincipalName
        #endregion

        # Output
        Write-Progress -Id 1 -Status "Auto Attendant '$($AA.Name)'" -Activity $MyInvocation.MyCommand -Completed
        Write-Progress -Id 0 -Status "Auto Attendant '$($AA.Name)'" -Activity $MyInvocation.MyCommand -Completed
        Write-Output $AAObject
      }

    }

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"

  } #end
} #Get-TeamsAutoAttendant