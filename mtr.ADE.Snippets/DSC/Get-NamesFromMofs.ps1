#Build list of computers based on available MOFs
$MofPath   = '.'
$computers = (get-childitem -Path $MofPath).BaseName.Replace(".meta","") | Get-Unique

Test-DscConfiguration -ComputerName $computers -Path $MofPath
Set-DscLocalConfiguration -ComputerName $computers -Path $MofPath
Start-DscConfiguration -ComputerName $computers -Path $MofPath