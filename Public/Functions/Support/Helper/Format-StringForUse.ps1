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
		Special Characters in strings usually lead to terminating errors.
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
  .EXAMPLE
    Format-StringForUse  -InputString "1 (555) 1234-567" -As E164
    Returns "+15551234567" for LineURI does not support spaces, dashes, parenthesis characters and must start with "+"
  .EXAMPLE
    Format-StringForUse  -InputString "1 (555) 1234-567" -As LineURI
    Returns "tel:+15551234567" for LineURI does not support spaces, dashes, parenthesis characters and must start with "tel:+"
  .INPUTS
    System.String
  .OUTPUTS
    System.String
  .NOTES
    None
  .COMPONENT
    SupportingFunction
	.FUNCTIONALITY
    Reformats a string to be used as an E.164 Number, LineUri/TelUri, DisplayName or UserPrincipalName; Removes special Characters in the process
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  .LINK
    about_SupportingFunction
  .LINK
    Format-StringForUse
  .LINK
    Format-StringRemoveSpecialCharacter
	#>

  [CmdletBinding(DefaultParameterSetName = 'Manual')]
  [OutputType([String])]
  param(
    [Parameter(Mandatory, Position = 0, ValueFromPipeline, HelpMessage = 'String to reformat')]
    [string]$InputString,

    [Parameter(HelpMessage = 'Replacement character or string for each removed character')]
    [string]$Replacement = '',

    [Parameter(ParameterSetName = 'Specific')]
    [ValidateSet('UserPrincipalName', 'DisplayName', 'E164', 'LineURI')]
    [string]$As,

    [Parameter(ParameterSetName = 'Manual')]
    [string]$SpecialChars = '?()[]{}'
  ) #param

  begin {
    Show-FunctionStatus -Level Live
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"
    Write-Verbose -Message "Need help? Online:  $global:TeamsFunctionsHelpURLBase$($MyInvocation.MyCommand)`.md"

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    switch ($PsCmdlet.ParameterSetName) {
      'Specific' {
        switch ($As) {
          'UserPrincipalName' {
            $CharactersToRemove = '\%&*+/=?{}|<>();:,[]"'
            $CharactersToRemove += "'´"
          }
          'DisplayName' {
            #$CharactersToRemove = '\%*+/=?{}|<>[]"'
            $CharactersToRemove = '\%*+=?{}|<>[]"'
          }
          'E164' {
            $CharactersToRemove = '\%*/@:=-()?{}|<>[]" abcdefghijklmnopqrstuvwxyz;'

            if ( $Replacement -ne '') {
              Write-Warning -Message "Replacement is not allowed for '$As'. Ignoring input"
              $Replacement = '' # Replacement is not allowed
            }
          }
          'LineURI' {
            $CharactersToRemove = '\%*/-()?{}|<>[]" abcdfghijkmnopqrsuvwyz'

            if ( $Replacement -ne '') {
              Write-Warning -Message "Replacement is not allowed for '$As'. Ignoring input"
              $Replacement = '' # Replacement is not allowed
            }
          }
        }
      }
      'Manual' { $CharactersToRemove = $SpecialChars }
      Default { }
    }

    $rePattern = ($CharactersToRemove.ToCharArray() | ForEach-Object { [regex]::Escape($_) }) -join '|'

    if ($As -eq 'E164') {
      # Truncating Extension if specified ";ext=" if specified
      $InputString = $InputString.split(';')[0]
    }

    [String]$String = $InputString -replace $rePattern, $Replacement

    if ($As -eq 'UserPrincipalName') {
      # Validate User Side of a UPN does not end in a '.'
      [String]$OutputString = $String.replace('.@', '@');
      if ( $($String.split('@')[0]).length -gt 64 ) {
        Write-Error -Message 'UserPrincipalName - Prefix (User) must not exceed 64 characters' -Category LimitsExceeded -ErrorAction Stop
      }
      if ( $($String.split('@')[1]).length -gt 48 ) {
        Write-Error -Message 'UserPrincipalName - Suffix (Domain) must not exceed 48 characters' -Category LimitsExceeded -ErrorAction Stop
      }
    }
    elseif ($As -eq 'E164') {
      switch -regex ($String) {
        '^\d' { [String]$OutputString = '+' + $String; Break }
        '^\+\d' { [String]$OutputString = $String; Break }
        default {
          if ($String -match '\+') {
            [String]$OutputString = '+' + $String.replace('+', '');
          }
          Break
        }
      }
      if ( -not $OutputString ) {
        [String]$OutputString = ''
      }
    }
    elseif ($As -eq 'LineURI') {
      switch -regex ($String) {
        '^\d' { [String]$OutputString = 'tel:+' + $String; Break }
        '^\+\d' { [String]$OutputString = 'tel:' + $String; Break }
        '^tel:\+\d' { [String]$OutputString = $String; Break }
        '^tel:\d' { [String]$OutputString = $String -replace 'tel:', 'tel:+'; Break }
      }
      if ( -not $OutputString ) {
        [String]$OutputString = ''
      }
    }
    else {
      [String]$OutputString = $String
    }

    return $OutputString
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Format-StringForUse
