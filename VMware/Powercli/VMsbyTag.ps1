[CmdletBinding()]
Param(
 [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
 [string]$v, 		## vcenter FQDN
 [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
 [string]$u,		## username
 [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
 [string]$p, 		## password
 [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
 [string]$tag, 		## filter got get VMs by
 [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
 [string]$output="test", 	## file to save report output
 [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
 [string]$sortBy,   ## sort output
 [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
 [string]$colour='#e6f2ff', ## table row colour
 [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
 [string]$title=$v + " - " + $tag, ## report title
 [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
 [string]$klas="table1" ## class to separate CSS styling from other HTML fragments
)

##$title = $v + " - " + "high"
write-host "$title"

function header{
 $style = @"
 <style>
 body{
 font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
 }
 
 table.$klas{
  border-collapse: collapse;
  border: none;
  font: 10pt Verdana, Geneva, Arial, Helvetica, sans-serif;
  color: black;
  margin-bottom: 10px;
 }
 
 table.$klas td{
  font-size: 12px;
  padding-left: 0px;
  padding-right: 20px;
  text-align: left;
 }
 
 table.$klas th{
  font-size: 12px;
  font-weight: bold;
  padding-left: 0px;
  padding-right: 20px;
  text-align: left;
 }
 
 h2{
  clear: both; font-size: 130%;color:#00134d;
 }
 
 p{
  margin-left: 10px; font-size: 12px;
 }
 
 table.$klas.list{
  float: left;
 }
 
 table.$klas tr:nth-child(even){background: $colour;} 
 table.$klas tr:nth-child(odd) {background: #FFFFFF;}

 div.column {width: 320px; float: left;}
 div.first {padding-right: 20px; border-right: 1px grey solid;}
 div.second {margin-left: 30px;}

 table.$klas{
  margin-left: 10px;
 }
 –>
 </style>
"@

 return [string] $style
 }

function header_backup{
 $style = @"
 <style>
 body{
 font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
 }
 
 table.$klas{
  border-collapse: collapse;
  border: none;
  font: 10pt Verdana, Geneva, Arial, Helvetica, sans-serif;
  color: black;
  margin-bottom: 10px;
 }
 
 table.$klas td{
  font-size: 12px;
  padding-left: 0px;
  padding-right: 20px;
  text-align: left;
 }
 
 table.$klas th{
  font-size: 12px;
  font-weight: bold;
  padding-left: 0px;
  padding-right: 20px;
  text-align: left;
 }
 
 h2{
  clear: both; font-size: 130%;color:#00134d;
 }
 
 p{
  margin-left: 10px; font-size: 12px;
 }
 
 table.$klas.list{
  float: left;
 }
 
 table.$klas tr:nth-child(even){background: $colour;} 
 table.$klas tr:nth-child(odd) {background: #FFFFFF;}

 div.column {width: 320px; float: left;}
 div.first {padding-right: 20px; border-right: 1px grey solid;}
 div.second {margin-left: 30px;}

 table.$klas{
  margin-left: 10px;
 }
 –>
 </style>
"@

 return [string] $style
 }
 
function login($vCenter, $user, $password) {
	connect-viserver $vCenter -user $user -password $password -ErrorAction SilentlyContinue
	$serverlist = $global:DefaultVIServer
	if($serverlist -eq $null) 
	{
	   write-host "No connected servers."
	   BREAK
	} else 
	{
		foreach ($server in $serverlist) 
		{
			$serverName = $server.Name
			if($serverName -eq $vCenter)
			{
				write-Host "Connection to $vCenter established!"
			} else 
			{
				write-host "Error: Unable to connect"
				BREAK
			}
		}
	}
}

function VMsbyTag($tag){
	
	if($tag -eq $nul)
	{
		$vms = Get-VM
		$list = foreach($vm in $vms)
		{
			$vmtag = Get-TagAssignment -Entity $vm
			#if($vmtag -eq $null) { varsAll }
			if($vmtag -eq $null) { varsBackup }
		}
	} else
	{
		$vms = Get-VM -Tag $tag
		#$list = foreach($vm in $vms) { varsAll }
		$list = foreach($vm in $vms) { varsBackup }
	}
		
	return $list
}

function varsAll {
	[PSCustomObject]@{
		"Name" = $vm.Name
		"Hostname" = $vm.ExtensionData.Summary.Guest.HostName
		"OS" = $vm.ExtensionData.Config.GuestFullName
		"vCPUs" = $vm.NumCpu
		"Cores" = $vm.CoresPerSocket
		"Memory" = $vm.MemoryGB
		"NICS" = $vm.ExtensionData.Summary.Config.NumEthernetCards
		"IPs" = $vm.Guest.IPAddress -join '|'
		"UUID" = $vm.ExtensionData.Config.Uuidk
		"Host" = $vm.VMHost.Name
		"Notes" = $vm.Notes
		"Version" = $vm.ExtensionData.Config.Version
		"attached ISO" = ($vm |Get-CDDrive).IsoPath
	}
}

function varsBackup {
	
	if (($vm |Get-CDDrive).IsoPath)	{ $iso = "yes" } else { $iso = "" }
	[PSCustomObject]@{
		"Name" = $vm.Name
		"Host" = $vm.VMHost.Name
		"Version" = $vm.ExtensionData.Config.Version
		"OS" = $vm.ExtensionData.Config.GuestFullName
		"ISO?" = $iso
	}
}

#$ips=$vm.guest.net.ipaddress
#if ($ips.count -gt 1) {$ips=$vm.guest.net.ipaddress[0] + " " + $vm.guest.net.ipaddress[1]}

function logout($vCenter) {
#Disconnect from vCenter or ESXi
  Disconnect-VIServer -Confirm:$False -Server $vCenter -ErrorAction Stop
}

login $v $u $p
$frag = VMsbyTag |Sort-Object -Property Name| ConvertTo-Html -Head $(header_backup) 
$frag = $frag -replace '<table>',"<table class=`"$klas`">"
## Debug
#$frag = VMsbyTag |Sort-Object -Property Name| ConvertTo-Html -Head $(header_backup) -PreContent $title
#$frag = $frag -replace '<table>',"<table class=`"$klas`">" | Add-Content c:\TEMP\$output
logout($v)
return $frag