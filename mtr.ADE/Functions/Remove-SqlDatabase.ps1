<#
.SYNOPSIS
    Short description
.DESCRIPTION
    Long description
.EXAMPLE
    PS C:\> <example usage>
    Explanation of what the example does
.INPUTS
    Inputs (if any)
.OUTPUTS
    Output (if any)
.NOTES
    General notes
#>
function Remove-SqlDatabase {
    [CmdLetBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [Alias('Server')]
        [string[]]$SqlServer,

        [Parameter(Mandatory=$true)]
        [string[]]$Database
    )

    Begin{

    }
    Process{
        foreach ($Server in $SqlServer){
            foreach($db in $Database){
                switch((Get-SqlDatabase -Name $db -ServerInstance $Server).Status){
                    "Normal" {
                        $query = "alter database $($db) set single_user with rollback immediate; drop database $($db)"    
                    }
                    "Restoring" {
                        $query = "drop database $($db)"
                    }
                    Default {
                        $query = "drop database $($db)"
                    }
                    
                }
            
                Write-Verbose "Removing '$db' from '$server' using query '$query'"
                Invoke-Sqlcmd -QueryTimeout 0 `
                -Query $query `
                -ServerInstance $Server `
                -SuppressProviderContextWarning
            }
        }
    }

    End{}

}
