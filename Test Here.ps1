$here = Split-Path -Parent $MyInvocation.MyCommand.Path

$module = 'TeamsFunctions'


$functions = Get-ChildItem -Directory $here\Public,$here\Private -Include "*.ps1" -ExClude "*.Tests.ps1" -Recurse
$functions