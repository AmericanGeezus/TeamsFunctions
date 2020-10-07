# Module:   TeamsFunctions
# Function: AutoAttendant
# Author:		David Eberhardtt
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
    [string]$Name
  ) #param

  begin {
    Show-FunctionStatus -Level PreLive
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

    # Capturing no input
    try {
      if (-not $PSBoundParameters.ContainsKey('Name')) {
        Write-Verbose -Message "No parameters specified. Acting as an Alias to Get-CsAutoAttendant" -Verbose
        Write-Verbose -Message "Warnings are suppressed for this operation. Please query with -Name to display them" -Verbose
        Get-CsAutoAttendant -WarningAction SilentlyContinue -ErrorAction STOP
      }
      else {
        foreach ($DN in $Name) {
          Write-Verbose -Message "[PROCESS] $($MyInvocation.Mycommand) - '$DN'"
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
            Write-Verbose -Message "'$($AA.Name)' - Constructing Output Object"
            # Building custom Object with Friendly Names
            $AAObject = [PSCustomObject][ordered]@{
              Identity                        = $AA.Identity
              Name                            = $AA.Name
              Operator                        = $Operator
              OperatorType                    = $AA.Operator.Type
              LanguageId                      = $AA.LanguageId
              TimeZoneId                      = $AA.TimeZoneId
              VoiceResponseEnabled            = $AA.VoiceResponseEnabled
              VoiceId                         = $AA.VoiceId

              OperatorObject                  = $AA.Operator | Select-Object Id, Type, EnableTranscription
              DefaultCallFlow                 = $AA.DefaultCallFlow | Select-Object Name
              CallFlows                       = $AA.CallFlows | Select-Object Name
              Schedules                       = $AA.Schedules | Select-Object Name
              CallHandlingAssociations        = $AA.CallHandlingAssociations | Select-Object Name
              DirectoryLookupScope            = $AA.DirectoryLookupScope | Select-Object Name

              GreetingsSettingAuthorizedUsers = $AA.GreetingsSettingAuthorizedUsers
              ApplicationInstances            = $AIObjects.UserPrincipalName
            }
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
    Write-Verbose -Message "[END    ] $($MyInvocation.Mycommand)"

  } #end
} #Get-TeamsAutoAttendant
