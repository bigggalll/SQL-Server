IF EXISTS(SELECT name FROM sys.procedures WHERE name = 'CloneLogin')
  DROP PROCEDURE dbo.CloneLogin;
GO 

CREATE PROCEDURE dbo.CloneLogin
  @NewLogin sysname,
  @NewLoginPwd NVARCHAR(MAX),
  @WindowsLogin CHAR(1),
  @LoginToClone sysname
AS BEGIN

	SET NOCOUNT ON;

	DECLARE @SQL nvarchar(MAX);
	DECLARE @Return int;

	IF (@WindowsLogin = 'T')
	  SET @SQL = 'CREATE LOGIN [' + @NewLogin + '] FROM WINDOWS;'
	ELSE
	  SET @SQL = 'CREATE LOGIN [' + @NewLogin + '] WITH PASSWORD = N''' + @NewLoginPwd + ''';';

    BEGIN TRAN;

	PRINT @SQL;
	EXEC @Return = sp_executesql @SQL;

	IF (@Return <> 0)
	BEGIN
	  ROLLBACK TRAN;
	  RAISERROR('Error encountered creating login', 16, 1);
	  RETURN(1);
	END


	-- Query to handle server roles
	DECLARE cursRoleMemberSQL CURSOR FAST_FORWARD
	FOR
	SELECT 'EXEC sp_addsrvrolemember @loginame = ''' + @NewLogin 
			  + ''', @rolename = ''' + R.name + ''';' AS 'SQL'
	FROM sys.server_role_members AS RM
	  JOIN sys.server_principals AS L
		ON RM.member_principal_id = L.principal_id
	  JOIN sys.server_principals AS R
		ON RM.role_principal_id = R.principal_id
	WHERE L.name = @LoginToClone;

	OPEN cursRoleMemberSQL;

	FETCH FROM cursRoleMemberSQL INTO @SQL;

	WHILE (@@FETCH_STATUS = 0)
	BEGIN
	  PRINT @SQL;
	  EXECUTE @Return = sp_executesql @SQL;

	  IF (@Return <> 0)
		BEGIN
		  ROLLBACK TRAN;
		  RAISERROR('Error encountered assigning role memberships.', 16, 1);
		  CLOSE cursRoleMembersSQL;
		  DEALLOCATE cursRoleMembersSQL;
		  RETURN(1);
		END

	  FETCH NEXT FROM cursRoleMemberSQL INTO @SQL;
	END;

	CLOSE cursRoleMemberSQL;
	DEALLOCATE cursRoleMemberSQL;

	DECLARE cursServerPermissionSQL CURSOR FAST_FORWARD
	FOR
	SELECT CASE P.state WHEN 'W' THEN 
			 'USE master; GRANT ' + P.permission_name + ' TO [' + @NewLogin + '] WITH GRANT OPTION;'
		   ELSE 
			 'USE master;  ' + P.state_desc + ' ' + P.permission_name + ' TO [' + @NewLogin + '];'   
		   END AS 'SQL'
	FROM sys.server_permissions AS P
	  JOIN sys.server_principals AS L
		ON P.grantee_principal_id = L.principal_id
	WHERE L.name = @LoginToClone
	  AND P.class = 100
	  AND P.type <> 'COSQ'
	UNION ALL
	SELECT CASE P.state WHEN 'W' THEN 
			 'USE master; GRANT ' + P.permission_name + ' ON LOGIN::[' + L2.name + 
			 '] TO [' + @NewLogin + '] WITH GRANT OPTION;' COLLATE DATABASE_DEFAULT
		   ELSE 
			 'USE master; ' + P.state_desc + ' ' + P.permission_name + ' ON LOGIN::[' + L2.name 
			 + '] TO [' + @NewLogin + '];' COLLATE DATABASE_DEFAULT
		   END AS 'SQL'
	FROM sys.server_permissions AS P
	  JOIN sys.server_principals AS L
		ON P.grantee_principal_id = L.principal_id
	  JOIN sys.server_principals AS L2
		ON P.major_id = L2.principal_id
	WHERE L.name = @LoginToClone
	  AND P.class = 101
	UNION ALL
	SELECT CASE P.state WHEN 'W' THEN 
			 'USE master; GRANT ' + P.permission_name + ' ON ENDPOINT::[' + E.name + 
			 '] TO [' + @NewLogin + '] WITH GRANT OPTION;' COLLATE DATABASE_DEFAULT
		   ELSE 
			 'USE master; ' + P.state_desc + ' ' + P.permission_name + ' ON ENDPOINT::[' + E.name 
			 + '] TO [' + @NewLogin + '];' COLLATE DATABASE_DEFAULT
		   END AS 'SQL'
	FROM sys.server_permissions AS P
	  JOIN sys.server_principals AS L
		ON P.grantee_principal_id = L.principal_id
	  JOIN sys.endpoints AS E
		ON P.major_id = E.endpoint_id
	WHERE L.name = @LoginToClone
	  AND P.class = 105;

	OPEN cursServerPermissionSQL;

	FETCH FROM cursServerPermissionSQL INTO @SQL;

	WHILE (@@FETCH_STATUS = 0)
	BEGIN
		PRINT @SQL;
		EXEC @Return = sp_executesql @SQL;

		IF (@Return <> 0)
		BEGIN
		  ROLLBACK TRAN;
		  RAISERROR('Error encountered adding server level permissions', 16, 1);
		  CLOSE cursServerPermissionSQL;
		  DEALLOCATE cursServerPermissionSQL;
		  RETURN(1);
		END

		FETCH NEXT FROM cursServerPermissionSQL INTO @SQL;
	END;

	CLOSE cursServerPermissionSQL;
	DEALLOCATE cursServerPermissionSQL;

	COMMIT TRAN;

	PRINT 'Login [' + @NewLogin + '] cloned successfully from [' + @LoginToClone + '].';
END;