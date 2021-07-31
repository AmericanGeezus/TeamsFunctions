# Module:   TeamsFunctions
# Function: Lookup
# Author:	  David Eberhardt
# Updated:  10-JAN-2021
# Status:   Live




function Remove-TeamsFunctionsGlobalVariable {
  <#
  .SYNOPSIS
    Removes Global Variables set by CmdLets in TeamsFunctions
  .DESCRIPTION
    Global Variables are set during the session which may include Tenant Data
    These Variables are removed with this Command
  .EXAMPLE
    Remove-TeamsFunctionsGlobalVariable
    Removes all Global Variables set by CmdLets in TeamsFunctions
  .INPUTS
    System.Void
  .OUTPUTS
    System.Void
  .FUNCTIONALITY
    Helper Function
  #>

  param ()
  #Show-FunctionStatus -Level Live

  <# Previous implementation, removal of all variables by name, now removing all that are starting with "TeamsFunctions"
  $VariableNames = @(
    #"TeamsFunctionsMSTelephoneNumbers", # Used for Microsoft TelephoneNumbers from the Tenant - no longer used.
    'TeamsFunctionsMSAzureAdLicenses', # Used for all Licensing commands
    'TeamsFunctionsMSAzureAdLicenseServicePlans', # Used for all Licensing commands
    'TeamsFunctionsTenantAzureAdGroups' # Used for CallableEntity cmdLets that query groups
  )

  $null = (Remove-Variable -Name $VariableNames -Scope Global -ErrorAction SilentlyContinue)
  #>
  $null = (Remove-Variable -Name TeamsFunctions* -Scope Global -ErrorAction SilentlyContinue)

} #Remove-TeamsFunctionsGlobalVariable
