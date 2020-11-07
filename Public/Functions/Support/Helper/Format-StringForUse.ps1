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
  .EXAMPLE
    Format-StringForUse  -InputString "<my>\Test(String)"
    Returns "<my>\TestString". All SpecialChars defined will be removed.
  .EXAMPLE
    Format-StringForUse  -InputString "<my>\Test(String)" -SpecialChars "\"
    Returns "myTest(String)". All SpecialChars defined will be removed.
  .EXAMPLE
    Format-StringForUse -InputString "<my>\Test(String)" -As UserPrincipalName
    Returns "myTestString" for UserPrincipalName does not support any of the special characters
  .EXAMPLE
    Format-StringForUse  -InputString "<my>\Test(String)" -As DisplayName
    Returns "myTest(String)" for DisplayName does not support some special characters
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
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
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
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Format-StringForUse
