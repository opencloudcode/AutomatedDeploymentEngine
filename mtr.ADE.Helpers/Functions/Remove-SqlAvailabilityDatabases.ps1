$contentDB = @{Name = 'LeeTest2'; Server = 'lrs-ci-dacd-02\dacd'}
    #Remove-SPWebApplication $App -confirm:$false -DeleteIISSite #-RemoveContentDatabases #Don't let SharePoint remove the DB's

foreach($database in $ContentDB.Name) {
    $AG = Get-SqlAvailabilityGroup -Server $ContentDb.Server -Database $database
    
    if($AG -ne $null){
        $ComputerName = ($AG.CurrentPrimary.Split('\')[0])

        $DbPath = "SQLSERVER:\Sql\$($AG.CurrentPrimary)\AvailabilityGroups\$($AG.Name)\AvailabilityDatabases\$($database)"

        $sb = {
            Remove-SqlAvailabilityDatabase -Path $Using:DbPath
        }
        Invoke-Command -ScriptBlock $sb -ComputerName $ComputerName
        
        Remove-SqlDatabase -Server $AG.CurrentSecondary -Database $database -Verbose
        Remove-SqlDatabase -Server $AG.CurrentPrimary -Database $database -Verbose
    }
    else {
        Remove-SqlDatabase -Server $contentDB.Server -Database $contentDb.Name -Verbose
    }
}