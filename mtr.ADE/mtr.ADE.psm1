#Import functions
Get-ChildItem "$PSScriptRoot\Functions\*.ps1" | %{
	Write-Verbose "Loading $($_.FullName)"
	.$_}

function Get-Function {

}