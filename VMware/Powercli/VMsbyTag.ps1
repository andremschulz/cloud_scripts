[CmdletBinding()]
Param(
 [Parameter(Mandatory=$false,Position=1)]
 [string]$hostFQDN,
 [Parameter(Mandatory=$false,Position=2)]
 [string]$tag,
 [Parameter(Mandatory=$false,Position=3)]
 [string]$user,
 [Parameter(Mandatory=$false,Position=4)]
 [string]$pass,
 [Parameter(Mandatory=$false,Position=5)]
 [string]$sortBy
)


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
 
 table tr:nth-child(even){background: #e6f2ff;} 
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
			if($vmtag -eq $null) { varsAll }
		}
	} else
	{
		$vms = Get-VM -Tag $tag
		$list = foreach($vm in $vms) { varsAll }
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
		"UUID" = $vm.ExtensionData.Config.Uuid
		"Host" = $vm.VMHost.Name
		"Notes" = $vm.Notes
		"Version" = $vm.ExtensionData.Config.HardwareVersion
		"attached ISO" = ($vm |Get-CDDrive).IsoPath
	}
}