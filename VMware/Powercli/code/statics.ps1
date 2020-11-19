function header($klas){
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

function login($vCenter, $user, $pass) {

	if($pass -eq "") { 
		loginWithCredential $vCenter $user
	}
	else {
		$connection = connect-viserver $vCenter -user $user -password $pass -ErrorAction SilentlyContinue
	}
	
	$serverlist = $global:DefaultVIServer
	if($serverlist -eq $null) 
	{
	   write-host "No connected servers."
	   BREAK
	} else {
		foreach ($server in $serverlist) 
		{
			$serverName = $server.Name
			if($serverName -eq $vCenter)
			{
				write-Host "==> Connection to $vCenter established!"
				return 0
			}
		}
		write-host "==> Error: Unable to connect"
		return 1
	}
}

function logout($vCenter) {
#Disconnect from vCenter or ESXi
  Disconnect-VIServer -Confirm:$False -Server $vCenter -ErrorAction Stop
}

Function email {
    Param (
        [Parameter(Mandatory=$false)]
        [String]$EmailTo=([adsisearcher]"(samaccountname=$env:USERNAME)").FindOne().Properties.mail,  #This gives a default value to the $EmailFrom command,
        [Parameter(Mandatory=$true)]
        [String]$Subject,
        [Parameter(Mandatory=$true)]
        [String]$Body,
        [Parameter(Mandatory=$false)]
        [String]$EmailFrom=$env:computername + "@office.corp",
        [Parameter(mandatory=$false)]
        [Array]$attachment,
        [Parameter(mandatory=$false)]   
        [String]$Password
    )

        $SMTPServer = "sr-fr-smtp.office.corp" 
        $SMTPMessage = New-Object System.Net.Mail.MailMessage($EmailFrom,$EmailTo,$Subject,$Body)
        if ($attachment.count -gt 0) {
			foreach($a in $attachment) {
				$SMTPattachment = New-Object System.Net.Mail.Attachment($a)
				$SMTPMessage.Attachments.Add($SMTPattachment)
			}
		}
        $SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 25) 
        $SMTPClient.EnableSsl = $true 
        #$SMTPClient.Credentials = New-Object System.Net.NetworkCredential($EmailFrom.Split("@")[0], $Password); 
        $SMTPClient.Send($SMTPMessage)
        Remove-Variable -Name SMTPClient
        Remove-Variable -Name Password
}

function eol {
	[CmdletBinding()]
	Param(
	  [Parameter(Mandatory=$True,Position=1)][ValidateSet("mac","unix","win")] [string]$lineEnding,
	  [Parameter(Mandatory=$True)][string]$file
	)

	# Convert the friendly name into a PowerShell EOL character
	Switch ($lineEnding) {
	  "mac"  { $eol="`r" }
	  "unix" { $eol="`n" }
	  "win"  { $eol="`r`n" }
	} 

	# Replace CR+LF with LF
	$text = [IO.File]::ReadAllText($file) -replace "`r`n", "`n"
	[IO.File]::WriteAllText($file, $text)

	# Replace CR with LF
	$text = [IO.File]::ReadAllText($file) -replace "`r", "`n"
	[IO.File]::WriteAllText($file, $text)

	#  At this point all line-endings should be LF.

	# Replace LF with intended EOL char
	if ($eol -ne "`n") {
	  $text = [IO.File]::ReadAllText($file) -replace "`n", $eol
	  [IO.File]::WriteAllText($file, $text)
	}
}

function createCredential($user) {
# create usage example - createCredentials -user 'vmware.service'
	$Key = [byte]1..16
	$path = "C:\scripts\vmware\credentials"
	$credential = Get-Credential -username $user -Message "supply password"
	$credential | Export-CliXml -Path "$path\$user.xml"

}

function loginWithCredential($vc, $user) {

	$path = "C:\scripts\vmware\credentials\" + $user + ".xml"
	$credential = Import-CliXml -Path $path
	$conn = Connect-VIServer $vc -credential $credential -ErrorAction SilentlyContinue

#$Key = [byte]1..16
#$encrypted = Get-Content "$path`\$user.key" | ConvertTo-SecureString -Key $Key
#$encrypted = Get-Content "C:\scripts\vmware\credentials\vmware.serivce@office.corp.key" | ConvertTo-SecureString -Key $Key
#$credential = New-Object System.Management.Automation.PsCredential -ArgumentList ($user, $encrypted)
#$credential = Import-CliXml -Path "$path\$user.xml"
#$credential = Import-CliXml -Path "C:\scripts\vmware\credentials\vmware.service@office.corp.xml"
#Connect-VIServer "dedc-bk-vci1.office.corp" -credential $credential -ErrorAction SilentlyContinue

}
