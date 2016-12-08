
function Restore-DatabaseWithMove{
    [CmdLetBinding(SupportsShouldProcess=$true, ConfirmImpact='High')]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$ComputerName,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$SqlInstance,

        [Parameter(Mandatory=$true)]
        [Alias('BackupFilePath')]
        [ValidateScript({Test-Path $_})]
        [string]$FilePath,

        [Parameter(Mandatory=$true)]
        [switch]$ReplaceDatabase,

        [Parameter(ParameterSetName='Differential')]
        [Alias('Diff')]
        [ValidateScript({Test-Path $_})]
        [string]$DifferentialBackupFilePath,

        [Parameter(Mandatory=$false)]
        [string]$LocalCachePath = "D:\",

        [Parameter(Mandatory=$false)]
        [switch]$PerformHash

    )

    BEGIN{
        Import-Module SqlPS -DisableNameChecking
        $sqlServer = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server "$ComputerName\$SqlInstance"
        $sqlServer.ConnectionContext.StatementTimeout = 3600
        if($SqlServer.Status -eq $null){
            $SqlStatus = "Failed"      
            Write-Verbose "$ComputerName -> $SqlInstance's status is $SqlStatus" 
        }
        else{
            $SqlStatus   = $SqlServer.Status
            $defaultFile = $SqlServer.Settings.DefaultFile
            $defaultLog  = $SqlServer.Settings.DefaultLog

            if($defaultFile.Length -eq 0){$defaultFile = $sqlServer.Information.MasterDBPath}
            if($defaultLog.Length -eq 0) {$defaultLog  = $sqlServer.Information.MasterDBLogPath}

            Write-Verbose "$ComputerName -> $SqlInstance's status is $SqlStatus"       
        }
    }
    PROCESS{
        if($SqlStatus -ne 'Failed'){
            #Test if file is available locally to target SQL server

            if($FilePath.StartsWith('\\') `
            -OR ((Test-Path -Path "\\$ComputerName\$($FilePath.Replace(':','$'))") -eq $false)){

                [System.IO.FileSystemInfo]$fileInfo = Get-Item $FilePath

                Write-Verbose "$($fileInfo.Name) is in remote location...checking for local copy in $LocalCachePath"
                $remoteCache     = Join-Path -Path "\\$ComputerName" -ChildPath $LocalCachePath.Replace(':','$')
                $remoteCacheItem = Join-Path -Path $remoteCache -ChildPath "$($fileInfo.Name)"

                if((Test-Path $remoteCacheItem) -eq $false){
                    Write-Verbose "$($fileInfo.Name) not found in $LocalCachePath. Will copy"
                    Copy-Item -Path "Microsoft.PowerShell.Core\FileSystem::$($fileInfo.FullName)" -Destination "Microsoft.PowerShell.Core\FileSystem::$remoteCacheItem" -Force 
                }
                if(($performHash -eq $true) -OR ((Test-Path $remoteCacheItem) -eq $false)){
                    $hashSource = (Get-FileHash $FilePath -Algorithm MD5).Hash
                    $hashDest   = (Get-FileHash $remoteCacheItem -Algorithm MD5).Hash

                    if($hashSource -ne $hashDest){
                        Write-Verbose "Source file hash '$hashSource' does not match destination hash '$hashDest', copying file"
                        Copy-Item -Path "Microsoft.PowerShell.Core\FileSystem::$($fileInfo.FullName)" -Destination "Microsoft.PowerShell.Core\FileSystem::$remoteCache" -Force
                    }
                    else{
                        Write-Verbose "Local item found with matching file hash"
                    }
                }
                $localFilePath = "$localCachePath\$($fileInfo.Name)"
                Write-Verbose "$($fileInfo.Name) available locally as  --> $localFilePath"
            }
            else{
                $localFilePath = $FilePath
            }

            Write-Verbose "Processing -> $localFilePath"
            Write-Verbose "Creating new Restore Job"
            $restoreJob = @{}
            $restoreJob.Add("BackupFile", $localFilePath)
                 
            $backupDevice    = New-Object -TypeName Microsoft.SqlServer.Management.Smo.BackupDeviceItem ($localFilePath, [Microsoft.SqlServer.Management.Smo.DeviceType]::File)          
            $databaseRestore = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Restore 
            $databaseRestore.NoRecovery = $false
            $databaseRestore.ReplaceDatabase = $ReplaceDatabase
            $databaseRestore.Devices.Add($backupDevice)

            if($PSCmdLet.ShouldProcess("$ComputerName - $SqlInstance:: Restore $localFilePath")){
                $fileList = $databaseRestore.ReadFileList($sqlServer) | Select LogicalName, Type, PhysicalName, TDEThumbprint
                $restoreJob.Add('Filelist', $fileList)
 
                foreach($file in $fileList){
                    $restoreFile = New-Object -TypeName Microsoft.SqlServer.Management.Smo.RelocateFile
                    $restoreFile.LogicalFileName = $file.LogicalName
                    switch($file.Type){
                        'D'{
                            $databaseRestore.Database = $file.LogicalName
                            $restoreJob.Add("Database", $file.LogicalName)
                            $restoreFile.PhysicalFileName = "$defaultFile$($file.LogicalName).mdf"
                        }
                        'L'{
                            $restoreFile.PhysicalFileName = "$defaultLog$($file.LogicalName).ldf"
                        }
                    }  
                    $id = $databaseRestore.RelocateFiles.Add($restoreFile)               
                }

                try{
                    Write-Verbose "Restoring $($databaseRestore.Database)"
                    $databaseRestore.SqlRestore($sqlServer)
                    Write-Verbose "Finished: $($databaseRestore.Database)" 
                }
                catch{
                    Write-Error "ERROR: While restoring $($databaseRestore.Database)"  
                    $restoreJob.Add("ErrorInformation", $Error[0]) 
                }
                finally{
                    $restoreJobs += $restoreJob
                }
            }
            #$databaseRestore.Devices.Clear()              
            
        }
    }
    END{
        $Properties = [ordered]@{
            SqlServer        = $ComputerName
            SqlInstance      = $SqlInstance
            SqlStatus        = $SqlStatus
            DefaultFile      = $defaultFile
            DefaultLog       = $defaultLog
            Database         = $restoreJob.Database
            FileList         = $restoreJob.FileList
            ErrorInformation = $restoreJob.ErrorInformation
        }

        $returnObject = New-Object -TypeName PSObject -Property $Properties
        Write-Output $returnObject    
    }
}

