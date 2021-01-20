# Module:   TeamsFunctions
# Function: CallQueue
# Author:		David Eberhardt
# Updated:  01-DEC-2020
# Status:   PreLive




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
	.FUNCTIONALITY
    Call Queue Troubleshooting
    Auto Attendant Troubleshooting
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
	.LINK
    Find-TeamsCallableEntity
	.LINK
    Get-TeamsCallableEntity
	.LINK
    New-TeamsCallableEntity
	.LINK
    Get-TeamsObjectType
	.LINK
    Get-TeamsCallQueue
	.LINK
    Get-TeamsAutoAttendant
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
    Show-FunctionStatus -Level PreLive
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

    # Asserting AzureAD Connection
    if (-not (Assert-AzureADConnection)) { break }

    # Asserting SkypeOnline Connection
    if (-not (Assert-SkypeOnlineConnection)) { break }

    # Setting Preference Variables according to Upstream settings
    if (-not $PSBoundParameters.ContainsKey('Verbose')) { $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference') }
    if (-not $PSBoundParameters.ContainsKey('Confirm')) { $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference') }
    if (-not $PSBoundParameters.ContainsKey('WhatIf')) { $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference') }
    if (-not $PSBoundParameters.ContainsKey('Debug')) { $DebugPreference = $PSCmdlet.SessionState.PSVariable.GetValue('DebugPreference') } else { $DebugPreference = 'Continue' }

    #Scope Hardcoded (will become a parameter later)
    #$Scope = "CallQueue"

    # Initialising counters for Progress bars
    [int]$step0 = 0
    [int]$sMax0 = 3

    #region Information Gathering 1
    $Status = 'Information Gathering'
    # Call Queues and Auto Attendants
    if ( $Scope -in ('All', 'CallQueue') ) {
      # Query Queues
      $Operation = 'Querying Call Queues'
      Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step0 / $sMax0 * 100)
      $CQs = Get-CsCallQueue -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
      Write-Verbose -Message "$Status - $Operation -Objects found: $($CQs.Count)"
      $step0++
    }

    if ( $Scope -in ('All', 'AutoAttendant') ) {
      # Query Queues
      $Operation = 'Querying Auto Attendants'
      Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step0 / $sMax0 * 100)
      $AAs = Get-CsAutoAttendant -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
      Write-Verbose -Message "$Status - $Operation - Objects found: $($AAs.Count)"
      $step0++
    }
    #endregion

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    $IdCounter = 0
    foreach ( $Id in $Identity) {
      $CallTarget = $null
      [System.Collections.ArrayList]$Output = @()

      $Operation = "Processing '$Id'"
      Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($IdCounter / $($Identity.Count) * 100)
      Write-Verbose -Message "$Status - $Operation"
      $IdCounter++

      # Initialising counters for Progress bars
      [int]$step = 0
      [int]$sMax = 1
      switch ($Scope) {
        'CallQueue' { $sMax = $sMax + 4 }
        'AutoAttendant' { $sMax = $sMax + 3 }
        'All' { $sMax = $sMax + 7 }
      }

      # Object
      $Operation = 'Teams Callable Entity'
      Write-Progress -Id 1 -ParentId 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message "$Status - $Operation"
      try {
        $CallTarget = Get-TeamsCallableEntity -Identity $Id
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
        continue
      }

      #region Search Results
      $Status = "$($CallTarget.Type) '$($CallTarget.Entity)'"
      #region Call Queues
      if ( $Scope -in ('All', 'CallQueue') ) {
        # 1 Searching for Agent or User
        $Operation = 'Call Queues: Agent or User'
        $step++
        Write-Progress -Id 1 -ParentId 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
        Write-Verbose -Message "$Status - $Operation"

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
        $Operation = 'Call Queues: Group'
        $step++
        Write-Progress -Id 1 -ParentId 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
        Write-Verbose -Message "$Status - $Operation"

        foreach ($CQ in $CQs) {
          if ( $CallTarget.Identity -in $CQ.DistributionLists ) {
            [void]$Output.Add([TFCallableEntityConnection]::new( "$($CallTarget.Entity)", 'Group', 'CallQueue', "$($CQ.Name)", "$($CQ.Identity)"))
          }
        }

        # 3 Searching for Overflow Target
        $Operation = 'Call Queues: Overflow Action Target'
        $step++
        Write-Progress -Id 1 -ParentId 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
        Write-Verbose -Message "$Status - $Operation"

        foreach ($CQ in $CQs) {
          if ( $CallTarget.Identity -in $CQ.OverflowActionTarget ) {
            [void]$Output.Add([TFCallableEntityConnection]::new( "$($CallTarget.Entity)", 'OverflowActionTarget', 'CallQueue', "$($CQ.Name)", "$($CQ.Identity)"))
          }
        }

        # 4 Searching for Timeout Target
        $Operation = 'Call Queues: Timout Action Target'
        $step++
        Write-Progress -Id 1 -ParentId 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
        Write-Verbose -Message "$Status - $Operation"

        foreach ($CQ in $CQs) {
          if ( $CallTarget.Identity -in $CQ.TimeoutActionTarget ) {
            [void]$Output.Add([TFCallableEntityConnection]::new( "$($CallTarget.Entity)", 'TimeoutActionTarget', 'CallQueue', "$($CQ.Name)", "$($CQ.Identity)"))
          }
        }

      }
      #endregion

      #region Auto Attendants
      if ( $Scope -in ('All', 'AutoAttendant') ) {
        # 1 Searching for Operator
        $Operation = 'Auto Attendants: Operator'
        $step++
        Write-Progress -Id 1 -ParentId 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
        Write-Verbose -Message "$Status - $Operation"

        foreach ($AA in $AAs) {
          if ( $CallTarget.Identity -in $AA.Operator.Id ) {
            [void]$Output.Add([TFCallableEntityConnection]::new( "$($CallTarget.Entity)", 'Operator', 'AutoAttendant', "$($AA.Name)", "$($AA.Identity)"))
          }
        }

        # 2 Searching for Routing Target
        $Operation = 'Auto Attendants: MenuOption - Default Call Flow'
        $step++
        Write-Progress -Id 1 -ParentId 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
        Write-Verbose -Message "$Status - $Operation"

        foreach ($AA in $AAs) {
          foreach ($Target in $AA.DefaultCallFlow.Menu.MenuOptions.CallTarget) {
            if ( $CallTarget.Identity -in $Target.Id ) {
              [void]$Output.Add([TFCallableEntityConnection]::new( "$($CallTarget.Entity)", 'DefaultCallFlow', 'AutoAttendant', "$($AA.Name)", "$($AA.Identity)"))
            }
          }
        }

        # 3 Searching for Routing Target
        $Operation = 'Auto Attendants: MenuOption - Call Flows'
        $step++
        Write-Progress -Id 1 -ParentId 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
        Write-Verbose -Message "$Status - $Operation"

        foreach ($AA in $AAs) {
          foreach ($Target in $AA.CallFlows.Menu.MenuOptions.CallTarget) {
            if ( $CallTarget.Identity -in $Target.Id ) {
              [void]$Output.Add([TFCallableEntityConnection]::new( "$($CallTarget.Entity)", 'CallFlows', 'AutoAttendant', "$($AA.Name)", "$($AA.Identity)"))
            }
          }
        }

      }
      #endregion
      Write-Progress -Id 1 -Completed -Activity $MyInvocation.MyCommand
      #endregion

      # Output
      Write-Progress -Id 0 -Completed -Activity $MyInvocation.MyCommand
      if ( $Output ) {
        Write-Output $Output #| Select-Object LinkedAs, ObjectType, ObjectName
      }
      else {
        Write-Verbose -Message "No Call Queues or Auto Attendants found for Identity '$Id'" -Verbose
      }
    }

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"

  } #end
} #Find-TeamsCallableEntity
