function Assert-DscConfigurationNodeProperties{
    <#
    .Synopsis

    .DESCRIPTION
		Helper function that parses two configuration data nodes, ensuring that all parameters are matching
    .EXAMPLE

    .EXAMPLE

    .EXAMPLE

    .EXAMPLE

    .OUTPUTS
       [String]
    .FUNCTIONALITY

    #>
	Param(
		[Parameter(Mandatory=$true)][Hashtable]$AssertNode,
		[Parameter(Mandatory=$true)][Hashtable]$Properties
	)
	$returnObj = @{}

	foreach($Property in $Properties.Keys){
		#Is there a value for property in config data
		if($AssertNode.ContainsKey($Property)){
            $AssertPropertyType = ($AssertNode.$Property).GetType()
			if($AssertPropertyType -ne $Properties.$Property){
				$returnObj.$Property = "The AssertNode data type of $AssertPropertyType does not match the required type of $($Properties.$property)"
			}
		}
		else{
			$returnObj.$Property = "$Property not found for $($AssertNode.NodeName) in Configuration Data"
		}
	}
	return $returnObj
}

