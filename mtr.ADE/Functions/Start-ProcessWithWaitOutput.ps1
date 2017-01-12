function Start-ProcessWithWaitOutput {
    Param(
        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory=$true, ValueFromPipeline = $true)]
        [string]$FileName,

        [Parameter(Mandatory=$false)]
        [string]$Arguments
    )

    $pInfo = New-Object System.Diagnostics.ProcessStartInfo
    $pInfo.FileName = $FileName
    $pinfo.RedirectStandardError = $true
    $pinfo.RedirectStandardOutput = $true
    $pinfo.UseShellExecute = $false
    $pinfo.Arguments = $Arguments

    $p = New-Object System.Diagnostics.Process
    $p.StartInfo = $pinfo
    $p.Start() | Out-Null
    $p.WaitForExit()

    Write-Output $p
}