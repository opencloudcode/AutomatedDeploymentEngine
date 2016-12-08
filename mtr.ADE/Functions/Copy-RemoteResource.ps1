function Copy-RemoteResource {
    Param(
        [string]$SourceShare,
        [string]$SourcePath,
        [switch]$Container, 
        [string]$LocalPath = 'C:\BUILD', 
        [string]$PSDriveName = 'BUILD',
        [pscredential]$Credential
    )

    if(-not(Test-Path $LocalPath)){New-Item -ItemType Directory -Path $LocalPath}

    New-PSDrive -Name $PSDriveName -PSProvider FileSystem -Root $SourceShare -Credential $Credential
    Copy-Item -Path (Join-Path -Path "$($PSDriveName):" -ChildPath $SourcePath) -Container:$Container -Destination $LocalPath -Recurse -Force
    Remove-PSDrive -Name $PSDriveName

}