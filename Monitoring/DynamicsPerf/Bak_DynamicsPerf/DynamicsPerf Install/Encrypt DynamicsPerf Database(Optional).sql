/*

http://social.technet.microsoft.com/wiki/contents/articles/16086.implementing-transparent-data-encryption-tde-in-sql-server.aspx

*/


/*************************************************************************
***  NOT RECOMMENDED TO ENCRYPT DynamicsPerf if installed local 
***           to the Dynamics Database
***  This will encrypt TempDb and possibly cause performance issues
**************************************************************************/










--Step #1 Create a master key.

      USE master;
       CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'CHANGE ME';  --Use a Strong Password
       
--Step #2 Validate if  a master key has been created.
     USE master;
     select * from sys.symmetric_keys;
     
 --Step #3.  Create a Database Certificate
       Use master
       CREATE CERTIFICATE DynamicsPerfcert
       WITH SUBJECT = 'DynamicsPerfcertificate'   
       
-- Create a backup of the server certificate in the master database.
-- The following code stores the backup of the certificate and the private key file in the default data location for this instance of SQL Server 
-- (C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA).       
       
  --Backup the Certificate     
BACKUP CERTIFICATE DynamicsPerfcert TO FILE = 'DynamicsPerfcert' 
WITH PRIVATE KEY ( FILE = 'DynamicsPerfPrivateKeyFile', 
ENCRYPTION BY PASSWORD = '*rt@40(FL&dasl1' --Change the password, use strong password


);    
       
--Step #4.  Validate that a Database Certificate has been created
		SELECT * FROM sys.certificates 
		
--Step #5.  Create a Database Encryption Key
      USE DynamicsPerf
       CREATE DATABASE ENCRYPTION KEY 
       WITH ALGORITHM = AES_256
       ENCRYPTION BY SERVER CERTIFICATE [DynamicsPerfcert]
       
--Step #6.  Set the Database to use Encryption
	   ALTER DATABASE DynamicsPerf
       SET ENCRYPTION ON;