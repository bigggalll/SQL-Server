SELECT *
FROM sys.dm_os_wait_stats
WHERE wait_type = 'RESOURCE_GOVERNOR_IDLE';