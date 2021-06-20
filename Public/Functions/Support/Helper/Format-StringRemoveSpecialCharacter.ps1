# Module:   TeamsFunctions
# Function: Support
# Author:   Francois-Xavier Cat
# Updated:  03-MAY-2020
# Status:   Live




function Format-StringRemoveSpecialCharacter {
  <#
  .SYNOPSIS
    This function will remove the special character from a string.
  .DESCRIPTION
    This function will remove the special character from a string.
    I'm using Unicode Regular Expressions with the following categories
    \p{L} : any kind of letter from any language.
    \p{Nd} : a digit zero through nine in any script except ideographic
    http://www.regular-expressions.info/unicode.html
    http://unicode.org/reports/tr18/
  .PARAMETER String
    Specifies the String on which the special character will be removed
  .PARAMETER SpecialCharacterToKeep
    Specifies the special character to keep in the output
  .EXAMPLE
    Format-StringRemoveSpecialCharacter -String "^&*@wow*(&(*&@"
    wow
  .EXAMPLE
    Format-StringRemoveSpecialCharacter -String "wow#@!`~)(\|?/}{-_=+*"
    wow
  .EXAMPLE
    Format-StringRemoveSpecialCharacter -String "wow#@!`~)(\|?/}{-_=+*" -SpecialCharacterToKeep "*","_","-"
    wow-_*
  .INPUTS
    System.String
  .OUTPUTS
    System.String
  .NOTES
    Originally written by:
    Francois-Xavier Cat
    @lazywinadmin
    lazywinadmin.com
    github.com/lazywinadmin
  .COMPONENT
    SupportingFunction
  .FUNCTIONALITY
    Reformats a string to be used; Removes special Characters in the process
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Format-StringRemoveSpecialCharacter.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_Supporting_Functions.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  #>

  [CmdletBinding()]
  [OutputType([String])]
  param
  (
    [Parameter(Mandatory, Position = 0, ValueFromPipeline, HelpMessage = 'String to reformat')]
    [ValidateNotNullOrEmpty()]
    [Alias('Text')]
    [System.String[]]$String,

    [Alias('Keep')]
    #[ValidateNotNullOrEmpty()]
    [String[]]$SpecialCharacterToKeep
  ) #param

  begin {
    Show-FunctionStatus -Level Live
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"
    Write-Verbose -Message "Need help? Online:  $global:TeamsFunctionsHelpURLBase$($MyInvocation.MyCommand)`.md"


  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    try {
      if ($PSBoundParameters['SpecialCharacterToKeep']) {
        $Regex = '[^\p{L}\p{Nd}'
        foreach ($Character in $SpecialCharacterToKeep) {
          if ($Character -eq '-') {
            $Regex += '-'
          }
          else {
            $Regex += [Regex]::Escape($Character)
          }
          #$Regex += "/$character"
        }

        $Regex += ']+'
      } #IF($PSBoundParameters["SpecialCharacterToKeep"])
      else { $Regex = '[^\p{L}\p{Nd}]+' }

      foreach ($Str in $string) {
        Write-Verbose -Message "Original String: $Str"
        $Str -replace $regex, ''
      }
    }
    catch {
      $PSCmdlet.ThrowTerminatingError($_)
    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Format-StringRemoveSpecialCharacter
