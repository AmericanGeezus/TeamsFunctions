# Module:   TeamsFunctions
# Function: AutoAttendant
# Author:		David Eberhardt
# Updated:  01-JAN-2021
# Status:   Live



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
  .EXTERNALHELP
    https://raw.githubusercontent.com/DEberhardt/TeamsFunctions/master/docs/TeamsFunctions-help.xml
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  .LINK
    Get-TeamsCallableEntity
  #>

  [CmdletBinding(ConfirmImpact = 'Low')]
  [OutputType([System.String])]
  param(
    [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline, HelpMessage = "Identity of the Call Target")]
    [string]$Identity
  ) #param

  begin {
    Show-FunctionStatus -Level Live
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

    # Asserting AzureAD Connection
    if (-not (Assert-AzureADConnection)) { break }

    # Asserting SkypeOnline Connection
    if (-not (Assert-SkypeOnlineConnection)) { break }

    # Setting Preference Variables according to Upstream settings
    if (-not $PSBoundParameters.ContainsKey('Verbose')) { $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference') }
    if (-not $PSBoundParameters.ContainsKey('Confirm')) { $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference') }
    if (-not $PSBoundParameters.ContainsKey('WhatIf')) { $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference') }
    if (-not $PSBoundParameters.ContainsKey('Debug')) { $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('DebugPreference') } else { $DebugPreference = 'Continue' }

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    if ($Identity -match "^tel:\+\d") {
      Write-Verbose -Message "Callable Entity - Call Target '$Identity' (TelURI) found: TelURI (ExternalPstn)"
      return "TelURI"
    }
    else {
      $User = Find-AzureAdUser $Identity
      if ( $User ) {
        if ($User[0].Department -eq "Microsoft Communication Application Instance") {
          #if ( Test-TeamsResourceAccount $Identity ) {
          Write-Verbose -Message "Callable Entity - Call Target '$Identity' found: ResourceAccount (ApplicationInstance), (VoiceApp)"
          return "ResourceAccount"
        }
        else {
          Write-Verbose -Message "Callable Entity - Call Target '$Identity' found: User (Forward, Voicemail)"
          return "User"
        }
      }
      else {
        if ( Test-AzureADGroup $Identity ) {
          Write-Verbose -Message "Callable Entity - Call Target '$Identity' found: Group (SharedVoicemail)"
          return "Group"
        }
        else {
          # Catch neither
          Write-Verbose -Message "ObjectType cannot be determined." -Verbose
          return
        }
      }
    }
  }

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Get-TeamsObjectType
