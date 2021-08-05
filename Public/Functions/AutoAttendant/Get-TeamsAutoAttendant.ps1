# Module:   TeamsFunctions
# Function: AutoAttendant
# Author:   David Eberhardt
# Updated:  01-JAN-2021
# Status:   Live


#IMPROVE Unknown what DialByNameResourceId is or does (GUID, denoting what object exactly? - how to test/query/translate?)

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
    Returns an Object for every Auto Attendant found with the exact Name "My AutoAttendant"
  .EXAMPLE
    Get-TeamsAutoAttendant -Name "My AutoAttendant" -Detailed
    Returns an Object for every Auto Attendant found with the exact Name "My AutoAttendant"
    Detailed view will display all nested Objects indented as a tree
  .EXAMPLE
    Get-TeamsAutoAttendant -Name "My AutoAttendant" -SearchString "My AutoAttendant"
    Returns an Object for every Auto Attendant found with the exact Name "My AutoAttendant" and
    Returns an Object for every Auto Attendant matching the String "My AutoAttendant"
  .EXAMPLE
    Get-TeamsAutoAttendant -SearchString "My AutoAttendant"
    Returns an Object for every Auto Attendant matching the String "My AutoAttendant"
    Synonymous with Get-CsAutoAttendant -NameFilter "My AutoAttendant", but output shown differently.
  .INPUTS
    System.String
  .OUTPUTS
    System.Object
  .NOTES
    Without any parameters, Get-TeamsAutoAttendant will show names only.
    Operator and Resource Accounts, etc. are displayed with friendly name.
    Main difference to Get-CsAutoAttendant (apart from the friendly names) is how the Objects are shown.
    The connected Objects DefaultCallFlow, CallFlows, Schedules, CallHandlingAssociations and DirectoryLookups
    are all shown with Name only, but can be queried with .<ObjectName>
    This also works with Get-CsAutoAttendant, but with the help of "Display" Parameters.
  .COMPONENT
    TeamsAutoAttendant
  .FUNCTIONALITY
    Get-CsAutoAttendant with friendly names instead of GUID-strings for connected objects
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-TeamsAutoAttendant.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsAutoAttendant.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
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

    if ($PSBoundParameters.ContainsKey('Detailed')) {
      Write-Verbose -Message "Parameter 'Detailed' - This may take a bit of time..." -Verbose
    }
  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    # Capturing no input
    if (-not $PSBoundParameters.ContainsKey('Name') -and -not $PSBoundParameters.ContainsKey('SearchString')) {
      Write-Information 'No Parameters - Listing names only. To query individual items, please provide Parameter Name or SearchString'
      Get-CsAutoAttendant -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | Select-Object Name
      return
    }
    else {
      #region Query objects
      $AutoAttendants = @()
      if ($PSBoundParameters.ContainsKey('Name')) {
        # Lookup
        Write-Verbose -Message "Parameter 'Name' - Querying unique result for each provided Name"
        foreach ($DN in $Name) {
          if ( $DN -match '^[0-9a-f]{8}-([0-9a-f]{4}\-){3}[0-9a-f]{12}$' ) {
            #Identity or ObjectId
            Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand) - ID - '$DN'"
            $AAById = Get-CsAutoAttendant -Identity "$DN" -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
            $AutoAttendants += $AAById
          }
          else {
            #Name
            Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand) - Name - '$DN'"
            $AAByName = Get-CsAutoAttendant -NameFilter "$DN" -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
            $AAByName = $AAByName | Where-Object Name -EQ "$DN"
            $AutoAttendants += $AAByName
          }
        }
      }

      if ($PSBoundParameters.ContainsKey('SearchString')) {
        # Search
        Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand) - SearchString - '$SearchString'"
        $AAByString = Get-CsAutoAttendant -NameFilter "$SearchString" -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
        $AutoAttendants += $AAByString
      }
      #endregion
    }

    # Parsing found Objects
    Write-Verbose -Message "[PROCESS] Processing found Auto Attendants: $AACount"
    $AACounter = 0
    [int]$AACount = $AutoAttendants.Count
    #IMPROVE Explore Workflows with Parallel parsing:
    #foreach -parallel ($AA in $AutoAttendants) {
    foreach ($AA in $AutoAttendants) {
      # Initialising counters for Progress bars
      Write-Progress -Id 0 -Status "Auto Attendant '$($AA.Name)'" -Activity $MyInvocation.MyCommand -PercentComplete ($AACounter / $AACount * 100)
      $AACounter++
      [int]$step = 0
      [int]$sMax = 5
      if ( $Detailed ) { $sMax = $sMax + 5 }

      # Initialising Arrays
      [System.Collections.ArrayList]$AIObjects = @()

      #region Finding Operator
      $Operation = 'Parsing Operator'
      Write-Progress -Id 1 -Status "Auto Attendant '$($AA.Name)'" -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message "'$($AA.Name)' - $Operation"
      if ($null -eq $AA.Operator) {
        $AAOperator = $null
      }
      else {
        # Parsing Callable Entity
        try {
          $CallableEntity = Get-TeamsCallableEntity "$($AA.Operator.Id)" -WarningAction SilentlyContinue
          $Operator = $CallableEntity.Entity
        }
        catch {
          Write-Warning -Message "'$($AA.Name)' Operator: Not enumerated: $($_.Exception.Message)"
        }
      }
      # Output: $Operator, $OperatorTranscription
      #endregion

      #region Application Instance UPNs
      $Operation = 'Parsing Application Instances'
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

      #region Inclusion & Exclusion Scope Groups
      $Operation = 'Parsing Inclusion & Exclusion Scope Groups'
      $step++
      Write-Progress -Id 1 -Status "Auto Attendant '$($AA.Name)'" -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message "'$($AA.Name)' - $Operation"
      if ($AA.DirectoryLookupScope.InclusionScope) {
        [System.Collections.ArrayList]$InclusionScopeDistributionLists = @()
        foreach ($DL in $AA.DirectoryLookupScope.InclusionScope.GroupScope.GroupIds) {
          #$DLObject = Get-UniqueAzureADGroup "$DL" -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
          $DLObject = $null
          $DLObject = Get-AzureADGroup -ObjectId "$DL" -WarningAction SilentlyContinue
          if ($DLObject) {
            [void]$InclusionScopeDistributionLists.Add($DLObject.DisplayName)
          }
        }
      }
      if ($AA.DirectoryLookupScope.ExclusionScope) {
        [System.Collections.ArrayList]$ExclusionScopeDistributionLists = @()
        foreach ($DL in $AA.DirectoryLookupScope.ExclusionScope.GroupScope.GroupIds) {
          #$DLObject = Get-UniqueAzureADGroup "$DL" -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
          $DLObject = $null
          $DLObject = Get-AzureADGroup -ObjectId "$DL" -WarningAction SilentlyContinue
          if ($DLObject) {
            [void]$ExclusionScopeDistributionLists.Add($DLObject.DisplayName)
          }
        }
      }
      # Output: $InclusionScopeDistributionLists, $ExclusionScopeDistributionLists
      #endregion


      #region Creating Output Object
      # Building custom Object with Friendly Names
      $Operation = 'Constructing Output Object'
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
        DialByNameResourceId            = $AA.DialByNameResourceId
        DirectoryLookupScope            = $AA.DirectoryLookupScope.Name
        InclusionScopeDistributionLists = $InclusionScopeDistributionLists
        ExclusionScopeDistributionLists = $ExclusionScopeDistributionLists
        GreetingsSettingAuthorizedUsers = $AA.GreetingsSettingAuthorizedUsers
      }
      #endregion

      #region Extending Output Object with Switch Detailed
      if ($PSBoundParameters.ContainsKey('Detailed')) {
        #region Operator
        $Operation = 'Switch Detailed - Parsing Operator'
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
        $Operation = 'Switch Detailed - Parsing DefaultCallFlow'
        $step++
        Write-Progress -Id 1 -Status "Auto Attendant '$($AA.Name)'" -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
        Write-Verbose -Message "'$($AA.Name)' - $Operation"
        # Default Call Flow Menu Prompts
        Write-Debug -Message "'$($AA.Name)' - $Operation - Prompts"
        if ( $AA.DefaultCallFlow.Menu.Prompts ) {
          $AADefaultCallFlowMenuPrompts = Merge-AutoAttendantArtefact -Type Prompt -Object $AA.DefaultCallFlow.Menu.Prompts
        }
        else {
          $AADefaultCallFlowMenuPrompts = ''
        }

        # Default Call Flow Menu Options
        Write-Debug -Message "'$($AA.Name)' - $Operation - MenuOptions"
        if ( $AA.DefaultCallFlow.Menu.MenuOptions ) {
          try {
            if ($AA.DefaultCallFlow.Menu.MenuOptions.Prompt) {
              # Announcements: Processing Call Flow Prompts
              Write-Debug -Message "'$($AA.Name)' - $Operation - MenuOptions - Prompt"
              $AADefaultCallFlowMenuOptionPrompt = Merge-AutoAttendantArtefact -Type Prompt -Object $AA.DefaultCallFlow.Menu.MenuOptions.Prompt
              Write-Debug -Message "'$($AA.Name)' - $Operation - MenuOptions - MenuOptions"
              $AADefaultCallFlowMenuOptions = Merge-AutoAttendantArtefact -Type MenuOption -Object $AA.DefaultCallFlow.Menu.MenuOptions -Prompts $AADefaultCallFlowMenuOptionPrompt
            }
            else {
              throw
            }
          }
          catch {
            $AADefaultCallFlowMenuOptions = Merge-AutoAttendantArtefact -Type MenuOption -Object $AA.DefaultCallFlow.Menu.MenuOptions
          }
        }
        else {
          $AADefaultCallFlowMenuOptions = ''
        }

        # Default Call Flow Menu
        Write-Debug -Message "'$($AA.Name)' - $Operation - Menu"
        $AADefaultCallFlowMenu = Merge-AutoAttendantArtefact -Type Menu -Object $AA.DefaultCallFlow.Menu -Prompts $AADefaultCallFlowMenuPrompts -MenuOptions $AADefaultCallFlowMenuOptions

        # Default Call Flow Greetings
        if ($AA.DefaultCallFlow.Greetings) {
          $AADefaultCallFlowGreetings = Merge-AutoAttendantArtefact -Type Prompt -Object $AA.DefaultCallFlow.Greetings
        }
        else {
          $AADefaultCallFlowGreetings = ''
        }

        # Default Call Flow
        Write-Debug -Message "'$($AA.Name)' - $Operation - Call Flow"
        $AADefaultCallFlow = Merge-AutoAttendantArtefact -Type CallFlow -Object $AA.DefaultCallFlow -Prompts $AADefaultCallFlowGreetings -Menu $AADefaultCallFlowMenu
        #endregion

        #region CallFlows
        $Operation = 'Switch Detailed - Parsing CallFlows'
        $step++
        Write-Progress -Id 1 -Status "Auto Attendant '$($AA.Name)'" -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
        Write-Verbose -Message "'$($AA.Name)' - $Operation"
        $AACallFlows = @()
        foreach ($Flow in $AA.CallFlows) {
          # Call Flow Prompts
          $AACallFlowMenuPrompts = $null
          Write-Debug -Message "'$($AA.Name)' - $Operation - $($Flow.Name) - Prompts"
          if ($Flow.Menu.Prompts) {
            $AACallFlowMenuPrompts = Merge-AutoAttendantArtefact -Type Prompt -Object $Flow.Menu.Prompts
          }
          else {
            $AACallFlowMenuPrompts = ''
          }

          # Call Flow Menu Options
          $AACallFlowMenuOptionPrompt = $null
          $AACallFlowMenuOptions = $null
          Write-Debug -Message "'$($AA.Name)' - $Operation - $($Flow.Name) - MenuOptions"
          if ($Flow.Menu.MenuOptions) {
            try {
              if ($Flow.Menu.MenuOptions.Prompt) {
              # Announcements: Processing Call Flow Prompts
              $AACallFlowMenuOptionPrompt = Merge-AutoAttendantArtefact -Type Prompt -Object $Flow.Menu.MenuOptions.Prompt
              $AACallFlowMenuOptions = Merge-AutoAttendantArtefact -Type MenuOption -Object $Flow.Menu.MenuOptions -Prompts $AACallFlowMenuOptionPrompt
            }
            else {
              throw
            }
          }
          catch {
              $AACallFlowMenuOptions = Merge-AutoAttendantArtefact -Type MenuOption -Object $Flow.Menu.MenuOptions
            }
          }
          else {
            $AACallFlowMenuOptions = ''
          }

          # Call Flow Menu
          Write-Debug -Message "'$($AA.Name)' - $Operation - $($Flow.Name) - Menu"
          $AACallFlowMenu = $null
          $AACallFlowMenu = Merge-AutoAttendantArtefact -Type Menu -Object $Flow.Menu -Prompts $AACallFlowMenuPrompts -MenuOptions $AACallFlowMenuOptions

          # Call Flow Greetings
          $AACallFlowGreetings = $null
          Write-Debug -Message "'$($AA.Name)' - $Operation - $($Flow.Name) - Greetings"
          if ($Flow.Greetings) {
            $AACallFlowGreetings = Merge-AutoAttendantArtefact -Type Prompt -Object $Flow.Greetings
          }
          else {
            $AACallFlowGreetings = ''
          }

          # Call Flow
          Write-Debug -Message "'$($AA.Name)' - $Operation - $($Flow.Name) - Call Flow"
          $AACallFlows += Merge-AutoAttendantArtefact -Type CallFlow -Object $Flow -Prompts $AACallFlowGreetings -Menu $AACallFlowMenu
        }
        #endregion

        #region Schedules
        $Operation = 'Switch Detailed - Parsing Schedules'
        $step++
        Write-Progress -Id 1 -Status "Auto Attendant '$($AA.Name)'" -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
        Write-Debug -Message "'$($AA.Name)' - $Operation"
        $AASchedules = @()
        foreach ($Schedule in $AA.Schedules) {
          $AASchedule = Get-CsOnlineSchedule -Id $Schedule.Id
          $AASchedules += Merge-AutoAttendantArtefact -Type Schedule -Object $AASchedule
        }
        #endregion

        #region CallHandlingAssociations
        $Operation = 'Switch Detailed - Parsing CallHandlingAssociations'
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
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"

  } #end
} #Get-TeamsAutoAttendant