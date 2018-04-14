select

work_queue_count,*

from

sys.dm_os_schedulers

where

status = 'VISIBLE ONLINE'