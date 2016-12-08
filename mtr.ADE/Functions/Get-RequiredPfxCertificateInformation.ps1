function Get-RequiredPfxCertificateInformation{
    Param(
        [Parameter(ParameterSetName = 'ByPath')]
        [string]$RoleInformationPath,

        [Parameter(ParameterSetName = 'ByObject',
                   ValueFromPipelineByPropertyName = $true)]
        [object[]]$RoleInformation,

        [Parameter(ParameterSetName = 'ByPath')]
        [string]$CertificateLibraryPath,

        [Parameter(ParameterSetName = 'ByObject',
                   ValueFromPipelineByPropertyName = $true)]
        [object[]]$CertificateLibrary,

        [Parameter(ParameterSetName = 'ByPath')]
        [ValidateNotNullOrEmpty()]
        [string]$Environment,
        
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true)]
        [string[]]$RoleGroup
    )
    Begin{
        if($PSCmdLet.ParameterSetName -eq 'ByPath'){
            $RoleInformation = Import-PowerShellDataFile -Path $RoleInformationPath.$Environment
            $CertificateLibrary = Import-PowerShellDataFile -Path $CertificateLibraryPath.$Environment 
        }
        
    }
    Process{
        foreach ($Item in $RoleGroup) {
            #Get a list of hostnames requiring certificate
            $Hostnames = ((($RoleInformation |
                             ? {$_.RoleGroup -eq $Item}).WebSites.BindingInformation |
                             ? {$_.CertificateRequired}).HostName | Get-Unique)
            
            foreach($Hostname in $Hostnames){
                $Cert = $CertificateLibrary.Where({$_.Hostname -eq $Hostname})
                Write-Output $Cert
            }
        }
    }
}
