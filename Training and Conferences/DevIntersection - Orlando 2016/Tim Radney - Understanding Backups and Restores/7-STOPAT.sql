USE MASTER
GO

RESTORE DATABASE BackupSample FROM DISK = 'c:\knowbackups\backupsample_prepit.bak' WITH REPLACE

/* SETUP DATABASE

USE [backupsample]
GO

CREATE TABLE [dbo].[PointInTime](
	[ROWID] [int] IDENTITY(1,1) NOT NULL,
	[DATE] [datetime] NULL
) ON [PRIMARY]

GO

USE [backupsample]
GO

SELECT * FROM [PointInTime]


INSERT INTO [dbo].[PointInTime]
           ([DATE])
     VALUES
           (getdate())
waitfor delay '00:0:30'
GO 10

SELECT * FROM [PointInTime]

BACKUP LOG BackupSample to disk = 'c:\knowbackups\backupsample_pit.trn' WITH COMPRESSION, INIT

*/

USE MASTER 
GO

RESTORE DATABASE BackupSample FROM DISK = 'c:\knowbackups\backupsample_prepit.bak' with norecovery, replace
RESTORE LOG BackupSample FROM DISK = 'C:\knowbackups\backupsample_pit.trn' WITH STOPAT = '2016-03-24 02:09:26.657';

USE BackupSample
GO

SELECT * FROM [PointInTime]
