function New-CertificateLibrary {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true, 
                   ValueFromPipelineByPropertyName=$true)]
        [ValidateScript({if (Test-Path $_){throw "File already exists"}})]
        [string]$Path
    )

    $l = @{
        CertificateLibrary = @(

        )
    }

    Export-PowerShellDataFile -ConfigurationData $l -FilePath $path
    
}