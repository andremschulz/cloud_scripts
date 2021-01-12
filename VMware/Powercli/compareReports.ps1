### Backup team report
[CmdletBinding()]
Param(
 [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
 [string]$u="", 						# username to login on vcenter and get the data
 [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
 [string]$p,         				# password
 [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
 [string]$vc,		                #  specify if you need to do it for only 1 vCenter
 [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
 [string]$em=""
 )
 
Set-Location -Path C:\scripts\vmware
. ".\code\statics.ps1"
$colours = '#FFEFE6', '#FFFBE1', '#EDFFE2', '#E8F5FF', '#FCD2FF', '#D2FFFC', '#FFD2FA'
$vCenters = ""

$thisM = (Get-Date).ToString('MM')
$thisY = (Get-Date).ToString("yyyy")
$lastM = (Get-Date).AddMonths(-1).ToString('MM')
if ( $lastM -eq 12 ) { 
	$lastY = (Get-Date).AddYears(-1).ToString("yyyy")
} else 
{
	$lastY = (Get-Date).ToString("yyyy")
}
$reportList = @()
$changeList = ""
$noCompareList = ""
ForEach ($v in $vCenters) {
	$d11="01/01/2021"
	$d12="01/08/2021"
	$d21="01/08/2021"
	$d22="01/30/2021"
	$pastFiles     = Get-ChildItem -Path D:\vmware-output\CSVs -Filter "$v*.csv" | where-Object { $_.CreationTime -ge "$lastM/01/$lastY" -and $_.CreationTime -le "$lastM/31/$lastY"} | Sort-Object -Property CreationTime
	#$pastFiles    = Get-ChildItem -Path D:\vmware-output\CSVs -Filter "$v*.csv" | where-Object { $_.CreationTime -ge "$d11" -and $_.CreationTime -le "$d12"} | Sort-Object -Property CreationTime
	$presentFiles  = Get-ChildItem -Path D:\vmware-output\CSVs -Filter "$v*.csv" | where-Object { $_.CreationTime -ge "$thisM/01/$thisY" -and $_.CreationTime -le "$thisM/31/$thisY"} | Sort-Object -Property CreationTime
	#$presentFiles = Get-ChildItem -Path D:\vmware-output\CSVs -Filter "$v*.csv" | where-Object { $_.CreationTime -ge "$d21" -and $_.CreationTime -le "$d22"} | Sort-Object -Property CreationTime
	$old_csv = $pastFiles[-1]
	$new_csv = $presentFiles[-1]
	$old_csv
	$new_csv
	$pastList = Import-Csv "D:\vmware-output\CSVs\$old_csv"
	$presentList = Import-Csv "D:\vmware-output\CSVs\$new_csv"
	$policies = $pastList.tag + $presentList.tag |Sort-Object -Descending |Get-Unique
	$reportHTML = $(header("$v - backup policy changes"))
	$flagChange = 0
	$colourCount = 0;
	ForEach($p in $policies) {
		$colour   = $colours[$colourCount % $policies.count]
		$pastVMs = ($pastList | where-Object { $_.tag -eq $p } | Select Name).Name
		$presentVMs = ($presentList | where-Object { $_.tag -eq $p } | Select Name).Name
		echo "================================ $p ===================================="
		$addedVMs = Compare-Object -ReferenceObject @($pastVMs | Select-Object) -DifferenceObject @($presentVMs | Select-Object) | Where-Object {$_.SideIndicator -eq "=>" }
		$removedVMs = Compare-Object -ReferenceObject @($pastVMs | Select-Object) -DifferenceObject @($presentVMs | Select-Object) | Where-Object {$_.SideIndicator -eq "<=" }
		$report = @();
		
		if($addedVMs.count -gt $removedVMs.count) {
			$max = $addedVMs.count
		} else {
			$max = $removedVMs.count
		}
		$i=0
		for($i=0; $i -lt $max; $i++) {
			#echo "$(@($addedVMs.InputObject)[$i]) vs $(@($removedVMs.InputObject)[$i])"
			$report += New-Object PSObject -Property @{added="$(@($addedVMs.InputObject)[$i])"; removed="$(@($removedVMs.InputObject)[$i])"} | Select-Object added, removed
			$flagChange = 1
		}
		if($i -eq 0) { $report+= New-Object PSObject -Property @{added=" "; removed=" "} | Select-Object added, removed }
		if($p -eq ""){ $p = "ERROR - NO STRING PROVIDED" }
		$report 	 =  $report | ConvertTo-Html -PostContent $(body $colourCount "250px") -PreContent $p
		$reportHTML +=  $report -replace '<table>',"<table class=`"t$colourCount`">"
		$colourCount++
	}
	$outputHTML = "D:\vmware-output\HTMLs\$v`_PolicyCompare_" + (get-date -Format "dd/MM/yyyy/HH/mm") + ".html"
	ConvertTo-HTML -PostContent "$reportHTML" | Out-File -FilePath "$outputHTML"
	$reportList += $outputHTML;
	if($old_csv -eq "") { $flagChange = 2 }            ## check if there is old file to compare, raise flag
	if($flagChange -eq 1) { $changeList += "$v, " }    ## if flag is up, there are no differences between reports, add vcenter to list
	if($flagChange -eq 2) { $noCompareList += "$v, " } ## if flag is up, there are no old reports to compare between reports, add vcenter to list
}
if($changeList -eq "") { $changeList = "No difference has been observed since last month.
" }
else { $changeList = "There is difference in clusters: $changeList
" }
if($noCompareList -ne "") { $noCompareList = "There are no comparison reference reports for clusters: $noCompareList
" } 
$mailBody = "Backup comparison report for Black environment.

$changeList 
$noCompareList"
echo "Sending mails..."
if($em -eq "") { 	email -Body $mailBody -Subject "Global Black: Comparison report" -attachment $reportList }
else { email -emailTo $em -Body $mailBody -Subject "Global Black: Comparison report" -attachment $reportList }
exit