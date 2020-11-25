### Backup team report
[CmdletBinding()]
Param(
 [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
 [string]$u, 		
 [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
 [Security.SecureString]$p,
 [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
 [string]$ct,
  [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
 [string]$em=""
 )
 
 Set-Location -Path C:\scripts\vmware

. ".\code\statics.ps1"

$vCenters =
"ilhq-bk-vci1.office.corp",
"dedc-bk-vci1.office.corp",
"dedc-bk-vcd1.office.corp",
"bghq-bk-vci01.office.corp",
"bgdc-bk-vci1.office.corp"

$colours = '#FFEFE6', '#FFFBE1', '#EDFFE2', '#E8F5FF', '#FCD2FF', '#D2FFFC', '#FFD2FA'
$reportList = @()
 ForEach ($v in $vCenters)
 {
	$tags = ""
	if( (login $v $u $p) -eq 0) { 
		$tags = tagsByCategory $v $ct
		$tags+="notag"
		write-host "==> Tags are $ct`: $tags"
		logout($v)
	}
	
	$report = ""
	$tagCount = 0
	$output = "C:\scripts\output\$v`_VMsByTag_" + (get-date -Format "dd/MM/yyyy/HH/mm") + ".html"
	forEach($t in $tags)
	{
		$clr = $tagCount % $colours.Count
		echo ("==> $v - $t")
		if($p -eq "") {
			$fragment = . ".\VMsByTag.ps1" -v $v -u $u       -tag $t -category $ct -colour $colours[$clr] -klas "$tagCount"
			
		}
		else {
			$fragment = . ".\VMsByTag.ps1" -v $v -u $u -p $p -tag $t -category $ct -colour $colours[$clr] -klas "$tagCount"
		}
		
		$report += $fragment
		$tagCount+=1
	}
	
	ConvertTo-HTML -head "VMs by TAG" -PostContent "$report" | Out-File -FilePath "$output"
	$reportList = $reportList + $output
 }
 
 
 if($em -eq "") { email -Body "VMs by backup tag for each vcenter in Black environment" -Subject "Global Black: VMs by Backup tag" -attachment $reportList }
 else { email -emailTo $em -Body "VMs by backup tag for each vcenter in Black environment" -Subject "Global Black: VMs by Backup tag" -attachment $reportList }


##testing
#	login ilhq-bk-vci1.office.corp vmware.service@office.corp ""
#	$fragment = . ".\VMsByTag.ps1" -v ilhq-bk-vci1.office.corp -u vmware.service@office.corp -tag notag -colour '#FFEFE6' -klas "1"
