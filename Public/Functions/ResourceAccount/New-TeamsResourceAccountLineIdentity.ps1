# Module:   TeamsFunctions
# Function: ResourceAccount Calling Line Identity
# Author:	  David Eberhardt
# Updated:  30-JUN-2021
# Status:   RC




function New-TeamsResourceAccountLineIdentity {
  <#
  .SYNOPSIS
    Creates a new Calling Line Identity for a Resource Account
  .DESCRIPTION
    Creates a CsCallingLineIdentity Object for the Phone Number assigned to a Resource Account
  .PARAMETER UserPrincipalName
    Required. Identifies the Resource Account for which the Line Identity is being created
  .PARAMETER BlockIncomingPstnCallerID
    Blocks incoming PSTN Caller ID for inbound calls to the Call Queue or Auto Attendant
  .PARAMETER EnableUserOverride
    Allows the User to choose the Caller Line Id before placing the call.
  .PARAMETER CompanyName
    Sets the Company Name displayed for outbound calls.
  .EXAMPLE
    New-TeamsResourceAccountLineIdentity -Identity ResourceAccount@domain.com
    Creates a new Line Identity for the Resource Account provided.
  .EXAMPLE
    New-TeamsResourceAccountLineIdentity -Identity ResourceAccount@domain.com -BlockIncomingPstnCallerID
    Creates a new Line Identity for the Resource Account provided and suppresses the inbound Caller ID
  .EXAMPLE
    New-TeamsResourceAccountLineIdentity -Identity ResourceAccount@domain.com -EnableUserOverride
    Creates a new Line Identity for the Resource Account provided and allows the User to choose which Caller ID to display
  .EXAMPLE
    New-TeamsResourceAccountLineIdentity -Identity ResourceAccount@domain.com -CompanyName "Contoso Domain Services"
    Creates a new Line Identity for the Resource Account provided and sets the outbound display name to 'Contoso Domain Services'
  .INPUTS
    System.String
  .OUTPUTS
    System.Object
  .NOTES
    The Calling Line Identity is created with New-CsCallingLineIdentity. The Parameters Identity, Description and
    CallingIDSubstitute are populated by the Resource Account data
    Identity is populated with the UPN of the Resource Account
    Description is "CLI for RA: " plus the Display Name of the Resource Account
    CallingIDSubstitute is "Resource".

    $ObjId = (Get-CsOnlineApplicationInstance -Identity dkcq@contoso.com).ObjectId
    New-CsCallingLineIdentity  -Identity DKCQ -CallingIDSubstitute Resource -EnableUserOverride $false -ResourceAccount $ObjId -CompanyName "Contoso"
    https://docs.microsoft.com/en-us/powershell/module/skype/new-cscallinglineidentity?view=skype-ps
  .COMPONENT
    TeamsResourceAccount
    TeamsCallingLineIdentity
  .FUNCTIONALITY
    Creates a Line Identity for a Resource Account and its Phone Number
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/New-TeamsResourceAccountLineIdentity.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsFunctions.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  #>

  [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
  [Alias('New-TeamsRAIdentity', 'New-TeamsRACLI')]
  [OutputType([PSCustomObject])]
  param (
    [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = 'UPN of the Object to create.')]
    [ValidateScript( {
        If ($_ -match '@') { $True } else {
          throw [System.Management.Automation.ValidationMetadataException] 'Parameter UserPrincipalName must be a valid UPN'
          $false
        }
      })]
    [Alias('Identity')]
    [string]$UserPrincipalName,

    [Parameter(HelpMessage = 'Blocks incoming PSTN Caller Id')]
    [switch]$BlockIncomingPstnCallerID,

    [Parameter(HelpMessage = 'Allows the User to select the Caller Id')]
    [switch]$EnableUserOverride,

    [Parameter(ValueFromPipeline, HelpMessage = 'Name of the Company')]
    [string]$CompanyName

  )

  begin {
    Show-FunctionStatus -Level RC
    $Stack = Get-PSCallStack
    $Called = ($stack.length -ge 3)

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

    # Preparing Splatting Object
    Write-Verbose -Message '[BEGIN  ] Preparing Splatting object and processing switches'
    $Parameters = $null
    $Parameters = @{
      'CallingIDSubstitute'       = 'Resource'
      'BlockIncomingPstnCallerID' = if ( $BlockIncomingPstnCallerID ) { $true } else { $false }
      'EnableUserOverride'        = if ( $EnableUserOverride ) { $true } else { $false }
      'CompanyName'               = "$CompanyName"
    }

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    Write-Verbose -Message "[PROCESS] Processing '$UserPrincipalName'"

    try {
      #Trying to query the Resource Account
      #$Object = (Get-CsOnlineApplicationInstance -Identity "$UserPrincipalName" -WarningAction SilentlyContinue -ErrorAction STOP)
      $Object = (Get-TeamsResourceAccount -Identity "$UserPrincipalName" -WarningAction SilentlyContinue -ErrorAction STOP)
      $DisplayName = $Object.DisplayName
      Write-Verbose -Message "OnlineApplicationInstance found: '$DisplayName' - '$($Object.UserPrincipalName)'"
      $Parameters += @{'Description' = $DisplayName }
      $Parameters += @{'Identity' = $Object.UserPrincipalName }
      $Parameters += @{'ResourceAccount' = $Object.ObjectId }
    }
    catch {
      # Catching anything
      Write-Error -Message "OnlineApplicationInstance not found with UserPrincipalName '$UserPrincipalName'!" -Category ObjectNotFound -RecommendedAction 'Please provide a valid UserPrincipalName of an existing Resource Account' #-ErrorAction Stop
      return
    }

    # Validating Resource Account Settings
    # Check for Line URI - only allow if PhoneNumber is set!
    if ( -not $Object.PhoneNumber ) {
      Write-Warning -Message "Resource Account '$($Object.UserPrincipalName)' does not have a Phone Number assigned."
    }
    # Check for OVP - if not set, write warning
    if ( -not $Object.OnlineVoiceRoutingPolicy ) {
      Write-Warning -Message "Resource Account '$($Object.UserPrincipalName)' does not have an OnlineVoiceRoutingPolicy assigned."
    }
    if (  -not $Object.AssociatedTo ) {
      Write-Warning -Message 'Caller Line Identity will be created, however, the Resource Account is currently not associated with a Call Queue or Auto Attendant!'
    }
    if (  -not $Object.PhoneNumber -or -not $Object.OnlineVoiceRoutingPolicy ) {
      Write-Verbose -Message 'Caller Line Identity will be created, however, outbound calls will not work for this Account without assigning a PhoneNumber and an OnlineVoiceRoutingPolicy to the Resource Account!' -Verbose
    }
    # Creating Line Identity
    Write-Verbose -Message '[PROCESS] Creating Line Identity'
    if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
      "Function: $($MyInvocation.MyCommand.Name): Parameters:", ($Parameters | Format-Table -AutoSize | Out-String).Trim() | Write-Debug
    }

    if ($PSCmdlet.ShouldProcess("$($Object.UserPrincipalName)", 'New-CsCallingLineIdentity Identity')) {
      try {
        $CallingLineIdentity = New-CsCallingLineIdentity @Parameters
        if ($Called) {
          Write-Information "SUCCESS: Line Identity with Identity '$($CallingLineIdentity.Identity)' created successfully"
        }
        return $CallingLineIdentity
      }
      catch {
        Write-Error -Message "Error action unsuccessful : $($_.Exception.Message)" -Category InvalidResult
        continue
      }
    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #New-TeamsResourceAccountLineIdentity
