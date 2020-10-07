####### VMware events

Connect-VIserver –Server ilhq-bk-vci1.office.corp

# error events
Get-VIevent –Types error –Maxsamples 10

# error events // grid view
Get-VIevent –Types error –Maxsamples 10 | Out-GridView

# error events by date // grid view
Get-VIevent –Start 4/6/2016 –Finish 4/8/2016 | Out-Gridview

# error events for VM for the last 7 days // grid view
	
Get-VIevent –Entity SR-FN-MICHPAL01  –Start 7/1/2020 -Finish 8/10/2020| Out-GridView
Get-VIevent –Entity fra-pxe-test01  –Start 7/1/2020 -Finish 8/10/2020| Out-GridView

Get-VIevent –UserName OFFICE\boriss  –Start 7/1/2020 -Finish 8/10/2020 –Entity SR-FN-MICHPAL01| ogv

