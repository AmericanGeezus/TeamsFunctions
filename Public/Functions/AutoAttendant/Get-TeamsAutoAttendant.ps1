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
    Required for ParameterSet Name. Finds all Auto Attendants with this name (unique results).
    If not provided, all Auto Attendants are queried, returning only the name
  .PARAMETER SearchString
    Required for ParameterSet Search. Searches all Auto Attendants for this string (multiple results possible).
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

  [CmdletBinding(DefaultParameterSetName = 'Name')]
  [Alias('Get-TeamsAA')]
  [OutputType([System.Object[]])]
  param(
    [Parameter(ParameterSetName = 'Name', Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = 'Full Name of the Auto Attendant')]
    [AllowNull()]
    [Alias('Identity')]
    [string[]]$Name,

    [Parameter(ParameterSetName = 'Search', HelpMessage = 'Partial or full Name of the Auto Attendant to search')]
    [Alias('NameFilter')]
    [string]$SearchString,

    [switch]$Detailed
  ) #param

  begin {
    Show-FunctionStatus -Level Live
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand.Name)"
    Write-Verbose -Message "Need help? Online:  $global:TeamsFunctionsHelpURLBase$($MyInvocation.MyCommand.Name)`.md"
    # Asserting AzureAD Connection
    if ( -not $script:TFPSSA) { $script:TFPSSA = Assert-AzureADConnection; if ( -not $script:TFPSSA ) { break } }

    # Asserting MicrosoftTeams Connection
    if ( -not $script:TFPSST) { $script:TFPSST = Assert-MicrosoftTeamsConnection; if ( -not $script:TFPSST ) { break } }

    # Setting Preference Variables according to Upstream settings
    if (-not $PSBoundParameters.ContainsKey('Verbose')) { $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference') }
    if (-not $PSBoundParameters.ContainsKey('Confirm')) { $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference') }
    if (-not $PSBoundParameters.ContainsKey('WhatIf')) { $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference') }
    if (-not $PSBoundParameters.ContainsKey('Debug')) { $DebugPreference = $PSCmdlet.SessionState.PSVariable.GetValue('DebugPreference') } else { $DebugPreference = 'Continue' }
    if ( $PSBoundParameters.ContainsKey('InformationAction')) { $InformationPreference = $PSCmdlet.SessionState.PSVariable.GetValue('InformationAction') } else { $InformationPreference = 'Continue' }

    #Initialising Counters
    $private:StepsID0, $private:StepsID1 = Get-WriteBetterProgressSteps -Code $($MyInvocation.MyCommand.Definition) -MaxId 1
    $private:ActivityID0 = $($MyInvocation.MyCommand.Name)
    [int] $private:CountID0 = [int] $private:CountID1 = 1

    if ($PSBoundParameters.ContainsKey('Detailed')) {
      Write-Verbose -Message "Parameter 'Detailed' - This may take a bit of time..." -Verbose
    }
  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    [int] $private:CountID0 = [int] $private:CountID1 = 1

    $StatusID0 = 'Information Gathering'
    #region Data gathering
    $CurrentOperationID0 = 'Querying Auto Attendants'
    Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
    # Capturing no input
    if (-not $PSBoundParameters.ContainsKey('Name') -and -not $PSBoundParameters.ContainsKey('SearchString') ) {
      Write-Information 'No Parameters - Listing names only. To query individual items, please provide Parameter Name or SearchString'
      Get-CsAutoAttendant -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | Select-Object Name
      return
    }
    else {
      $AutoAttendants = @()
      switch ($PSCmdlet.ParameterSetName) {
        'Name' {
          # Lookup
          Write-Verbose -Message "Parameter 'Name' - Querying unique result for each provided Name"
          foreach ($DN in $Name) {
            if ( $DN -match '^[0-9a-f]{8}-([0-9a-f]{4}\-){3}[0-9a-f]{12}$' ) {
              #Identity or ObjectId
              #NOTE MicrosoftTeams v2.3.1 - DO NOT use `-IncludeStatus` with Identity, it generates an error ParameterBindingException
              Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand.Name) - ID - '$DN'"
              $AAByName = Get-CsAutoAttendant -Identity "$DN" -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
              $AutoAttendants += $AAByName
            }
            else {
              #Name
              Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand.Name) - Name - '$DN'"
              #$AAByName = Get-CsAutoAttendant -NameFilter "$DN" -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
              $AAByName = Get-CsAutoAttendant -NameFilter "$DN" -IncludeStatus -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
              $AAByName = $AAByName | Where-Object Name -EQ "$DN"
              $AutoAttendants += $AAByName
            }
          }
        }
        'Search' {
          # Search
          Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand.Name) - SearchString - '$SearchString'"
          #$AAbyName = Get-CsAutoAttendant -NameFilter "$SearchString" -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
          $AAbyName = Get-CsAutoAttendant -NameFilter "$SearchString" -IncludeStatus -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
          $AutoAttendants += $AAByName
        }
      }
    }
    #endregion

    # Parsing found Objects
    Write-Verbose -Message "[PROCESS] Processing found Auto Attendants: $($AutoAttendants.Count)"
    #IMPROVE Explore Workflows with Parallel parsing:
    #foreach -parallel ($AA in $AutoAttendants) {
    foreach ($AA in $AutoAttendants) {
      # Initialising counters for Progress bars
      [int] $private:CountID0 = 1
      $ActivityID0 = "'$($AA.Name)'"

      # Initialising Arrays
      [System.Collections.ArrayList]$AIObjects = @()

      $StatusID0 = 'Parsing'
      #region Finding Operator
      $CurrentOperationID0 = 'Operator'
      Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
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
          Write-Warning -Message "$ActivityID0 $StatusID0 $CurrentOperationID0`: Not enumerated: $($_.Exception.Message)"
        }
      }
      # Output: $Operator, $OperatorTranscription
      #endregion

      #region Application Instance UPNs
      $CurrentOperationID0 = 'Application Instances'
      Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
      foreach ($AI in $AA.ApplicationInstances) {
        $AIObject = $null
        $AIObject = Get-CsOnlineApplicationInstance -WarningAction SilentlyContinue | Where-Object { $_.ObjectId -eq $AI } | Select-Object UserPrincipalName, DisplayName, PhoneNumber
        if ($null -ne $AIObject) {
          [void]$AIObjects.Add($AIObject)
        }
      }
      # Output: $AIObjects.UserPrincipalName

      #region Inclusion & Exclusion Scope Groups
      $CurrentOperationID0 = 'Inclusion Scope Groups'
      Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
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
      $CurrentOperationID0 = 'Exclusion Scope Groups'
      Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
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
      $StatusID0 = 'Processing'
      $CurrentOperationID0 = 'Constructing Output Object'
      Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
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
        $StatusID0 = 'Switch Detailed (Nested Objects)'
        #region Operator
        $CurrentOperationID0 = 'Operator'
        Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
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
        $CurrentOperationID0 = 'DefaultCallFlow'
        Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
        Write-Debug -Message "$ActivityID0 - $StatusID0 - $CurrentOperationID0`: Prompts"
        #Write-Debug -Message "'$($AA.Name)' - $Operation - Prompts"
        if ( $AA.DefaultCallFlow.Menu.Prompts ) {
          $AADefaultCallFlowMenuPrompts = Merge-AutoAttendantArtefact -Type Prompt -Object $AA.DefaultCallFlow.Menu.Prompts
        }
        else {
          $AADefaultCallFlowMenuPrompts = ''
        }

        # Default Call Flow Menu Options
        Write-Debug -Message "$ActivityID0 - $StatusID0 - $CurrentOperationID0`: MenuOptions"
        #Write-Debug -Message "'$($AA.Name)' - $Operation - MenuOptions"
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
        Write-Debug -Message "$ActivityID0 - $StatusID0 - $CurrentOperationID0`: Menu"
        #Write-Debug -Message "'$($AA.Name)' - $Operation - Menu"
        $AADefaultCallFlowMenu = Merge-AutoAttendantArtefact -Type Menu -Object $AA.DefaultCallFlow.Menu -Prompts $AADefaultCallFlowMenuPrompts -MenuOptions $AADefaultCallFlowMenuOptions

        # Default Call Flow Greetings
        if ($AA.DefaultCallFlow.Greetings) {
          $AADefaultCallFlowGreetings = Merge-AutoAttendantArtefact -Type Prompt -Object $AA.DefaultCallFlow.Greetings
        }
        else {
          $AADefaultCallFlowGreetings = ''
        }

        # Default Call Flow
        Write-Debug -Message "$ActivityID0 - $StatusID0 - $CurrentOperationID0`: Call Flow"
        #Write-Debug -Message "'$($AA.Name)' - $Operation - Call Flow"
        $AADefaultCallFlow = Merge-AutoAttendantArtefact -Type CallFlow -Object $AA.DefaultCallFlow -Prompts $AADefaultCallFlowGreetings -Menu $AADefaultCallFlowMenu
        #endregion

        #region CallFlows
        $CurrentOperationID0 = 'CallFlows'
        Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
        $AACallFlows = @()
        foreach ($Flow in $AA.CallFlows) {
          # Call Flow Prompts
          $AACallFlowMenuPrompts = $null
          Write-Debug -Message "$ActivityID0 - $StatusID0 - $CurrentOperationID0`: '$($Flow.Name)' - Prompts"
          #Write-Debug -Message "'$($AA.Name)' - $Operation - $($Flow.Name) - Prompts"
          if ($Flow.Menu.Prompts) {
            $AACallFlowMenuPrompts = Merge-AutoAttendantArtefact -Type Prompt -Object $Flow.Menu.Prompts
          }
          else {
            $AACallFlowMenuPrompts = ''
          }

          # Call Flow Menu Options
          $AACallFlowMenuOptionPrompt = $null
          $AACallFlowMenuOptions = $null
          Write-Debug -Message "$ActivityID0 - $StatusID0 - $CurrentOperationID0`: '$($Flow.Name)' - MenuOptions"
          #Write-Debug -Message "'$($AA.Name)' - $Operation - $($Flow.Name) - MenuOptions"
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
          Write-Debug -Message "$ActivityID0 - $StatusID0 - $CurrentOperationID0`: '$($Flow.Name)' - Menu"
          #Write-Debug -Message "'$($AA.Name)' - $Operation - $($Flow.Name) - Menu"
          $AACallFlowMenu = $null
          $AACallFlowMenu = Merge-AutoAttendantArtefact -Type Menu -Object $Flow.Menu -Prompts $AACallFlowMenuPrompts -MenuOptions $AACallFlowMenuOptions

          # Call Flow Greetings
          $AACallFlowGreetings = $null
          Write-Debug -Message "$ActivityID0 - $StatusID0 - $CurrentOperationID0`: '$($Flow.Name)' - Greetings"
          #Write-Debug -Message "'$($AA.Name)' - $Operation - $($Flow.Name) - Greetings"
          if ($Flow.Greetings) {
            $AACallFlowGreetings = Merge-AutoAttendantArtefact -Type Prompt -Object $Flow.Greetings
          }
          else {
            $AACallFlowGreetings = ''
          }

          # Call Flow
          Write-Debug -Message "$ActivityID0 - $StatusID0 - $CurrentOperationID0`: '$($Flow.Name)' - Call Flow"
          #Write-Debug -Message "'$($AA.Name)' - $Operation - $($Flow.Name) - Call Flow"
          $AACallFlows += Merge-AutoAttendantArtefact -Type CallFlow -Object $Flow -Prompts $AACallFlowGreetings -Menu $AACallFlowMenu
        }
        #endregion

        #region Schedules
        $CurrentOperationID0 = 'Schedules'
        Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
        $AASchedules = @()
        foreach ($Schedule in $AA.Schedules) {
          $AASchedule = Get-CsOnlineSchedule -Id $Schedule.Id
          $AASchedules += Merge-AutoAttendantArtefact -Type Schedule -Object $AASchedule
        }
        #endregion

        #region CallHandlingAssociations
        $CurrentOperationID0 = 'CallHandlingAssociations'
        Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
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
      Write-Progress -Id 1 -Activity $ActivityID0 -Completed
      Write-Progress -Id 0 -Activity $ActivityID0 -Completed
      Write-Output $AAObject
    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand.Name)"

  } #end
} #Get-TeamsAutoAttendant