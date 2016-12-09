# Automated Deployment Engine (ADE)
The aim of ADE is to simplify the process of Infrastructure deployments, agnostic to the hosting provider. 

While services such as Azure provide a rich feature set to aid in the deployment and configuration of IaaS resources,  
using such features cause vendor lock-in.  

ADE is a configure first tool set, meaning that it relies heavily on the configuration files; currently PowerShell Data Files (.psd1).  

This is still a very early release and is worked on as and when I get time. Feedback is appreciated but support may be slow.


## Project Layout
### mtr.ADE
The main PowerShell module - this may get split out in the future in an attempt to provide a more succinct set of functionality.

### mtr.ADE.ConfigurationData
Currently holding a single example of 'RoleInformation.psd1'. Part of the mtr.ADE module is responsible for;

* Create a list of nodes with information specific to the environment.
```powershell 
@(
    @{
        NodeName = 'MY-SERVER-01'
        CertificatePath = '\\SomeServer\SomeShare\Certs\MY-SERVER-01.cer'
        CertificateThumprint = 'A1C1ACACACACACACACACAC'
    }
    @{
        ...
    }
)
```

* Look in RoleInformation for a match, based on MatchKey and MatchValue
* Copy any keys from a matching role, into the node's information object
* Export the merged object to a PSD1 file for later use

### mtr.ADE.Deploy
Will be responsible for the deployment of Virtual Machines. This may include uploading the module and configuration data 
as artifacts for full deployment. 

### mtr.ADE.Helpers
Currently a set of helper and proxy scripts, making up the manual aspects of deployment. Over time, these should be 
integrated into the main module and provide a fully automated experience. Although providing a set of operational 
functions is also an aim of ADE