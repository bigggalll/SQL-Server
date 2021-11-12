IF EXISTS(SELECT name FROM sys.procedures WHERE name = 'CloneLoginAndAllDBPerms')
  DROP PROCEDURE dbo.CloneLoginAndAllDBPerms;
GO 

CREATE PROC dbo.CloneLoginAndAllDBPerms
  @NewLogin sysname,
  @NewLoginPwd NVARCHAR(MAX),
  @WindowsLogin CHAR(1),
  @LoginToClone sysname
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @Return int;

  BEGIN TRAN;

  EXEC @Return = dbo.CloneLogin 
    @NewLogin = @NewLogin, 
	@NewLoginPwd = @NewLoginPwd, 
	@WindowsLogin = @WindowsLogin, 
	@LoginToClone = @LoginToClone;

  IF (@Return <> 0)
	BEGIN
	  ROLLBACK TRAN;
	  RAISERROR('Exiting because login could not be created', 16, 1);
	  RETURN(1);
	END

  DECLARE @DBName sysname;
  DECLARE @SQL nvarchar(MAX);

  DECLARE cursDBs CURSOR FAST_FORWARD
  FOR
  SELECT name 
  FROM sys.databases 
  WHERE state_desc = 'ONLINE';

  OPEN cursDBs;

  FETCH FROM cursDBs INTO @DBName;

  WHILE (@@FETCH_STATUS = 0)
  BEGIN
    EXEC @Return = dbo.CreateUserInDB 
	  @NewLogin = @NewLogin, 
	  @LoginToClone = @LoginToClone, 
	  @DBName = @DBName;

	IF (@Return <> 0)
	BEGIN
	  ROLLBACK TRAN;
	  RAISERROR('Exiting because user could not be created.', 16, 1);
	  RETURN(1);
	END;

	EXEC @Return = dbo.GrantUserRoleMembership
	  @NewLogin = @NewLogin, 
	  @LoginToClone = @LoginToClone, 
	  @DBName = @DBName;

	IF (@Return <> 0)
	BEGIN
	  ROLLBACK TRAN;
	  RAISERROR('Exiting because role meberships could not be granted.', 16, 1);
	  RETURN(1);
	END;

	EXEC @Return = dbo.CloneDBPerms
	  @NewLogin = @NewLogin, 
	  @LoginToClone = @LoginToClone, 
	  @DBName = @DBName;

	IF (@Return <> 0)
	BEGIN
	  ROLLBACK TRAN;
	  RAISERROR('Exiting because user could not be created.', 16, 1);
	  RETURN(1);
	END;

    FETCH NEXT FROM cursDBs INTO @DBName;
  END;

  CLOSE cursDBs;
  DEALLOCATE cursDBs;

  COMMIT TRAN;
END;

GO

--exec dbo.CloneLoginAndAllDBPerms
--  @NewLogin ='GROUPE\amartin',
--  @NewLoginPwd ='',
--  @WindowsLogin = 'T',
--  @LoginToClone = 'GROUPE\svcSQLvrf'