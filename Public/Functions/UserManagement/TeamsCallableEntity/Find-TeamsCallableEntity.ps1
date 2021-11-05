# Module:   TeamsFunctions
# Function: CallQueue
# Author:   David Eberhardt
# Updated:  01-DEC-2020
# Status:   Live





function Find-TeamsCallableEntity {
  <#
  .SYNOPSIS
    Finds all Call Queues where a specific User is an Agent
  .DESCRIPTION
    Finding all Call Queues where a User is linked as an Agent, as an OverflowActionTarget or as a TimeoutActionTarget
  .PARAMETER Identity
    Required. Callable Entity Object to be found (Tel URI, User, Group, Resource Account)
  .PARAMETER Scope
    Optional. Limits searches to Call Queues, Auto Attendants or both (All) - Currently Hardcoded to CallQueue until development finishes
  .EXAMPLE
    Find-TeamsCallableEntity "John@domain.com" [-Scope All]
    Finds all Call Queues or Auto Attendants in which John is an Agent, OverflowTarget or TimeoutTarget, Menu Option, Operator, etc.
  .EXAMPLE
    Find-TeamsCallableEntity "MyGroup@domain.com" -Scope CallQueue
    Finds all Call Queues in which My Group is linked as an Agent Group, OverflowTarget or TimeoutTarget
  .EXAMPLE
    Find-TeamsCallableEntity "tel:+15551234567" -Scope AutoAttendant
    Finds all Auto Attendants in which the Tel URI is linked as an Operator, Menu Option, etc.
  .INPUTS
    System.String
  .OUTPUTS
    System.Object
  .NOTES
    Finding linked agents is useful if the Call Queues are in an unusable state.
    This happens if a User is unlicensed, disabled for Enterprise Voice or disabled completely
    while still being targeted as an Agent or for Overflow or Timeout.
  .COMPONENT
    UserManagement
    TeamsAutoAttendant
    TeamsCallQueue
  .FUNCTIONALITY
    Finding Call Queues and/or Auto Attendants where specific Callable Entity is attached
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Find-TeamsCallableEntity.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsAutoAttendant.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsCallQueue.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_UserManagement.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  #>

  [CmdletBinding()]
  [OutputType([System.Object[]])]
  param(
    [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = 'User Identifier')]
    [Alias('ObjectId', 'UserPrincipalName')]
    [string[]]$Identity,

    [Parameter(HelpMessage = 'Scope')]
    [ValidateSet('All', 'CallQueue', 'AutoAttendant')]
    [string]$Scope = 'All'

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

    #Initialising Counters
    $script:StepsID0, $script:StepsID1 = Get-WriteBetterProgressSteps -Code $($MyInvocation.MyCommand.Definition) -MaxId 1
    $script:ActivityID0 = $($MyInvocation.MyCommand.Name)
    [int]$script:CountID0 = [int]$script:CountID1 = 1

    #region Information Gathering 1
    $StatusID0 = 'Information Gathering'
    # Call Queues and Auto Attendants
    if ( $Scope -in ('All', 'CallQueue') ) {
      # Query Queues
      $CurrentOperationID0 = 'Querying Call Queues'
      Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($script:CountID0++) -Of $script:StepsID0
      $CQs = Get-CsCallQueue -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
      Write-Verbose -Message "$Status - $Operation -Objects found: $($CQs.Count)"
    }

    if ( $Scope -in ('All', 'AutoAttendant') ) {
      # Query Auto Attendants
      $CurrentOperationID0 = 'Querying Auto Attendants'
      Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($script:CountID0++) -Of $script:StepsID0
      $AAs = Get-CsAutoAttendant -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
      Write-Verbose -Message "$Status - $Operation - Objects found: $($AAs.Count)"
    }
    #endregion

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    [int] $script:CountID0 = 1
    [int] $script:StepsID0 = $script:CountID0 + $Identity.Count
    foreach ( $Id in $Identity) {
      [int] $script:CountID1 = 1
      $CallTarget = $null
      [System.Collections.ArrayList]$Output = @()
      $StatusID0 = 'Processing Entities'
      $CurrentOperationID0 = $ActivityID1 = "'$Id'"
      Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($script:CountID0++) -Of $script:StepsID0

      $StatusID1 = 'Querying Entity'
      #region Object
      $CurrentOperationID1 = 'Teams Callable Entity'
      Write-BetterProgress -Id 1 -Activity $ActivityID1 -Status $StatusID1 -CurrentOperation $CurrentOperationID1 -Step ($script:CountID1++) -Of $script:StepsID1
      try {
        $CallTarget = Get-TeamsCallableEntity -Identity "$Id"
        if ( -not $CallTarget ) {
          Write-Error -Message "Callable Entity '$Id' not found - Please validate input"
          continue
        }
        else {
          Write-Debug -Message "Callable Entity '$Id' found:"
          Write-Debug "$CallTarget"
        }
      }
      catch {
        Write-Error -Message "Callable Entity '$Id' found, but no unique result determined. Cannot continue."
        Write-Progress -Id 1 -Activity $ActivityID1 -Completed
        continue
      }
      #endregion

      #region Search Results
      $StatusID1 = 'Checking Call Queues'
      $Status = "$($CallTarget.Type) '$($CallTarget.Entity)'"
      #region Call Queues
      if ( $Scope -in ('All', 'CallQueue') ) {
        # 1 Searching for Agent or User
        $CurrentOperationID1 = 'Querying Agent or User'
        Write-BetterProgress -Id 1 -Activity $ActivityID1 -Status $StatusID1 -CurrentOperation $CurrentOperationID1 -Step ($script:CountID1++) -Of $script:StepsID1
        foreach ($CQ in $CQs) {
          if ( $CallTarget.Identity -in $CQ.Agents.ObjectId ) {
            if ( $CallTarget.Identity -in $CQ.Users ) {
              [void]$Output.Add([TFCallableEntityConnection]::new( "$($CallTarget.Entity)", 'User', 'CallQueue', "$($CQ.Name)", "$($CQ.Identity)"))
            }
            else {
              [void]$Output.Add([TFCallableEntityConnection]::new( "$($CallTarget.Entity)", 'Agent', 'CallQueue', "$($CQ.Name)", "$($CQ.Identity)"))
            }
          }
        }

        # 2 Searching for Group
        $CurrentOperationID1 = 'Groups'
        Write-BetterProgress -Id 1 -Activity $ActivityID1 -Status $StatusID1 -CurrentOperation $CurrentOperationID1 -Step ($script:CountID1++) -Of $script:StepsID1
        foreach ($CQ in $CQs) {
          if ( $CallTarget.Identity -in $CQ.DistributionLists ) {
            [void]$Output.Add([TFCallableEntityConnection]::new( "$($CallTarget.Entity)", 'Group', 'CallQueue', "$($CQ.Name)", "$($CQ.Identity)"))
          }
        }

        # 3 Searching for Overflow Target
        $CurrentOperationID1 = 'Overflow Action Target'
        Write-BetterProgress -Id 1 -Activity $ActivityID1 -Status $StatusID1 -CurrentOperation $CurrentOperationID1 -Step ($script:CountID1++) -Of $script:StepsID1
        foreach ($CQ in $CQs) {
          if ( $CallTarget.Identity -in $CQ.OverflowActionTarget ) {
            [void]$Output.Add([TFCallableEntityConnection]::new( "$($CallTarget.Entity)", 'OverflowActionTarget', 'CallQueue', "$($CQ.Name)", "$($CQ.Identity)"))
          }
        }

        # 4 Searching for Timeout Target
        $CurrentOperationID1 = 'Timout Action Target'
        Write-BetterProgress -Id 1 -Activity $ActivityID1 -Status $StatusID1 -CurrentOperation $CurrentOperationID1 -Step ($script:CountID1++) -Of $script:StepsID1
        foreach ($CQ in $CQs) {
          if ( $CallTarget.Identity -in $CQ.TimeoutActionTarget ) {
            [void]$Output.Add([TFCallableEntityConnection]::new( "$($CallTarget.Entity)", 'TimeoutActionTarget', 'CallQueue', "$($CQ.Name)", "$($CQ.Identity)"))
          }
        }

      }
      #endregion

      #region Auto Attendants
      $StatusID1 = 'Checking Auto Attendants'
      if ( $Scope -in ('All', 'AutoAttendant') ) {
        # 1 Searching for Operator
        $CurrentOperationID1 = 'Operator'
        Write-BetterProgress -Id 1 -Activity $ActivityID1 -Status $StatusID1 -CurrentOperation $CurrentOperationID1 -Step ($script:CountID1++) -Of $script:StepsID1
        foreach ($AA in $AAs) {
          if ( $CallTarget.Identity -in $AA.Operator.Id ) {
            [void]$Output.Add([TFCallableEntityConnection]::new( "$($CallTarget.Entity)", 'Operator', 'AutoAttendant', "$($AA.Name)", "$($AA.Identity)"))
          }
        }

        # 2 Searching for Routing Target
        $CurrentOperationID1 = 'Default Call Flow - Menu - MenuOption'
        Write-BetterProgress -Id 1 -Activity $ActivityID1 -Status $StatusID1 -CurrentOperation $CurrentOperationID1 -Step ($script:CountID1++) -Of $script:StepsID1
        foreach ($AA in $AAs) {
          foreach ($Target in $AA.DefaultCallFlow.Menu.MenuOptions.CallTarget) {
            if ( $CallTarget.Identity -in $Target.Id ) {
              [void]$Output.Add([TFCallableEntityConnection]::new( "$($CallTarget.Entity)", 'DefaultCallFlow', 'AutoAttendant', "$($AA.Name)", "$($AA.Identity)"))
            }
          }
        }

        # 3 Searching for Routing Target
        $CurrentOperationID1 = 'Call Flows - Menu - MenuOption'
        Write-BetterProgress -Id 1 -Activity $ActivityID1 -Status $StatusID1 -CurrentOperation $CurrentOperationID1 -Step ($script:CountID1++) -Of $script:StepsID1
        foreach ($AA in $AAs) {
          foreach ($Target in $AA.CallFlows.Menu.MenuOptions.CallTarget) {
            if ( $CallTarget.Identity -in $Target.Id ) {
              [void]$Output.Add([TFCallableEntityConnection]::new( "$($CallTarget.Entity)", 'CallFlows', 'AutoAttendant', "$($AA.Name)", "$($AA.Identity)"))
            }
          }
        }

      }
      #endregion
      Write-Progress -Id 1 -Activity $ActivityID1 -Completed
      #endregion

      # Output
      Write-Progress -Id 0 -Activity $ActivityID0 -Completed
      if ( $Output ) {
        Write-Output $Output #| Select-Object LinkedAs, ObjectType, ObjectName
      }
      else {
        Write-Verbose -Message "No Call Queues or Auto Attendants found where Identity '$Id' is linked" -Verbose
      }
    }

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"

  } #end
} #Find-TeamsCallableEntity
