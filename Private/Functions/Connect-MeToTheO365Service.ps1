# Module:   TeamsFunctions
# Function: Session
# Author:		David Eberhardt
# Updated:  01-JAN-2021
# Status:   Live




function Connect-MeToTheO365Service {
  <#
  .SYNOPSIS
    Short description
  .DESCRIPTION
    Long description
  .PARAMETER Service

  .PARAMETER AccountId
    Optional String. Instructs connecting with this Account
  .PARAMETER OverrideAdminDomain
    Situational String. For connection to Skype Online in Hybrid Scenarios only
  .EXAMPLE
    Connect-MeToTheO365Service -Service AzureAd - AccountId John@domain.com
    Connects to the AzureAd Service of the Domain.com Tenant with John@domain.com
  .EXAMPLE
    Connect-MeToTheO365Service -MicrosoftTeams AzureAd - AccountId John@domain.com
    Connects to the Teams (FrontEnd) Service of the Domain.com Tenant with John@domain.com
  .EXAMPLE
    Connect-MeToTheO365Service -Service AzureAd - AccountId John@domain.com [-OverrideAdminDomain domain.onmicrosoft.com]
    Connects to the Teams (Backend) Service of the Domain.com Tenant with John@domain.com
    Optionally, in Hybrid Scenarios, the OverrideAdminDomain can be used to connect
  .INPUTS
    Inputs to this cmdlet (if any)
  .OUTPUTS
    Output from this cmdlet (if any)
  .NOTES
    Only starts to connect if the Test Cmdlet could not determine a valid connection
  .COMPONENT
    Session
  .ROLE
    Session Connection
  .FUNCTIONALITY
    Imports and verifies Module is present, whether a Session is already created
  #>

  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [ValidateSet('AzureAd', 'MicrosoftTeams', 'SkypeOnline', 'ExchangeOnlineManagement')]
    [string]$Service,

    [Parameter()]
    [string]$AccountId,

    [Parameter()]
    [string]$OverrideAdminDomain
  )

  begin {
    #Show-FunctionStatus -Level Live
    #Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

    if (-not $PSBoundParameters.ContainsKey('Debug')) { $DebugPreference = $PSCmdlet.SessionState.PSVariable.GetValue('DebugPreference') } else { $DebugPreference = 'Continue' }

    # preparing Splatting Object
    $ConnectionParameters = $null
    $ConnectionParameters += @{'ErrorAction' = 'Stop' }
    $ConnectionParameters += @{'WarningAction' = 'Continue' }

    if ($PSBoundParameters.ContainsKey('Verbose')) {
      $ConnectionParameters += @{ 'Verbose' = $true }
    }
    if ($PSBoundParameters.ContainsKey('Debug')) {
      $ConnectionParameters += @{ 'Debug' = $true }
    }

  }

  process {
    #Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    try {
      $ServiceConnected = $null
      $ServiceConnected = switch ($Service) {
        'AzureAd' { Test-AzureAdConnection }
        'MicrosoftTeams' { Test-MicrosoftTeamsConnection }
        'SkypeOnline' { Test-SkypeOnlineConnection }
        'ExchangeOnlineManagement' { Test-ExchangeOnlineConnection }
      }

      if ( -not $ServiceConnected ) {
        if ( $Service -eq 'ExchangeOnlineManagement' ) {
          if ($PSBoundParameters.ContainsKey('AccountId')) {
            $ConnectionParameters += @{ 'UserPrincipalName' = $AccountId }
          }
          $ConnectionParameters += @{ 'ShowProgress' = $true }
          $ConnectionParameters += @{ 'ShowBanner' = $false }
        }
        else {
          if ($PSBoundParameters.ContainsKey('AccountId')) {
            $ConnectionParameters += @{ 'AccountId' = $AccountId }
          }
        }

        # Handling OverrideAdminDomain
        if ( $OverrideAdminDomain ) {
          $ConnectionParameters += @{ 'OverrideAdminDomain' = $OverrideAdminDomain }
        }

        # DEBUG Information
        if ( $PSBoundParameters.ContainsKey('Debug') ) {
          "Function: $($MyInvocation.MyCommand.Name): Parameters:", ($ConnectionParameters | Format-Table -AutoSize | Out-String).Trim() | Write-Debug
        }

        $ConnectionFeedback = $null
        $ConnectionFeedback = switch ($Service) {
          'AzureAd' { Connect-AzureAD @ConnectionParameters }
          'MicrosoftTeams' {
            try {
              Connect-MicrosoftTeams @ConnectionParameters
            }
            catch {
              [void]$ConnectionParameters.Remove('AccountId')
              Connect-MicrosoftTeams @ConnectionParameters
            }
          }
          'SkypeOnline' {
            [void]$ConnectionParameters.Remove('AccountId')
            Connect-SkypeOnline @ConnectionParameters
          }
          'ExchangeOnlineManagement' { Connect-ExchangeOnline @ConnectionParameters }
        }

        return $ConnectionFeedback
      }
      else {
        Write-Warning -Message "$Service - Connection already established. If reconnect is desired, please disconnect this seesion first!"
      }
    }
    catch {
      Write-Error -Message "$Service - Connection failed to establish. Please run connect command manually. Exception message: $($_.Exception.Message)"
    }
  }

  end {
    #Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  }
} # Connect-MeToThe365Service
