
Set-Location -Path C:\scripts\vmware

. ".\code\statics.ps1"

$colours = '#FFEFE6', '#FFFBE1', '#EDFFE2', '#E8F5FF', '#FCD2FF', '#D2FFFC', '#FFD2FA'
$vCenters = ""

$thisMonth = (Get-Date).ToString('MM')
$thisYear = (Get-Date).ToString("yyyy")
$lastMonth = (Get-Date).AddMonths(-1).ToString('MM')
if ( $lastMonth -eq 12 ) { 
	$LastYear = (Get-Date).AddYears(-1).ToString("yyyy")
} else 
{
	$LastYear = (Get-Date).ToString("yyyy")
}


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
	$reportHTML = $(header("$v - policy changes"))
	$colourCount = 0;
	ForEach($p in $policies) {
		$colour   = $colours[$colourCount % $policies.count]
		#$p="Veeam Backup/APP Aware"
		$pastVMs = ($pastList | where-Object { $_.tag -eq $p } | Select Name).Name
		$presentVMs = ($presentList | where-Object { $_.tag -eq $p } | Select Name).Name
		echo "================================ $p ===================================="
		$addedVMs = Compare-Object -ReferenceObject @($pastVMs | Select-Object) -DifferenceObject @($presentVMs | Select-Object) | Where-Object {$_.SideIndicator -eq "=>" }
		$removedVMs = Compare-Object -ReferenceObject @($pastVMs | Select-Object) -DifferenceObject @($presentVMs | Select-Object) | Where-Object {$_.SideIndicator -eq "<=" }
		$report = @();
		$vmR  = "" | Select-Object added, removed
		$i=0
		while($val -ne 10) {
			if($addedVMs.InputObject -eq $null -And $removedVMs.InputObject -eq $null) { break }
			$a = ($addedVMs.InputObject[$i]   | Select-Object )
			$r = ($removedVMs.InputObject[$i] | Select-Object )
			if($a -eq $null -And $r -eq $null) { break }
			
			$vmR.added   = $a
			$vmR.removed = $r
			$report+=$vmR
			$i++
		
		}
		#$reportHTML 		  +=  $addedVMs.InputObject  |Sort-Object | ConvertTo-Html -PostContent $(body($colourCount)) -PreContent $p
		#$reportHTML 		  +=  $removedVMs.InputObject|Sort-Object | ConvertTo-Html -PostContent $(body($colourCount)) -PreContent $p
		$report 	 =  $report | ConvertTo-Html -PostContent $(body($colourCount)) -PreContent $p
		$reportHTML +=  $report -replace '<table>',"<table class=`"t$colourCount`">"
		#echo "added  vms in   $P tag - $($report[$p][`"added`"]) "
		#echo "removed vms from $P tag - $($report[$p][`"removed`"])"
		$colourCount++
	}
	$outputHTML = "D:\vmware-output\HTMLs\$v`_PolicyCompare_" + (get-date -Format "dd/MM/yyyy/HH/mm") + ".html"
	ConvertTo-HTML -PostContent "$reportHTML" | Out-File -FilePath "$outputHTML"
}


#Get-Variable $report[$p]["added"] | Select *