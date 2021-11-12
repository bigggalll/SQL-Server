USE MASTER;
GO

RESTORE DATABASE [BackupSample] FROM DISK = 'C:\KNOWBACKUPS\BACKUPS\BACKUPSAMPLE_BASE.BAK' WITH NORECOVERY, REPLACE;
RESTORE LOG [BackupSample] FROM DISK = 'C:\KNOWBACKUPS\BACKUPS\BACKUPSAMPLE_LOG1.BAK' WITH NORECOVERY;
RESTORE LOG [BackupSample] FROM DISK = 'C:\KNOWBACKUPS\backups\BACKUPSAMPLE_LOG2.BAK' WITH NORECOVERY;
RESTORE LOG [BackupSample] FROM DISK = 'C:\KNOWBACKUPS\backups\BACKUPSAMPLE_LOG3.BAK' WITH NORECOVERY;
RESTORE LOG [BackupSample] FROM DISK = 'C:\KNOWBACKUPS\backups\BACKUPSAMPLE_LOG4.BAK' WITH NORECOVERY;
RESTORE DATABASE [BackupSample] WITH RECOVERY;
GO

--VIEW SalesOrderID's
USE [BackupSample];
GO

SELECT TOP 1 *
	FROM Sales 
	ORDER BY SalesOrderID DESC;
GO

--Insert another record
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
           ('99999'
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

--View last record inserted
SELECT TOP 2 *
	FROM Sales 
	ORDER BY SalesOrderID DESC;
GO

--SET Database OFFLINE
USE MASTER;
GO

ALTER DATABASE [BackupSample] SET OFFLINE;
GO

--*****  NOW DELETE THE MDF FILE  *****

--SET Database ONLINE
ALTER DATABASE [BackupSample] SET ONLINE;
GO

--Nasty little error isn't it?

--Now let's try to backup that last transaction we inserted.
BACKUP LOG [BackupSample] TO DISK = 'C:\KnowBackups\backups\backupsample_taillog.bak' 
WITH INIT, NO_TRUNCATE;
GO

--Now let's restore our base full backup, all our transaction logs including the taillog we just made.
USE MASTER;
GO
RESTORE DATABASE [BackupSample] 
		FROM DISK = 'C:\KNOWBACKUPS\BACKUPS\BACKUPSAMPLE_BASE.BAK' WITH NORECOVERY, REPLACE;
RESTORE LOG [BackupSample] FROM DISK = 'C:\KNOWBACKUPS\BACKUPS\BACKUPSAMPLE_LOG1.BAK' WITH NORECOVERY;
RESTORE LOG [BackupSample] FROM DISK = 'C:\KNOWBACKUPS\backups\BACKUPSAMPLE_LOG2.BAK' WITH NORECOVERY;
RESTORE LOG [BackupSample] FROM DISK = 'C:\KNOWBACKUPS\backups\BACKUPSAMPLE_LOG3.BAK' WITH NORECOVERY;
RESTORE LOG [BackupSample] FROM DISK = 'C:\KNOWBACKUPS\backups\BACKUPSAMPLE_LOG4.BAK' WITH NORECOVERY;
RESTORE LOG [BackupSample] FROM DISK = 'C:\KNOWBACKUPS\backups\BACKUPSAMPLE_taillog.BAK' WITH NORECOVERY;
RESTORE DATABASE [BackupSample] WITH RECOVERY;
GO

--Now let's see if we can view our '99999' transaction.
USE [BackupSample];
GO

SELECT TOP 2 *
	FROM Sales 
	ORDER BY SalesOrderID DESC;
GO

USE MASTER;
GO
