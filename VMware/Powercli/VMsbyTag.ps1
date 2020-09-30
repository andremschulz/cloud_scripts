[CmdletBinding()]
Param(
 [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
 [string]$v, ##vcenter FQDN
 [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
 [string]$u, ##username
 [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
 [string]$p, ##password
 [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
 [string]$tag,
 [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
 [string]$output,
 [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
 [string]$sortBy,
 [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
 [string]$colour='#e6f2ff'
)

if($tag -eq "")
{
	$title = $v + " - " + "no tag"
} else
{
	$title = $v + " - " + $tag
}

function header{
 $style = @"
 <style>
 body{
 font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
 }
 
 table{
  border-collapse: collapse;
  border: none;
  font: 10pt Verdana, Geneva, Arial, Helvetica, sans-serif;
  color: black;
  margin-bottom: 10px;
 }
 
 table td{
  font-size: 12px;
  padding-left: 0px;
  padding-right: 20px;
  text-align: left;
 }
 
 table th{
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
 
 table.list{
  float: left;
 }
 
 table tr:nth-child(even){background: $colour;} 
 table tr:nth-child(odd) {background: #FFFFFF;}

 div.column {width: 320px; float: left;}
 div.first {padding-right: 20px; border-right: 1px grey solid;}
 div.second {margin-left: 30px;}

 table{
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
	[PSCustomObject]@{
		"Name" = $vm.Name
		"Host" = $vm.VMHost.Name
		"Version" = $vm.ExtensionData.Config.Version
		"OS" = $vm.ExtensionData.Config.GuestFullName
		"attached ISO" = ($vm |Get-CDDrive).IsoPath
	}
}


#$ips=$vm.guest.net.ipaddress
#if ($ips.count -gt 1) {$ips=$vm.guest.net.ipaddress[0] + " " + $vm.guest.net.ipaddress[1]}


login $v $u $p
VMsbyTag |Sort-Object -Property Name| ConvertTo-Html -Head $(header) -PreContent $title | Add-Content c:\TEMP\$output

