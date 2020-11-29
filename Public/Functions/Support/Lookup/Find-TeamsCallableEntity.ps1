# Module:   TeamsFunctions
# Function: CallQueue
# Author:		David Eberhardt
# Updated:  01-DEC-2020
# Status:   ALPHA




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
    NOTE: This is currently not operational. As the script is developed, the Scope parameter can be used to do this.
	.EXAMPLE
		Find-TeamsCallableEntity "MyGroup@domain.com" -Scope CallQueue
		Finds all Call Queues in which My Group is linked as an Agent Group, OverflowTarget or TimeoutTarget
	.EXAMPLE
		Find-TeamsCallableEntity "tel:+15551234567" -Scope AutoAttendant
		Finds all Auto Attendants in which the Tel URI is linked as an Operator, Menu Option, etc.
    NOTE: This is currently not operational. As the script is developed, the Scope parameter can be used to do this.
  .INPUTS
    System.String
  .OUTPUTS
    System.Object
  .NOTES
    Finding linked agents is useful if the Call Queues are in an unusable state.
    This happens if a User is unlicensed, disabled for Enterprise Voice or disabled completely
    while still being targeted as an Agent or for Overflow or Timeout.

    While this script is being developed, the Scope is limited to "CallQueue"
    Once this has been tested, it is going to be expanded to cover Auto Attendants too.
	.FUNCTIONALITY
    Call Queue Troubleshooting
    Auto Attendant Troubleshooting
	.LINK
    Find-TeamsCallableEntity
    Get-TeamsCallableEntity
    New-TeamsAutoAttendantCallableEntity
    Get-TeamsObjectType
    Get-TeamsCallQueue
    Get-TeamsAutoAttendant
  #>

  [CmdletBinding()]
  [OutputType([System.Object[]])]
  param(
    [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = 'User Identifier')]
    [string]$Identity

    #[Parameter(HelpMessage = 'Scope')]
    #[ValidateSet('All', 'CallQueue', 'AutoAttendant')]
    #[string]$Scope = "All"

  ) #param

  begin {
    Show-FunctionStatus -Level Alpha
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

    #Scope Hardcoded (will become a parameter later)
    [string]$Scope = "CallQueue"

    # Initialising counters for Progress bars
    [int]$step = 0
    [int]$sMax = 3
    if ( $Scope -eq "All" ) { $sMax = $sMax + 2 }

    [System.Collections.ArrayList]$Output = @()

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    #region Information Gathering
    $Status = "Information Gathering"
    # Object
    $Operation = "Teams Callable Entity"
    Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
    Write-Verbose -Message "$Status - $Operation"
    $Entity = Get-TeamsCallableEntity -Identity $Identity

    if ( -not $Entity.Entity ) {
      Write-Verbose -Message "Callable Entity '$Identity' not found - Please validate UserPrincipalName" -Verbose
      return
    }
    else {
      Write-Debug -Message "Callable Entity '$Identity' found:"
      Write-Debug $Entity
    }

    # Call Queues and Auto Attendants
    if ( $Scope -in ("All", "CallQueue") ) {
      # Query Queues
      $Operation = "Querying Call Queues"
      $step++
      Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message "$Status - $Operation"

      $CQs = Get-CsCallQueue -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
      Write-Verbose -Message "Scope '$Scope' - Call Queues found: $($CQs.Count)"
    }

    if ( $Scope -in ("All", "AutoAttendant") ) {
      # Query Queues
      $Operation = "Querying Auto Attendants"
      $step++
      Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message "$Status - $Operation"

      $AAs = Get-CsAutoAttendant -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
      Write-Verbose -Message "Scope '$Scope' - Auto Attendants found: $($AAs.Count)"
    }
    #endregion


    #region Search Results
    $Status = "Searching"
    #region Call Queues
    if ( $Scope -in ("All", "CallQueue") ) {
      $Operation = "Call Queues for $($Entity.Type) '$($Entity.Entity)'"
      $step++
      Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message "$Status - $Operation"

      # Initialising counters for Progress bars ID 1
      [int]$step1 = 0
      [int]$sMax1 = 4

      $Status1 = "Call Queues for $($Entity.Type) '$($Entity.Entity)'"
      # 1 Searching for Agent or User
      $Operation1 = "Agent or User"
      Write-Progress -Id 1 -ParentId 0 -Status $Status1 -CurrentOperation $Operation1 -Activity $MyInvocation.MyCommand -PercentComplete ($step1 / $sMax1 * 100)
      Write-Verbose -Message "$Status1 - $Operation1" -Verbose

      foreach ($CQ in $CQs) {
        if ( $Entity.Identity -in $CQ.Agents ) {
          if ( $Entity.Identity -in $CQ.Users ) {
            [void]$Output.Add([TFCallableEntityConnection]::new( "User", "CallQueue", "$($CQ.Name)", "$($CQ.ObjectId)"))
          }
          else {
            [void]$Output.Add([TFCallableEntityConnection]::new( "Agent", "CallQueue", "$($CQ.Name)", "$($CQ.ObjectId)"))
          }
        }
      }

      # 2 Searching for Group
      $Operation1 = "Group"
      $step1++
      Write-Progress -Id 1 -ParentId 0 -Status $Status1 -CurrentOperation $Operation1 -Activity $MyInvocation.MyCommand -PercentComplete ($step1 / $sMax1 * 100)
      Write-Verbose -Message "$Status1 - $Operation1" -Verbose

      foreach ($CQ in $CQs) {
        if ( $Entity.Identity -in $CQ.Groups ) {
          [void]$Output.Add([TFCallableEntityConnection]::new( "Group", "CallQueue", "$($CQ.Name)", "$($CQ.ObjectId)"))
        }
      }

      # 3 Searching for Overflow Target
      $Operation1 = "Overflow Target"
      $step1++
      Write-Progress -Id 1 -ParentId 0 -Status $Status1 -CurrentOperation $Operation1 -Activity $MyInvocation.MyCommand -PercentComplete ($step1 / $sMax1 * 100)
      Write-Verbose -Message "$Status1 - $Operation1" -Verbose

      foreach ($CQ in $CQs) {
        if ( $Entity.Identity -in $CQ.OverflowActionTarget ) {
          [void]$Output.Add([TFCallableEntityConnection]::new( "OverflowActionTarget", "CallQueue", "$($CQ.Name)", "$($CQ.ObjectId)"))
        }
      }

      # 4 Searching for Timeout Target
      $Operation1 = "Timeout Target"
      $step1++
      Write-Progress -Id 1 -ParentId 0 -Status $Status1 -CurrentOperation $Operation1 -Activity $MyInvocation.MyCommand -PercentComplete ($step1 / $sMax1 * 100)
      Write-Verbose -Message "$Status1 - $Operation1" -Verbose

      foreach ($CQ in $CQs) {
        if ( $Entity.Identity -in $CQ.TimeoutActionTarget ) {
          [void]$Output.Add([TFCallableEntityConnection]::new( "TimeoutActionTarget", "CallQueue", "$($CQ.Name)", "$($CQ.ObjectId)"))
        }
      }

      Write-Progress -Id 1 -ParentId 0 -Completed -Activity $MyInvocation.MyCommand
    }
    #endregion

    #region Auto Attendants
    if ( $Scope -in ("All", "AutoAttendant") ) {
      $Operation = "Searching Auto Attendants for $($Entity.Type) '$($Entity.Entity)'"
      $step++
      Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message "$Status - $Operation"

      # Initialising counters for Progress bars ID 1
      [int]$step1 = 0
      [int]$sMax1 = 2

      $Status1 = "Searching Auto Attendants for $($Entity.Type) '$($Entity.Entity)'"
      # 1 Searching for Operator
      $Operation1 = "Operator"
      Write-Progress -Id 1 -ParentId 0 -Status $Status1 -CurrentOperation $Operation1 -Activity $MyInvocation.MyCommand -PercentComplete ($step1 / $sMax1 * 100)
      Write-Verbose -Message "$Status1 - $Operation1" -Verbose

      foreach ($AA in $AAs) {
        if ( $Entity.Identity -in $AA.Operator.Id ) {
          [void]$Output.Add([TFCallableEntityConnection]::new( "Operator", "AutoAttendant", "$($AA.Name)", "$($AA.ObjectId)"))
        }
      }

      # 2 Searching for Routing Target
      $Operation1 = "Routing Target (MenuOption)"
      $step1++
      Write-Progress -Id 1 -ParentId 0 -Status $Status1 -CurrentOperation $Operation1 -Activity $MyInvocation.MyCommand -PercentComplete ($step1 / $sMax1 * 100)
      Write-Verbose -Message "$Status1 - $Operation1" -Verbose

      foreach ($AA in $AAs) {
        foreach ($Flow in $AA.Flow) {
          foreach ($Menu in $Flow.Menu) {
            foreach ($MenuOption in $Menu.MenuOption) {
              if ( $Entity.Identity -in $MenuOption.CallTarget ) {
                [void]$Output.Add([TFCallableEntityConnection]::new( "MenuOption", "AutoAttendant", "$($AA.Name)", "$($AA.ObjectId)"))
              }
            }
          }
        }
      }

      Write-Progress -Id 1 -ParentId 0 -Completed -Activity $MyInvocation.MyCommand
    }
    #endregion
    #endregion

    # Output
    return $Output

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"

  } #end
} #Find-TeamsCallableEntity
