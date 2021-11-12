--
-- Référence: https://www.mssqltips.com/sqlservertip/3648/how-to-clone-a-sql-server-login-part-3-of-3/
--

:r  "C:\GitHub\SQLServer\Login, Permissions and Authorization\CloneLogin_CloneLogin.sql"
go
:r  "C:\GitHub\SQLServer\Login, Permissions and Authorization\CloneLogin_CreateUserInDB.sql"
go
:r  "C:\GitHub\SQLServer\Login, Permissions and Authorization\CloneLogin_GrantUserRoleMembership.sql"
go
:r  "C:\GitHub\SQLServer\Login, Permissions and Authorization\CloneLogin_CloneDBPerms.sql"
go
:r  "C:\GitHub\SQLServer\Login, Permissions and Authorization\CloneLogin_CloneLoginAndAllDBPerms.sql"
go
exec CloneLogin
--if NOT EXISTS (SELECT 1 FROM sys.server_principals where name = 'GJC\GRP Centre Rx - Web-Micro')
--exec dbo.CloneLoginAndAllDBPerms
  @NewLogin ='GROUPEDEV\GS-APP - DW-MSBI-DevD',
  @NewLoginPwd ='',
  @WindowsLogin = 'T',
  @LoginToClone = 'GJC\DW_MSBI_Dev'
go
-- Cas du secondaire
--exec dbo.CloneLogin
--  @NewLogin ='GROUPEQA\BD SGE CIRX DistributionQ',
--  @NewLoginPwd ='',
--  @WindowsLogin = 'T',
--  @LoginToClone = 'GJC\Distribution HighJump ReadOnly'
--go

