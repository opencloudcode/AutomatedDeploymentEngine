function Export-PowerShellDataFile{
    <#
    .Synopsis

    .DESCRIPTION
		Writes a PowerShell Data File, appends date-time group to filename if already exists
    .EXAMPLE

    .OUTPUTS
       [String]
    .FUNCTIONALITY

    #>
    [CmdletBinding()]
    param(
        [Alias('Config')]
        [Parameter(Mandatory=$true,
            ValueFromPipeLine=$true,
            ValueFromPipeLineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [hashtable]$ConfigurationData,
        [parameter(Mandatory=$true)][string]$FilePath,
		[int]$IndentCount = 4 #Default is 4 * IndentCharacter
    )

    
    Write-Verbose "Processing $($ConfigurationData.Count) Configuration Items"

    $output = @()   
    $output += ConvertTo-PowerShellDataFileNode -Node $ConfigurationData -IndentCount $IndentCount -IndentLevel 0

    $outputFilePath = [System.IO.Path]::GetDirectoryName($FilePath)
    $outputFileName = [System.IO.Path]::GetFileNameWithoutExtension($FilePath)
    $outputFileExtn = "psd1"

    $OutputFile = Join-Path -Path $outputFilePath -ChildPath "$outputFileName.$outputFileExtn"# -Resolve
    if((Test-Path $OutputFile) -and $UpdateExisting -ne $true){
        $outPutFile = "$outPutFilePath\$outputFileName" + "_$(Get-Date -format 'yyyyMMdd-HHmmss').$outputFileExtn"
    }

    $output | Out-File -FilePath $outputFile -Encoding utf8
    Write-Verbose "Processing completed successfully, data written to $outputFile"
	Write-Output $outputFile
}


function ConvertTo-PowerShellDataFileNode{
    <#
    .Synopsis

    .DESCRIPTION
		Helper function that parses and returns a formatted node, including indentation
    .EXAMPLE

    .EXAMPLE

    .EXAMPLE

    .EXAMPLE

    .OUTPUTS
       [String]
    .FUNCTIONALITY

    #>
    Param(
        $Node,
		[int]$IndentCount,
		[int]$IndentLevel
    )

    $_nodeEntry = @()
    $_nodeEntry += (New-IndentedString -Value "@{" -IndentLevel $IndentLevel)
    $IndentLevel++

    foreach($_Key in $Node.Keys){
        $LastNodeCheck = $false
        $_Value = $Node[$_Key]
        if($_Value.GetType().Name -eq 'Object[]'){
            $_nodeEntry += (New-IndentedString -Value "$_Key = @(" -IndentLevel $IndentLevel)
            if($_Value.Count -gt 0){$IndentLevel++}			

            for($childIndex = 0; $childIndex -lt $_Value.Count; $childIndex++){
                if($childIndex -eq $_Value.Count -1){
                    $LastNodeCheck = $true
                }
                $_childEntry = ConvertTo-PowerShellDataFileNode $_Value[$childIndex] `
								-IndentCharacter $IndentCharacter `
								-IndentCount $IndentCount `
								-IndentLevel ($IndentLevel)

                $_nodeEntry += $_childEntry
            }
            if($_Value.Count -gt 0){$IndentLevel--}

            $_nodeEntry += (New-IndentedString -Value ");" -IndentLevel $IndentLevel)
        }
        else{
            if($_Value.GetType() -eq [bool]){
                $quotedValue = '$' + "$_Value"
            }
            else{
                $quotedValue = "'$_Value'"
            }
            $_nodeEntry += (New-IndentedString -Value "$_Key = $quotedValue" -IndentLevel $IndentLevel)
        }
    }  

    $IndentLevel--
    $_nodeEntry += New-IndentedString -Value "}" -IndentLevel $IndentLevel

    Write-Output $_nodeEntry
}