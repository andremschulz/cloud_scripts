$thisMonth = (Get-Date).ToString('MM')
$thisYear = (Get-Date).ToString("yyyy")
$lastMonth = (Get-Date).AddMonths(-1).ToString('MM')
if ( $lastMonth -eq 12 ) { 
	$LastYear = (Get-Date).AddYears(-1).ToString("yyyy")
} else 
{
	$LastYear = (Get-Date).ToString("yyyy")
}




$vCenters = ""

ForEach ($v in $vCenters) {
	$d11="01/01/2021"
	$d12="01/08/2021"
	$d21="01/08/2021"
	$d22="01/30/2021"
	#$pastFiles = Get-ChildItem -Path D:\vmware-output\CSVs -Filter *.csv | where-Object { $_.CreationTime -ge "$lastMonth/01/$LastYear" -and $_.CreationTime -le "$lastMonth/31/$LastYear"}
	$pastFiles = Get-ChildItem -Path D:\vmware-output\CSVs -Filter "$source*.csv" | where-Object { $_.CreationTime -ge "$d11" -and $_.CreationTime -le "$d12"}
	#$presentFiles = Get-ChildItem -Path D:\vmware-output\CSVs -Filter *.csv | where-Object { $_.CreationTime -ge "$thisMonth/01/$thisYear" -and $_.CreationTime -le "$thisMonth/31/$thisYear"}
	$presentFiles = Get-ChildItem -Path D:\vmware-output\CSVs -Filter "$source*.csv" | where-Object { $_.CreationTime -ge "$d21" -and $_.CreationTime -le "$d22"}
	$old_csv = $pastFiles[-1]
	$new_csv = $presentFiles[-1]
	$old_csv
	$new_csv
	$pastList = Import-Csv "D:\vmware-output\CSVs\$old_csv"
	$presentList = Import-Csv "D:\vmware-output\CSVs\$new_csv"
	$policies = $pastList.tag + $presentList.tag |Sort-Object -Descending |Get-Unique
	ForEach($p in $policies) {
		#$p="Veeam Backup/APP Aware"
		$pastVMs = ($pastList | where-Object { $_.tag -eq $p } | Select Name).Name
		$presentVMs = ($presentList | where-Object { $_.tag -eq $p } | Select Name).Name
		echo "================================ $p ===================================="
		$differentVMs = Compare-Object -ReferenceObject @($pastVMs | Select-Object) -DifferenceObject @($presentVMs | Select-Object) #-PassThru
	}
	

	$c = Compare-Object -ReferenceObject $pastList.name		-presentListObject $presentList.name -PassThru
	$c = Compare-Object -ReferenceObject $presentList.name	-presentListObject $pastList.name 	 -PassThru
	
	$csv = Import-Csv
}