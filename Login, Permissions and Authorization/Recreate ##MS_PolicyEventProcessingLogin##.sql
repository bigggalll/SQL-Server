Ok, what I did:
1) at the machine where you deleted the logins run:

use master
go
sp_change_users_login 'Report'
-> This shoud show you the SID of the ##MS_PolicyEventProcessingLogin##
2) replace in the following line <enter SID from step 1 here> with SID from step 1 and run the script
CREATE LOGIN [##MS_PolicyEventProcessingLogin##] WITH PASSWORD = 0x0100EBB95886A3A65AD6C770157B4E767D146D83E079A3A33321 HASHED, SID = <enter SID from step 1 here>, DEFAULT_DATABASE = [master], CHECK_POLICY = ON, CHECK_EXPIRATION = OFF; ALTER LOGIN [##MS_PolicyEventProcessingLogin##] DISABLE
CREATE LOGIN [##MS_PolicyTsqlExecutionLogin##] WITH PASSWORD = 0x01008D22A249DF5EF3B79ED321563A1DCCDC9CFC5FF954DD2D0F HASHED, SID = 0x8F651FE8547A4644A0C06CA83723A876, DEFAULT_DATABASE = [master], CHECK_POLICY = ON, CHECK_EXPIRATION = OFF; ALTER LOGIN [##MS_PolicyTsqlExecutionLogin##] DISABLE
