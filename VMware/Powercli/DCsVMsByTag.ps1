### Backup team report

. ".\code\statics.ps1"
$vCenters =
"ilhq-bk-vci1.office.corp"
#"dedc-bk-vci1.office.corp",
#"dedc-bk-vcd1.office.corp",
#"bghq-bk-vci01.office.corp",
#"bgdc-bk-vci1.office.corp"
 
 $tags =
 "high",
 "medium",
 "low"
 
 
 $colours = @{
 "high"	   = '#FFEFE6';
 "medium"  = '#FFFBE1';
 "low"     = '#EDFFE2';
 "notag"   = '#E8F5FF';
 "cutag"   = '#FCD2FF'
}

$user = ''
$pass = ''

 #$reportList = []
 
 ForEach ($v in $vCenters)
 {
	$report = ""
	$output = "C:\scripts\output\$v`_VMsByTag_" + (get-date -Format "dd/MM/yyyy/HH/mm") + ".html"
	forEach($t in $tags)
	{
		echo "==> $v - $t with colour: $colours[`"$t`"]"
		$frag = . ".\VMsByTag.ps1" -v $v -u $user -p $pass -tag $t -colour $colours["$t"]
		$report = $report + $frag
	}
	
	ConvertTo-HTML -head "$v - VMs by TAG" -PostContent "$report" | Out-File -FilePath "$output"
	
	## No tags
	#report.ps1 -v $v -u $user -p $pass			     -colour $colours["notag"]   -output $output
	
	#$reportList = $reportList + $output
 }

	
	#ConvertTo-HTML -head "DEDC-BK-VCI01 BACKUP REPORT" -PostContent "$frag_high,$frag_medium,$frag_low,$frag_no" |Add-Content c:\TEMP\reporting1.html
		
	
	
		
	#$v = "ILHQ-BK-VCI1"
	#$v = "DEDC-BK-VCI01"
	#$output = $v + "_" + (get-date -Format s) + '.html'