$Context = 'LRS'
$UpdateExisting = $true
$EnvConfig = Import-PowerShellDataFile -Path 'F:\BUILD\DSC\Configuration Data\SecurityGroups.psd1'

##Complete
#$Context = ($EnvConfig.SecurityGroups | ? {$_.Type -eq 'Rights'})

##Selective
$Context = ($EnvConfig.SecurityGroups | ? {$_.Type -eq 'Rights' -and $_.Context -eq $Context})
$DomainDN = (Get-AdDomain).DistinguishedName

foreach($c in $Context){
    foreach ($group in $c.Groups){
        if(-not $c.Path.EndsWith($DomainDN)){
            $c.Path = "$($c.Path),$DomainDn"
        }

        try{
            $groupObject = $null
            $groupObject = Get-AdGroup $group.Name -ErrorAction Ignore
        }
        catch{#Look to remove Try/Catch as long as Get-AdGroup silently fails for null groups
        }

        switch ($c.Type){
            'Roles' {
                $groupScope = [Microsoft.ActiveDirectory.Management.ADGroupScope]::DomainGlobal
            }
            'Rights'{
                $groupScope = [Microsoft.ActiveDirectory.Management.ADGroupScope]::DomainLocal
            }
            Default {}
        }

        $groupProperties = @{
            DisplayName    = $group.Name
            samAccountName = $group.Name
            Description    = $group.Description
            GroupScope     = $groupScope
            GroupCategory  = [Microsoft.ActiveDirectory.Management.ADGroupCategory]::Security     
        }

        if($groupObject -eq $null){
            New-AdGroup -Name $group.Name -Path $c.Path @groupProperties -PassThru
        }
        elseif($updateExisting -eq $true){
            $groupObject | Set-AdGroup @groupProperties -PassThru
        }

        $group.MemberOf | % {
            if(-not([string]::IsNullOrWhiteSpace($_))){
                Add-ADGroupMember -Identity $_ -Members "$($group.Name)$"
            }
        }
    }
}