# Module:   TeamsFunctions
# Function: AutoAttendant
# Author:		David Eberhardt
# Updated:  01-OCT-2020
# Status:   BETA




function Get-TeamsAutoAttendant {
  <#
	.SYNOPSIS
		Queries Auto Attendants and displays friendly Names (UPN or DisplayName)
	.DESCRIPTION
		Same functionality as Get-CsAutoAttendant, but display reveals friendly Names,
		like UserPrincipalName or DisplayName for the following connected Objects
    Operator and ApplicationInstances (Resource Accounts)
	.PARAMETER Name
		Optional. Searches all Auto Attendants for this name (multiple results possible).
    If omitted, Get-TeamsAutoAttendant acts like an Alias to Get-CsAutoAttendant (no friendly names)
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
  .INPUTS
    System.String
  .OUTPUTS
    System.Object
	.NOTES
    Main difference to Get-CsAutoAttendant (apart from the friendly names) is how the Objects are shown.
    The connected Objects DefaultCallFlow, CallFlows, Schedules, CallHandlingAssociations and DirectoryLookups
    are all shown with Name only, but can be queried with .<ObjectName>
    This also works with Get-CsAutoAttendant, but with the help of "Display" Parameters.
	.FUNCTIONALITY
		Get-CsAutoAttendant with friendly names instead of GUID-strings for connected objects
	.LINK
		New-TeamsCallQueue
		Get-TeamsCallQueue
    Set-TeamsCallQueue
    Remove-TeamsCallQueue
    New-TeamsAutoAttendant
    Get-TeamsAutoAttendant
    Set-TeamsAutoAttendant
    Remove-TeamsAutoAttendant
    Get-TeamsResourceAccountAssociation
    New-TeamsResourceAccountAssociation
		Remove-TeamsResourceAccountAssociation
  #>

  [CmdletBinding()]
  [Alias('Get-TeamsAA')]
  [OutputType([System.Object[]])]
  param(
    [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = 'Partial or full Name of the Auto Attendant to search')]
    [AllowNull()]
    [string]$Name,

    [switch]$Detailed
  ) #param

  begin {
    Show-FunctionStatus -Level PreLive
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

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    # Capturing no input
    try {
      if (-not $PSBoundParameters.ContainsKey('Name')) {
        Write-Verbose -Message "Name not specified, listing call queue names only. Please query contents by targeting them with -Name" -Verbose
        (Get-CsAutoAttendant -WarningAction SilentlyContinue -ErrorAction STOP).Name
      }
      else {
        #TODO Add Progress bars!
        foreach ($DN in $Name) {
          Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand) - '$DN'"
          # Finding all AAs with this Name (Should return one Object, but since it IS a filter, handling it as an array)
          #$AAs = Get-CsAutoAttendant -NameFilter "$DN" -WarningAction SilentlyContinue -ErrorAction STOP
          $AAs = Get-CsAutoAttendant -NameFilter "$DN" -WarningAction SilentlyContinue -ErrorAction STOP | Select-Object *

          # Initialising Arrays
          [System.Collections.ArrayList]$AIObjects = @()

          # Reworking Objects
          Write-Verbose -Message "[PROCESS] Finding parsable Objects for $($AAs.Count) Auto Attendants"
          foreach ($AA in $AAs) {
            #region Finding Operator
            Write-Verbose -Message "'$($AA.Name)' - Parsing Operator"
            if ($null -eq $AA.Operator) {
              $OperatorObject = $null
            }
            else {
              # Parsing Callable Entity
              #TODO Get-TeamsCallableEntity can be used to do this, if it can search by type (needs to be extended first though)
              switch ($AA.Operator.Type) {
                "User" {
                  try {
                    $OperatorObject = Get-AzureADUser -ObjectId "$($AA.Operator.Id)" -WarningAction SilentlyContinue -ErrorAction STOP
                    $Operator = $OperatorObject.UserPrincipalName
                  }
                  catch {
                    Write-Warning -Message "'$($AA.Name)' Operator: Not enumerated"
                  }
                }
                "OrganizationalAutoAttendant" {
                  try {
                    $OperatorObject = Get-CsOrganizationalAutoAttendant -Identity "$($AA.Operator.Id)" -WarningAction SilentlyContinue -ErrorAction STOP
                    $Operator = $OperatorObject.Name
                  }
                  catch {
                    Write-Warning -Message "'$($AA.Name)' Operator: Not enumerated"
                  }
                }
                "HuntGroup" {
                  try {
                    $OperatorObject = Get-CsHuntGroup -Identity "$($AA.Operator.Id)" -WarningAction SilentlyContinue -ErrorAction STOP
                    $Operator = $OperatorObject.Name
                  }
                  catch {
                    Write-Warning -Message "'$($AA.Name)' Operator: Not enumerated"
                  }
                }
                "ApplicationEndpoint" {
                  try {
                    $OperatorObject = Get-CsOnlineApplicationInstance -ObjectId "$($AA.Operator.Id)" -WarningAction SilentlyContinue -ErrorAction STOP
                    $Operator = $OperatorObject.UserPrincipalName
                  }
                  catch {
                    Write-Warning -Message "'$($AA.Name)' Operator: Not enumerated"
                  }
                }
                "ExternalPstn" {
                  try {
                    $Operator = $AA.Id
                  }
                  catch {
                    Write-Warning -Message "'$($AA.Name)' Operator: Not enumerated"
                  }
                }
                "SharedVoicemail" {
                  try {
                    $OperatorObject = Get-AzureADGroup -ObjectId "$($AA.Operator.Id)" -WarningAction SilentlyContinue -ErrorAction STOP
                    $Operator = $OperatorObject.DisplayName
                  }
                  catch {
                    Write-Warning -Message "'$($AA.Name)' Operator: Not enumerated"
                  }
                }
                default {
                  try {
                    $OperatorObject = Get-AzureADUser -ObjectId "$($AA.Operator.Id)" -WarningAction SilentlyContinue -ErrorAction STOP
                    $Operator = $OperatorObject.UserPrincipalName
                    if ($null -eq $Operator) {
                      try {
                        $OperatorObject = Get-AzureADGroup -ObjectId "$($AA.Operator.Id)" -WarningAction SilentlyContinue -ErrorAction STOP
                        $Operator = $OperatorObject.DisplayName
                        if ($null -eq $Operator) {
                          throw
                        }
                      }
                      catch {
                        Write-Warning -Message "'$($AA.Name)' Operator: Not enumerated"
                      }
                    }
                  }
                  catch {
                    Write-Warning -Message "'$($AA.Name)' Operator: Not enumerated"
                  }
                }
              }

            }
            # Output: $Operator, $OperatorTranscription
            #endregion

            #region Application Instance UPNs
            Write-Verbose -Message "'$($AA.Name)' - Parsing Resource Accounts"
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
            Write-Verbose -Message "'$($AA.Name)' - Constructing Output Object"
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
              Write-Verbose -Message "'$($AA.Name)' - Constructing Output Object with Switch 'Detailed' - This may take a bit..." -Verbose

              #region Operator
              Write-Verbose -Message "Parsing Operator"
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
                $OperatorObject = $null
              }
              #endregion

              #region DefaultCallFlow
              Write-Verbose -Message "Parsing DefaultCallFlow"
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
              Write-Verbose -Message "Parsing CallFlows"
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
              Write-Verbose -Message "Parsing Schedules"
              $AASchedules = @()
              foreach ($Schedule in $AA.Schedules) {
                $AASchedule = Get-CsOnlineSchedule -Id $Schedule.Id
                $AASchedules += Merge-AutoAttendantArtefact -Type Schedule -Object $AASchedule

              }
              #endregion

              #region CallHandlingAssociations
              Write-Verbose -Message "Parsing CallHandlingAssociations"
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
            Write-Output $AAObject
          }
        }
      }
    }
    catch {
      Write-Error -Message 'Could not query Auto Attendants' -Category OperationStopped
      Write-ErrorRecord $_ #This handles the error message in human readable format.
      return
    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"

  } #end
} #Get-TeamsAutoAttendant