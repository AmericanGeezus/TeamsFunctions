# Module:     TeamsFunctions
# Function:   Teams Auto Attendant
# Author:    David Eberhardt
# Updated:    01-NOV-2020
# Status:     Live

#TODO Explore adding an option to pass an object to this function (to avoid duplicating Get-CsOnlineUser) and speed up lookup
#TODO Add Announcement TTV and File

function Get-TeamsCallableEntity {
  <#
  .SYNOPSIS
    Returns a callable Entity Object from an Identity/ObjectId or string
  .DESCRIPTION
    Determines an Objects validity for use in an Auto Attendant or Call Queue
    Prepares output of Get-CsCallQueue by querying the Team and Channel (used in Get-TeamsCallQueue)
    Prepares output of Get-CsAutoAttendant (nested Objects) for display (used in Get-TeamsAutoAttendant)
    Returns a custom Object mimiking a CallableEntity Object, returning Entity, Identity & Type
  .PARAMETER Identity
    The ObjectId of the CallableEntity linked
  .EXAMPLE
    Get-TeamsCallableEntity -Identity "My Group Name"
    Queries whether "My Group Name" can be found as an AzureAdUser, AzureAdGroup or CsOnlineApplicationInstance.
  .EXAMPLE
    Get-TeamsCallableEntity -Identity "John@domain.com","MyResourceAccount@domain.com"
    Queries whether John or MyResourceAccount can be found as an AzureAdUser, AzureAdGroup or CsOnlineApplicationInstance.
  .EXAMPLE
    Get-TeamsCallableEntity -Identity 00000000-0000-0000-0000-000000000000
    Queries whether the provided ObjectId can be found as an AzureAdUser, AzureAdGroup or CsOnlineApplicationInstance.
  .EXAMPLE
    Get-TeamsCallableEntity -Identity "1 (555) 1234-567"
    No Queries performed, number is normalised into a LineURI then passed on as the Tel URI.
    Returns a custom Object mimiking a CallableEntity Object, returning Entity, Identity & Type
  .EXAMPLE
    Get-TeamsCallableEntity -Identity "tel:+15551234567"
    No Queries performed, as the Tel URI is passed on as-is.
    Returns a custom Object mimiking a CallableEntity Object, returning Entity, Identity & Type
  .EXAMPLE
    Get-TeamsCallableEntity -Identity "00000000-0000-0000-0000-000000000000\19:abcdef1234567890abcdef1234567890@thread.tacv2"
    Format provided is of in TeamId\ChannelId. This is interpreted as a TeamsChannel. Queries Team & Channel.
    Returns a custom Object mimiking a CallableEntity Object, returning Entity, Identity & Type
  .EXAMPLE
    Get-TeamsCallableEntity -Identity "My Team Name\My Channel Name"
    Format provided is of in TeamDisplayName\ChannelDisplayName. This is interpreted as a TeamsChannel. Queries Team & Channel.
    Returns a custom Object mimiking a CallableEntity Object, returning Entity, Identity & Type
  .INPUTS
    System.String
  .OUTPUTS
    System.Object
  .NOTES
    If a match for Team\Channel or PhoneNumber is found, these are treated as such.
    For Team\Channel, the Id and DisplayName are interchangeable. The first match is performed for '\', if it matches,
    the string is split and individual matches are performed for Team and Channel respectively.
    The PhoneNumber is found with a very flexible match based on multiple formats (Integer, E.164 or LineUri)
    If no match is found, queries the string sequentially against AzureAdUser, CsOnlineApplicationInstance and AzureAdGroup.
    Returns a custom Object mimiking a CallableEntity Object, returning Entity, Identity & Type

    This script is used to determine the eligibility of an Object as a Callable Entity in Call Queues and Auto Attendants
    This script does not yet support Announcements (sorry. Working on it)
    This script does not support the Types for legacy Hunt Group or Organisational Auto Attendant
    If nothing can be found for the String, an Object is returned with the Entity being $null
  .COMPONENT
    UserManagement
    TeamsAutoAttendant
    TeamsCallQueue
  .FUNCTIONALITY
    Queries a Callable Entity attached to a Call Queues or Auto Attendants
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  .LINK
    about_UserManagement
  .LINK
    about_TeamsAutoAttendant
  .LINK
    about_TeamsCallQueue
  .LINK
    Assert-TeamsCallableEntity
  .LINK
    Find-TeamsCallableEntity
  .LINK
    Get-TeamsCallableEntity
  .LINK
    New-TeamsCallableEntity
  .LINK
    Get-TeamsCallQueue
  .LINK
    Get-TeamsAutoAttendant
  .LINK
    Get-TeamsObjectType
  #>

  [CmdletBinding()]
  [OutputType([PSCustomObject])]
  param(
    [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = 'Identity of the Callable Entity')]
    [Alias('ObjectId', 'UserPrincipalName')]
    [string[]]$Identity

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
    if (-not $PSBoundParameters.ContainsKey('Debug')) { $DebugPreference = $PSCmdlet.SessionState.PSVariable.GetValue('DebugPreference') } else { $DebugPreference = 'Continue' }
    if ( $PSBoundParameters.ContainsKey('InformationAction')) { $InformationPreference = $PSCmdlet.SessionState.PSVariable.GetValue('InformationAction') } else { $InformationPreference = 'Continue' }

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    foreach ($Id in $Identity) {
      Write-Verbose -Message "Processing '$Id'"
      if ($Id -match "\\") {
        $Team,$Channel = Get-TeamAndChannel -String "$Id"
        if ($Channel) {
          Write-Verbose 'Target is a Teams Channel'
          $TeamAndChannelName = $Team.DisplayName + "\" + $Channel.DisplayName
          $CallableEntity = [TFCallableEntity]::new( "$TeamAndChannelName", "$($Channel.Id)", 'Channel', 'Channel')
        }
      }
      elseif ($Id -match '^(tel:)?\+?(([0-9]( |-)?)?(\(?[0-9]{3}\)?)( |-)?([0-9]{3}( |-)?[0-9]{4})|([0-9]{7,15}))?((;( |-)?ext=[0-9]{3,8}))?$' -and -not ($Id -match '@')) {
        Write-Verbose 'Target is a Tel URI'
        $Id = Format-StringForUse -InputString "$Id" -As LineURI
        $CallableEntity = [TFCallableEntity]::new( "$Id", "$Id", 'TelURI', 'ExternalPstn')

      }
      else {
        Write-Verbose 'Target is not a Tel URI'
        try {
          # FIRST: Trying an AzureAdUser for User or ApplicationEndPoint
          $CallTarget = Get-AzureADUser -ObjectId "$Id" -WarningAction SilentlyContinue
          Write-Verbose 'Target is a User or Application Endpoint'
          if ( $CallTarget ) {
            try {
              $null = Get-CsOnlineApplicationInstance -Identity "$($CallTarget.ObjectId)" -WarningAction SilentlyContinue -ErrorAction Stop
              Write-Verbose 'Target is an Application Endpoint'
              $CallableEntity = [TFCallableEntity]::new( "$($CallTarget.UserPrincipalName)", "$($CallTarget.ObjectId)", 'ApplicationEndpoint', 'ApplicationEndpoint')
            }
            catch {
              Write-Verbose 'Target is a User'
              $CallableEntity = [TFCallableEntity]::new( "$($CallTarget.UserPrincipalName)", "$($CallTarget.ObjectId)", 'User', 'User')
            }
          }
          else {
            Write-Verbose 'Target is not a User or Application Endpoint'
            throw
          }
        }
        catch {
          # Not a User, not an ApplicationEndPoint
          Write-Verbose 'Target is not a User or Application Endpoint'
          try {
            # SECOND: Trying a AzureAdGroup for SharedVoicemail
            $CallTarget = $null
            $CallTarget = Get-AzureADGroup -SearchString "$Id" -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
            if (-not $CallTarget ) {
              try {
                $CallTarget = Get-AzureADGroup -ObjectId "$Id" -WarningAction SilentlyContinue -ErrorAction Stop
              }
              catch {
                Write-Information 'Performing Search... finding ALL Groups'
                if ( -not $global:TeamsFunctionsTenantAzureAdGroups) {
                  Write-Verbose -Message 'Groups not loaded yet, depending on the size of the Tenant, this will run for a while!' -Verbose
                  $global:TeamsFunctionsTenantAzureAdGroups = Get-AzureADGroup -All $true -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
                }
                if ($Id -match '@') {
                  $CallTarget = $global:TeamsFunctionsTenantAzureAdGroups | Where-Object Mail -EQ "$Id" -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
                }
                else {
                  $CallTarget = $global:TeamsFunctionsTenantAzureAdGroups | Where-Object DisplayName -EQ "$Id" -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
                }
              }
            }
            else {
              Write-Verbose 'Target is a Group'
            }

            # dealing with potential duplicates
            if ( $CallTarget.Count -gt 1 ) {
              Write-Verbose 'Target is a Group, but multiple Groups found'
              $CallTarget = $CallTarget | Where-Object DisplayName -EQ "$Id"
            }
            if ( $CallTarget.Count -gt 1 ) {
              Write-Verbose 'Target is a Group, but not unique!'
              throw [System.Reflection.AmbiguousMatchException]::New('Multiple Targets found - Result not unique (Group)')
            }
            else {
              # Unique result found
              if ( $CallTarget ) {
                $CallableEntity = [TFCallableEntity]::new( "$($CallTarget.DisplayName)", "$($CallTarget.ObjectId)", 'Group', 'SharedVoicemail')
              }
              else {
                throw
              }
            }
          }
          catch [System.Reflection.AmbiguousMatchException] {
            Write-Error -Message "No Unique Target found for '$Id'" -Exception System.Reflection.AmbiguousMatchException -ErrorAction Stop
          }
          catch {
            Write-Warning -Message 'The Object is not supported as a Callable Entity for AutoAttendants or CallQueues'
            # Defaulting to Unknown
            $CallableEntity = [TFCallableEntity]::new( "$Id", $null, 'Unknown', $null )
          }
        }
      }

      Write-Output $CallableEntity
    }

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end

} # Get-TeamsCallableEntity
