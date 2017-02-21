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


function Get-SqlAvailabilityGroup {
    [CmdLetBinding()]
    Param(
        [Parameter(ParameterSetName ='ByAvailabilityGroup')]
        [Alias('AGName')]
        [string]$AvailabilityGroupName,

        [Parameter(ParameterSetName ='ByDatabase')]
        [string]$Database,

        [Parameter(Mandatory=$true)]
        [string]$Server
    )

    if($PSCmdlet.ParameterSetName -eq 'ByAvailabilityGroup'){
        Write-Verbose "Querying for $AvailabilityGroupName on $Server"
        $SqlAG = (Invoke-Sqlcmd -QueryTimeout 60 -Query "select * from sys.availability_groups where name = '$($AvailabilityGroupName)'" -ServerInstance $Server -SuppressProviderContextWarning)
        if ($SqlAg -eq $null){
            Write-Verbose "$AvailabilityGroupName not found on $Server"
        }
    }
    elseif($PSCmdLet.ParameterSetName -eq 'ByDatabase'){
        Write-Verbose "Querying for $Database on $Server"
        $SqlAG = (Invoke-Sqlcmd -QueryTimeout 60 `
                  -Query "select * from sys.availability_groups where group_id in (select group_id from sys.availability_databases_cluster where database_name = '$($Database)')" -ServerInstance $Server -SuppressProviderContextWarning) 

        if ($SqlAg -eq $null){
            Write-Verbose "$Database not found on $Server"
        }
    }
    else{
        $SqlAG = (Invoke-Sqlcmd -QueryTimeout 60 `
                  -Query "select * from sys.availability_groups" -ServerInstance $Server -SuppressProviderContextWarning)
    }

    foreach ($grp in $sqlAg){
        $output = @{
            Name = $grp.Name; 
            Group_Id = $grp.group_Id
        }

        $PrimaryReplica = (Invoke-SqlCmd -QueryTimeout 60 `
                            -Query "SELECT primary_replica FROM sys.dm_hadr_availability_group_states WHERE group_id = '$($grp.group_id)'" `
                            -ServerInstance $Server `
                            -SuppressProviderContextWarning).primary_replica 
        

        $replicas = (Invoke-Sqlcmd -QueryTimeout 0 `
                    -Query "select * from sys.availability_replicas where replica_id in 
                            (select replica_id from sys.dm_hadr_availability_replica_states where group_id = '$($grp.Group_Id)')" `
                    -ServerInstance $PrimaryReplica)
        
        if($replicas -eq $null){
            $output.Replicas = 'NONE'
        }
        else{
            $output.Replicas = $replicas

            foreach ($replica in $output.Replicas) {
                $role = (Invoke-SqlCmd -queryTimeout 0 `
                        -Query "select role_desc from sys.dm_hadr_availability_replica_states 
                                where group_id = '$($output.Group_Id)' and replica_id = '$($replica.replica_id)'" `
                        -ServerInstance $PrimaryReplica).Role_Desc
                
                switch($role) {
                    'PRIMARY' {
                        $output.CurrentPrimary += $replica.replica_server_name
                    }
                    'SECONDARY' {
                        $output.CurrentSecondary += @($replica.replica_server_name)
                    }
                }
            }
        }

        $returnObj = New-Object -TypeName PSObject -Property $output
        Write-Output $returnObj
    }
}