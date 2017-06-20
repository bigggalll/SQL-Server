--USE AdventureWorks
--GO
-- Get Backup History for required database
SELECT TOP 1000 s.database_name,
               m.physical_device_name,
               CAST(CAST(s.backup_size / 1000000 AS INT) AS VARCHAR(14))+' '+'MB' AS bkSize,
               CAST(DATEDIFF(second, s.backup_start_date, s.backup_finish_date) AS VARCHAR(4))+' '+'Seconds' TimeTaken,
               s.backup_start_date,
               CAST(s.first_lsn AS VARCHAR(50)) AS first_lsn,
               CAST(s.last_lsn AS VARCHAR(50)) AS last_lsn,
               CASE s.[type]
                   WHEN 'D'
                   THEN 'Full'
                   WHEN 'I'
                   THEN 'Differential'
                   WHEN 'L'
                   THEN 'Transaction Log'
               END AS BackupType,
               s.server_name,
               s.recovery_model
FROM msdb.dbo.backupset s
     INNER JOIN msdb.dbo.backupmediafamily m ON s.media_set_id = m.media_set_id
WHERE s.database_name = DB_NAME() -- Remove this line for all the database
and  backup_start_date >'2016-05-26 00:00:00' and backup_start_date <'2016-05-26 02:00:00'
ORDER BY backup_start_date DESC,
         backup_finish_date;
GO