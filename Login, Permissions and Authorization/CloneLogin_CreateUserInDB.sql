IF EXISTS(SELECT name FROM sys.procedures WHERE name = 'CreateUserInDB')
  DROP PROCEDURE dbo.CreateUserInDB;
GO 

CREATE PROC dbo.CreateUserInDB
  @NewLogin sysname,
  @LoginToClone sysname,
  @DBName sysname
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @TSQL nvarchar(MAX);
  DECLARE @Return int;

  BEGIN TRAN; 

  SET @TSQL = 'USE [' + @DBName + ']; IF EXISTS(SELECT name FROM sys.database_principals 
                         WHERE name = ''' + @LoginToClone + ''')
                 BEGIN
				   CREATE USER [' + @NewLogin + '] FROM LOGIN [' + @NewLogin + '];
				 END;';
  EXEC @Return = sp_executesql @TSQL;

  IF (@Return <> 0)
    BEGIN
	  ROLLBACK TRAN;
	  RAISERROR('Error creating user', 16, 1);
	  RETURN(1);
	END;

  COMMIT TRAN;
END;