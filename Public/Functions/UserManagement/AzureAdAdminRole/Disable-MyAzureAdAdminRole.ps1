# Module:   TeamsFunctions
# Function: Testing
# Author:   David Eberhardt
# Updated:  13-MAR-2021
# Status:   Beta




function Disable-MyAzureAdAdminRole {
  <#
  .SYNOPSIS
    Activates Azure Ad Admin Roles for currently connected User
  .DESCRIPTION
    Activates Azure Active Directory Privileged Identity Management Admin Roles for the currently connected User.
    Requires a Connection to AzureAd
  .EXAMPLE
    Disable-MyAzureAdAdminRole
  .INPUTS
    None
  .OUTPUTS
    System.Void - If executed from shell
    Boolean - If called by other CmdLets
  .NOTES
    None
  .COMPONENT
    UserManagement
  .FUNCTIONALITY
    Disables eligible Privileged Identity roles for Administration of Teams for the currently connected on User
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  .LINK
    about_UserManagement
  .LINK
    Connect-Me
  .LINK
    Assert-MicrosoftTeamsConnection
  .LINK
    Disable-AzureAdAdminRole
  .LINK
    Disable-MyAzureAdAdminRole
  .LINK
    Get-AzureAdAdminRole
  .LINK
    Get-MyAzureAdAdminRole
  #>

  [CmdletBinding()]
  [Alias('dar')]
  [OutputType([Boolean])]
  param() #param

  begin {
    Show-FunctionStatus -Level Live
    #Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

    # Asserting AzureAD Connection
    if (-not (Assert-AzureADConnection)) { break }

    # Setting Preference Variables according to Upstream settings
    if (-not $PSBoundParameters.ContainsKey('Verbose')) { $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference') }
    if (-not $PSBoundParameters.ContainsKey('Confirm')) { $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference') }
    if (-not $PSBoundParameters.ContainsKey('WhatIf')) { $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference') }
    if (-not $PSBoundParameters.ContainsKey('Debug')) { $DebugPreference = $PSCmdlet.SessionState.PSVariable.GetValue('DebugPreference') } else { $DebugPreference = 'Continue' }
    if ( $PSBoundParameters.ContainsKey('InformationAction')) { $InformationPreference = $PSCmdlet.SessionState.PSVariable.GetValue('InformationAction') } else { $InformationPreference = 'Continue' }

    $Stack = Get-PSCallStack
    $Called = ($stack.length -ge 3)

  } #begin

  process {
    #Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    try {
      $PIMavailable = Get-Command -Name 'Get-AzureADMSPrivilegedRoleAssignment' -ErrorAction Stop
      #region Activating Admin Roles
      if ( $PIMavailable ) {
        try {
          $AzureAdFeedback = Get-AzureADCurrentSessionInfo
          $DeactivatedRoles = Disable-AzureAdAdminRole -Identity "$($AzureAdFeedback.Account)" -PassThru -Force -ErrorAction Stop #(default should only enable the Teams ones? switch?)
          if ( $DeactivatedRoles -or $DeactivatedRoles.Count -gt 0 ) {
            return $(if ($Called) { $DeactivatedRoles } else {
                Write-Information "Disable-MyAzureAdAdminrole - $($DeactivatedRoles.Count) Roles deactivated." -InformationAction Continue
                Write-Output $DeactivatedRoles
              })
          }
          else {
            return $(if ($Called) { $DeactivatedRoles } else {
                Write-Information 'Disable-MyAzureAdAdminrole - No Roles deactivated, the following roles are active' -InformationAction Continue
                Get-MyAzureAdAdminRole
              })
          }
        }
        catch {
          $Exception = $_.Exception.Message
          return $(if ($Called) { $false } else {
              if ($Exception -contains 'The following policy rules failed: ["MfaRule"]') {
                Write-Information 'Disable-MyAzureAdAdminrole - No valid authentication via MFA is present. Please authenticate again and retry' -InformationAction Continue
              }
              else {
                Write-Information 'Disable-MyAzureAdAdminrole - Privileged Identity Management could not be contacted' -InformationAction Continue
                throw "$($Exception)"
              }
            })
        }
      }
      else {
        return $(if ($Called) { $false } else {
            Write-Information 'Disable-MyAzureAdAdminrole - Privileged Identity Management is not enabled for this tenant' -InformationAction Continue
          })
      }
      #endregion
    }
    catch {
      return $(if ($Called) { $false } else {
          Write-Information 'Disable-MyAzureAdAdminrole - Privileged Identity Management functions are not available' -InformationAction Continue
        })
    }
  } #process

  end {
    #Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} # Disable-MyAzureAdAdminrole
