USE MASTER
GO 
SELECT name as SQLServerLogIn,SID as SQLServerSID FROM sys.syslogins
WHERE [name] = 'suprkron'
GO

USE tkcsdb
GO 
SELECT name DataBaseID,SID as DatabaseSID FROM sysusers
WHERE [name] = 'suprkron'
GO

sp_change_users_login @Action='update_one', 
@UserNamePattern='cirxread', 
@LoginName='cirxread'
GO
sp_change_users_login @Action='update_one', 
@UserNamePattern='kronread', 
@LoginName='kronread'
GO
sp_change_users_login @Action='update_one', 
@UserNamePattern='slwm', 
@LoginName='slwm'
GO
sp_change_users_login @Action='update_one', 
@UserNamePattern='usranalyseft', 
@LoginName='usranalyseft'
GO
sp_change_users_login @Action='update_one', 
@UserNamePattern='usrdbremoteaccess', 
@LoginName='usrdbremoteaccess'
GO
sp_change_users_login @Action='update_one', 
@UserNamePattern='usrfeuilletemps', 
@LoginName='usrfeuilletemps'
GO
sp_change_users_login @Action='update_one', 
@UserNamePattern='usrfeuilletemps8', 
@LoginName='usrfeuilletemps8'
GO
