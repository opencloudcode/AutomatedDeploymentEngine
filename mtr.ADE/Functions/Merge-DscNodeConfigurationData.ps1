
function Merge-DscNodeConfigurationDataFile{
##NOT CURRENTLY USED OR TESTED
	[string]$AllNodesPath,
	[string]$RoleInformationPath

	$AllNodes = (Import-PowerShellDataFile -Path $AllNodesPath).AllNodes
	$RoleInformation = (Import-PowerShellDataFile -Path $RoleInformationPath).RoleInformation

	Merge-DscNodeConfigurationData -AllNodes $AllNodes -RoleInformation $RoleInformation
}


function Merge-DscNodeConfigurationData{
    [CmdLetBinding()]
    Param(
        [Alias('Nodes')]
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [object[]]$AllNodes,

        [Alias('Roles')]
        [ValidateNotNullOrEmpty()]
        [object[]]$RoleInformation
    )

    foreach($node in $AllNodes){
        $matchedRole = $false
        #You have a node
        #Loop through all roles, to find a match

        foreach($role in $roleInformation){
            if($role.matchValue -eq '*' -and $node[$role.matchKey] -eq '*'){
                Write-Verbose "$($role.matchKey)=$($node[$role.matchKey]) -> Matches shared node '$($role.matchValue)'"
                #Only execute for the * shared node key
                $matchedRole = $true
            }
            elseif($role.matchValue -ne '*' -and $node[$role.matchKey] -like $role.matchValue){
                Write-Verbose "$($role.matchKey)=$($node[$role.matchKey]) -> Matches '$($role.matchValue)'"  
                $matchedRole = $true
            }
            else{
                #Keep looking
            }


            if($matchedRole -eq $true){
                Write-Verbose "Merging Data for $($Node.NodeName) from $($role.RoleID) : $($role.Role)"
                foreach($roleKey in $role.Keys.Where({$_ -ne 'MatchKey' -and $_ -ne 'MatchValue'})){
                    if(-not($node.Contains($roleKey))){
                        Write-Verbose "Adding $roleKey"
                        $node.Add($roleKey, $role[$roleKey])
                    }
                    else{
                        Write-Verbose "Updating $roleKey"
                        $node[$roleKey] = $role[$roleKey]
                    }
                }
            }
            $matchedRole = $false
        }
    
    }
    <#
    foreach($role in $roleInformation){
        $matchKey   = $role.MatchKey
        $matchValue = $role.MatchValue
        $matchedValue = $false
        Write-Verbose "Key to match = $matchKey"
        Write-Verbose "Value to match = $matchValue"

        if($matchKey -ne $null -and $matchValue -ne $null){
            foreach($node in $AllNodes){
                if($matchValue -eq '*'){
                    if($node[$matchKey] -eq $matchValue){
                        $matchedNode = $true
                        Write-Verbose "$matchKey=$($node[$matchKey]) -> Matches '$matchValue'"
                        #This is the shared key and it hasn't already been matched
                    }
                }
                elseif($matchValue -ne '*' -and $node[$matchKey] -like $matchValue){
                    $matchedNode = $true
                    Write-Verbose "$matchKey=$($node[$matchKey]) -> Matches '$matchValue'"
                    #This is NOT the shared key, the value is like what we're looking for, and it hasn't already been found
                }
                else{
                    Write-Verbose "$matchKey=$($node[$matchKey]) -> DOES NOT MATCH '$matchValue'"
                }

                if($matchedNode -eq $true){
                    Write-Verbose "Match found for $($node.NodeName)"
                    foreach($roleKey in $role.Keys.Where({$_ -ne 'MatchKey' -and $_ -ne 'MatchValue'})){
                        if(-not($node.Contains($roleKey))){
                            Write-Verbose "Adding $roleKey"
                            $node.Add($roleKey, $role[$roleKey])
                        }
                        else{
                            Write-Verbose "Updating $roleKey"
                            $node[$roleKey] = $role[$roleKey]
                        }
                    }
                    
                    #break
                }
            }
        }
        else{
            #Return an error message that match options were empty
        }
    }
       #>

	[hashtable]$ConfigData = @{}
	$ConfigData.AllNodes = $AllNodes
    Write-Output $ConfigData
}
