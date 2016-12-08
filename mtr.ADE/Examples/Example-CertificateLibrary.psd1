@{
    CertificateLibrary = @(
		@{
			Hostname = 'mywebsite.com'
			Description = 'Certificate for "MyWebsite.com"'
			CertificateThumbprint = '21BFEC7A488B7441DB5A2A3DCB3FCF680697E120'
			CertificateStore = 'My'
			Path = '\\Source\Dsc\Certificates'
		}
		@{
			Hostname = 'anotherwebsite.com'
			Description = 'Certificate for "anotherwebsite.com"'
			CertificateThumbprint = '21BFEC7A488B7441DB5A2A3DCB3FCF680697E120'
			CertificateStore = 'My'
			Path = '\\Source\Dsc\Certificates'
		}        
    )
}