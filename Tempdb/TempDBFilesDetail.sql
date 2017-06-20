SELECT db_name() dbname, count(l.fileid) as nbFiles
       ,case when l.groupid=0 then 'LOG' else 'DATA' end as type_file
       ,sum(round(fileproperty(l.name,'SpaceUsed')*1.0/128,0))  AS [Used_size_MB]
       ,(SUM(l.size)*1.0/128) AS [Total_size_MB]
       ,max(volume_mount_point) AS volume_mount_point
       ,count(distinct volume_mount_point) AS nbVolume
       ,max((total_bytes-available_bytes)/1024/1024) AS volume_used_MB
       ,max(available_bytes/1024/1024) AS volume_available_MB
       ,max(total_bytes/1024/1024) AS Volume_total_MB
FROM sys.sysfiles l CROSS APPLY sys.dm_os_volume_stats(db_id(), l.fileid) as v
group by groupid      
