--------------------------------------------------------------------------------- 
--Database Backups for all databases For Previous Week 
--------------------------------------------------------------------------------- 
SELECT 
   CONVERT(CHAR(100), SERVERPROPERTY('Servername')) AS Server, 
   msdb.dbo.backupset.database_name, 
   msdb.dbo.backupset.backup_start_date, 
   msdb.dbo.backupset.backup_finish_date, 
   msdb.dbo.backupset.expiration_date, msdb..backupset.type,
   CASE msdb..backupset.type 
      WHEN 'D' THEN 'Database' 
      WHEN 'L' THEN 'Log' 
      WHEN 'I' THEN 'Differential database' 
      WHEN 'F' THEN 'File or filegroup' 
      WHEN 'G' THEN 'Differentail file' 
      WHEN 'P' THEN 'Partial' 
      WHEN 'Q' THEN 'Differential partial' 
      END AS backup_type, 
   msdb.dbo.backupset.backup_size, 
   msdb.dbo.backupmediafamily.logical_device_name, 
   msdb.dbo.backupmediafamily.physical_device_name, 
   msdb.dbo.backupset.name AS backupset_name, 
   msdb.dbo.backupset.description 
FROM 
   msdb.dbo.backupmediafamily 
   INNER JOIN msdb.dbo.backupset ON msdb.dbo.backupmediafamily.media_set_id = msdb.dbo.backupset.media_set_id 
WHERE 
   (CONVERT(datetime, msdb.dbo.backupset.backup_start_date, 102) >= GETDATE() - 7) 
ORDER BY 
   msdb.dbo.backupset.database_name, 
   msdb.dbo.backupset.backup_finish_date 