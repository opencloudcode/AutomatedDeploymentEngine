function Assert-ADComputerOU{
    <#
    .Synopsis

    .DESCRIPTION

    .EXAMPLE

    .EXAMPLE

    .EXAMPLE

    .EXAMPLE

    .OUTPUTS
       [String]
    .FUNCTIONALITY

    #>
    Param(
        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory = $true)][hashtable]$RoleInformation,
        [Parameter(Mandatory = $true)][hashtable]$OUInformation
    )

    foreach($item in $RoleInformation){
        if($item.RoleID.Contains('-')){
            $roleID = "*" + $item.RoleID
        }
        else{$roleID = "*" + $item.RoleID + "-*"}
        $servers = Get-ADComputer -SearchBase $OUInformation.DefaultComputersOU -Filter "name -like '$roleID'"
        foreach($server in $servers)
        {
            #Set server description based on role information
            $server | Set-ADComputer -Description $item.RoleDescription
            if($item.RoleType -eq "Solution"){$roleParent = $OUInformation.SolutionOU}
            elseif($item.RoleType -eq "Infrastructure"){$roleParent = $OUInformation.InfrastructureOU}

            #Check location of computer account, move into appropriate OU if required.
            $computerOUFilter = "OU=Computers,OU=$($Item.RoleOU),$roleParent"
            $computerOU = Get-ADOrganizationalUnit -Filter {DistinguishedName -eq $computerOUFilter}
            $server | Move-ADObject -TargetPath $computerOU.DistinguishedName
        }
    }
}
