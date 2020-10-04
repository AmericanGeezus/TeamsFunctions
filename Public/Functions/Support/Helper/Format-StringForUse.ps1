# Module:   TeamsFunctions
# Function: AzureAd Licensing
# Author:   Unknown
# Updated:  03-MAY-2020
# Status:   Live

function Format-StringForUse {
  <#
	.SYNOPSIS
		Formats a string by removing special characters usually not allowed.
	.DESCRIPTION
		Special Characters in strings usually lead to terminating erros.
		This function gets around that by formating the string properly.
		Use is limited, but can be used for UPNs and Display Names
		Adheres to Microsoft recommendation of special Characters
	.PARAMETER InputString
		Mandatory. The string to be reformatted
	.PARAMETER As
		Optional String. DisplayName or UserPrincipalName. Uses predefined special characters to remove
		Cannot be used together with -SpecialChars
	.PARAMETER SpecialChars
		Default, Optional String. Manually define which special characters to remove.
		If not specified, only the following characters are removed: ?()[]{}
		Cannot be used together with -As
	.PARAMETER Replacement
		Optional String. Manually replaces removed characters with this string.
  .INPUTS
    System.String
  .OUTPUTS
    System.String
	#>

  [CmdletBinding(DefaultParameterSetName = "Manual")]
  [OutputType([String])]
  param(
    [Parameter(Mandatory, HelpMessage = "String to reformat")]
    [string]$InputString,

    [Parameter(HelpMessage = "Replacement character or string for each removed character")]
    [string]$Replacement = "",

    [Parameter(ParameterSetName = "Specific")]
    [ValidateSet("UserPrincipalName", "DisplayName")]
    [string]$As,

    [Parameter(ParameterSetName = "Manual")]
    [string]$SpecialChars = "?()[]{}"
  ) #param

  begin {
    Show-FunctionStatus -Level Live
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.Mycommand)"

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.Mycommand)"
    switch ($PsCmdlet.ParameterSetName) {
      "Specific" {
        switch ($As) {
          "UserPrincipalName" {
            $CharactersToRemove = '\%&*+/=?{}|<>();:,[]"'
            $CharactersToRemove += "'´"
          }
          "DisplayName" { $CharactersToRemove = '\%*+/=?{}|<>[]"' }
        }
      }
      "Manual" { $CharactersToRemove = $SpecialChars }
      Default { }
    }

    $rePattern = ($CharactersToRemove.ToCharArray() | ForEach-Object { [regex]::Escape($_) }) -join "|"

    $InputString -replace $rePattern, $Replacement
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.Mycommand)"
  } #end
} #Format-StringForUse
