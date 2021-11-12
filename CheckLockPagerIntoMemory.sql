SET NOCOUNT ON;
 
DECLARE @CMDShellFlag [bit] ,
        @CheckCommand [nvarchar](256);
         
 
DECLARE @xp_cmdshell_output TABLE
    (
      [output] [varchar](8000)
    );
 
IF NOT EXISTS ( SELECT  *
                FROM    [sys].[configurations]
                WHERE   [name] = N'xp_cmdshell'
                        AND [value_in_use] = 1 )
    BEGIN
         
        SET @CMDShellFlag = 1;
 
        EXEC [sp_configure] 'show advanced options', 1;
 
        RECONFIGURE;
 
        EXEC [sp_configure] 'xp_cmdshell', 1;
 
        RECONFIGURE;
 
        EXEC [sp_configure] 'show advanced options', 0;
 
        RECONFIGURE;
    END
 
SELECT  @CheckCommand = 'EXEC [master]..[xp_cmdshell]' + SPACE(1) + QUOTENAME('whoami /priv', '''');
 
INSERT INTO @xp_cmdshell_output
        ( [output] )
EXEC [sys].[sp_executesql] @CheckCommand;
 
IF EXISTS ( SELECT  *
            FROM    @xp_cmdshell_output
            WHERE   [output] LIKE '%SeLockMemoryPrivilege%enabled%' )
    SELECT  'Windows policy Lock Pages in Memory option is enabled' AS [Finding];
ELSE
    SELECT  'Windows policy Lock Pages in Memory option is disabled' AS [Finding]; 
 
IF @CMDShellFlag = 1
    BEGIN
 
        EXEC [sp_configure] 'show advanced options', 1;
 
        RECONFIGURE;
 
        EXEC [sp_configure] 'xp_cmdshell', 0;
 
        RECONFIGURE;
 
        EXEC [sp_configure] 'show advanced options', 0;
 
        RECONFIGURE;
    END
 
SET NOCOUNT OFF;