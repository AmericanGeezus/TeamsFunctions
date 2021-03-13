# Module:   TeamsFunctions
# Function: Testing
# Author:		David Eberhardt
# Updated:  13-MAR-2021
# Status:   Live




function Enable-MyAzureAdAdminRole {
  <#
	.SYNOPSIS
		Activates Azure Ad Admin Roles for currently connected User
	.DESCRIPTION
		Activates Azure Active Directory Privileged Identity Management Admin Roles for the currently connected User.
    Requires a Connection to AzureAd
	.EXAMPLE
		Enable-MyAzureAdAdminRole
  .INPUTS
    None
  .OUTPUTS
    Boolean if called
    None if executed from shell
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  .LINK
    Connect-Me
  .LINK
    Assert-MicrosoftTeamsConnection
  .LINK
    Enable-AzureAdAdminRole
	#>

  [CmdletBinding()]
  [OutputType([Boolean])]
  param() #param

  begin {
    Show-FunctionStatus -Level Live
    #Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

    # Asserting AzureAD Connection
    if (-not (Assert-AzureADConnection)) { break }

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
          $ActivatedRoles = Enable-AzureAdAdminRole -Identity $AzureAdFeedback.Account -PassThru -Force -ErrorAction Stop #(default should only enable the Teams ones? switch?)
          if ( $ActivatedRoles.Count -gt 0 ) {
            return $(if ($Called) { $ActivatedRoles } else {
                Write-Information "Enable-MyAzureAdAdminrole - $($ActivatedRoles.Count) Roles activated." -InformationAction Continue
                Write-Output $ActivatedRoles
              })
          }
        }
        catch {
          return $(if ($Called) { $false } else {
              Write-Information 'Enable-MyAzureAdAdminrole - Privileged Identity Management is not enabled for this tenant' -InformationAction Continue
            })
        }
      }
      else {
        return $(if ($Called) { $false } else {
            Write-Information 'Enable-MyAzureAdAdminrole - Privileged Identity Management is not enabled for this tenant' -InformationAction Continue
          })
      }
      #endregion
    }
    catch {
      return $(if ($Called) { $false } else {
          Write-Information 'Enable-MyAzureAdAdminrole - Privileged Identity Management functions are not available' -InformationAction Continue
        })
    }
  } #process

  end {
    #Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} # Enable-MyAzureAdAdminRole
