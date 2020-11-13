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

function logout($vCenter) {
#Disconnect from vCenter or ESXi
  Disconnect-VIServer -Confirm:$False -Server $vCenter -ErrorAction Stop
}

Function email {
    Param (
        [Parameter(Mandatory=$true)]
        [String]$EmailTo,
        [Parameter(Mandatory=$true)]
        [String]$Subject,
        [Parameter(Mandatory=$true)]
        [String]$Body,
        [Parameter(Mandatory=$false)]
        [String]$EmailFrom=([adsisearcher]"(samaccountname=$env:USERNAME)").FindOne().Properties.mail,  #This gives a default value to the $EmailFrom command
        [Parameter(mandatory=$false)]
        [Array]$attachment,
        [Parameter(mandatory=$false)]
        [String]$Password
    )
		write-Host "are we here? - "$attachment.count

        $SMTPServer = "sr-fr-smtp.office.corp" 
        $SMTPMessage = New-Object System.Net.Mail.MailMessage($EmailFrom,$EmailTo,$Subject,$Body)
        if ($attachment.count -gt 0) {
			write-Host "is array - $attachment"
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
