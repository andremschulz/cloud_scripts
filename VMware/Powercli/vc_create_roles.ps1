[CmdletBinding()]
Param(
 [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
 [string]$v, ##vcenter FQDN
 [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
 [string]$u, ##username
 [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
 [string]$p ##password
 )

function login($vCenter, $user, $password) {
	Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false
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

function listRolesPermissions {

	
	foreach($role in Get-VIRole){
		Write-host " =========================== $role ============================= "
		$permissions = (Get-VIPrivilege -Role $role -Server $v) #-replace '(\w+).*', '$1,'
		$permissions | Select @{N="Role";E={$role.Name}},@{N="Privilege Name";E={$_.Name}},@{N="Privilege ID";E={$_.ID}} | Format-Table -Wrap -AutoSize
		#$permissions | Select @{N="Privilege ID";E={$_.ID}}
		Write-Host -NoNewLine 'Press any key to continue...';
		$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
	}
}

function logout($vCenter) {
#Disconnect from vCenter or ESXi
  Disconnect-VIServer -Confirm:$False -Server $vCenter -ErrorAction Stop
}

function createRole($v, $roles, $PIDs)
{

#testing some user
New-VIRole -Name cyberobserver -Server $v -Privilege (Get-VIPrivilege -Id Global.Licenses, Global.Settings, profile.Edit, profile.View)
##New-VIRole -Name cyberobserver  -Server dedc-bk-vcd1.office.corp -Privilege (Get-VIPrivilege -Id Global.Licenses, Global.Settings, profile.Edit, profile.View)
}

$global:defaultviserver

login $v $u $p
createRole $v
logout $v