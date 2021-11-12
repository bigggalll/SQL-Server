# Using System.Diagnostics.PerformanceCounter
$ppt = New-Object System.Diagnostics.PerformanceCounter
$ppt.CategoryName = 'Processor'
$ppt.CounterName = '% Processor Time'
$ppt.InstanceName = '_Total'
$ppt.NextValue()

$mab = New-Object System.Diagnostics.PerformanceCounter
$mab.CategoryName = 'Memory'
$mab.CounterName = 'Available MBytes'
$mab.NextValue()

# Using Get-Counter
$srv = 'SQLTBWS'
$iname = 'MSSQL$INST02'
$counters = @(
    "\Processor(_Total)\% Processor Time",
    "\Memory\Available MBytes",
    "\Paging File(_Total)\% Usage",
    "\PhysicalDisk(_Total)\Avg. Disk sec/Read",
    "\PhysicalDisk(_Total)\Avg. Disk sec/Write",
    "\System\Processor Queue Length",
    "\$($iname):Access Methods\Forwarded Records/sec",
    "\$($iname):Access Methods\Page Splits/sec",
    "\$($iname):Buffer Manager\Buffer cache hit ratio",
    "\$($iname):Buffer Manager\Page life expectancy",
    "\$($iname):Databases(_Total)\Log Growths",
    "\$($iname):General Statistics\Processes blocked",
    "\$($iname):SQL Statistics\Batch Requests/sec",
    "\$($iname):SQL Statistics\SQL Compilations/sec",
    "\$($iname):SQL Statistics\SQL Re-Compilations/sec"
    )
      
# Get performance counter data
$ctr = Get-Counter -ComputerName $srv -Counter $counters -SampleInterval 1 -MaxSamples 1
$ctr | Get-Member
