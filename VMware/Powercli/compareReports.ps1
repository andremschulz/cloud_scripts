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

$lastStart = Get-Date (Get-Date).AddMonths(-1) -day 1 -hour 0 -minute 0 -second 0
$lastEnd   =  ($lastStart).AddMonths(1).AddSeconds(-1)
$thisStart = Get-Date -day 1 -hour 0 -minute 0 -second 0
$thisEnd   = ($thisStart).AddMonths(1).AddSeconds(-1)
echo "Previous: $lastStart to $lastEnd"
echo "Current:  $thisStart to $thisEnd"
$reportList = @()
$changeList = ""
$noCompareList = ""
ForEach ($v in $vCenters) {
	write-host "================================ $v ====================================`r`n"
	$pastFiles     = Get-ChildItem -Path D:\vmware-output\CSVs -Filter "$v*.csv" | where-Object { $_.CreationTime -ge "$lastStart" -and $_.CreationTime -le "$lastEnd"} | Sort-Object -Property CreationTime
	$presentFiles  = Get-ChildItem -Path D:\vmware-output\CSVs -Filter "$v*.csv" | where-Object { $_.CreationTime -ge "$thisStart" -and $_.CreationTime -le "$thisEnd"} | Sort-Object -Property CreationTime
	$old_csv = @($pastFiles)[-1]
	echo "OLD FILE: $old_csv"
	$new_csv = @($presentFiles)[-1]
	echo "NEW FILE: $new_csv"
	$presentList = ""
	$pastList    = ""
	$pastList    = Import-Csv "D:\vmware-output\CSVs\$old_csv"
	$presentList = Import-Csv "D:\vmware-output\CSVs\$new_csv"
	$policies    = $pastList.tag + $presentList.tag |Sort-Object -Descending |Get-Unique
	$reportHTML  = $(header("$v - backup policy changes"))
	$colourCount = 0

	ForEach($p in $policies) {
		$flagChange  = 0
		$colour     = $colours[$colourCount % $policies.count]
		$pastVMs    = ($pastList    | where-Object { $_.tag -eq $p } | Select Name).Name
		$presentVMs = ($presentList | where-Object { $_.tag -eq $p } | Select Name).Name
		echo "`r`n>>>>> $p <<<<<<"
		$addedVMs   = (Compare-Object -ReferenceObject @($pastVMs | Select-Object) -DifferenceObject @($presentVMs | Select-Object) | Where-Object {$_.SideIndicator -eq "=>" }).InputObject
		$removedVMs = (Compare-Object -ReferenceObject @($pastVMs | Select-Object) -DifferenceObject @($presentVMs | Select-Object) | Where-Object {$_.SideIndicator -eq "<=" }).InputObject
		echo "$(@($addedVMs).Length) added - $addedVMs"
		echo "$(@($removedVMs).Length) removed - $removedVMs"
		$report = @();
		if(@($addedVMs)[0] -eq $null -AND @($addedVMs)[0] -eq $null) {
			$max = 0
			echo "YES IT IS!"
		} elseif(@($addedVMs).Length -gt @($removedVMs).Length) {
			$max = @($addedVMs).Length
		} else {
			$max = @($removedVMs).Length
		}
		for($i=0; $i -lt $max; $i++) {
			#echo "$(@($addedVMs)[$i]) vs $(@($removedVMs)[$i])"
			$report += New-Object PSObject -Property @{added="$(@($addedVMs)[$i])"; removed="$(@($removedVMs)[$i])"} | Select-Object added, removed
			$flagChange = 1
		}
		if($i -eq 0) { $report+= New-Object PSObject -Property @{added=" "; removed=" "} | Select-Object added, removed }
		if($p -eq ""){ $p = "ERROR - NO STRING PROVIDED" }
		$report 	 =  $report | ConvertTo-Html -PostContent $(body $colourCount "250px") -PreContent $p
		$reportHTML +=  $report -replace '<table>',"<table class=`"t$colourCount`">"
		$colourCount++
	}
	echo "change is $flagChange"
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