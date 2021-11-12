/* Delete C:\sqlbackup to remove backups and encryption keys

DROP certificate SQLskillsEncryptCert
DROP master key

-- Creates a database master key. 
-- The key is encrypted using the password "SQLskills"
*/ 

USE [master];
GO
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'SQLskills@';
GO
-- Next you will have to create a certificate, or asymmetric key, for
-- the instance if one does not already exist. 
-- Creates a new certificate for your instance

USE [master];
GO
CREATE CERTIFICATE [SQLskillsEncryptCert]
	WITH SUBJECT = 'SQLskills Backup Encryption Certificate';
GO
-- If you back up the database now with encryption, you would get an
-- error warning the encryption key has not been backed up

BACKUP MASTER KEY TO FILE = 'C:\SQLBackup\MasterKey' 
    ENCRYPTION BY PASSWORD = 'C0MplexP@$$w0rd';
GO

-- You should also backup the server certificate

BACKUP CERTIFICATE [SQLskillsEncryptCert]
	TO FILE = 'C:\SQLBackup\SQLskillsEncryptCert'
    WITH PRIVATE KEY ( FILE = 'c:\SQLBackup\SQLskillsEncryptCertkey' , 
    ENCRYPTION BY PASSWORD = 'C0MplexP@$$w0rd' );
GO

--Backup using T-SQL
BACKUP DATABASE [BackupSample]
	TO DISK = 'C:\SQLBackup\AdventureWorks2014_Compressed-Encryption.BAK'
	WITH COMPRESSION, ENCRYPTION 
		(ALGORITHM = AES_256, SERVER CERTIFICATE = SQLskillsEncryptCert);
GO

BACKUP DATABASE [BackupSample]
	TO DISK = 'C:\SQLBackup\AdventureWorks2014_TSQL_NC.BAK';
GO

/*
To restore an encrypted database, you do not have to specify any encryption
parameters. 
You do need to have the certificate or asymmetric key that you used to encrypt
the backup file. 
This key or certificate must be available on the instance you are restoring to. 
Your user account will need to have VIEW DEFINITION permissions on the key or
certificate.
If you are restoring a backup encrypted from TDE, the TDE certificate will have
to be available on the instance you are restoring to, as well.
*/

RESTORE DATABASE [BackupSample]
	FROM DISK = 'C:\SQLBackup\AdventureWorks2014_Compressed-Encryption.BAK'
	WITH REPLACE;
GO

-- Drop certificate 
DROP CERTIFICATE [SQLskillsEncryptCert];
GO

-- Attempt restore to show error
RESTORE DATABASE [BackupSample]
	FROM DISK = 'C:\SQLBackup\AdventureWorks2014_Compressed-Encryption.BAK'
	WITH REPLACE;
GO

-- Create the same certificate - NOT RESTORED
USE [master];
GO
CREATE CERTIFICATE [SQLskillsEncryptCert]
   WITH SUBJECT = 'SQLskills Backup Encryption Certificate';
GO

-- Attempt restore again
RESTORE DATABASE [BackupSample]
	FROM DISK = 'C:\SQLBackup\AdventureWorks2014_Compressed-Encryption.BAK'
	WITH REPLACE;
GO

--Drop certificate 
DROP CERTIFICATE [SQLskillsEncryptCert];
GO

-- Restore certificate
CREATE CERTIFICATE [SQLskillsEncryptCert] 
	FROM FILE = 'C:\sqlbackup\SQLskillsEncryptCert'
    WITH PRIVATE KEY ( FILE = 'C:\SQLBackup\SQLskillsEncryptCertkey' , 
    DECRYPTION BY PASSWORD = 'C0MplexP@$$w0rd');
GO

-- Show restore successful
RESTORE DATABASE [BackupSample]
	FROM DISK = 'C:\SQLBackup\AdventureWorks2014_Compressed-Encryption.BAK'
	WITH REPLACE;
GO

USE [master];
GO
