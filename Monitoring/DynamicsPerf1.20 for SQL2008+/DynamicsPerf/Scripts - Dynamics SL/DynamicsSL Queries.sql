-- --------------------------------------------------------------
--
--  get Dynamics SL  version
--  On system DB run:
--
-- --------------------------------------------------------------
EXEC Getversion

-- --------------------------------------------------------------
--
--  get Dynamics SL authentication type
--  On system DB run:
--
-- --------------------------------------------------------------
EXEC Getauthenticationtype

-- --------------------------------------------------------------
--
--  Update Dbs for a server move:
--  On system DB run:
--
-- --------------------------------------------------------------
--(if name of DBs stayed the same, just different server name)
UPDATE domain
SET    servername = 'NAMEOFNEWSERVER'

-- no need to run system views
-- (if name of DBs changed)
UPDATE domain
SET    servername = 'NAMEOFNEWSERVER'

UPDATE company
SET    databasename = 'NAMEOFNEWDB'
WHERE  databasename = 'NAMEOFOLDDB'

UPDATE domain
SET    databasename = 'NAMEOFNEWDB'
WHERE  databasename = 'NAMEOFOLDDB'

-- then need to run system views in DB Maintenance
-- --------------------------------------------------------------
--
--  Disable all triggers
--  handy if suspect a custom trigger is breaking something.
--  reenable script is listed after this script
-- --------------------------------------------------------------
SET QUOTED_IDENTIFIER ON

GO

SET ANSI_NULLS ON

GO

IF EXISTS (SELECT *
           FROM   sysobjects
           WHERE  id = Object_id('dbo.udf_Tbl_TriggerStatusTAB'))
  DROP FUNCTION dbo.udf_Tbl_TriggerStatusTAB

GO

CREATE FUNCTION dbo.Udf_tbl_triggerstatustab (@TABLENamePattern AS SYSNAME = NULL -- Tables to show, 
-- NULL for all
)
RETURNS TABLE
-- No schemabinding due to use of system tables.
/*
* Shows the enabled/disabled status of triggers that match
* the table name pattern.  Use NULL for triggers on all tables
* or a pattern for the LIKE operator to match names.
*
* Example:
select * from udf_Tbl_TriggerStatusTAB(null)
* 
* History:
* When          Who     Description
* ------------- ------- ----------------------------------------
* 2003-11-10    ASN     Initial Coding
*
* © Copyright 2003 Andrew Novick http://www.NovickSoftware.com
* You may use this function in any of your SQL Server databases
* including databases that you sell, so long as they contain 
* other unrelated database objects. You may not publish this 
* UDF either in print or electronically.
* Published in the T-SQL UDF of the Week Vol 2 #7 2/3/04
http://www.NovickSoftware.com/UDFofWeek/UDFofWeek.htm
****************************************************************/
AS
  RETURN
    SELECT TOP 100 PERCENT WITH TIES T.[name]  AS TableName,
                                     TR.[Name] AS TriggerName,
                                     CASE
                                       WHEN 1 = Objectproperty(TR.[id], 'ExecIsTriggerDisabled') THEN 'Disabled'
                                       ELSE 'Enabled'
                                     END       Status
    FROM   sysobjects T
           INNER JOIN sysobjects TR
             ON t.[ID] = TR.parent_obj
    WHERE  ( T.xtype = 'U'
              OR T.XType = 'V' )
           AND ( @TableNamePattern IS NULL
                  OR T.[name] LIKE @TableNamePattern )
           AND ( TR.xtype = 'TR' )
    ORDER  BY T.[name],
              TR.[name]

GO

---------------------------------------------------
DECLARE @TableName VARCHAR(255)
DECLARE @TriggerName VARCHAR(255)
DECLARE @QueryString VARCHAR(255)
DECLARE trigger_cursor CURSOR FOR
  SELECT TableName,
         TriggerName
  FROM   Udf_tbl_triggerstatustab(NULL)
  WHERE  status = 'Enabled'

OPEN trigger_cursor

FETCH NEXT FROM trigger_cursor INTO @TableName, @TriggerName

WHILE @@FETCH_STATUS = 0
  BEGIN
      SET @QueryString='ALTER TABLE ' + @TableName + ' DISABLE TRIGGER ' + @TriggerName

      EXECUTE (@QueryString)

      FETCH NEXT FROM trigger_cursor INTO @TableName, @TriggerName
  END

CLOSE trigger_cursor

DEALLOCATE trigger_cursor

---------------------------------------------------
SELECT TableName,
       TriggerName,
       Status
FROM   Udf_tbl_triggerstatustab(NULL)

---------------------------------------------------
-- --------------------------------------------------------------
--
--  Reenable all triggers
--  handy if suspect a custom trigger is breaking something.
--
-- --------------------------------------------------------------
SET QUOTED_IDENTIFIER ON

GO

SET ANSI_NULLS ON

GO

IF EXISTS (SELECT *
           FROM   sysobjects
           WHERE  id = Object_id('dbo.udf_Tbl_TriggerStatusTAB'))
  DROP FUNCTION dbo.udf_Tbl_TriggerStatusTAB

GO

CREATE FUNCTION dbo.Udf_tbl_triggerstatustab (@TABLENamePattern AS SYSNAME = NULL -- Tables to show, 
-- NULL for all
)
RETURNS TABLE
-- No schemabinding due to use of system tables.
/*
* Shows the enabled/disabled status of triggers that match
* the table name pattern.  Use NULL for triggers on all tables
* or a pattern for the LIKE operator to match names.
*
* Example:
select * from udf_Tbl_TriggerStatusTAB(null)
* 
* History:
* When          Who     Description
* ------------- ------- ----------------------------------------
* 2003-11-10    ASN     Initial Coding
*
* © Copyright 2003 Andrew Novick http://www.NovickSoftware.com
* You may use this function in any of your SQL Server databases
* including databases that you sell, so long as they contain 
* other unrelated database objects. You may not publish this 
* UDF either in print or electronically.
* Published in the T-SQL UDF of the Week Vol 2 #7 2/3/04
http://www.NovickSoftware.com/UDFofWeek/UDFofWeek.htm
****************************************************************/
AS
  RETURN
    SELECT TOP 100 PERCENT WITH TIES T.[name]  AS TableName,
                                     TR.[Name] AS TriggerName,
                                     CASE
                                       WHEN 1 = Objectproperty(TR.[id], 'ExecIsTriggerDisabled') THEN 'Disabled'
                                       ELSE 'Enabled'
                                     END       Status
    FROM   sysobjects T
           INNER JOIN sysobjects TR
             ON t.[ID] = TR.parent_obj
    WHERE  ( T.xtype = 'U'
              OR T.XType = 'V' )
           AND ( @TableNamePattern IS NULL
                  OR T.[name] LIKE @TableNamePattern )
           AND ( TR.xtype = 'TR' )
    ORDER  BY T.[name],
              TR.[name]

GO

---------------------------------------------------
DECLARE @TableName VARCHAR(255)
DECLARE @TriggerName VARCHAR(255)
DECLARE @QueryString VARCHAR(255)
DECLARE trigger_cursor CURSOR FOR
  SELECT TableName,
         TriggerName
  FROM   Udf_tbl_triggerstatustab(NULL)
  WHERE  status = 'Disabled'

OPEN trigger_cursor

FETCH NEXT FROM trigger_cursor INTO @TableName, @TriggerName

WHILE @@FETCH_STATUS = 0
  BEGIN
      SET @QueryString='ALTER TABLE ' + @TableName + ' ENABLE TRIGGER ' + @TriggerName

      EXECUTE (@QueryString)

      FETCH NEXT FROM trigger_cursor INTO @TableName, @TriggerName
  END

CLOSE trigger_cursor

DEALLOCATE trigger_cursor

---------------------------------------------------
SELECT TableName,
       TriggerName,
       Status
FROM   Udf_tbl_triggerstatustab(NULL)

---------------------------------------------------
-- --------------------------------------------------------------
--
--  Rebuild system triggers
--  
--  
-- --------------------------------------------------------------
-- Drop all windows authentication triggers.  
-- If using windows authentication, it will also recreate the triggers
--  and cleans up any stray vs_acctsub or vs_acctxref records
--
-- 1 - Make a good database backup
-- 2 - Run as is against your SL System database
--
-- last updated: 5/13/2008
-- Step 1: Drop all ACCTSUB and ACCTXREF triggers
DECLARE @triggername AS CHAR(100)
DECLARE @execString AS CHAR(200)
DECLARE trigger_cursor CURSOR FOR
  SELECT name
  FROM   sysobjects
  WHERE  TYPE = 'TR'
         AND ( name LIKE 'sDeleteAcctSub_%'
                OR name LIKE 'sInsertAcctSub_%'
                OR name LIKE 'sUpdateAcctSub_%'
                OR name LIKE 'sDeleteAcctXref_%'
                OR name LIKE 'sInsertAcctXref_%'
                OR name LIKE 'sUpdateAcctXref_%' )

OPEN trigger_cursor

FETCH NEXT FROM trigger_cursor INTO @triggername

WHILE @@FETCH_STATUS = 0
  BEGIN
      SET @execString = 'drop trigger ' + @triggername

      PRINT @execString

      EXEC (@execString)

      PRINT 'Done'

      FETCH NEXT FROM trigger_cursor INTO @triggername
  END

CLOSE trigger_cursor

DEALLOCATE trigger_cursor

-- only do step 2 and 3 if windows auth
IF (SELECT TOP 1 TEXT
    FROM   syscomments
    WHERE  ID IN (SELECT ID
                  FROM   sysobjects
                  WHERE  name = 'getauthenticationtype'
                         AND TYPE = 'P')) LIKE '%Windows%'
  BEGIN
      -- Step 2: Recreate a new set of 6 triggers for each app database listed in the company table
      DECLARE @dbname AS CHAR(100)
      DECLARE @execString2 AS CHAR(1000)
      DECLARE db_cursor CURSOR FOR
        SELECT DISTINCT databasename
        FROM   company
        WHERE  databasename <> ''

      OPEN db_cursor

      FETCH NEXT FROM db_cursor INTO @dbname

      WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @execString2 = 'CREATE TRIGGER sDeleteAcctSub_' + Rtrim(@dbname) + ' ON AcctSub WITH EXECUTE AS ' + CHAR(39) + '07718158D19D4f5f9D23B55DBF5DF1' + CHAR(39) + ' AFTER DELETE ' + ' AS Delete ' + Rtrim(@dbname) + '..vs_AcctSub from ' + Rtrim(@dbname) + '..vs_acctsub v join deleted on v.acct = deleted.acct and v.cpnyid = deleted.cpnyid and v.sub = deleted.sub'

            PRINT @execString2

            EXEC (@execString2)

            PRINT 'Done'

            SET @execString2 = 'CREATE TRIGGER sInsertAcctSub_' + Rtrim(@dbname) + ' ON AcctSub WITH EXECUTE AS ' + CHAR(39) + '07718158D19D4f5f9D23B55DBF5DF1' + CHAR(39) + ' AFTER INSERT ' + ' AS Insert into ' + Rtrim(@dbname) + '..vs_AcctSub select acct,active,cpnyid,crtd_datetime,crtd_prog,crtd_user,descr,lupd_datetime,lupd_prog,lupd_user,noteid,s4future01,s4future02,s4future03,s4future04,s4future05,s4future06,s4future07,s4future08,s4future09,s4future10,' + 's4future11,s4future12,sub,user1,user2,user3,user4,user5,user6,user7,user8,null from inserted'

            PRINT @execString2

            EXEC (@execString2)

            PRINT 'Done'

            SET @execString2 = 'CREATE TRIGGER sUpdateAcctSub_' + Rtrim(@dbname) + ' ON AcctSub WITH EXECUTE AS ' + CHAR(39) + '07718158D19D4f5f9D23B55DBF5DF1' + CHAR(39) + ' AFTER UPDATE ' + ' AS Delete ' + Rtrim(@dbname) + '..vs_acctsub from ' + Rtrim(@dbname) + '..vs_acctsub v join deleted on v.acct = deleted.acct and v.cpnyid = deleted.cpnyid and v.sub = deleted.sub' + ' Insert into ' + Rtrim(@dbname) + '..vs_acctsub select acct,active,cpnyid,crtd_datetime,crtd_prog,crtd_user,descr,lupd_datetime,lupd_prog,lupd_user,noteid,s4future01,s4future02,s4future03,s4future04,s4future05,s4future06,s4future07,s4future08,s4future09,s4future10,' + 's4future11,s4future12,sub,user1,user2,user3,user4,user5,user6,user7,user8,null from inserted'

            PRINT @execString2

            EXEC (@execString2)

            PRINT 'Done'

            SET @execString2 = 'CREATE TRIGGER sDeleteAcctXref_' + Rtrim(@dbname) + ' ON AcctXref WITH EXECUTE AS ' + CHAR(39) + '07718158D19D4f5f9D23B55DBF5DF1' + CHAR(39) + ' AFTER DELETE ' + ' AS Delete ' + Rtrim(@dbname) + '..vs_acctxref from ' + Rtrim(@dbname) + '..vs_acctxref v join deleted on v.acct = deleted.acct and v.cpnyid = deleted.cpnyid'

            PRINT @execString2

            EXEC (@execString2)

            PRINT 'Done'

            SET @execString2 = 'CREATE TRIGGER sInsertAcctXref_' + Rtrim(@dbname) + ' ON AcctXref WITH EXECUTE AS ' + CHAR(39) + '07718158D19D4f5f9D23B55DBF5DF1' + CHAR(39) + ' AFTER INSERT ' + ' AS Insert into ' + Rtrim(@dbname) + '..vs_acctXref select acct,accttype,active,cpnyid,descr,user1,user2,user3,user4,null from inserted'

            PRINT @execString2

            EXEC (@execString2)

            PRINT 'Done'

            SET @execString2 = 'CREATE TRIGGER sUpdateAcctXref_' + Rtrim(@dbname) + ' ON AcctXref WITH EXECUTE AS ' + CHAR(39) + '07718158D19D4f5f9D23B55DBF5DF1' + CHAR(39) + ' AFTER UPDATE ' + ' AS Delete ' + Rtrim(@dbname) + '..vs_acctxref from ' + Rtrim(@dbname) + '..vs_acctxref v join deleted on v.acct = deleted.acct and v.cpnyid = deleted.cpnyid' + ' Insert into ' + Rtrim(@dbname) + '..vs_acctXref select acct,accttype,active,cpnyid,descr,user1,user2,user3,user4,null from inserted'

            PRINT @execString2

            EXEC (@execString2)

            PRINT 'Done'

            FETCH NEXT FROM db_cursor INTO @dbname
        END

      CLOSE db_cursor

      DEALLOCATE db_cursor

      -- Step 3: Cleanup any stray vs_acctxref or vs_acctsub records
      DECLARE @dbName3 AS CHAR(85)
      DECLARE @execString3 AS CHAR(200)
      DECLARE db_cursor3 CURSOR FOR
        SELECT DISTINCT databasename
        FROM   company
        WHERE  databasename <> ''

      OPEN db_cursor3

      FETCH NEXT FROM db_cursor3 INTO @dbName3

      WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @execString3 = 'delete a from ' + Quotename(Rtrim(@dbName3)) + '..vs_acctxref a left join acctxref b on a.acct=b.acct and a.cpnyid=b.cpnyid where b.acct is null'

            PRINT @execString3

            EXEC (@execString3)

            SET @execString3 = 'delete a from ' + Quotename(Rtrim(@dbName3)) + '..vs_acctsub a left join acctsub b on a.acct=b.acct and a.sub=b.sub and a.cpnyid=b.cpnyid where b.acct is null'

            PRINT @execString3

            EXEC (@execString3)

            FETCH NEXT FROM db_cursor3 INTO @dbName3
        END

      CLOSE db_cursor3

      DEALLOCATE db_cursor3
  END

-- END
-- --------------------------------------------------------------
--
--  BFGroup script – rebuilds the BusinessPortalUser permissions.  
--  
-- --------------------------------------------------------------
IF NOT EXISTS (SELECT *
               FROM   sysusers
               WHERE  name = 'BFGROUP'
                      AND issqlrole = 1)
  EXEC Sp_addrole 'BFGROUP'

GO

DECLARE @cStatement VARCHAR(255)
DECLARE G_cursor CURSOR FOR
  SELECT 'grant select,update,insert,delete on "' + CONVERT(VARCHAR(64), name) + '" to BFGROUP'
  FROM   sysobjects
  WHERE  ( TYPE = 'U'
            OR TYPE = 'V' )
         AND uid = 1
  ORDER  BY name

SET nocount ON

OPEN G_cursor

FETCH NEXT FROM G_cursor INTO @cStatement

WHILE ( @@FETCH_STATUS <> -1 )
  BEGIN
      PRINT @cStatement

      EXEC (@cStatement)

      FETCH NEXT FROM G_cursor INTO @cStatement
  END

DEALLOCATE G_cursor

GO

DECLARE @cStatement VARCHAR(255)
DECLARE G_cursor CURSOR FOR
  SELECT 'grant execute on "' + CONVERT(VARCHAR(64), name) + '" to BFGROUP'
  FROM   sysobjects
  WHERE  ( TYPE = 'P' )
         AND uid = 1
  ORDER  BY name

SET nocount ON

OPEN G_cursor

FETCH NEXT FROM G_cursor INTO @cStatement

WHILE ( @@FETCH_STATUS <> -1 )
  BEGIN
      PRINT @cStatement

      EXEC (@cStatement)

      FETCH NEXT FROM G_cursor INTO @cStatement
  END

DEALLOCATE G_cursor

GO 
