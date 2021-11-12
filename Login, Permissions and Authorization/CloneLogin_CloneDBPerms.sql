IF EXISTS(SELECT name FROM sys.procedures WHERE name = 'CloneDBPerms')
  DROP PROCEDURE dbo.CloneDBPerms;
GO 

CREATE PROC dbo.CloneDBPerms
  @NewLogin sysname,
  @LoginToClone sysname,
  @DBName sysname
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @SQL nvarchar(max);
	DECLARE @Return int;

	CREATE TABLE #DBPermissionsTSQL 
	(
		PermsTSQL nvarchar(MAX)
	);


	SET @SQL = 'INSERT INTO #DBPermissionsTSQL (PermsTSQL) 
	SELECT CASE [state]
	   WHEN ''W'' THEN ''GRANT '' + permission_name + '' ON DATABASE::[' 
		 + @DBName + '] TO [' + @NewLogin + '] WITH GRANT OPTION;'' COLLATE DATABASE_DEFAULT
	   ELSE state_desc + '' '' + permission_name + '' ON DATABASE::[' 
		 + @DBName + '] TO [' + @NewLogin + '];'' COLLATE DATABASE_DEFAULT
	   END AS ''Permission''
	FROM [' + @DBName + '].sys.database_permissions AS P
	  JOIN [' + @DBName + '].sys.database_principals AS U
		ON P.grantee_principal_id = U.principal_id
	WHERE class = 0
	  AND P.[type] <> ''CO''
	  AND U.name = ''' + @LoginToClone + ''';';

	EXECUTE @Return = sp_executesql @SQL;

	IF (@Return <> 0)
	BEGIN
		ROLLBACK TRAN;
		RAISERROR('Error encountered building permissions.', 16, 1);
		RETURN(1);
	END

	SET @SQL = 'INSERT INTO #DBPermissionsTSQL (PermsTSQL)
	SELECT CASE [state]
	   WHEN ''W'' THEN ''GRANT '' + permission_name + '' ON SCHEMA::['' 
		 + S.name + ''] TO [' + @NewLogin + '] WITH GRANT OPTION;'' COLLATE DATABASE_DEFAULT
	   ELSE state_desc + '' '' + permission_name + '' ON SCHEMA::['' 
		 + S.name + ''] TO [' + @NewLogin + '];'' COLLATE DATABASE_DEFAULT
	   END AS ''Permission''
	FROM [' + @DBName + '].sys.database_permissions AS P
	  JOIN [' + @DBName + '].sys.database_principals AS U
		ON P.grantee_principal_id = U.principal_id
	  JOIN [' + @DBName + '].sys.schemas AS S
		ON S.schema_id = P.major_id
	WHERE class = 3
	  AND U.name = ''' + @LoginToClone + ''';';

	EXECUTE @Return = sp_executesql @SQL;

	IF (@Return <> 0)
	BEGIN
		ROLLBACK TRAN;
		RAISERROR('Error encountered building permissions.', 16, 1);
		RETURN(1);
	END

	SET @SQL = 'INSERT INTO #DBPermissionsTSQL (PermsTSQL) 
	SELECT CASE [state]
	   WHEN ''W'' THEN ''GRANT '' + permission_name + '' ON OBJECT::['' 
		 + S.name + ''].['' + O.name + ''] TO [' + @NewLogin + '] WITH GRANT OPTION;'' COLLATE DATABASE_DEFAULT
	   ELSE state_desc + '' '' + permission_name + '' ON OBJECT::['' 
		 + S.name + ''].['' + O.name + ''] TO [' + @NewLogin + '];'' COLLATE DATABASE_DEFAULT
	   END AS ''Permission''
	FROM [' + @DBName + '].sys.database_permissions AS P
	  JOIN [' + @DBName + '].sys.database_principals AS U
		ON P.grantee_principal_id = U.principal_id
	  JOIN [' + @DBName + '].sys.objects AS O
		ON O.object_id = P.major_id
	  JOIN [' + @DBName + '].sys.schemas AS S
		ON O.schema_id = S.schema_id
	WHERE class = 1
	  AND U.name = ''' + @LoginToClone + '''
	  AND P.major_id > 0
	  AND P.minor_id = 0';

	EXECUTE @Return = sp_executesql @SQL;

	IF (@Return <> 0)
	BEGIN
		ROLLBACK TRAN;
		RAISERROR('Error encountered building permissions.', 16, 1);
		RETURN(1);
	END

	SET @SQL = 'INSERT INTO #DBPermissionsTSQL (PermsTSQL)
	SELECT CASE [state]
	   WHEN ''W'' THEN ''GRANT '' + permission_name + '' ON OBJECT::['' 
		 + O.name + ''] ('' + C.name + '') TO [' + @NewLogin + '] WITH GRANT OPTION;'' 
		 COLLATE DATABASE_DEFAULT
	   ELSE state_desc + '' '' + permission_name + '' ON OBJECT::['' 
		 + O.name + ''] ('' + C.name + '') TO [' + @NewLogin + '];'' 
		 COLLATE DATABASE_DEFAULT
	   END AS ''Permission''
	FROM [' + @DBName + '].sys.database_permissions AS P
	  JOIN [' + @DBName + '].sys.database_principals AS U
		ON P.grantee_principal_id = U.principal_id
	  JOIN [' + @DBName + '].sys.objects AS O
		ON O.object_id = P.major_id
	  JOIN [' + @DBName + '].sys.columns AS C
		ON C.column_id = P.minor_id AND O.object_id = C.object_id
	WHERE class = 1
	  AND U.name = ''' + @LoginToClone + '''
	  AND P.major_id > 0
	  AND P.minor_id > 0;'
	
	EXECUTE @Return = sp_executesql @SQL;

	IF (@Return <> 0)
	BEGIN
		ROLLBACK TRAN;
		RAISERROR('Error encountered building permissions.', 16, 1);
		RETURN(1);
	END

	SET @SQL = 'INSERT INTO #DBPermissionsTSQL (PermsTSQL) 
	SELECT CASE [state]
	   WHEN ''W'' THEN ''GRANT '' + permission_name + '' ON USER::['' 
		 + U2.name + ''] TO [' + @NewLogin + '] WITH GRANT OPTION;'' COLLATE DATABASE_DEFAULT
	   ELSE state_desc + '' '' + permission_name + '' ON USER::['' 
		 + U2.name + ''] TO [' + @NewLogin + '];'' COLLATE DATABASE_DEFAULT
	   END AS ''Permission''
	FROM [' + @DBName + '].sys.database_permissions AS P
	  JOIN [' + @DBName + '].sys.database_principals AS U
		ON P.grantee_principal_id = U.principal_id
	  JOIN [' + @DBName + '].sys.database_principals AS U2
		ON U2.principal_id = P.major_id
	WHERE class = 4
	  AND U.name = ''' + @LoginToClone + ''';';

	EXECUTE @Return = sp_executesql @SQL;

	IF (@Return <> 0)
	BEGIN
		ROLLBACK TRAN;
		RAISERROR('Error encountered building permissions.', 16, 1);
		RETURN(1);
	END

	SET @SQL = 'INSERT INTO #DBPermissionsTSQL (PermsTSQL)
	SELECT CASE [state]
	   WHEN ''W'' THEN ''GRANT '' + permission_name + '' ON SYMMETRIC KEY::['' 
		 + K.name + ''] TO [' + @NewLogin + '] WITH GRANT OPTION;'' COLLATE DATABASE_DEFAULT
	   ELSE state_desc + '' '' + permission_name + '' ON SYMMETRIC KEY::['' 
		 + K.name + ''] TO [' + @NewLogin + '];'' COLLATE DATABASE_DEFAULT
	   END AS ''Permission''
	FROM [' + @DBName + '].sys.database_permissions AS P
	  JOIN [' + @DBName + '].sys.database_principals AS U
		ON P.grantee_principal_id = U.principal_id
	  JOIN [' + @DBName + '].sys.symmetric_keys AS K
		ON P.major_id = K.symmetric_key_id
	WHERE class = 24
	  AND U.name = ''' + @LoginToClone + ''';';

	EXECUTE @Return = sp_executesql @SQL;

	IF (@Return <> 0)
	BEGIN
		ROLLBACK TRAN;
		RAISERROR('Error encountered building permissions.', 16, 1);
		RETURN(1);
	END

	SET @SQL = 'INSERT INTO #DBPermissionsTSQL (PermsTSQL) 
	SELECT CASE [state]
	   WHEN ''W'' THEN ''GRANT '' + permission_name + '' ON ASYMMETRIC KEY::['' 
		 + K.name + ''] TO [' + @NewLogin + '] WITH GRANT OPTION;'' COLLATE DATABASE_DEFAULT
	   ELSE state_desc + '' '' + permission_name + '' ON ASYMMETRIC KEY::['' 
		 + K.name + ''] TO [' + @NewLogin + '];'' COLLATE DATABASE_DEFAULT
	   END AS ''Permission''
	FROM [' + @DBName + '].sys.database_permissions AS P
	  JOIN [' + @DBName + '].sys.database_principals AS U
		ON P.grantee_principal_id = U.principal_id
	  JOIN [' + @DBName + '].sys.asymmetric_keys AS K
		ON P.major_id = K.asymmetric_key_id
	WHERE class = 26
	  AND U.name = ''' + @LoginToClone + ''';';
	
	EXECUTE @Return = sp_executesql @SQL;

	IF (@Return <> 0)
	BEGIN
		ROLLBACK TRAN;
		RAISERROR('Error encountered building permissions.', 16, 1);
		RETURN(1);
	END

	SET @SQL = 'INSERT INTO #DBPermissionsTSQL (PermsTSQL) 
	SELECT CASE [state]
	   WHEN ''W'' THEN ''GRANT '' + permission_name + '' ON CERTIFICATE::['' 
		 + C.name + ''] TO [' + @NewLogin + '] WITH GRANT OPTION;'' COLLATE DATABASE_DEFAULT
	   ELSE state_desc + '' '' + permission_name + '' ON CERTIFICATE::['' 
		 + C.name + ''] TO [' + @NewLogin + '];'' COLLATE DATABASE_DEFAULT
	   END AS ''Permission''
	FROM [' + @DBName + '].sys.database_permissions AS P
	  JOIN [' + @DBName + '].sys.database_principals AS U
		ON P.grantee_principal_id = U.principal_id
	  JOIN [' + @DBName + '].sys.certificates AS C
		ON P.major_id = C.certificate_id
	WHERE class = 25
	  AND U.name = ''' + @LoginToClone + ''';';

	EXECUTE @Return = sp_executesql @SQL;

	IF (@Return <> 0)
	BEGIN
		ROLLBACK TRAN;
		RAISERROR('Error encountered building permissions.', 16, 1);
		RETURN(1);
	END

	DECLARE cursDBPermsSQL CURSOR FAST_FORWARD
	FOR
	SELECT PermsTSQL FROM #DBPermissionsTSQL

	OPEN cursDBPermsSQL;

	FETCH FROM cursDBPermsSQL INTO @SQL;

	WHILE (@@FETCH_STATUS = 0)
	BEGIN
	  SET @SQL = 'USE [' + @DBName + ']; ' + @SQL;

	  PRINT @SQL;
	  EXEC @Return = sp_executesql @SQL;

	  IF (@Return <> 0)
	  BEGIN
		  ROLLBACK TRAN;
		  RAISERROR('Error granting permission', 16, 1);
		  CLOSE cursDBPermsSQL;
		  DEALLOCATE cursDBPermsSQL;
		  RETURN(1);
	  END;

	  FETCH NEXT FROM cursDBPermsSQL INTO @SQL;
	END;

	CLOSE cursDBPermsSQL;
	DEALLOCATE cursDBPermsSQL;
	DROP TABLE #DBPermissionsTSQL;
END;
GO 