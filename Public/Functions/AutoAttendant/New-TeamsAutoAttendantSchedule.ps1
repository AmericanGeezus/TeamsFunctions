# Module:   TeamsFunctions
# Function: AutoAttendant
# Author:		David Eberhardt
# Updated:  01-OCT-2020
# Status:   BETA

function New-TeamsAutoAttendantSchedule {
  <#
  .SYNOPSIS
    Creates a Schedule to be used in Auto Attendants
  .DESCRIPTION
    Wrapper for New-CsOnlineSchedule to simplify creation of Schedules with repeating patterns
    Incorporates New-CsOnlineTimeRange with examples
  .PARAMETER Name
    Provides a friendly Name to the Schedule (visible in the Auto Attendant Object)
  .PARAMETER WeeklyRecurrentSchedule
    Defines a schedule that is recurring weekly with Business Hours for every day of the week.
    This is suitable for an After Hours in an Auto Attendant. New-TeamsAutoAttendant will utilise a Default Schedule
    For simplicity, this command assumes the same hours of operation for each day that the business is open.
    For a more granular approach, aim for a "best match", then amend the schedule afterwards in the Admin Center
    If desired via PowerShell, please use New-CsOnlineTimeRange and New-CsOnlineSchedule respectively.
  .PARAMETER Fixed
    Defines a fixed schedule, suitable for Holiday Sets
  .PARAMETER BusinessDays
    Days defined as Business days. Will be combined with BusinessHours to form a WeeklyReccurrentSchedule
  .PARAMETER BusinessHours
    Predefined business hours. These will be combined with BusinessDays, forms the WeeklyRecurrentSchedule
  .PARAMETER DateTimeRanges
    Object or Objects defined with New-CsOnlineTimeRange
    Allows for more granular options then the provided BusinessHours examples or to provide Dates for Fixed
  .PARAMETER Complement
    The Complement parameter indicates how the schedule is used.
    When Complement is enabled, the schedule is used as the inverse of the provided configuration
    For example, if Complement is enabled and the schedule only contains time ranges of Monday to Friday from 9AM to 5PM,
    then the schedule is active at all times other than the specified time ranges.
  .EXAMPLE
    New-TeamsAutoAttendantSchedule -WeeklyRecurrentSchedule -BusinessDays MonToFri -BusinesHours 9to5
    Creates a weekly recurring schedule for business hours Monday to Friday from 9am to 5pm
  .EXAMPLE
    New-TeamsAutoAttendantSchedule -WeeklyRecurrentSchedule -BusinessDays SunToThu -DateTimeRange @($TR1, $TR2)
    Creates a weekly recurring schedule for business hours Sunday to Thursday with custom TimeRange(s) provided with the Objects $TR1 and $TR2
  .EXAMPLE
    New-TeamsAutoAttendantSchedule -Fixed -DateTimeRange @($TR1, $TR2)
    Adds a fixed schedule for the TimeRange(s) provided with the Objects $TR1 and $TR2
  .NOTES
    Combinations of BusinesHours and BusinessDays are numerous but not exhaustive.
    For example, all Business days will receive the same Business hours. For more granular options,
    please define TimeRange manually and use the Switch -DateTimeRange to provide the Object instead.
  .INPUTS
    System.String, System.Object
  .OUTPUTS
    System.Object
  .COMPONENT
    TeamsAutoAttendant
  #>

  [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low', DefaultParameterSetName = 'WeeklyBusinessHours')]
  [Alias('New-TeamsAASchedule')]
  [OutputType([System.Object])]
  param(
    [Parameter(Mandatory)]
    [string]$Name,

    [Parameter(Mandatory, ParameterSetName = 'WeeklyBusinessHours')]
    [Parameter(Mandatory, ParameterSetName = 'WeeklyTimeRange')]
    [switch]$WeeklyRecurrentSchedule,

    [Parameter(Mandatory, ParameterSetName = 'FixedTimeRange')]
    [switch]$Fixed,

    [Parameter(Mandatory, ParameterSetName = 'WeeklyBusinessHours')]
    [Parameter(Mandatory, ParameterSetName = 'WeeklyTimeRange')]
    [ValidateSet('MonToFri', 'MonToSat', 'MonToSun', 'SunToThu')]
    [string]$BusinessDays,

    [Parameter(Mandatory, ParameterSetName = 'WeeklyBusinessHours')]
    [ValidateSet('9to6', '9to5', '9to4', '8to6', '8to5', '8to4', '7to6', '7to5', '7to4', '6to6', '10to6', '0830to1700', '0830to1730', '0800to1730', '0830to1800', '0900to1730', '0930to1730', '0930to1800', '8to12and13to17', '8to12and13to18', '9to12and13to17', '9to12and13to18', '9to13and14to18', '8to12and14to18')]
    [string]$BusinessHours,

    [Parameter(Mandatory, ParameterSetName = 'WeeklyTimeRange')]
    [Parameter(Mandatory, ParameterSetName = 'FixedTimeRange')]
    [system.Object[]]$DateTimeRanges,

    [Parameter(ParameterSetName = 'WeeklyBusinessHours')]
    [Parameter(ParameterSetName = 'WeeklyTimeRange')]
    [switch]$Complement
  ) #param

  begin {
    # Caveat - Script in Development
    $VerbosePreference = "Continue"
    $DebugPreference = "Continue"
    Show-FunctionStatus -Level BETA
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.Mycommand)"

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

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.Mycommand)"

    #region Prep
    # Initialising Splatting Object
    $CsOnlineScheduleParams = @{}

    # Adding generic parameters
    $CsOnlineScheduleParams.Name = $Name
    #$CsOnlineScheduleParams.ErrorAction' = $Stop }

    if ($Complement) {
      Write-Verbose -Message "[PROCESS] Processing Complement"
      $CsOnlineScheduleParams.Complement = $true
    }
    #endregion

    #region Defining recurrance Fixed/Weekly
    if ($PSBoundParameters.ContainsKey('WeeklyRecurrentSchedule')) {
      Write-Verbose -Message "[PROCESS] Processing WeeklyRecurrentSchedule"
      $CsOnlineScheduleParams.WeeklyRecurrentSchedule = $true
    }
    elseif ($PSBoundParameters.ContainsKey('Fixed')) {
      Write-Verbose -Message "[PROCESS] Processing Fixed"
      $CsOnlineScheduleParams.Fixed = $true
    }
    #endregion

    #region Defining $TimeFrame
    if ($PSBoundParameters.ContainsKey('DateTimeRanges')) {
      Write-Verbose -Message "[PROCESS] Processing DateTimeRanges"
      Write-Verbose -Message "Please note, the DateTimeRanges provided are not validated, just passed on to New-CsOnlineSchedule as is. Handle with care" -Verbose
      $TimeFrame = @($DateTimeRanges)
    }
    else {
      Write-Verbose -Message "[PROCESS] Processing BusinessHours '$BusinessHours'"
      switch ($BusinessHours) {
        # Defining time of Day ($TimeFrame)
        '9to6' { $TimeFrame = New-CsOnlineTimeRange -Start 09:00 -End 18:00 }
        '9to5' { $TimeFrame = New-CsOnlineTimeRange -Start 09:00 -End 17:00 }
        '9to4' { $TimeFrame = New-CsOnlineTimeRange -Start 09:00 -End 16:00 }
        '8to6' { $TimeFrame = New-CsOnlineTimeRange -Start 08:00 -End 18:00 }
        '8to5' { $TimeFrame = New-CsOnlineTimeRange -Start 08:00 -End 17:00 }
        '8to4' { $TimeFrame = New-CsOnlineTimeRange -Start 08:00 -End 16:00 }
        '7to6' { $TimeFrame = New-CsOnlineTimeRange -Start 07:00 -End 18:00 }
        '7to5' { $TimeFrame = New-CsOnlineTimeRange -Start 07:00 -End 17:00 }
        '7to4' { $TimeFrame = New-CsOnlineTimeRange -Start 07:00 -End 16:00 }
        '6to6' { $TimeFrame = New-CsOnlineTimeRange -Start 06:00 -End 18:00 }
        '10to6' { $TimeFrame = New-CsOnlineTimeRange -Start 10:00 -End 18:00 }
        '0800to1730' { $TimeFrame = New-CsOnlineTimeRange -Start 09:00 -End 17:00 }
        '0830to1700' { $TimeFrame = New-CsOnlineTimeRange -Start 09:00 -End 17:00 }
        '0830to1730' { $TimeFrame = New-CsOnlineTimeRange -Start 09:00 -End 17:00 }
        '0830to1800' { $TimeFrame = New-CsOnlineTimeRange -Start 09:00 -End 17:00 }
        '0900to1730' { $TimeFrame = New-CsOnlineTimeRange -Start 09:00 -End 17:30 }
        '0930to1730' { $TimeFrame = New-CsOnlineTimeRange -Start 09:30 -End 17:30 }
        '0930to1800' { $TimeFrame = New-CsOnlineTimeRange -Start 09:30 -End 18:00 }
        '8to12and13to17' {
          $Range1 = New-CsOnlineTimeRange -Start 08:00 -End 12:00
          $Range2 = New-CsOnlineTimeRange -Start 13:00 -End 17:00
          $TimeFrame = @($Range1, $Range2)
        }
        '8to12and13to18' {
          $Range1 = New-CsOnlineTimeRange -Start 08:00 -End 12:00
          $Range2 = New-CsOnlineTimeRange -Start 13:00 -End 18:00
          $TimeFrame = @($Range1, $Range2)
        }
        '9to12and13to17' {
          $Range1 = New-CsOnlineTimeRange -Start 09:00 -End 12:00
          $Range2 = New-CsOnlineTimeRange -Start 13:00 -End 17:00
          $TimeFrame = @($Range1, $Range2)
        }
        '9to12and13to18' {
          $Range1 = New-CsOnlineTimeRange -Start 09:00 -End 12:00
          $Range2 = New-CsOnlineTimeRange -Start 13:00 -End 18:00
          $TimeFrame = @($Range1, $Range2)
        }
        '9to13and14to18' {
          $Range1 = New-CsOnlineTimeRange -Start 09:00 -End 13:00
          $Range2 = New-CsOnlineTimeRange -Start 14:00 -End 17:00
          $TimeFrame = @($Range1, $Range2)
        }
        '8to12and14to18' {
          $Range1 = New-CsOnlineTimeRange -Start 08:00 -End 12:00
          $Range2 = New-CsOnlineTimeRange -Start 14:00 -End 18:00
          $TimeFrame = @($Range1, $Range2)
        }
        default { $TimeFrame = @($(New-CsOnlineTimeRange -Start 09:00 -End 17:00)) }
      }
    }
    #endregion

    #region Defining $BusinessDays
    # Then Using $TimeFrame to define full Schedule for $BusinessDays
    if ($BusinessDays) {
      Write-Verbose -Message "[PROCESS] Processing BusinessDays '$BusinessDays"
      switch ($BusinessDays) {
        'MonToFri' {
          $CsOnlineScheduleParams.MondayHours = @($TimeFrame)
          $CsOnlineScheduleParams.TuesdayHours = @($TimeFrame)
          $CsOnlineScheduleParams.WednesdayHours = @($TimeFrame)
          $CsOnlineScheduleParams.ThursdayHours = @($TimeFrame)
          $CsOnlineScheduleParams.FridayHours = @($TimeFrame)
        }
        'MonToSat' {
          $CsOnlineScheduleParams.MondayHours = @($TimeFrame)
          $CsOnlineScheduleParams.TuesdayHours = @($TimeFrame)
          $CsOnlineScheduleParams.WednesdayHours = @($TimeFrame)
          $CsOnlineScheduleParams.ThursdayHours = @($TimeFrame)
          $CsOnlineScheduleParams.FridayHours = @($TimeFrame)
          $CsOnlineScheduleParams.SaturdayHours = @($TimeFrame)
        }
        'MonToSun' {
          $CsOnlineScheduleParams.MondayHours = @($TimeFrame)
          $CsOnlineScheduleParams.TuesdayHours = @($TimeFrame)
          $CsOnlineScheduleParams.WednesdayHours = @($TimeFrame)
          $CsOnlineScheduleParams.ThursdayHours = @($TimeFrame)
          $CsOnlineScheduleParams.FridayHours = @($TimeFrame)
          $CsOnlineScheduleParams.SaturdayHours = @($TimeFrame)
          $CsOnlineScheduleParams.SundayHours = @($TimeFrame)
        }
        'SunToThu' {
          $CsOnlineScheduleParams.SundayHours = @($TimeFrame)
          $CsOnlineScheduleParams.MondayHours = @($TimeFrame)
          $CsOnlineScheduleParams.TuesdayHours = @($TimeFrame)
          $CsOnlineScheduleParams.WednesdayHours = @($TimeFrame)
          $CsOnlineScheduleParams.ThursdayHours = @($TimeFrame)
        }
        default {
          $CsOnlineScheduleParams.MondayHours = @($TimeFrame)
          $CsOnlineScheduleParams.TuesdayHours = @($TimeFrame)
          $CsOnlineScheduleParams.WednesdayHours = @($TimeFrame)
          $CsOnlineScheduleParams.ThursdayHours = @($TimeFrame)
          $CsOnlineScheduleParams.FridayHours = @($TimeFrame)
        }
      }
    }
    #endregion


    #region Creating Schedule
    Write-Verbose -Message "[PROCESS] Creating Schedule"
    try {
      if ($PSCmdlet.ShouldProcess("$Name", "New-CsOnlineSchedule")) {
        $ScheduleObject = New-CsOnlineSchedule @CsOnlineScheduleParams
      }

      # Output
      return $ScheduleObject
    }
    catch {
      throw $($_.Exception.Message)
    }
    #endregion

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.Mycommand)"
  } #end
} #New-TeamsAutoAttendantSchedule
