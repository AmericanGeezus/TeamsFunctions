# Module:   TeamsFunctions
# Function: Helper
# Author:		David Eberhardt
# Updated:  29-OCT-2021
# Status:   Live




function Get-WriteBetterProgressSteps {
  <#
  .SYNOPSIS
    Max number of Steps Write-BetterProgress is used to calculate PercentComplete
  .DESCRIPTION
    Determines the number of times 'Write-BetterProgress' is called in the provided Code
  .EXAMPLE
    Get-WriteBetterProgressSteps
    Runs through the provided Code object (or, if not provided, the code of the calling function)
    Returns integer value for each level discovered
  .PARAMETER Code
    Required. Code to read.
    Planned: If not provided, will use the code of the calling function
  .PARAMETER Levels
    Optional. Number of cascaded levels to use.
    If not provided, will assume single level (ID 0)
  .INPUTS
    System.String, System.Integer
  .OUTPUTS
    System.Object
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  .LINK
    Get-WriteBetterProgressSteps
	#>

  [CmdletBinding()]
  [OutputType([Boolean])]
  param(
    [Parameter(Mandatory)]
    $Code,

    [Parameter()]
    [int]$MaxId = 0
  ) #param

  begin {
    #Show-FunctionStatus -Level Live
    #Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

    # Setting Preference Variables according to Upstream settings
    if (-not $PSBoundParameters.ContainsKey('Verbose')) { $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference') }
    if (-not $PSBoundParameters.ContainsKey('Confirm')) { $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference') }
    if (-not $PSBoundParameters.ContainsKey('WhatIf')) { $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference') }
    if (-not $PSBoundParameters.ContainsKey('Debug')) { $DebugPreference = $PSCmdlet.SessionState.PSVariable.GetValue('DebugPreference') } else { $DebugPreference = 'Continue' }
    if ( $PSBoundParameters.ContainsKey('InformationAction')) { $InformationPreference = $PSCmdlet.SessionState.PSVariable.GetValue('InformationAction') } else { $InformationPreference = 'Continue' }

    #Initialising Counters
    $ScriptAst = [System.Management.Automation.Language.Parser]::ParseInput($Code, [ref] $null, [ref]$null)

    #Retrieving Call Stack
    $Stack = Get-PSCallStack
    $FunctionCalling = $Stack[1].FunctionName
    #$FunctionCalling = $MyInvocation.InvocationName

  } #begin

  process {
    #Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    0..$MaxId | ForEach-Object {
      $Steps = ($ScriptAst.Extent.Text -Split "Write-BetterProgress -Id $_ " | Measure-Object | Select-Object -ExpandProperty Count) -1
      if ($PSBoundParameters.ContainsKey('Debug')) { "Function: '$FunctionCalling': Steps for Level $_`: $Steps" | Write-Debug }
      Write-Output $Steps
    }
  } #process

  end {
    #Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} # Get-WriteBetterProgressSteps
