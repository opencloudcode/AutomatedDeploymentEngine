function Get-DscConfigurationStatusReport{
    [CmdLetBinding()]
    Param(  
        [Parameter(Mandatory = $true)]
        [Alias('NewerThan')]
        [DateTime]$DateFilter,

        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true)]
        [string[]]$ComputerName
    )

    Begin{

    }
    Process{
        foreach($computer in $ComputerName){
            $computerStatus = Get-ChildItem -Path "\\$computer\C$\Windows\System32\Configuration\ConfigurationStatus" -Filter "*.json" | 
                ? {$_.LastWriteTime -gt $DateFilter} | 
                Get-Content -Raw -Encoding Unicode | ConvertFrom-Json

            if($computerStatus[0].GetType() -eq [PSCustomObject]){
                $configurationStatus = $computerStatus
            }
            elseif($computerStatus[0].GetType() -eq [Object[]]){
                $computerStatus | % {$configurationStatus += $_}
            }

            $properties = @{
                Computer = $computer
                ConfigurationStatus = $configurationStatus
            }

            $output = New-Object -TypeName PSObject -Property $properties
            Write-Output $output
        }#END: foreach($computer in $ComputerName) 
    
    }#END: Process
    End{
    
    }
}

<#
$DateThing = (Get-Date).AddHours(-48)

$Result = Get-DscConfigurationStatusReport -DateFilter $DateThing -ComputerName DCS-PD-DEDSA-01

$Result.ConfigurationStatus | Select-Object @{Name='time'; expression={[datetime]$_.time}}, @{Name='type'; expression={$_.type.ToUpper()}}, message
#>
