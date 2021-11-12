--RESTORE BackupSample from our base backup.
USE [master];
GO
RESTORE DATABASE [BackupFileGroupSample] 
	FROM DISK = 'C:\KNOWBACKUPS\BackupFileGroupSample_BASE.bak' WITH NORECOVERY, REPLACE;
GO

RESTORE DATABASE [BackupFileGroupSample] WITH RECOVERY;
GO

--Change database and view data in table
USE [BackupFileGroupSample];
GO
SELECT  SalesOrderID, SalesOrderDetailID, UnitPrice, ModifiedDate
FROM    Sales
WHERE   modifieddate < '2013-01-02';
GO

--Need a Full Backup then a Log backup in order to add FileGroups.
BACKUP DATABASE [BackupFileGroupSample] 
	TO DISK = 'c:\knowbackups\backups\BackupFileGroupSample_BASE.bak';
GO

BACKUP LOG [BackupFileGroupSample] 
	TO DISK = 'NUL';
GO

--Create File Groups  **SHOW CURRENT FILES AND FILEGROUPS IN GUI**
USE [master];
GO

ALTER DATABASE [BACKUPFILEGROUPSAMPLE] ADD FILEGROUP [2011];
GO

ALTER DATABASE [BACKUPFILEGROUPSAMPLE] ADD FILEGROUP [2010];
GO

ALTER DATABASE [BACKUPFILEGROUPSAMPLE] ADD FILEGROUP [2009];
GO

--Create Files and add to File Groups  **SHOW FILES GROUPS CREATE - NO FILES**
USE [master];
GO

ALTER DATABASE [BackupFileGroupSample]
ADD FILE
( NAME = BackupFilegroupSample2009,
	FILENAME = 'C:\sqldata\BackupFilegroupSample2009.ndf',
	SIZE = 1MB,
	MAXSIZE = 100MB,
	FILEGROWTH = 1MB
	)TO FILEGROUP [2009];
	GO
ALTER DATABASE [BackupFileGroupSample]
ADD FILE
( NAME = BackupFilegroupSample2010,
	FILENAME = 'C:\sqldata\BackupFilegroupSample2010.ndf',
	SIZE = 1MB,
	MAXSIZE = 100MB,
	FILEGROWTH = 1MB
	)TO FILEGROUP [2010];
	GO
ALTER DATABASE [BackupFileGroupSample]
ADD FILE
( NAME = BackupFilegroupSample2011,
	FILENAME = 'C:\sqldata\BackupFilegroupSample2011.ndf',
	SIZE = 1MB,
	MAXSIZE = 100MB,
	FILEGROWTH = 1MB
	)TO FILEGROUP [2011];
	GO
	
--**SHOW FILE GROUPS, FILES, SHOW IN EXPLORER THE FILE SIZE OF 1MB**
--CREATE A PARTITION FUNCTION TO RELOCATE THE DATA
USE [BackupFilegroupSample];
GO

BEGIN TRANSACTION
CREATE PARTITION FUNCTION [SalesModifiedDateFunction](DATETIME) AS RANGE LEFT FOR VALUES (N'2010-01-01T00:00:00', N'2011-01-01T00:00:00', N'2012-01-01T00:00:00', N'2013-01-01T00:00:00')

CREATE PARTITION SCHEME [SalesModifiedDateScheme] AS PARTITION [SalesModifiedDateFunction] TO ([2009], [2010], [2011], [PRIMARY], [PRIMARY])

CREATE CLUSTERED INDEX [ClusteredIndex_on_SalesModifiedDateScheme_634683074366356000] ON [dbo].[SALES] 
(
[ModifiedDate]
)WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [SalesModifiedDateScheme]([ModifiedDate])

DROP INDEX [ClusteredIndex_on_SalesModifiedDateScheme_634683074366356000] ON [dbo].[SALES] WITH ( ONLINE = OFF )

COMMIT TRANSACTION

--@@@@@ END PARTITION FUNCTION

--Now let's work on a piecemeal restore  **** This is where things get fun ****

--Get a baseline backup of our partitioned database
BACKUP DATABASE [BackupFileGroupSample] 
	TO DISK = 'C:\KnowBackups\Backups\BackupFileGroupSample_After.bak';
GO

--Backup filegroups
BACKUP DATABASE [BackupFileGroupSample]
	FILEGROUP = 'PRIMARY',
	FILEGROUP = '2009',
	FILEGROUP = '2010',
	FILEGROUP = '2011'
	TO DISK = 'C:\KNOWBACKUPS\Backups\FILEGROUP_BACKUP.BAK';
GO

--View Data to show all years are available
SELECT  SalesOrderID, SalesOrderDetailID, UnitPrice, ModifiedDate
	FROM    Sales 
	WHERE modifieddate < '2013-01-02';
GO

--Restore only the primary file group.
USE [master];
GO

RESTORE DATABASE [BackupFileGroupSample] FILEGROUP = 'Primary' 
	FROM DISK = 'C:\KnowBackups\backups\BackupFileGroupSample_After.bak' WITH Partial, RECOVERY, REPLACE;
GO

--Show that only the primary file group and the transaction log are online.
SELECT  NAME, state_desc
	FROM    [BackupFileGroupSample].sys.database_files;
GO

--Can now view information in the online filegroups
SELECT  SalesOrderID, SalesOrderDetailID, UnitPrice, ModifiedDate
	FROM [BackupFileGroupSample].dbo.Sales 
	WHERE modifieddate > '2012-01-02';
GO

--Can NOT access data in the recovery_pending filegroups
SELECT  SalesOrderID, SalesOrderDetailID, UnitPrice, ModifiedDate
	FROM [BackupFileGroupSample].dbo.Sales 
	WHERE modifieddate > '2009-01-02';
GO

--RESTORE 2009 FILEGROUP
RESTORE DATABASE [BackupFileGroupSample] FILEGROUP = '2009' WITH RECOVERY;
GO

--View State
SELECT  NAME , state_desc
	FROM    [BackupFileGroupSample].sys.database_files;
GO

--QUERY 2009 Data Only
SELECT  SalesOrderID, SalesOrderDetailID, UnitPrice, ModifiedDate
	FROM [BackupFileGroupSample].dbo.Sales 
	WHERE modifieddate BETWEEN '2009-01-02' AND '2009-12-31';
GO

--QUERY More than 2009
SELECT  SalesOrderID, SalesOrderDetailID, UnitPrice, ModifiedDate
	FROM [BackupFileGroupSample].dbo.Sales 
	WHERE modifieddate > '2009-01-02';
GO

--QUERY 2009 Data and 2012 Data
SELECT  SalesOrderID, SalesOrderDetailID, UnitPrice, ModifiedDate
	FROM [BackupFileGroupSample].dbo.Sales 
	WHERE modifieddate BETWEEN '2009-01-02' AND '2009-12-31' 
		OR ModifiedDate BETWEEN '2012-01-02' AND '2012-12-31';
GO

--Restore Other File Groups
RESTORE DATABASE [BackupFileGroupSample] FILEGROUP = '2010' WITH RECOVERY;
GO

RESTORE DATABASE [BackupFileGroupSample] FILEGROUP = '2011' WITH RECOVERY;
GO

--View State
SELECT  NAME, state_desc
	FROM    [BackupFileGroupSample].sys.database_files;
GO

--View All Data
SELECT  SalesOrderID, SalesOrderDetailID, UnitPrice, ModifiedDate
	FROM [BackupFileGroupSample].dbo.Sales 
	WHERE modifieddate < '2013-01-02';
GO

USE [master]
GO


