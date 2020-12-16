### Backup team report
[CmdletBinding()]
Param(
 [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
 [string]$u, 						# username to login on vcenter and get the data
 [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
 [string]$p,         				# password
 [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
 [string]$ct,		                # category by which to get all the tags
  [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
 [string]$em=""
 )
 
 Set-Location -Path C:\scripts\vmware

. ".\code\statics.ps1"

$vCenters =
"xx",
"xx",
"xx",
"xx",
"xx"

$colours = '#FFEFE6', '#FFFBE1', '#EDFFE2', '#E8F5FF', '#FCD2FF', '#D2FFFC', '#FFD2FA'
$reportList = @()
 ForEach ($v in $vCenters)
 {
	$tags = ""
	$report = ""
	$tagCount = 0
	$output = "D:\vmware-output\$v`_VMsByTag_" + (get-date -Format "dd/MM/yyyy/HH/mm") + ".html"
	
	if( (login $v $u $p) -eq 0) { 
		$tags = tagsByCategory $v $ct
		$tags+="notag"
		write-host "==> Tags are $ct`: $tags"
		logout($v)
	}

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
