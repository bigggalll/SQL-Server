SELECT DB_NAME(dovs.database_id) AS DBName
	,f.physical_name AS PhysicalFileLocation
	,dovs.logical_volume_name AS LogicalName
	,CASE 
		WHEN f.type = 0
			THEN 'Data'
		ELSE 'Log'
		END AS FileType
	,dovs.volume_mount_point AS Drive
	,CONVERT(DEC(12, 2), (f.size * 8.) / 1024.0) AS FileUsedSpaceInMB
	,CONVERT(DEC(12, 2), (dovs.available_bytes / 1048576.0) / 1024.0) AS DriveFreeSpaceInGB
FROM sys.database_files AS f
CROSS APPLY sys.dm_os_volume_stats(DB_ID(), f.file_id) dovs
--ORDER BY DBName;