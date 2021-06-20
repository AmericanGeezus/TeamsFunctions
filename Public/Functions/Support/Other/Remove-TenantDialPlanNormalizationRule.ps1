# Module:     TeamsFunctions
# Function:   Other
# Author:    Jeff Brown
# Updated:    01-SEP-2020
# Status:     Unmanaged




function Remove-TenantDialPlanNormalizationRule {
  <#
  .SYNOPSIS
    Removes a normalization rule from a tenant dial plan.
  .DESCRIPTION
    This command will display the normalization rules for a tenant dial plan in a list with
    index numbers. After choosing one of the rule index numbers, the rule will be removed from
    the tenant dial plan. This command requires a remote PowerShell session to Teams.
    Note: The Module name is still referencing Skype for Business Online (SkypeOnlineConnector).
  .PARAMETER DialPlan
    This is the name of a valid dial plan for the tenant. To view available tenant dial plans,
    use the command Get-TeamsTDP.
  .EXAMPLE
    Remove-TenantDialPlanNormalizationRule -DialPlan US-OK-OKC-DialPlan
    Displays available normalization rules to remove from dial plan US-OK-OKC-DialPlan.
  .INPUTS
    System.String
  .OUTPUTS
    System.Void - Default Behavior
    System.Object - With Switch PassThru
  .NOTES
    The dial plan rules will display in format similar the example below:
    RuleIndex Name            Pattern    Translation
    --------- ----            -------    -----------
    0 Intl Dialing    ^011(\d+)$ +$1
    1 Extension Rule  ^(\d{5})$  +155512$1
    2 Long Distance   ^1(\d+)$   +1$1
    3 Default         ^(\d+)$    +1$1
  .COMPONENT
    TeamsSession
  .FUNCTIONALITY
    Removes a Normalisation Rule from a Tenant Dial Plan - This script is untested and unmanaged
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Remove-TenantDialPlanNormalizationRule.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_Unmanaged.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  #>

  [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
  param(
    [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = 'Enter the name of the dial plan to modify the normalization rules.')]
    [string]$DialPlan
  ) #param

  begin {
    Show-FunctionStatus -Level Unmanaged
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"
    Write-Verbose -Message "Need help? Online:  $global:TeamsFunctionsHelpURLBase$($MyInvocation.MyCommand)`.md"

    # Asserting MicrosoftTeams Connection
    if (-not (Assert-MicrosoftTeamsConnection)) { break }

    # Setting Preference Variables according to Upstream settings
    if (-not $PSBoundParameters.ContainsKey('Verbose')) { $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference') }
    if (-not $PSBoundParameters.ContainsKey('Confirm')) { $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference') }
    if (-not $PSBoundParameters.ContainsKey('WhatIf')) { $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference') }
    if (-not $PSBoundParameters.ContainsKey('Debug')) { $DebugPreference = $PSCmdlet.SessionState.PSVariable.GetValue('DebugPreference') } else { $DebugPreference = 'Continue' }
    if ( $PSBoundParameters.ContainsKey('InformationAction')) { $InformationPreference = $PSCmdlet.SessionState.PSVariable.GetValue('InformationAction') } else { $InformationPreference = 'Continue' }

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    $dpInfo = Get-CsTenantDialPlan -Identity $DialPlan -WarningAction SilentlyContinue -ErrorAction SilentlyContinue

    if ($null -ne $dpInfo) {
      $currentNormRules = $dpInfo.NormalizationRules
      [int]$ruleIndex = 0
      [int]$ruleCount = $currentNormRules.Count
      [array]$ruleArray = @()
      [array]$indexArray = @()

      if ($ruleCount -ne 0) {
        foreach ($normRule in $dpInfo.NormalizationRules) {
          $output = [PSCustomObject][ordered]@{
            'RuleIndex'   = $ruleIndex
            'Name'        = $normRule.Name
            'Pattern'     = $normRule.Pattern
            'Translation' = $normRule.Translation
          }

          $ruleArray += $output
          $indexArray += $ruleIndex
          $ruleIndex++
        } # End of foreach ($normRule in $dpInfo.NormalizationRules)

        # Displays rules to the screen with RuleIndex added
        $ruleArray | Out-Host

        do {
          $indexToRemove = Read-Host -Prompt 'Enter the Rule Index of the normalization rule to remove from the dial plan (leave blank to quit without changes)'

          if ($indexToRemove -NotIn $indexArray -and $indexToRemove.Length -ne 0) {
            Write-Warning -Message 'That is not a valid Rule Index. Please try again or leave blank to quit.'
          }
        } until ($indexToRemove -in $indexArray -or $indexToRemove.Length -eq 0)

        if ($indexToRemove.Length -eq 0) { RETURN }

        # If there is more than 1 rule left, remove the rule and set to new normalization rules
        # If there is only 1 rule left, we have to set -NormalizationRules to $null
        if ($ruleCount -ne 1) {
          $newNormRules = $currentNormRules
          [void]$newNormRules.Remove($currentNormRules[$indexToRemove])
          if ($PSCmdlet.ShouldProcess("$DialPlan", 'Set-CsTenantDialPlan')) {
            Set-CsTenantDialPlan -Identity $DialPlan -NormalizationRules $newNormRules
          }
        }
        else {
          if ($PSCmdlet.ShouldProcess("$DialPlan", 'Set-CsTenantDialPlan')) {
            Set-CsTenantDialPlan -Identity $DialPlan -NormalizationRules $null
          }
        }
      }
      else {
        Write-Warning -Message "$DialPlan does not contain any normalization rules."
      }
    }
    else {
      Write-Warning -Message "$DialPlan is not a valid dial plan for the tenant. Please try again."
    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Remove-TenantDialPlanNormalizationRule
