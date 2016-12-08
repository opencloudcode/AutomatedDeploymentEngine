Function Set-Disk {
    Param(
        [int]$DiskNumber,  
        [char]$DriveLetter,
        [string]$FileSystemLabel
    )

    #Configure data disk
    Get-Disk -Number $DiskNumber |
    Initialize-Disk -PartitionStyle GPT -PassThru | 
    New-Partition -UseMaximumSize -DriveLetter $DriveLetter |
    Format-Volume -FileSystem NTFS -NewFileSystemLabel $FileSystemLabel -Confirm:$false
}