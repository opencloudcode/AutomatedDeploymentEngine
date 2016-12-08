<#

.EXAMPLE 
    $Dictionary = Import-Csv -Path "F:\Management\Source\ConfigFiles\DCFT URI List.csv" | Select-Object @{Name="From"; Expression={$_.LegacyURI}}, @{Name="To"; Expression={$_.DesiredURI}}
    $Files = (Get-Childitem .\WebConfigFiles -recurse -Include "*.config").FullName
    Update-Content -Path $Files -Dictionary $Dictionary -Verbose
#>
function Update-ContentUsingDictionary{
    [CmdletBinding()]
    [OutputType([string])]
    Param(
        [Parameter(Mandatory=$true,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName=$true,
                   HelpMessage = "Full path to one or more input files, does not accept wildcards",
                   Position=0)]
        [Alias('PSPath', 'FullName')]
        [string[]]$Path,

        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   HelpMessage = 'Object Array of HashTables representing values to find and replace')]
        [Alias('Lookup')]
        [object[]]$Dictionary
    )

    Begin{
        if(($Dictionary.From.Count -le 0) -or ($Dictionary.To.Count -le 0)){
            throw "Invalid Dictionary: 'From' count = $($Dictionary.From.Count) -> 'To' count = $($Dictionary.To.Count)"
        }
    }
    Process{
        foreach($File in $Path){
            Write-Verbose "Processing $File"
            $content = Get-Content -Path $File
            $updatedContent = @()
            foreach($contentLine in $content){
                foreach($Entry in $Dictionary){
                    if($contentLine.ToLower().Contains($Entry.From.ToLower())){
                        Write-Verbose "Replacing $($Entry.From) -> $($Entry.To)"
                        $contentLine = $contentLine.Replace($Entry.From, $Entry.To)
                    }
                }
                $updatedContent += $contentLine
            }    
            $updatedContent | Set-Content $File -Force
            $updatedContent = $null
        }#END: foreach($content in $Path)
    }
    End{

    }
}
