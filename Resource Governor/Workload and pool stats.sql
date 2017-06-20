-- https://technet.microsoft.com/en-us/library/bb934197(v=sql.110).aspx

WITH OS_SYS_INFO
     AS (SELECT cpu_count
         FROM sys.dm_os_sys_info)
     SELECT drgwgps.name
            -- Time that statistics collection was reset for the workload group. Is not nullable.
          , drgwgps.statistics_start_time
            -- Durée en ms des statistique
          , DATEDIFF(ms, drgwgps.statistics_start_time, GETDATE()) AS elapse_stats_ms
          -- Temps en ms CPU disponible pour du traitement
          , CAST(osi.cpu_count AS bigint) * DATEDIFF(ms, drgwgps.statistics_start_time, GETDATE()) AS procesing_time_evalable_ms
          --  -- Cumulative count of requests exceeding the CPU limit. Is not nullable.
          , drgwgps.total_cpu_limit_violation_count
            -- Cumulative CPU usage, in milliseconds, by this workload group. Is not nullable.
          , drgwgps.total_cpu_usage_ms
            -- Maximum CPU usage, in milliseconds, for a single request. Is not nullable.
            -- This is a measured value, unlike request_max_cpu_time_sec, which is a configurable setting. For more information, see CPU Threshold Exceeded Event Class.
          , drgwgps.max_request_cpu_time_ms
            -- Current setting for maximum CPU use limit, in seconds, for a single request. Is not nullable.
          , drgwgps.request_max_cpu_time_sec
            -- pas trouvé de doc
            --drgwgps.total_cpu_usage_preemptive_ms,
          , osi.cpu_count AS [Logical CPU Count]
     FROM sys.dm_resource_governor_workload_groups drgwgps
          JOIN master.sys.resource_governor_resource_pools rgrp ON drgwgps.pool_id = rgrp.pool_id
          CROSS JOIN OS_SYS_INFO osi;