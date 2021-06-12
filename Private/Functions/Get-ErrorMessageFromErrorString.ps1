# Module:     TeamsFunctions
# Function:   UserAdmin
# Author:     David Eberhardt
# Updated:    20-DEC-2020
# Status:     Beta




function Get-ErrorMessageFromErrorString {
  <#
  .SYNOPSIS
    Extracts Message from an AzureAd Error Message
  .DESCRIPTION
    AzureAd Error Messages are displayed as a multi-line string.
    This CmdLet splits the string and returns the third line (Message) only
  .PARAMETER Exception
    String returned by an AzureAd CmdLet
  .EXAMPLE
    Get-ErrorMessageFromErrorString $_
    Returns String with the Message only
  .EXAMPLE
    $_ | Get-ErrorMessageFromErrorString
    Returns String with the Message only
  .INPUTS
    System.String
  .OUTPUTS
    System.String
  .NOTES
    Use in a CATCH Block to pass the Exception from TRY to this command.
    V1 will only return a String with the message
    V2 may return a better Error-Object
  .COMPONENT
    ErrorHandling
  .FUNCTIONALITY
    Translates Exception Multi-Line String to Exception Message (single line string)
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  .LINK
    about_SupportingFunctions
  .LINK
    Get-ErrorMessageFromErrorString
  #>

  [CmdletBinding()]
  [OutputType([System.String])]

  param(
    [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = 'Enter the identity of the Admin Account')]
    [Alias('Message', 'String')]
    [string]$Exception
  ) #param

  begin {
    Show-FunctionStatus -Level Beta
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"
    Write-Verbose -Message "Need help? Online:  $global:TeamsFunctionsHelpURLBase$($MyInvocation.MyCommand)`.md"

    $Stack = Get-PSCallStack
    $Called = ($stack.length -ge 3)

    # Setting Preference Variables according to Upstream settings
    if (-not $PSBoundParameters.ContainsKey('Verbose')) { $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference') }
    if (-not $PSBoundParameters.ContainsKey('Debug')) { $DebugPreference = $PSCmdlet.SessionState.PSVariable.GetValue('DebugPreference') } else { $DebugPreference = 'Continue' }
    if ( $PSBoundParameters.ContainsKey('InformationAction')) { $InformationPreference = $PSCmdlet.SessionState.PSVariable.GetValue('InformationAction') } else { $InformationPreference = 'Continue' }

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    $Message = $Exception.Split("`n")[2]

    Write-Output $Message
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Get-ErrorMessageFromErrorString
