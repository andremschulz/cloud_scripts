(Get-ChildItem -Path D:\vmware-output -Filter *.html | Sort-Object -Property CreationTime -Descen |select Name, CreationTime |Format-Table).CreationTime.month

$thisMonth = (Get-Date).ToString('MM')
$thisYear = (Get-Date).ToString("yyyy")
$lastMonth = (Get-Date).AddMonths(-1).ToString('MM')
if ( $lastMonth -eq 12 ) { 
	$LastYear = (Get-Date).AddYears(-1).ToString("yyyy")
} else 
{
	$LastYear = (Get-Date).ToString("yyyy")
}



$last_files = Get-ChildItem -Path D:\vmware-output -Filter *.html | where-Object { $_.CreationTime -ge "$lastMonth/01/$LastYear" -and $_.CreationTime -le "$lastMonth/31/$LastYear"}
$new_files = Get-ChildItem -Path D:\vmware-output -Filter *.html | where-Object { $_.CreationTime -ge "$thisMonth/01/$thisYear" -and $_.CreationTime -le "$thisMonth/31/$thisYear"}
$old_csv = $last_files[-1]
$new_csv = $new_files[-1]
$old_csv
$new_csv