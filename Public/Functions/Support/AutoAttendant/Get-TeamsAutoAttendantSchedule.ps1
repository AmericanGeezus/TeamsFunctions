
# Module:   TeamsFunctions
# Function: AutoAttendant
# Author:   David Eberhardt
# Updated:  13-JUN-2021
# Status:   Live



function Get-TeamsAutoAttendantSchedule {
  <#
  .SYNOPSIS
    Returns Teams Schedule Objects by Id or Name and/or Association
  .DESCRIPTION
    Queries the Nager.Date API for public Holidays for Country and year and creates a CsOnlineSchedule object for each.
  .PARAMETER Id
    Id of the Schedule Object
  .PARAMETER Name
    String to search for (partial or full match)
  .PARAMETER AssociatedOnly
    Optional. Considers only associated Schedules
  .PARAMETER UnAssociatedOnly
    Optional. Considers only unassociated Schedules
  .PARAMETER ParseAutoAttendants
    Optional. Resolves Auto Attendant Names
  .EXAMPLE
    Get-TeamsAutoAttendantSchedule -Id abcd1234-5678-efg9-0123-4567890abcd
    Returns the Schedules with the Id  abcd1234-5678-efg9-0123-4567890abcd - Same behaviour as Get-CsOnlineSchedule
  .EXAMPLE
    Get-TeamsAutoAttendantSchedule -Name "CAN","MEX"
    Returns all Schedules with "CAN" or "MEX" in the Name
  .EXAMPLE
    Get-TeamsAutoAttendantSchedule -Name "Canada 202*"
    Returns all Schedules with the String "Canada 202" in the name (like)
  .EXAMPLE
    Get-TeamsAutoAttendantSchedule -Name "Canada 202*" -UnassociatedOnly
    Returns all Schedules with the String "Canada 202" in the name (like) that are not associated to any Auto Attendant Call Flow
  .EXAMPLE
    Get-TeamsAutoAttendantSchedule -Name "Canada 202*" -AssociatedOnly
    Returns all Schedules with the String "Canada 202" in the name (like) that are associated to any Auto Attendant Call Flow
  .EXAMPLE
    Get-TeamsAutoAttendantSchedule -UnassociatedOnly
    Returns all Schedules that are not associated to any Auto Attendant Call Flow
  .INPUTS
    System.String
  .OUTPUTS
    System.Object
  .NOTES
    Schedule Object can be queried by Name or Id (partent CmdLet). Additionally filtered by Association
  .COMPONENT
    SupportingFunction
    TeamsAutoAttendant
  .FUNCTIONALITY
    Queries Online Schedules in the tenant by Name or Id and optionally filters on Association
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-TeamsAutoAttendantSchedule.md
  .LINK
    about_SupportingFunction
  .LINK
    about_TeamsAutoAttendant
  .LINK
    Get-TeamsAutoAttendantSchedule
  .LINK
    New-TeamsAutoAttendantSchedule
  .LINK
    New-TeamsHolidaySchedule
  .LINK
    New-TeamsAutoAttendant
  .LINK
    Set-TeamsAutoAttendant
  .LINK
    Get-PublicHolidayList
  .LINK
    Get-PublicHolidayCountry
  #>

  [CmdletBinding(ConfirmImpact = 'Low')]
  [Alias('Get-TeamsAASchedule')]
  [OutputType([PSCustomObject])]
  param (
    [Parameter(ValueFromPipeline, ParameterSetName = 'Identity', HelpMessage = 'Guid of the Object')]
    [String]$Id,

    [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'Search', HelpMessage = 'Name of the Schedule Object')]
    [Parameter(ValueFromPipeline, ParameterSetName = 'AssociatedOnly', HelpMessage = 'Name of the Schedule Object')]
    [Parameter(ValueFromPipeline, ParameterSetName = 'UnAssociatedOnly', HelpMessage = 'Name of the Schedule Object')]
    [String]$Name,

    [Parameter(Mandatory, ParameterSetName = 'AssociatedOnly', HelpMessage = 'Returns only Objects used in an Auto Attendant')]
    [Alias('Assigned', 'InUse')]
    [switch]$AssociatedOnly,

    [Parameter(Mandatory, ParameterSetName = 'UnAssociatedOnly', HelpMessage = 'Returns only Objects not used in an Auto Attendant')]
    [Alias('Unassigned', 'Free')]
    [switch]$UnAssociatedOnly,

    [Parameter(ParameterSetName = 'Identity', HelpMessage = 'Returns Auto Attendant Names if used in an Auto Attendant')]
    [Parameter(ParameterSetName = 'Search', HelpMessage = 'Returns Auto Attendant Names if used in an Auto Attendant')]
    [Parameter(ParameterSetName = 'AssociatedOnly', HelpMessage = 'Returns Auto Attendant Names if used in an Auto Attendant')]
    [switch]$ParseAutoAttendants
  )

  begin {
    Show-FunctionStatus -Level Live
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"
    Write-Verbose -Message "Need help? Online:  $global:TeamsFunctionsHelpURLBase$($MyInvocation.MyCommand)`.md"

    # Asserting AzureAD Connection
    if (-not (Assert-AzureADConnection)) { break }

    # Asserting MicrosoftTeams Connection
    if (-not (Assert-MicrosoftTeamsConnection)) { break }

    # Setting Preference Variables according to Upstream settings
    if (-not $PSBoundParameters.ContainsKey('Verbose')) { $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference') }
    if (-not $PSBoundParameters.ContainsKey('Confirm')) { $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference') }
    if (-not $PSBoundParameters.ContainsKey('WhatIf')) { $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference') }
    if (-not $PSBoundParameters.ContainsKey('Debug')) { $DebugPreference = $PSCmdlet.SessionState.PSVariable.GetValue('DebugPreference') } else { $DebugPreference = 'Continue' }
    if ( $PSBoundParameters.ContainsKey('InformationAction')) { $InformationPreference = $PSCmdlet.SessionState.PSVariable.GetValue('InformationAction') } else { $InformationPreference = 'Continue' }

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    $Schedules = $null

    #region Data gathering
    if ($PSBoundParameters.ContainsKey('Id')) {
      Write-Verbose -Message "$($MyInvocation.MyCommand) - Lookup by Id"
      $Schedules = Get-CsOnlineSchedule -Id $Id
    }
    elseif ($PSBoundParameters.ContainsKey('AssociatedOnly')) {
      Write-Verbose -Message "$($MyInvocation.MyCommand) - Searching for ASSOCIATED Schedules"
      $Schedules = Get-CsOnlineSchedule | Where-Object DisplayAssociatedConfigurationIds -NE ''
    }
    elseif ($PSBoundParameters.ContainsKey('UnAssociatedOnly')) {
      Write-Verbose -Message "$($MyInvocation.MyCommand) - Searching for UNASSOCIATED Schedules"
      $Schedules = Get-CsOnlineSchedule | Where-Object DisplayAssociatedConfigurationIds -EQ ''
    }
    else {
      Write-Verbose -Message "$($MyInvocation.MyCommand) - Running Get-CsOnlineSchedule"
      $Schedules = Get-CsOnlineSchedule
    }

    #Filtering on Name
    if ($PSBoundParameters.ContainsKey('Name')) {
      Write-Verbose -Message "$($MyInvocation.MyCommand) - Filtering Schedules with '$Name' in the name"
      $Schedules = $Schedules | Where-Object Name -Like "*$Name*"
    }

    # Parsing Associated Auto Attendants where appropriate
    if ($ParseAutoAttendants) {
      if (-not $UnAssociatedOnly) {
        Write-Information "$($MyInvocation.MyCommand) - Parsing Associated Auto Attendants. This will take some time for bigger datasets..."
      }
      foreach ($S in $Schedules) {
        Write-Verbose -Message "[FOREACH] $($MyInvocation.MyCommand) - Schedule '$($S.Name)'"
        if ($ParseAutoAttendants -and $S.DisplayAssociatedConfigurationIds -NE '') {
          [System.Collections.ArrayList]$AssociatedAAs = @()
          foreach ($Id in $S.AssociatedConfigurationIds) {
            Write-Debug -Message "[FOREACH] $($MyInvocation.MyCommand) - Schedule '$($S.Name)' - Parsing '$Id'"
            $AA = Get-CsAutoAttendant -Identity "$Id" -WarningAction SilentlyContinue
            [void]$AssociatedAAs.Add($AA.Name)
          }

          # creating new PS Object (synchronous with Get and Set)
          $ScheduleObject = [PSCustomObject][ordered]@{
            Id                       = $S.Id
            Name                     = $S.Name
            Type                     = $S.Type
            WeeklyRecurrentSchedule  = $S.DisplayWeeklyRecurrentSchedule
            FixedSchedule            = $S.DisplayFixedSchedule
            AssociatedAutoAttendants = $AssociatedAAs
          }
          Write-Output $ScheduleObject
        }
      }
    }
    else {
      Write-Output $Schedules
    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Get-TeamsAutoAttendantSchedule
