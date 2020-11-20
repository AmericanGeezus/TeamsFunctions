# Module:     TeamsFunctions
# Function:   Teams Auto Attendant
# Author:     David Eberhardt
# Updated:    01-NOV-2020
# Status:     PreLive




function Get-TeamsAutoAttendantCallableEntity {
  <#
	.SYNOPSIS
		Returns a callable Entity Object from an Identity/ObjectId or string
	.DESCRIPTION
    Helper function to prepare a nested Object of an Auto Attendant for display
    Helper function to determine an Objects validity for use in an Auto Attendant or Call Queue
    Used in Get-TeamsAutoAttendant
  .PARAMETER Identity
    The ObjectId of the CallableEntity linked
  .EXAMPLE
    Get-TeamsAutoAttendantCallableEntity -Identity "My Group Name"
    Queries the provided ObjectId against AzureAdUser, AzureAdGroup and CsOnlineApplicationInstance.
    Returns a custom Object mimiking a CallableEntity Object, returning Entity, Identity & Type
  .EXAMPLE
    Get-TeamsAutoAttendantCallableEntity -Identity 000000-000000-0000000
    Queries the provided ObjectId against AzureAdUser, AzureAdGroup and CsOnlineApplicationInstance.
    Returns a custom Object mimiking a CallableEntity Object, returning Entity, Identity & Type
  .INPUTS
    System.String
  .OUTPUTS
    System.Object
  .COMPONENT
    TeamsAutoAttendant
    TeamsCallQueue
  .LINK
    Get-TeamsObjectType
    Get-TeamsCallQueue
    Get-TeamsAutoAttendant

	#>

  [CmdletBinding()]
  [OutputType([PSCustomObject])]
  param(
    [Parameter(Mandatory, ValueFromPipeline, Position = 0, HelpMessage = 'Identity of the Callable Entity')]
    [Alias('ObjectId')]
    [string[]]$Identity

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

    foreach ($Id in $Identity) {
      Write-Verbose -Message "Processing '$Id'"
      if ($Id -match "^tel:\+\d") {
        $CallableEntity = [PsCustomObject][ordered]@{
          'Entity'       = $Id
          'Identity'     = $Id
          'Type'         = "TelURI"
          'UsableInAaAs' = "ExternalPstn"
          'UsableInCqAs' = "Forward"
        }
      }
      else {
        try {
          # FIRST: Trying an AzureAdUser for User or ApplicationEndPoint
          $CallTarget = Get-AzureADUser -ObjectId $Id -WarningAction SilentlyContinue
          if ( $CallTarget ) {
            try {
              $ApplicationInstance = Get-CsOnlineApplicationInstance -Identity $CallTarget.ObjectId -WarningAction SilentlyContinue -ErrorAction Stop
            }
            catch {
              $ApplicationInstance = $null
            }

            if ($ApplicationInstance) {
              $CallableEntity = [PsCustomObject][ordered]@{
                'Entity'       = $CallTarget.UserPrincipalName
                'Identity'     = $CallTarget.ObjectId
                'Type'         = "ApplicationInstance"
                'UsableInAaAs' = "ApplicationEndpoint"
                'UsableInCqAs' = "Forward"
              }
            }
            else {
              $CallableEntity = [PsCustomObject][ordered]@{
                'Entity'       = $CallTarget.UserPrincipalName
                'Identity'     = $CallTarget.ObjectId
                'Type'         = "User"
                'UsableInAaAs' = "User"
                'UsableInCqAs' = @( "Forward", "Voicemail" )
              }
            }
          }
          else {
            throw
          }
        }
        catch {
          # Not a User, not an ApplicationEndPoint
          try {
            # SECOND: Trying a AzureAdGroup for SharedVoicemail
            $CallTarget = Find-AzureADGroup "$Id"
            if ( $CallTarget ) {
              $CallableEntity = [PsCustomObject][ordered]@{
                'Entity'       = $CallTarget.DisplayName
                'Identity'     = $CallTarget.ObjectId
                'Type'         = "Group"
                'UsableInAaAs' = "SharedVoicemail"
                'UsableInCqAs' = "SharedVoicemail"
              }
            }
            else {
              throw
            }
          }
          catch {
            Write-Warning -Message "The Object is not supported as a Callable Entity for AutoAttendants or CallQueues"
            # Defaulting to Unknown
            $CallableEntity = [PsCustomObject][ordered]@{
              'Entity'       = $null
              'Identity'     = $Id
              'Type'         = "Unknown"
              'UsableInAaAs' = ""
              'UsableInCqAs' = ""
            }
          }
        }
      }

      Write-Output $CallableEntity
    }

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end

} # Get-TeamsAutoAttendantCallableEntity
