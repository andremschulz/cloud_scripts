function header($heading) {
$header = @"
<head><style>
.header {
  padding: 10px;
  text-align: center;
  background: #1abc9c;
  color: white;
  font-size: 15px;
}
 
</style> </head>

<div class="header">
  <h1>$heading</h1>
</div>
"@

return [string] $header
}

function body($klas, $columnWidth){
 $style = @"
 <style>
 body{
 font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
 text-align: center;
 font-size: 22px;
 }
 
 table.t$klas{
  border-collapse: collapse;
  border: none;
  font: 10pt Verdana, Geneva, Arial, Helvetica, sans-serif;
  color: black;
  margin-bottom: 10px;
 }
 
 table.t$klas td{
  width: $columnWidth;
  font-size: 12px;
  padding-left: 0px;
  padding-right: 20px;
  text-align: left;
 }
 
 table.t$klas th{
  font-size: 12px;
  font-weight: bold;
  padding-left: 0px;
  padding-right: 20px;
  text-align: center;
 }
 
 h2{
  clear: both; font-size: 130%;color:#00134d;
 }
 
 p{
  margin-left: 10px; font-size: 12px;
 }
 
 table.t$klas.list{
  float: left;
 }
 
 table.t$klas tr:nth-child(even){background: $colour;} 
 table.t$klas tr:nth-child(odd) {background: #FFFFFF;}

 div.column {width: 320px; float: left;}
 div.first {padding-right: 20px; border-right: 1px grey solid;}
 div.second {margin-left: 30px;}

 table.t$klas{
  margin-left: auto;
  margin-right: auto;
 }
 –>
 </style>
"@

 return [string] $style
 }

function login($vCenter, $user, $pass) {
	
	Write-host $pass
	if($user -eq "") { 
		$credfile = "C:\scripts\vmware\credentials\$($env:UserName)_vmware.service@XXXX.XXXX"
		$credentials = Get-VICredentialStoreItem -Host $vCenter -File $credfile
		$connection = connect-viserver $vCenter -User $credentials.User -Password $credentials.Password -ErrorAction SilentlyContinue
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
        [String]$EmailFrom=$env:computername + "@XXXX.XXXX",
        [Parameter(mandatory=$false)]
        [Array]$attachment,
        [Parameter(mandatory=$false)]   
        [String]$Password
    )

        $SMTPServer = "XXXX.XXXX.XXXX" 
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

function CreateCredential($user, $pass, $vCenters) {
	#use to create new items: CreateCredential user@domain.int 'password' $vCenters
	$target = "C:\scripts\vmware\credentials\$($env:UserName)_vmware.service@XXXX.XXXX"
	Foreach($v in $vCenters){
		New-VICredentialStoreItem -Host $v -User $user -Password $pass -File $target
	}
}

function tagsByCategory($v, $category){
	foreach($c in (Get-Tag -Server $v).Category.Name) {
		if($c -eq $category) {
			$tags = (Get-Tag -Category $category -Server $v).name
			return $tags
		}
	}
}