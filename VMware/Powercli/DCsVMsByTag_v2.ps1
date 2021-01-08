### Backup team report
[CmdletBinding()]
Param(
 [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
 [string]$u="", 						# username to login on vcenter and get the data
 [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
 [string]$p,         				# password
 [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
 [string]$c,		                # category by which to get all the tags
  [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
 [string]$em=""
 )
  
 $c="Veeam Backup"
 Set-Location -Path C:\scripts\vmware

. ".\code\statics.ps1"

$vCenters = ""

$colours = '#FFEFE6', '#FFFBE1', '#EDFFE2', '#E8F5FF', '#FCD2FF', '#D2FFFC', '#FFD2FA'

$reportList = @()
 ForEach ($v in $vCenters)
 {
	$report = ""
	$outputHTML = "D:\vmware-output\HTMLs\$v`_VMsByTag_" + (get-date -Format "dd/MM/yyyy/HH/mm") + ".html"
	$outputCSV = "D:\vmware-output\CSVs\$v`_VMsByTag_" + (get-date -Format "dd/MM/yyyy/HH/mm") + ".csv"
	
	if( (login $v $u $p) -eq 0) {
		$report=""
		$vmList=@()
		$vmsByTag=@{}
		echo "Collecting data..."
		$vms = Get-VM -Location (Get-Datacenter -Server $v).Name
		
		
		echo "Begining data mapping..."
		$ListSize = $vms.Length
		$VMCounter = 1
		$PrintMark = 10
		
		foreach($vm in $vms){
			$this = "" | Select-Object name, uuid, hostname, os, state, vcpu, cores, memoryGB, host, datastore, totalSizeGB, nics, tags, IPs, notes, version, iso, tag
			$this.name 				= $vm.Name
			#$this.uuid 				= $vm.ExtensionData.Config.Uuid
			#$this.hostname 			= $vm.ExtensionData.Summary.Guest.HostName
			$this.os 				= $vm.ExtensionData.Config.GuestFullName
			$this.state 			= $vm.PowerState
			#$this.vCPU	 			= $vm.NumCpu 			#$vm.summary.config.numcpu
			#$this.cores	 			= $vm.CoresPerSocket 	#$vm.summary.config.numcpu
			#$this.memoryGB	 		= $vm.MemoryGB
			$this.host				 = $vm.VMHost.Name
			#$this.notes 				= $vm.Notes
			$this.version 			= $vm.ExtensionData.Config.Version
			if (($vm |Get-CDDrive).IsoPath)	{ $iso = "yes" } else { $iso = "" }
			$this.iso 				= $iso
			#$this.nics 				= $vm.ExtensionData.Summary.Config.NumEthernetCards #$vm.Summary.Config.NumEthernetCards
			#$this.IPs 				= $vm.Guest.IPAddress -join '|'
			$this.tags 				= (Get-TagAssignment -Entity $vm).Tag
			$this.totalSizeGB 		= [System.Math]::Round($vm.UsedSpaceGB)
			#$this.usedSpaceGB 		= [math]::Round($vm.Summary.Storage.Committed/1GB,2)
			#$this.provisionedSpaceGB = [math]::Round($vm.Summary.Storage.UnCommitted/1GB,2)
			#$this.datastore 			= $vm.Config.DatastoreUrl[0].Name
			$vmList+=$this
			#echo "$($VMCounter/$ListSize)"
			if ("$(($VMCounter/$ListSize)*100)" > $PrintMark) {
				echo "$PrintMark%..."
				$PrintMark+=10;
			}
		   $VMCounter++;
		}
		#$vmList| where  {$_.name -eq "ILHQ-VMM01"} |select Name, Tags| Format-Table
		echo "Policy filtering..."
		$vmsByTag["no tag"]=@()
		foreach($vm in $vmList){
			$flag = 0
			foreach($tag in $vm.tags){
				if($tag.Category.Name -eq $c) {
					if( $vmsByTag["$tag"] -isnot [array]) { $vmsByTag["$tag"] = @() }
					$vm.tag = $tag;
					$vmsByTag["$tag"]+=$vm;
					$flag = 1;
				}
			}
			if($flag -eq 0) { 
				$vm.tag = "no tag";
				$vmsByTag["no tag"]+=$vm 
			}
		}
		
		### Sorting data and preparing the report
		$colourCount = 0;
		
		echo "Generating reports..."
		$report = $(header("$v - VMs by TAG"))
		$csv = @();
		foreach($key in $vmsByTag.keys){
			$colour   = $colours[$colourCount % $vmsByTag.keys.count]
			$fragment = $vmsByTag["$key"] 
			$csv	 += $fragment| Sort-Object -Property Name| Select name, state, host, totalSizeGB, version, os, iso, tag
			$html 	  = $fragment| Sort-Object -Property Name| Select name, state, host, totalSizeGB, version, os, iso| ConvertTo-Html -PostContent $(body($colourCount)) -PreContent $key
			$report  += $html  -replace '<table>',"<table class=`"t$colourCount`">"
			$colourCount++
		}
		ConvertTo-HTML -PostContent "$report" | Out-File -FilePath "$outputHTML"
		$csv |export-csv $outputCSV
		
		logout($v)
		$reportList = $reportList + $outputHTML
	}
}
echo "Sending mails..."
if($em -eq "") { email -Body "VMs by backup tag for each vcenter in Black environment" -Subject "Global Black: VMs by Backup tag" -attachment $reportList }
else { email -emailTo $em -Body "VMs by backup tag for each vcenter in Black environment" -Subject "Global Black: VMs by Backup tag" -attachment $reportList }