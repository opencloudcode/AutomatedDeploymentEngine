Get-Module -Name "mtr.ADE*" | Remove-Module

Import-Module ActiveDirectory
Import-Module mtr.ADE


$Environment = 'SI'
$SqlInstance = 'DEDS'
$IsAlwaysOnConfigured = $true
$IsAlwaysOnWaitTimeInSeconds = 10


$ComputerName =  "DCS-$($Environment)-$($SqlInstance)D-02" , "DCS-$($Environment)-$($SqlInstance)D-01"
$AgtAcct     = "sa_$($SqlInstance)D_SqlAgnt"
$DbeAcct     = "sa_$($SqlInstance)D_SqlDBE"

$AgtPw = New-ComplexPassword -PasswordLength 200
$DbePw = New-ComplexPassword -PasswordLength 200

Set-ADuser -Identity $AgtAcct -Enabled $true
Set-ADAccountPassword -Identity $AgtAcct -NewPassword (ConvertTo-SecureString -string $AgtPw -Force -AsPlainText)

Set-ADuser -Identity $DbeAcct -Enabled $true
Set-ADAccountPassword -Identity $DbeAcct -NewPassword (ConvertTo-SecureString -string $DbePw -Force -AsPlainText)

Sleep 5

foreach($Computer in $ComputerName){

    $AgtSvcName = "SqlAgent`$$SqlInstance"
    $DbeSvcName = "MsSql`$$SqlInstance"

    $AgtSvc = Get-Service -ComputerName $Computer -Name $AgtSvcName
    $DbeSvc = Get-Service -ComputerName $Computer -Name $DbeSvcName

    $AgtSvc | Stop-Service -Force
    $DbeSvc | Stop-Service
    
    Set-ServiceIdentity -ComputerName $Computer -Filter "DisplayName = 'SQL Server Agent ($SqlInstance)'" -Domain "$Env:UserDomain" -Identity "$AgtAcct" -Password $AgtPw -Verbose
    Set-ServiceIdentity -ComputerName $Computer -Filter "DisplayName = 'SQL Server ($SqlInstance)'" -Domain "$Env:UserDomain" -Identity "$DbeAcct" -Password $DbePw -verbose

    $DbeSvc | Start-Service
    $AgtSvc | Start-Service

    if($IsAlwaysOnConfigured-eq$true)
    {
       Write-Host "Waiting for Always On to Sync after a Service Restart". -ForegroundColor Red
       Sleep $IsAlwaysOnWaitTimeInSeconds
    }
}

$Properties = @{
    $AgtAcct = $AgtPw
    $DbeAcct = $DbePw
}

$Result = New-Object -TypeName PSObject -Property $Properties
Write-Output $Result