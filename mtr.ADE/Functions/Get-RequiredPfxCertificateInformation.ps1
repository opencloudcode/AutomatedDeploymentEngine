function Get-RequiredPfxCertificateInformation{
    Param(
        [Parameter(ParameterSetName = 'ByObject',
                   ValueFromPipelineByPropertyName = $true)]
        [object[]]$RoleInformation,

        [Parameter(ParameterSetName = 'ByPath')]
        [string]$CertificateLibraryPath,

        [Parameter(ParameterSetName = 'ByObject',
                   ValueFromPipelineByPropertyName = $true)]
        [object[]]$CertificateLibrary,

        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true)]
        [string[]]$RoleID
    )
    Begin{
        if($PSCmdLet.ParameterSetName -eq 'ByPath'){
            $RoleInformation = Import-PowerShellDataFile -Path $RoleInformationPath.RoleInformation
            $CertificateLibrary = Import-PowerShellDataFile -Path $CertificateLibraryPath.CertificateLibrary 
        }
        
    }
    Process{
        foreach ($Role in $RoleID) {
            #Get a list of hostnames requiring certificate
            $Hostnames = ((($RoleInformation |
                             Where-Object {$_.RoleID -eq $Role}).WebSites.BindingInformation |
                             Where-Object {$_.CertificateRequired}).HostName | Get-Unique)
            
            foreach($Hostname in $Hostnames){
                $Cert = $CertificateLibrary.Where({$_.Hostname -eq $Hostname})
                Write-Output $Cert
            }
        }
    }
}
