SELECT SUSER_NAME(members.role_principal_id) AS [ServerRole]
   ,logins.name AS 'RoleMember'
   ,'EXEC sp_addsrvrolemember ''' +logins.name+''', '''+
   SUSER_NAME(members.role_principal_id)+'''' AS [Command to add role members]
FROM sys.server_role_members members, sys.server_principals logins
WHERE members.role_principal_id >=3 AND members.role_principal_id <=10 AND
members.member_principal_id = logins.principal_id
and logins.name <>'sa'
order by RoleMember