 ## vcenter FQDN### Backup team report
[CmdletBinding()]
Param(
 [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
 [string]$u, 		
 [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
 [string]$p=""
 )
 

#$vCenters =
#"bghq-bk-vci01.office.corp"
 
. ".\code\statics.ps1"

 $vCenters =
"ilhq-bk-vci1.office.corp",
"dedc-bk-vci1.office.corp",
"dedc-bk-vcd1.office.corp",
"bghq-bk-vci01.office.corp",
"bgdc-bk-vci1.office.corp"
 

$reports = @()
 ForEach ($v in $vCenters)
 {
	$output = "C:\scripts\output\" + $v + "_vmsbytools.html"
	echo  "==> Logging on $v..."
	if($p -eq "") {
		.\vmsByTools.ps1 -v $v -u $u       -output "$output"
	}
	else {
		.\vmsByTools.ps1 -v $v -u $u -p $p -output "$output"
	}
	eol -lineEnding unix -file $output
	$reports += $output
	echo  " ==> Report complete!"
 }
 
#email -EmailTo "backup.team@NSOGROUP.COM" -Body "VMs by VMware tools for each vcenter in Black environment" -Subject "Global Black: VMs by tools" -attachment $reports
email -Body "VMs by VMware tools for each vcenter in Black environment" -Subject "Global Black: VMs by tools" -attachment $reports

	
