function New-IndentedString{
    <#
    .Synopsis

    .DESCRIPTION
		Helper function to return indented string.

	.PARAMETERS
		[int]IndentCount - Number of spaces to pad, <default = 4>
		[int]IndentLevel - Level of indentation, used as a multiplier of IndentCount

    .EXAMPLE
		Set-Indent "Some Value" -IndentLevel 2

		Expected result "        Some Value"

    .EXAMPLE
		Set-Indent "Some Value' -IndentLevel 2 -IndentCount 2

		Expected result "    Some Value"

    .OUTPUTS
       [string] Return of passed in value with left Padding of IndentCount * IndentLevel
    .FUNCTIONALITY

    #>
    Param(
        [string]$Value,
		[int]$IndentCount = 4,
		[int]$IndentLevel
    )
    $returnStr = ""
    if($IndentLevel -gt 0){
            $returnStr = $Value.PadLeft(($Value).Length + ($IndentLevel * $IndentCount))
    }
    else
    {
        $returnStr = $Value
    }
    return $returnStr
}

