SELECT DB_NAME() dbname,
       COUNT(l.fileid) AS nbFiles,
       CASE
           WHEN l.groupid = 0
           THEN 'LOG'
           ELSE 'DATA'
       END AS type_file,
       SUM(ROUND(FILEPROPERTY(l.name, 'SpaceUsed')*1.0/128, 0)) AS [Used_size_MB],
       SUM(ROUND(FILEPROPERTY(l.name, 'SpaceUsed')*1.0/128, 0))/1024 AS [Used_size_GB],
       (SUM(l.size) * 1.0 / 128) / 1024 AS [Total_size_GB],
       (SUM(l.size) * 1.0 / 128) AS [Total_size_MB],
       MAX(volume_mount_point) AS volume_mount_point,
       COUNT(DISTINCT volume_mount_point) AS nbVolume,
       MAX((total_bytes - available_bytes) / 1024 / 1024 / 1024) AS volume_used_GB,
       MAX(available_bytes / 1024 / 1024 / 1024) AS volume_available_GB,
       MAX(total_bytes / 1024 / 1024 / 1024) AS Volume_total_GB
FROM sys.sysfiles l
     CROSS APPLY sys.dm_os_volume_stats(DB_ID(), l.fileid) AS v
GROUP BY groupid;
