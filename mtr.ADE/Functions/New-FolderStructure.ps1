<#
.DESCRIPTION
Creates folder structure defined in a hashtable array, under the specified path
	
.EXAMPLE
$Structure = @( #Notice this is an array, containing one or more hashtables
	@{
		Name = "First child folder"; 
		Children = @(
			@{Name = "Second Tier First Child""}
			@{Name = "Second Tier Second Child; Children = @(
				@{Name = "Third Tier First Child"}
			)}
		)
	}
)

New-FolderStructure -Path C:\Test -FolderStructure $Structure

The above example will create the following folder structure

C:\Test
->First Child Folder
  |-->Second Tier First Child
  |-->Second Tier Second Child
      |-->Third Tier First Child
	  
.OUTPUTS
	Nothing without verbose
#>

function New-FolderStructure{
	[CmdLetBinding(ConfirmImpact='Medium')]
	Param(
		[Parameter(Mandatory=$true, HelpMessage='object array of folders to create under "Path"')]
		[ValidateNotNullOrEmpty()]
		[object[]]$FolderStructure,
		
		[Parameter(Mandatory=$true,
				   Position=0,
				   ValueFromPipeline=$true,
				   ValueFromPipelineByPropertyName=$true,
				   HelpMessage="One or more paths to create folder structure. Must already exist.")]
		[Alias("PSPath")]
		[ValidateNotNullOrEmpty()]
		[ValidateScript({Test-Path $_})]
		[string[]]$Path
	)

	foreach($folder in $FolderStructure){
		$itemName = $Folder.Name
		$itemPath = (Join-Path -Path $ParentPath -ChildPath $ItemName)
		if(-not(Test-Path $itemPath)){
			Write-Verbose "$itemPath not found"
			New-Item -Path $itemPath -ItemType Directory
			Write-Verbose "$itemPath created"
		}
		else{
			Write-Verbose "$itemPath already exists - nothing changed"
		}
		if($Folder.Children.Count -gt 0)
		{
			New-FolderStructure -FolderStructure $folder.Children -Path $itemPath
		}
	}
}