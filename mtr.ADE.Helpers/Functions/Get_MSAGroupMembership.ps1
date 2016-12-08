$groups = Get-ADGroup -SearchBase "OU=Data Collections, DC=DataCollections, DC=Production" -Filter *

foreach ($group in $groups){
    Get-ADGroupMember -Identity $group | % {
        if ($_.name -eq 'sa_ILAppPool'){
            $properties = [Ordered]@{
                Account = $_.Name
                MemberOf = $group.Name
                Path = $group.DistinguishedName
            }
            $returnobj = New-Object -TypeName PSObject -Property $properties
            Write-Output $returnobj
        }           
    }
}
