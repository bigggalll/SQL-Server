select wait_type, waiting_tasks_count, wait_time_ms, wait_time_ms/waiting_tasks_count as 'time_per_wait'
from sys.dm_os_wait_stats where waiting_tasks_count >0
 and wait_type = 'HADR_SYNC_COMMIT'