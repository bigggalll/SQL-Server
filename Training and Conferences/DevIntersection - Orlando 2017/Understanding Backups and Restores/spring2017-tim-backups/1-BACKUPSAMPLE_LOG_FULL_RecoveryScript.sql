--RESTORE BackupSample from our base backup.
USE [master]
GO
RESTORE DATABASE [BackupSample] FROM DISK = 'C:\KNOWBACKUPS\BACKUPSAMPLE_BASE.BAK' WITH NORECOVERY, REPLACE;
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

--Show the top 10 orders by SalesOrderID DESC
--This will allow us to see when we insert new records
USE [BackupSample];
GO
SELECT TOP 10 * 
	FROM Sales 
	ORDER BY SalesOrderID DESC;
GO

--Backup the database and log 
BACKUP DATABASE [BackupSample] 
	TO DISK = 'C:\KNOWBACKUPS\BACKUPS\BACKUPSAMPLE_BASE.BAK';
GO
BACKUP LOG [BackupSample] 
	TO DISK = 'C:\KNOWBACKUPS\BACKUPS\BACKUPSAMPLE_LOG1.BAK';
GO

--INSERT a single record into the sales table.
INSERT  INTO [BackupSample].[dbo].[sales]
        ( [SalesOrderID] ,
          [CarrierTrackingNumber] ,
          [OrderQty] ,
          [ProductID] ,
          [SpecialOfferID] ,
          [UnitPrice] ,
          [UnitPriceDiscount] ,
          [LineTotal] ,
          [rowguid] ,
          [ModifiedDate]
        )
VALUES  ( '75150' ,
          NULL ,
          '2' ,
          '879' ,
          '1' ,
          '159.00' ,
          '0.00' ,
          '318.00' ,
          NEWID() ,
          GETDATE()
        );
GO

--Backup the log 
BACKUP LOG [BackupSample] 
	TO DISK = 'C:\KNOWBACKUPS\BACKUPS\BACKUPSAMPLE_LOG2.BAK';
GO

--INSERT another record into the sales table.
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

--Take another log backup.
BACKUP LOG [BackupSample] 
	TO DISK = 'C:\KNOWBACKUPS\BACKUPS\BACKUPSAMPLE_LOG3.BAK';
GO

--Lets insert another record for good measure into the sales table.
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
           ('75250'
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

--A final log backup.
BACKUP LOG [BackupSample] 
	TO DISK = 'C:\KNOWBACKUPS\BACKUPS\BACKUPSAMPLE_LOG4.BAK';
GO

--Now lets see if we see our 3 records we inserted.
--Should have SalesOrderID 75150, 75200 and 75250
USE [BackupSample];
GO

SELECT TOP 10 *
	FROM SALES ORDER BY SalesOrderID DESC;
GO

/* Now lets run a simple script to generate a restore script
that includes the last FULL backup and each transaction log
since the last FULL backup, this can be a life saver */
--BEGIN SCRIPT

DECLARE @databaseName sysname
DECLARE @backupStartDate datetime
DECLARE @backup_set_id_start INT
DECLARE @backup_set_id_end INT

-- set database to be used
SET @databaseName = 'BackupSample';


SELECT @backup_set_id_start = MAX(backup_set_id) 
	FROM  msdb.dbo.backupset 
	WHERE database_name = @databaseName AND TYPE = 'D';


SELECT @backup_set_id_end = MIN(backup_set_id) 
	FROM  msdb.dbo.backupset 
	WHERE database_name = @databaseName AND TYPE = 'D'
	AND backup_set_id > @backup_set_id_start;

IF @backup_set_id_end IS NULL SET @backup_set_id_end = 999999999;

SELECT backup_set_id, 'RESTORE DATABASE ' + @databaseName + ' FROM DISK = ''' 
               + mf.physical_device_name + ''' WITH NORECOVERY'
	FROM msdb.dbo.backupset b,
         msdb.dbo.backupmediafamily mf
	WHERE b.media_set_id = mf.media_set_id
          AND b.database_name = @databaseName
          AND b.backup_set_id = @backup_set_id_start
UNION
SELECT backup_set_id, 'RESTORE LOG ' + @databaseName + ' FROM DISK = ''' 
          + mf.physical_device_name + ''' WITH NORECOVERY'
	FROM  msdb.dbo.backupset b,
          msdb.dbo.backupmediafamily mf
	WHERE b.media_set_id = mf.media_set_id
          AND b.database_name = @databaseName
          AND b.backup_set_id >= @backup_set_id_start AND b.backup_set_id < @backup_set_id_end
          AND b.type = 'L'
UNION
SELECT 999999999 AS backup_set_id, 'RESTORE DATABASE ' + @databaseName + ' WITH RECOVERY'
ORDER BY backup_set_id;
GO

--END RESTORE SCRIPT
USE [master];
GO
