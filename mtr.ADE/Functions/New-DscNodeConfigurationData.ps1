function New-DscNodeConfigurationData{
    <#
    .Synopsis

    .DESCRIPTION
		1. Creates a ConfigurationData HashTable object.
		2. Loops through all computers specified, checking the central cert store for the <computername>.cer public cert.
		3. Creates an AllNodes entry with all computers, certificate paths, and thumbprints required.
        4. Error information is added to an AllErrors object array.
        5. Metadata about the ConfigurationData generation is added to an 'Information' object array and hashtable.
        6. ConfigurationData HashTable is returned.
    .EXAMPLE
		New-DscNodeConfigurationData -Computer Svr1, Svr2, Svr3 -CertificateLocation 'C:\Public Certs'

    .OUTPUTS
		[HashTable] of Configuration Data
    .FUNCTIONALITY

    #>
    [CmdletBinding()]
    param (
        [Alias('Nodes')]
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Computer,
        [Alias('Certs','CertStore')]
        [ValidateNotNullOrEmpty()]
        [string]$CertificateLocation
    )

    $configurationData = @{}
    $allErrors = @()
    $allNodes = @()   
	$allNodesEntry = @{}
    $generatedInformation = @(
        @{
            Username = 'get the current username'
            Domain = 'get the current domain name'
            DateTime = 'get the current date time'
            Computer = 'computername being used'
        }
    )
    $configurationData.Information = $generatedInformation

	$allNodesEntry.NodeName = "*"
    $allNodes += $allNodesEntry

    foreach($name in $Computer){
        $errorInformation = @{}
        $computerInformation = @{}
        $computerInformation.Nodename = $name

        try{
            $certFile = Join-Path $CertificateLocation "$name.cer"
            if($certFile -ne $null){
                Write-Verbose "GET: Certificate information for $name"
                $computerInformation.CertificateFile = $certFile
                Write-Verbose "GET: Certificate path $certFile"
                $computerInformation.Thumbprint = (Get-PfxCertificate -FilePath $certFile).Thumbprint
                Write-Verbose "GET: Certificate thumbprint is $($computerInformation.Thumbprint)"
            }
            else{
                $ErrInformation.Add($name, "Certificate file $name.cer not found in $certificateLocation or could not resolve thumbprint. Ensure file exists and you have permissions to read")
            }
        }
        catch{
            $ErrorInformation.Add($name, $Error)
            Write-Error "Certificate file $name.cer not found in $certificateLocation or could not resolve thumbprint. Ensure file exists and you have permissions to read"
        }
        $allNodes += $computerInformation
    
        if($ErrorInformation.Count -gt 0){
            $allErrors += $ErrorInformation
        }
    }
    $configurationData.AllNodes = $allNodes
    $configurationData.AllErrors = $allErrors
	Write-Output $configurationData
}

