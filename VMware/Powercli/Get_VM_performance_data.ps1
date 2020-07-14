Get-StatType -Entity CVP -Realtime virtualDisk.read.average

PS C:\Users\yordank> Get-StatType -Entity CVP -Realtime
virtualDisk.readIOSize.latest
virtualDisk.readOIO.latest
virtualDisk.mediumSeeks.latest
virtualDisk.smallSeeks.latest
virtualDisk.writeIOSize.latest
virtualDisk.writeLatencyUS.latest
virtualDisk.totalWriteLatency.average
virtualDisk.totalReadLatency.average
disk.usage.average
disk.commandsAveraged.average
disk.numberRead.summation
disk.write.average
disk.read.average
datastore.totalWriteLatency.average
datastore.totalReadLatency.average
datastore.numberWriteAveraged.average
datastore.write.average
datastore.read.average
disk.numberWrite.summation
virtualDisk.numberWriteAveraged.average
virtualDisk.numberReadAveraged.average
virtualDisk.write.average
power.power.average
net.pnicBytesTx.average
net.received.average
net.multicastRx.summation
net.usage.average
net.broadcastRx.summation
net.droppedTx.summation
net.packetsTx.summation
net.bytesTx.average
net.bytesRx.average
disk.numberReadAveraged.average
net.transmitted.average
net.packetsRx.summation
net.pnicBytesRx.average
virtualDisk.writeOIO.latest
virtualDisk.largeSeeks.latest
net.multicastTx.summation
net.broadcastTx.summation
virtualDisk.readLoadMetric.latest
disk.commandsAborted.summation
mem.llSwapOutRate.average
mem.llSwapInRate.average
mem.shared.average
mem.vmmemctltarget.average
mem.vmmemctl.average
mem.swapoutRate.average
mem.swapout.average
mem.swapin.average
mem.swapped.average
net.droppedRx.summation
mem.zipSaved.latest
mem.zipped.latest
mem.overheadTouched.average
mem.overheadMax.average
mem.activewrite.average
mem.active.average
mem.swapinRate.average
mem.consumed.average
mem.usage.average
cpu.demandEntitlementRatio.latest
mem.granted.average
mem.latency.average
cpu.swapwait.summation
cpu.run.summation
cpu.system.summation
cpu.maxlimited.summation
cpu.costop.summation
datastore.numberReadAveraged.average
cpu.demand.average
cpu.readiness.average
mem.entitlement.average
cpu.used.summation
cpu.idle.summation
virtualDisk.writeLoadMetric.latest
cpu.wait.summation
disk.busResets.summation
disk.commands.summation
cpu.ready.summation
cpu.overlap.summation
cpu.latency.average
cpu.usagemhz.average
sys.osUptime.latest
mem.decompressionRate.average
sys.heartbeat.latest
rescpu.actpk5.latest
rescpu.samplePeriod.latest
rescpu.actpk15.latest
virtualDisk.readLatencyUS.latest
rescpu.actav15.latest
virtualDisk.read.average
mem.zero.average
power.energy.summation
rescpu.actav1.latest
rescpu.runpk1.latest
mem.llSwapUsed.average
mem.overhead.average
rescpu.maxLimited5.latest
rescpu.maxLimited1.latest
rescpu.runav5.latest
mem.compressed.average
rescpu.runpk5.latest
rescpu.maxLimited15.latest
rescpu.sampleCount.latest
rescpu.runav15.latest
mem.compressionRate.average
rescpu.actav5.latest
mem.swaptarget.average
rescpu.actpk1.latest
disk.maxTotalLatency.latest
rescpu.runav1.latest
cpu.entitlement.latest
disk.numberWriteAveraged.average
datastore.maxTotalLatency.latest
rescpu.runpk15.latest
sys.uptime.latest
cpu.usage.average


Get-VM | Where {$_.PowerState -eq "PoweredOn"}  | Select Name, Host, NumCpu, MemoryMB, `
@{N="CPU Usage (Average), Mhz" ; E={[Math]::Round((($_ | Get-Stat -Stat cpu.usagemhz.average -Start (Get-Date).AddDays(-30) -IntervalMins 5 | Measure-Object Value -Average).Average),2)}}, `
@{N="Memory Usage (Average), %" ; E={[Math]::Round((($_ | Get-Stat -Stat mem.usage.average -Start (Get-Date).AddDays(-30) -IntervalMins 5 | Measure-Object Value -Average).Average),2)}} , `
@{N="Network Usage (Average), KBps" ; E={[Math]::Round((($_ | Get-Stat -Stat net.usage.average -Start (Get-Date).AddDays(-30) -IntervalMins 5 | Measure-Object Value -Average).Average),2)}} , `
@{N="Disk Usage (Average), KBps" ; E={[Math]::Round((($_ | Get-Stat -Stat disk.usage.average -Start (Get-Date).AddDays(-30) -IntervalMins 5 | Measure-Object Value -Average).Average),2)}} |`
Export-Csv -Path d:AverageUsage.csv


 Get-VM -Name CVP | Where {$_.PowerState -eq "PoweredOn"}  | Select Name, Host, NumCpu, MemoryMB, `
@{N="Disk Usage (Average)" ; E={[Math]::Round((($_ | Get-Stat -Stat virtualDisk.readIOSize.latest -Start (Get-Date).AddDays(-30) -IntervalMins 5 | Measure-Object Value -Average).Average),2)}} 
Export-Csv -Path C:AverageUsage.csv

 Get-VM -Name CVP | Where {$_.PowerState -eq "PoweredOn"}  | Select Name, Host, NumCpu, MemoryMB, `
@{N="Disk Usage (Average)" ; E={[Math]::Round((($_ | Get-Stat -Stat datastore.numberWriteAveraged.average -Start (Get-Date).AddDays(-30) -IntervalMins 5 | Measure-Object Value -Average).Average),2)}} 
Export-Csv -Path C:AverageUsage.csv


Get-VM | Where {$_.PowerState -eq "PoweredOn"}  | Select Name, Host, NumCpu, MemoryMB, `
@{N="CPU Usage (Average) %" ; E={[Math]::Round((($_ | Get-Stat -Stat cpu.usage.average -Start (Get-Date).AddDays(-30) -IntervalMins 5 | Measure-Object Value -Average).Average),2)}}, `
@{N="Memory Usage (Average), %" ; E={[Math]::Round((($_ | Get-Stat -Stat mem.usage.average -Start (Get-Date).AddDays(-30) -IntervalMins 5 | Measure-Object Value -Average).Average),2)}} , `
@{N="Network Usage (Average), KBps" ; E={[Math]::Round((($_ | Get-Stat -Stat net.usage.average -Start (Get-Date).AddDays(-30) -IntervalMins 5 | Measure-Object Value -Average).Average),2)}} , `
@{N="Disk Usage (Average), KBps" ; E={[Math]::Round((($_ | Get-Stat -Stat disk.usage.average -Start (Get-Date).AddDays(-30) -IntervalMins 5 | Measure-Object Value -Average).Average),2)}} |`
@{N="total Read Latency" ; E={[Math]::Round((($_ | Get-Stat -Stat total.Read.Latency -Start (Get-Date).AddDays(-30) -IntervalMins 5 | Measure-Object Value -Average).Average),2)}} |`
Export-Csv -Path C:/TEMP/S_AverageUsage.csv


$sVcenter = "xx.xx.xx.xx"
$sVcUser = "administrator@vsphere.local"
$sVcPassword = "xxxx"
$sHostName = ""
Connect-VIserver -Server $sVcenter -User $sVcUser  -Password $sVcPassword

$allvms = @()
$OnVMCount = Get-VM | Where-Object {$_.powerstate -eq 'PoweredOn' } | measure-object -line
$vms = "" | Select-Object VMName, OS, VMState, TotalCPU, CPUAffinity, CPUHotAdd, CPUShare, CPUlimit, OverallCpuUsage, CPUreservation, TotalMemory, MemoryShare, MemoryUsage, MemoryHotAdd, MemoryLimit, MemoryReservation, Swapped, Ballooned, Compressed, TotalNics, ToolsStatus, ToolsVersion, HardwareVersion, TimeSync, CBT,


$vms = Get-Vm CVP        
$start =  "07/07/2020 00:01 AM"
$FInish = "07/08/2020 11:59 AM"
$metrics = "cpu.usage.average","mem.usage.average"
$stats = Get-Stat -Entity $vms -Start $start -Finish $Finish -Stat $metrics    
$stats | Group-Object -Property {$_.Timestamp.Day},{$_.Entity.Name} | %{
  $vmstat = "" | Select VmName, Day, MemMax, MemAvg, MemMin, CPUMax, CPUAvg, CPUMin
  $vmstat.VmName = $_.Values[1]
  $vmstat.Day = $_.Group[0].Timestamp.Date
  $cpu = $_.Group | where {$_.MetricId -eq "cpu.usage.average"} | Measure-Object -Property value -Average -Maximum -Minimum
  $mem = $_.Group | where {$_.MetricId -eq "mem.usage.average"} | Measure-Object -Property value -Average -Maximum -Minimum
  $vmstat.CPUMax = [int]$cpu.Maximum
  $vmstat.CPUAvg = [int]$cpu.Average
  $vmstat.CPUMin = [int]$cpu.Minimum
  $vmstat.MemMax = [int]$mem.Maximum
  $vmstat.MemAvg = [int]$mem.Average
  $vmstat.MemMin = [int]$mem.Minimum  
  $allvms += $vmstat
}
$allvms



#########GET VM UUID
Get-VM <VM-name> |%{(Get-View $_.Id).config.uuid}