Select instance_name AS GroupName, object_name, 
    CPU_USAGE = Convert(decimal(8, 2),
         ([CPU usage %]*100./[CPU usage % base]))
From (Select instance_name, object_name, counter_name, cntr_value
    From sys.dm_os_performance_counters WITH (NOLOCK) 
    Where counter_name In ('CPU usage %', 'CPU usage % base')
          AND object_name like '%:Workload Group Stats%') Pvt
Pivot (Min(cntr_value) For counter_name In ([CPU usage %], [CPU usage % base]) ) As Pvt2


