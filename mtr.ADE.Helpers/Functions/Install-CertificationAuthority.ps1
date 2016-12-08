Function Install-CertificationAuthority {
    Param(
        [String]$ParentCA
    )

    Install-WindowsFeature RSAT-AD-Tools, ADCS-Cert-Authority
    $Domain = Get-AdDomain

    $CertDBPath  = 'F:\CertDB'
    $CertLogPath = 'F:\CertLog'
    $CASubordinateName         = "$($Domain.Name)-IssuingSubordinate"
    $CADistinguishedNameSuffix = $Domain.DistinguishedName
    $CryptoProviderName   = 'RSA#Microsoft Software Key Storage Provider'
    $HashAlgorithm        = 'SHA256'
    $KeyLength            = 2048
    $ValidityPeriod       = 'Years'
    $ValidityPeriodUnits  = 5

    #Create directories
    New-Item -ItemType Directory -Path $CertDBPath, $CertLogPath -ErrorAction SilentlyContinue

    #Configure ADCS
    if([string]::IsNullOrEmpty($ParentCA)){
        Install-AdcsCertificationAuthority `
            -CACommonName "$($Domain.Name)-RootCA" -CADistinguishedNameSuffix $CADistinguishedNameSuffix `
            -CAType EnterpriseRootCA -CryptoProviderName $CryptoProviderName -HashAlgorithmName $HashAlgorithm -KeyLength $KeyLength `
            -DatabaseDirectory $CertDBPath  -LogDirectory $CertLogPath `
            -ValidityPeriod $ValidityPeriod -ValidityPeriodUnits $ValidityPeriodUnits
    }
    else{
        Install-AdcsCertificationAuthority `
            -CACommonName "$($Domain.Name)-IssuingSubordinate" -CADistinguishedNameSuffix $CADistinguishedNameSuffix `
            -CAType EnterpriseSubordinateCA -ParentCA $ParentCA `
            -DatabaseDirectory $CertDBPath  -LogDirectory $CertLogPath            
    }
}