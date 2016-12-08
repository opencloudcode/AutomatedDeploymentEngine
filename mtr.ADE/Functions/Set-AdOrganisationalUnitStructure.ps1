
function Set-ADOrganisationalUnitStructure {
	<#
	.Synopsis

	.DESCRIPTION
	Function that checks for, and creates required OU structures. 

	OU Structures are represented as Hash Table items in a single parent Object Array. See examples for clarity.
	
		
	.EXAMPLE
	$RootDN = (Get-ADDomain).DistinguishedName
	$ChildOUs = @(
		@{
			Name = "Top Tier OU"; 
			Description = "The first container, also containin the default OUs"; 
			ContainsDefaultOUs = $true; 
			Children = @(
				@{Name = "Second Tier OU"; Description = "A second tier container"}
				@{Name = "Another Second Tier OU"; Description = "Another second tier container, containing the default OUs"; ContainsDefaultOUs = $true}
			)
		}
	)

	$DefaultOUs = @(
		@{Name = "Computers"}
		@{Name = "Users"}
		@{Name = "Service Accounts"}

	Set-AdOrganisationalUnitStructure -ParentDistinguishedName $RootDN -Children $ChildOUs -DefaultOUs $DefaultOUs -CreateIfAbsent $true -Verbose

	In this example, the following steps are performed:
	1. The Distinguished Name for the domain is retrieved and assigned to the $RootDN variable.
	2. An Object array is created containing one or more Hash Tables representing the OU structure to be created. 
		*Any OUs that must also contain the default OUs, have the ContainsDefaultOUs property set to $true
	3. An Object array is created containing one or more Hash Tables that represent the default OUs that may be created under one or more OUs.
	4. The Set-AdOrganisationalUnitStructure  funciton is called using the previously created variables. 
		The 'CreateIfAbsent' flag is set to $true in order to create the OUs - this value is $false by default in order to protect from accidental creations

	.OUTPUTS
		AdOrganisationalUnit object.
	.FUNCTIONALITY

	#>

	Param(
		[CmdletBinding(SupportsShouldProcess=$true,
                       ConfirmImpact='Low')]
		[Parameter(Mandatory = $true)]
		[ValidateNotNullOrEmpty()]			   
        [string]$ParentDistinguishedName,
		
		[ValidateNotNullOrEmpty()]
		[Parameter(Mandatory = $true)]
        [object[]]$Children,
		
        [object[]]$DefaultOUs,
		
        [bool]$PreventAccidentalDeletion = $true
    )
    $returnObj = @()

    foreach($Child in $Children){
        #Check for each OU and create if appropriate
        if($Child.Name -eq $null){break}
        $OUtoAssert = "OU=$($Child.Name),$ParentDistinguishedName"
        Write-Output "OU to Assert = $OUtoAssert"

        $OU = Get-ADOrganizationalUnit -Filter {DistinguishedName -eq $OUtoAssert} -ErrorAction SilentlyContinue
		if($OU -eq $null){
			Write-Verbose "-->$($child.Name) not found under $ParentDistinguishedName"
			if($PSCmdLet.ShouldProcess("Create $($Child.Name) OU")){
				Write-Verbose "-->Creating $childName Organisational Unit under $ParentDistinguishedName"
				New-ADOrganizationalUnit -Name $($child.Name) -DisplayName $($child.Name) `
					-Path $ParentDistinguishedName `
					-Description "Automatically Created" `
					-ProtectedFromAccidentalDeletion $PreventAccidentalDeletion
			}
		    $OU = Get-ADOrganizationalUnit -Filter {DistinguishedName -eq $OUtoAssert}
		    $returnObj += $newOU

		}
        if($Child.ContainsDefaultOUs -eq $true){
            Set-ADOrganisationalUnitStructure -ParentDistinguishedName $OU.DistinguishedName -Children $DefaultOUs -DefaultOUs $DefaultOUs
        }

        if($Child.Children.Count -gt 0){
            Set-ADOrganisationalUnitStructure -ParentDistinguishedName $OU.DistinguishedName -Children $child.Children -DefaultOUs $DefaultOUs
        }
    }
    Write-Output $returnObj
}
