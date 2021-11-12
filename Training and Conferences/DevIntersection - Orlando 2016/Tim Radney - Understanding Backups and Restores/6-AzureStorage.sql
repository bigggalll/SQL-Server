--Azure Backup
USE [master];
GO

BACKUP DATABASE BackupSample 
TO  URL = 'https://sqlskills.blob.core.windows.net/sqlskills/BackupSampletest92.bak' 
WITH CREDENTIAL = N'AzureBackup', COMPRESSION, STATS = 1


RESTORE DATABASE BackupSample
	FROM URL = 'https://sqlskills.blob.core.windows.net/sqlskills/BackupSampletest92.bak' 
WITH CREDENTIAL = N'AzureBackup', REPLACE, STATS = 1
