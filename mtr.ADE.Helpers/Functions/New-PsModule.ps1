# We cloned our project to C:\sc\PSStackExchange
$Path = 'C:\sc\PSStackExchange'
$ModuleName = 'PSStackExchange'
$Author = 'RamblingCookieMonster'
$Description = 'PowerShell module to query the StackExchange API'

# Create the module and private function directories
mkdir $Path\$ModuleName
mkdir $Path\$ModuleName\Private
mkdir $Path\$ModuleName\Public
mkdir $Path\$ModuleName\en-US # For about_Help files
mkdir $Path\Tests

#Create the module and related files
New-Item "$Path\$ModuleName\$ModuleName.psm1" -ItemType File
New-Item "$Path\$ModuleName\$ModuleName.Format.ps1xml" -ItemType File
New-Item "$Path\$ModuleName\en-US\about_PSStackExchange.help.txt" -ItemType File
New-Item "$Path\Tests\PSStackExchange.Tests.ps1" -ItemType File
New-ModuleManifest -Path $Path\$ModuleName\$ModuleName.psd1 `
                   -RootModule $Path\$ModuleName\$ModuleName.psm1 `
                   -Description $Description `
                   -PowerShellVersion 3.0 `
                   -Author $Author `
                   -FormatsToProcess "$ModuleName.Format.ps1xml"