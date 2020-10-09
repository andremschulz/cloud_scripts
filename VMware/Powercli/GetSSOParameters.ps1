###############################################################################
# Gets the NetBIOS Domain, base DN's, Domain Controller
# of a Active Directory Domain for use as Identity Source with
# VMware SSO Service
# Author Michael Albert michlstechblog.info
###############################################################################
[reflection.assembly]::LoadWithPartialName("System.DirectoryServices.Protocols")|Out-Null 

if($args.count -ne 1){
	Write-Warning " Start script with fqdn as parameter"
	Write-Warning (" for example: "+$myInvocation.myCommand.name+" yourdomain.com")
	exit 1
}
$sDomainName=$args[0]
$oDomain=[System.DirectoryServices.ActiveDirectory.Domain]::GetDomain(
	(New-Object System.DirectoryServices.ActiveDirectory.DirectoryContext([System.DirectoryServices.ActiveDirectory.DirectoryContextType]::Domain,$sDomainName))
)
# Get all domain Controllers
$aDCs=$oDomain.DomainControllers
$sDC1=@($aDCs)[0]
$sDC2=@($aDCs)[1]
# Get Base DN
$oADBase=New-object System.DirectoryServices.DirectoryEntry("LDAP://"+$sDomainName)
$sBaseDN=$oADBase.distinguishedName
# Get AD Root
$oRootDSE = [ADSI]"LDAP://RootDSE"
$sConfig = $oRootDSE.Get("configurationNamingContext") 
# AD Object AD Root
$oADSearchRoot=New-object System.DirectoryServices.DirectoryEntry("LDAP://CN=Partitions," + $sConfig) 
# Search for Netbiosname of the specified domain
$sSearchString="(&(objectclass=Crossref)(dnsRoot="+$sDomainName+")(netBIOSName=*))"
$oSearch=New-Object directoryservices.DirectorySearcher($oADSearchRoot,$sSearchString)
$sNetBIOSName=($oSearch.FindOne()).Properties["netbiosname"]
# Print out
write-host "Basic Config for VMware SSO Identity source"
Write-Host " NAME:              " $sNetBIOSName
Write-Host " Primary Server:    " ("ldap://"+$sDC1.name)
Write-Host " Secondary Server:  " ("ldap://"+$sDC2.name)
Write-Host " BaseDN Users:      " $sBaseDN
Write-Host " Domain:            " $sDomainName
Write-Host " Domain Alias:      " $sNetBIOSName
Write-Host " BaseDN Groups:     " $sBaseDN
