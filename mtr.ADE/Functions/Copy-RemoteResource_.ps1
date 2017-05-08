<#
.SYNOPSIS
    Short description
.DESCRIPTION
    Long description
.EXAMPLE
    Example of how to use this cmdlet
.EXAMPLE
    Another example of how to use this cmdlet
.INPUTS
    Inputs to this cmdlet (if any)
.OUTPUTS
    Output from this cmdlet (if any)
.NOTES
    General notes
.COMPONENT
    The component this cmdlet belongs to
.ROLE
    The role this cmdlet belongs to
.FUNCTIONALITY
    The functionality that best describes this cmdlet
#>


function Copy-RemoteResource {

    [CmdletBinding()]
    Param(
        [Alias('Share')]
        [string]$SourceShare,

        [Alias('ChildPath')]
        [string[]]$SourcePath,

        [Alias('Directory')]
        [switch]$Container, 

        [Alias('Destination')]
        [string[]]$LocalPath = 'C:\BUILD', 

        [Alias('Mount')]
        [string]$PSDriveName = 'BUILD',

        [pscredential]$Credential,

        [switch]$PassThru, 
        [switch]$Recurse,
        [switch]$Force
    )

    BEGIN {
        $ErrorActionPreference
        foreach ($path in $LocalPath){
            if(-not(Test-Path -Path $path -PathType Container)){
                if($Force -eq $true){
                    Write-Verbose "Destination '$LocalPath' does not exist. Will create"
                    $f = New-Item -ItemType Directory -Path $LocalPath
                    if($PassThru){Write-Output $f}
                }
                else{
                    Write-Error -Message "$path does not exist" -RecommendedAction "Try again using the -Force switch if you want to create the target directories"
                }
            }
        }
        Write-Verbose "Creating PSDrive '$PSDriveName' for '$SourceShare'"
        New-PSDrive -Name $PSDriveName -PSProvider FileSystem -Root $SourceShare -Credential $Credential
    }

    PROCESS {


        Write-Verbose "Copying contents of '$SourceShare\$SourcePath' to '$LocalPath'"
        Copy-Item -Path (Join-Path -Path "$($PSDriveName):" -ChildPath $SourcePath) -Container:$Container -Destination $LocalPath -Recurse:$Recurse -Force:$force -PassThru:$PassThru
    }

    END {
        Write-Verbose "Removing PSDrive '$PSDrive'"
        Remove-PSDrive -Name $PSDriveName
    }
}