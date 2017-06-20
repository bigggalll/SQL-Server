--------------------------------------------------------------------------------- 
--Database Backups for all databases For Previous Week 
--------------------------------------------------------------------------------- 


SELECT CONVERT( CHAR(100), SERVERPROPERTY('Servername')) AS Server,
       msdb.dbo.backupset.database_name,
       msdb.dbo.backupset.backup_start_date,
       msdb.dbo.backupset.backup_finish_date,
      datediff(minute, msdb.dbo.backupset.backup_start_date,msdb.dbo.backupset.backup_finish_date) as duree_en_minutes,
      --msdb.dbo.backupset.expiration_date,
       CASE msdb..backupset.type
           WHEN 'D'
           THEN 'Database'
           WHEN 'L'
           THEN 'Log'
           WHEN 'I'
           THEN 'Differential database'
           WHEN 'F'
           THEN 'File or filegroup'
           WHEN 'G'
           THEN 'Differential file'
           WHEN 'P'
           THEN 'Partial'
           WHEN 'Q'
           THEN 'Differential partial'
       END AS backup_type,
       msdb.dbo.backupset.backup_size / 1024 / 1024 / 1024 AS SizeInGB,
       --msdb.dbo.backupmediafamily.logical_device_name,
       msdb.dbo.backupmediafamily.physical_device_name,
       msdb.dbo.backupset.name AS backupset_name,
       msdb.dbo.backupset.description
FROM msdb.dbo.backupmediafamily
     INNER JOIN msdb.dbo.backupset ON msdb.dbo.backupmediafamily.media_set_id = msdb.dbo.backupset.media_set_id
WHERE(CONVERT(DATETIME, msdb.dbo.backupset.backup_start_date, 102) >= GETDATE() - 28)
    -- AND database_name = 'ax2012r3'
	--and msdb..backupset.type='D'
	--and 'LegatoNWMSQL'=msdb.dbo.backupset.name
--and 
--physical_device_name like '%425584442%'
ORDER BY msdb.dbo.backupset.database_name,
         msdb.dbo.backupset.backup_finish_date DESC;