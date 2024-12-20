ALTER SERVER ROLE [dbcreator] DROP MEMBER [NT AUTHORITY\SYSTEM]
GO
ALTER SERVER ROLE [sysadmin] DROP MEMBER [NT AUTHORITY\SYSTEM]
GO
GRANT ALTER ANY AVAILABILITY GROUP TO [NT AUTHORITY\SYSTEM]
GO
GRANT CONNECT SQL TO [NT AUTHORITY\SYSTEM]
GO
GRANT VIEW SERVER STATE TO [NT AUTHORITY\SYSTEM]
GO


SELECT * 
FROM (
SELECT
	ServerRole = rp.name,
	PrincipalName = SP.name
FROM sys.server_role_members rm
	Inner JOIN sys.server_principals rp
		ON rm.role_principal_id = rp.principal_id
	Inner JOIN sys.server_principals SP
		ON rm.member_principal_id = SP.principal_id
Union
Select 'Public' as ServerRole, SP.name as PrincipalName
	From sys.server_principals SP
	where type in ('u','s','g')
		And is_disabled = 0) t
 where PrincipalName='NT AUTHORITY\SYSTEM'

 SELECT pr.principal_id, pr.name, pr.type_desc, 
    pe.state_desc, pe.permission_name 
FROM sys.server_principals AS pr 
JOIN sys.server_permissions AS pe 
    ON pe.grantee_principal_id = pr.principal_id
where pr.name='NT AUTHORITY\SYSTEM';