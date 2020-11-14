# Module:   TeamsFunctions
# Function: AutoAttendant
# Author:		David Eberhardt
# Updated:  01-DEC-2020
# Status:   Beta

#CHECK Create separate Function Find-TeamsCallableEntity that returns an Object with Type and ObjectId (mocking CallableEntity)?


function Get-TeamsObjectType {
  <#
  .SYNOPSIS
    Resolves the type of the object
  .DESCRIPTION
    Helper function to find the Callable Entity Type of Teams Objects
    Returns ObjectType: User (AzureAdUser), Group (AzureAdGroup), ResourceAccount (ApplicationInstance) or TelURI String (ExternalPstn)
  .PARAMETER Identity
    Required. String for the TelURI, Group Name or Mailnickname, UserPrincipalName, depending on the Entity Type
  .EXAMPLE
    Get-TeamsObjectType -Identity John@domain.com -Type User
    Creates a callable Entity for the User John@domain.com
  .EXAMPLE
    Get-TeamsObjectType -Identity "John@domain.com"
    Returns "User" as the type of Entity if an AzureAdUser with the UPN "John@domain.com" is found
  .EXAMPLE
    Get-TeamsObjectType -Identity "Accounting"
    Returns "Group" as the type of Entity if a AzureAdGroup with the Name "Accounting" is found.
  .EXAMPLE
    Get-TeamsObjectType -Identity "Accounting@domain.com"
    Returns "Group" as the type of Entity if a AzureAdGroup with the Mailnickname "Accounting@domain.com" is found.
  .EXAMPLE
    Get-TeamsObjectType -Identity "ResourceAccount@domain.com"
    Returns "ResourceAccount" as the type of Entity if a CsOnlineApplicationInstance with the UPN "ResourceAccount@domain.com" is found
  .EXAMPLE
    Get-TeamsObjectType -Identity "tel:+1555123456"
    Returns "TelURI" as the type of Entity
  .EXAMPLE
    Get-TeamsObjectType -Identity "+1555123456"
    Returns an Error as the type of Entity cannot be determined correctly
  .INPUTS
    System.String
  .OUTPUTS
    System.String
  .COMPONENT
    TeamsAutoAttendant
    TeamsCallQueue
  #>

  [CmdletBinding(ConfirmImpact = 'Low')]
  [OutputType([System.String])]
  param(
    [Parameter(Mandatory = $true, Position = 0, HelpMessage = "Identity of the Call Target")]
    [string]$Identity
  ) #param

  begin {
    # Caveat - Script in Development
    $VerbosePreference = "Continue"
    $DebugPreference = "Continue"
    Show-FunctionStatus -Level Beta
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

    # Type ExternalPstn
    if ($Identity -match "^tel:\+\d") {
      Write-Verbose -Message "Callable Entity - Call Target '$Identity' (TelURI) found: TelURI (ExternalPstn)"
      return "TelURI"
    }

    $RA = Find-TeamsResourceAccount "$Identity"
    if ( $RA ) {
      Write-Verbose -Message "Callable Entity - Call Target '$Identity' found: ResourceAccount (ApplicationInstance), (VoiceApp)"
      return "ResourceAccount"
    }

    $User = Find-AzureAdUser "$Identity"
    if ( $User ) {
      Write-Verbose -Message "Callable Entity - Call Target '$Identity' found: User (Forward, Voicemail)"
      return "User"
    }

    $Group = Find-AzureAdGroup "$Identity"
    if ( $Group ) {
      Write-Verbose -Message "Callable Entity - Call Target '$Identity' found: Group (SharedVoicemail)"
      return "Group"
    }

    # Catch neither
    throw [System.IO.IOException] "Callable Entity - Call Target '$Identity' - Type not enumerated"


    <# Alternative Approach - from Get-TeamsUserVoiceConfig - Untested- Unmeasured
    #TEST Measure-Object against Find VS Test commands.
    if ($Identity -match "^tel:\+\d") {
      Write-Verbose -Message "Callable Entity - Call Target '$Identity' (TelURI) found: TelURI (ExternalPstn)"
      return "TelURI"
    }
    elseif ( Test-AzureADGroup $Identity ) {
      Write-Verbose -Message "Callable Entity - Call Target '$Identity' found: Group (SharedVoicemail)"
      return "Group"
    }
    elseif ( Test-TeamsResourceAccount $Identity ) {
      Write-Verbose -Message "Callable Entity - Call Target '$Identity' found: ResourceAccount (ApplicationInstance), (VoiceApp)"
      return "ResourceAccount"
    }
    elseif ( Test-AzureADUser $Identity ) {
      Write-Verbose -Message "Callable Entity - Call Target '$Identity' found: User (Forward, Voicemail)"
      return "User"
    }
    else {
      Write-Verbose -Message "ObjectType is 'Unknown'"
      # Catch neither
      throw [System.IO.IOException] "Callable Entity - Call Target '$Identity' - Type not enumerated"

    }
    #>

  }

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Resolve-TeamsCallableEntity
