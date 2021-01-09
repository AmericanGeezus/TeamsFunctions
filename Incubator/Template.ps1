# Module:   TeamsFunctions
# Function:
# Author:	  David Eberhardt
# Updated:  xx-xxxx-2021
# Status:   Alpha




function Verb-Noun {
  <#
  .SYNOPSIS
    Short description
  .DESCRIPTION
    Long description
  .PARAMETER Identity
    x
  .PARAMETER x
    x
  .EXAMPLE
    Verb-Noun -Identity John@domain.com
    xx
  .INPUTS
    System.String
  .OUTPUTS
    System.Object
  .NOTES
    xx
  .COMPONENT
    xx
  .ROLE
    xx
  .FUNCTIONALITY
    xx
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  .LINK
    Verb2-Noun
  #>

  [CmdletBinding()]
  [Alias('')]
  [OutputType([PSCustomObject])]
  param (
    [Parameter(Mandatory, Position = 0, HelpMessage = "Username(s)")]
    [Alias('', '')]
    [string[]]$Identity,

    [Parameter(HelpMessage = "")]
    [Alias('')]
    [String]$x

  )

  begin {
    Show-FunctionStatus -Level Alpha
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

    foreach ($Id in $Identity) {
      Write-Verbose -Message "[PROCESS] Processing '$Id'"



    } #foreach Identity

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Verb-Noun