select *
, volume_available_MB/Volume_total_MB AS FreeSpaceVolume
 from
(
	SELECT getdate() as DataCollection
		,count(*) as nb_Files
		,volume_mount_point AS volume_mount_point     
		,max((total_bytes-available_bytes)/1024/1024) AS volume_used_MB
		,max(available_bytes/1024/1024.0) AS volume_available_MB
		,max(total_bytes/1024/1024.0) AS Volume_total_MB
	FROM sys.sysaltfiles l 
		CROSS APPLY sys.dm_os_volume_stats(l.dbid, l.fileid) as v
	group by volume_mount_point

	) x