--RESTORE WITH DIFFERENTIAL

--RESTORE BackupSample from our base backup.
USE [master];
GO

RESTORE DATABASE [BackupSample] 
	FROM DISK = 'C:\KNOWBACKUPS\BACKUPSAMPLE_BASE.BAK' WITH NORECOVERY, REPLACE;
GO
RESTORE DATABASE [BackupSample] WITH RECOVERY;
GO

--Clear backup history just in case I have ran this demo before.
USE MSDB;
GO
DECLARE @DATE DATETIME
SET @DATE = GETDATE()+1
EXEC SP_DELETE_BACKUPHISTORY @DATE;
GO

USE [master];
GO

--BACKUP FOR CLEAN LIST
BACKUP DATABASE [BackupSample] 
	TO DISK = 'C:\KNOWBACKUPS\BACKUPS\BACKUPSAMPLE_FULL_DEMODIFF.BAK';
GO

BACKUP LOG [BackupSample] 
	TO DISK = 'C:\KNOWBACKUPS\BACKUPS\BACKUPSAMPLE_DEMODIFF_LOG.BAK';
GO

--Insert First Record
INSERT INTO [BackupSample].[dbo].[sales]
           ([SalesOrderID]
           ,[CarrierTrackingNumber]
           ,[OrderQty]
           ,[ProductID]
           ,[SpecialOfferID]
           ,[UnitPrice]
           ,[UnitPriceDiscount]
           ,[LineTotal]
           ,[rowguid]
           ,[ModifiedDate])
     VALUES
           ('75150'
           ,NULL
           ,'2'
           ,'879'
           ,'1'
           ,'159.00'
           ,'0.00'
           ,'318.00'
           ,NEWID()
           ,getdate());
GO
--LOG BACKUP
BACKUP LOG [BackupSample] 
	TO DISK = 'C:\KNOWBACKUPS\BACKUPS\BACKUPSAMPLE_DEMODIFF_LOG1.BAK';
GO

--Insert second record
INSERT INTO [BackupSample].[dbo].[sales]
           ([SalesOrderID]
           ,[CarrierTrackingNumber]
           ,[OrderQty]
           ,[ProductID]
           ,[SpecialOfferID]
           ,[UnitPrice]
           ,[UnitPriceDiscount]
           ,[LineTotal]
           ,[rowguid]
           ,[ModifiedDate])
     VALUES
           ('75200'
           ,NULL
           ,'2'
           ,'879'
           ,'1'
           ,'159.00'
           ,'0.00'
           ,'318.00'
           ,NEWID()
           ,getdate());
GO

--PERFORM DIFFERENTIAL
BACKUP DATABASE [BackupSample] 
	TO DISK = 'C:\KNOWBACKUPS\backups\BACKUPSAMPLE_DIFF.BAK' WITH DIFFERENTIAL;
GO

--Insert a third record

INSERT INTO [BackupSample].[dbo].[sales]
           ([SalesOrderID]
           ,[CarrierTrackingNumber]
           ,[OrderQty]
           ,[ProductID]
           ,[SpecialOfferID]
           ,[UnitPrice]
           ,[UnitPriceDiscount]
           ,[LineTotal]
           ,[rowguid]
           ,[ModifiedDate])
     VALUES
           ('75400'
           ,NULL
           ,'2'
           ,'879'
           ,'1'
           ,'159.00'
           ,'0.00'
           ,'318.00'
           ,NEWID()
           ,getdate());
GO

--Backup Log
BACKUP LOG [BackupSample] 
	TO DISK = 'C:\KNOWBACKUPS\BACKUPS\BACKUPSAMPLE_DEMODIFF_LOG3.BAK';
GO

--Insert a fourth record.
INSERT INTO [BackupSample].[dbo].[sales]
           ([SalesOrderID]
           ,[CarrierTrackingNumber]
           ,[OrderQty]
           ,[ProductID]
           ,[SpecialOfferID]
           ,[UnitPrice]
           ,[UnitPriceDiscount]
           ,[LineTotal]
           ,[rowguid]
           ,[ModifiedDate])
     VALUES
           ('75500'
           ,NULL
           ,'2'
           ,'879'
           ,'1'
           ,'159.00'
           ,'0.00'
           ,'318.00'
           ,NEWID()
           ,getdate());
GO

--Final Transaction log backup
BACKUP LOG [BackupSample] 
	TO DISK = 'C:\KNOWBACKUPS\BACKUPS\BACKUPSAMPLE_DEMODIFF_LOG4.BAK';
GO

/* Now lets run a simple script to generate a restore script
that includes the last FULL backup, then the last Differential backup
plus each transaction log since the last Differential backup, 
this can be a life saver */
--BEGIN SCRIPT
DECLARE @databaseName sysname
DECLARE @backupStartDate datetime
DECLARE @backup_set_id_start INT
DECLARE @backup_set_id_FULL INT
DECLARE @backup_set_id_end INT

-- set database to be used
SET @databaseName = 'BackupSample' 

SELECT @backup_set_id_FULL = MAX(backup_set_id) 
	FROM  msdb.dbo.backupset 
	WHERE database_name = @databaseName AND type = 'D'

SELECT @backup_set_id_start = MAX(backup_set_id) 
	FROM  msdb.dbo.backupset 
	WHERE database_name = @databaseName AND type = 'I'

SELECT @backup_set_id_end = MIN(backup_set_id) 
	FROM  msdb.dbo.backupset 
	WHERE database_name = @databaseName AND type = 'D'
	AND backup_set_id > @backup_set_id_start

IF @backup_set_id_end IS NULL SET @backup_set_id_end = 999999999

SELECT backup_set_id, 'RESTORE DATABASE ' + @databaseName + ' FROM DISK = ''' 
               + mf.physical_device_name + ''' WITH NORECOVERY'
	FROM msdb.dbo.backupset b,
         msdb.dbo.backupmediafamily mf
	WHERE b.media_set_id = mf.media_set_id
			AND b.database_name = @databaseName
			AND b.backup_set_id = @backup_set_id_FULL
UNION
SELECT backup_set_id, 'RESTORE DATABASE ' + @databaseName + ' FROM DISK = ''' 
            + mf.physical_device_name + ''' WITH NORECOVERY'
	FROM    msdb.dbo.backupset b,
			msdb.dbo.backupmediafamily mf
	WHERE   b.media_set_id = mf.media_set_id
			AND b.database_name = @databaseName
			AND b.backup_set_id = @backup_set_id_start
UNION
SELECT backup_set_id, 'RESTORE LOG ' + @databaseName + ' FROM DISK = ''' 
         + mf.physical_device_name + ''' WITH NORECOVERY'
	FROM	msdb.dbo.backupset b,
			msdb.dbo.backupmediafamily mf
	WHERE b.media_set_id = mf.media_set_id
			AND b.database_name = @databaseName
			AND b.backup_set_id >= @backup_set_id_start AND b.backup_set_id < @backup_set_id_end
			AND b.type = 'L'
UNION
SELECT 999999999 AS backup_set_id, 'RESTORE DATABASE ' + @databaseName + ' WITH RECOVERY'
ORDER BY backup_set_id;

--END SCRIPT
USE [master];
GO
