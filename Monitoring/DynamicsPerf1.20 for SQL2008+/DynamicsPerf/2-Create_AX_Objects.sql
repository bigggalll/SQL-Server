
/************************* START OF CREATE TABLES  ***************************************/
USE [DynamicsPerf]
GO

/****** Object:  Table [dbo].[AX_TABLE_DETAIL]    Script Date: 02/02/2011 13:38:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT *
               FROM   sys.objects
               WHERE  object_id = Object_id(N'[dbo].[AX_TABLE_DETAIL]')
                      AND type IN ( N'U' )) 
BEGIN
DROP TABLE [dbo].[AX_TABLE_DETAIL]
END
GO



CREATE TABLE [dbo].[AX_TABLE_DETAIL](
	[STATS_TIME] [datetime] NULL,
	[DATABASE_NAME] [nvarchar](128) NOT NULL,
	[TABLE_NAME] [nvarchar](128) NOT NULL,
	[TABLE_ID] [int] NOT NULL,
	[OCC_ENABLED] [bit] NOT NULL,
	[CACHE_LOOKUP] [tinyint] NOT NULL,
	[INSERT_METHOD_OVERRIDDEN] [bit] NOT NULL,
	[UPDATE_METHOD_OVERRIDDEN] [bit] NOT NULL,
	[DELETE_METHOD_OVERRIDDEN] [bit] NOT NULL,
	[AOS_VALIDATE_INSERT] [bit] NOT NULL,
	[AOS_VALIDATE_UPDATE] [bit] NOT NULL,
	[AOS_VALIDATE_DELETE] [bit] NOT NULL,
	[DATABASELOG_INSERT] [bit] NOT NULL,
	[DATABASELOG_DELETE] [bit] NOT NULL,
	[DATABASELOG_UPDATE] [bit] NOT NULL,
	[DATABASELOG_RENAME_KEY] [bit] NOT NULL,
	[EVENT_INSERT] [bit] NOT NULL,
	[EVENT_DELETE] [bit] NOT NULL,
	[EVENT_UPDATE] [bit] NOT NULL,
	[EVENT_RENAME_KEY] [bit] NOT NULL,
	[TABLE_GROUP] [int] NULL,
	[APPLAYER] [nvarchar](3) NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[AX_SQLTRACE]    Script Date: 02/02/2011 13:38:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT *
               FROM   sys.objects
               WHERE  object_id = Object_id(N'[dbo].[AX_SQLTRACE]')
                      AND type IN ( N'U' )) 
BEGIN
DROP TABLE [dbo].[AX_SQLTRACE]
END
GO


CREATE TABLE [dbo].[AX_SQLTRACE]
  (
     [STATS_TIME]                    [DATETIME] NOT NULL,
     [DATABASE_NAME]                 [NVARCHAR](128) NOT NULL,
     [SQL_DURATION]                  [INT] NOT NULL,
     [TRACE_CATEGORY]                [INT] NOT NULL,
     [SQL_TEXT]                      [NVARCHAR](MAX) NULL,
     [CALL_STACK]                    [NTEXT] NULL,
     [TRACE_EVENT_CODE]              [INT] NOT NULL,
     [TRACE_EVENT_DESC]              [NVARCHAR](MAX) NULL,
     [TRACE_EVENT_DETAILS]           [NVARCHAR](MAX) NULL,
     [CONNECTION_TYPE]               [NVARCHAR](50) NOT NULL,
     [SQL_SESSION_ID]                [INT] NOT NULL,
     [AX_CONNECTION_ID]              [INT] NOT NULL,
     [IS_LOBS_INCLUDED]              [INT] NOT NULL,
     [IS_MORE_DATA_PENDING]          [INT] NOT NULL,
     [ROWS_AFFECTED]                 [INT] NOT NULL,
     [ROW_SIZE]                      [INT] NOT NULL,
     [ROWS_PER_FETCH]                [INT] NOT NULL,
     [IS_SELECTED_FOR_UPDATE]        [INT] NOT NULL,
     [IS_STARTED_WITHIN_TRANSACTION] [INT] NOT NULL,
     [SQL_TYPE]                      [INT] NOT NULL,
     [STATEMENT_ID]                  [INT] NOT NULL,
     [STATEMENT_REUSE_COUNT]         [INT] NOT NULL,
     [DETAIL_TYPE]                   [INT] NOT NULL,
     [CREATED_DATETIME]              [DATETIME] NOT NULL,
     [AX_USER_ID]                    [NVARCHAR](50) NOT NULL,
     [ROW_NUM]                       [BIGINT] IDENTITY(1, 1) NOT NULL,
     [COMMENT]                       [NVARCHAR](MAX) NULL
  )
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY] 


GO
/****** Object:  Table [dbo].[AX_NUM_SEQUENCES]    Script Date: 02/02/2011 13:38:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT *
               FROM   sys.objects
               WHERE  object_id = Object_id(N'[dbo].[AX_NUM_SEQUENCES]')
                      AND type IN ( N'U' )) 
BEGIN
DROP TABLE [dbo].[AX_NUM_SEQUENCES]
END
GO

USE DynamicsPerf
CREATE TABLE [dbo].[AX_NUM_SEQUENCES]
  (
     [RUN_NAME]            [NVARCHAR](60) NOT NULL,
     [STATS_TIME]          [DATETIME] NOT NULL,
     [DATABASE_NAME]       [NVARCHAR](128) NULL,
     [RECID]               [BIGINT] NULL,
     [NUMBERSEQUENCE]      [NVARCHAR](40) NULL,
     [TEXT]                [NVARCHAR](120) NULL,
     [LOWEST]              [INT] NULL,
     [HIGHEST]             [INT] NULL,
     [NEXTREC]             [INT] NULL,
     [PERCENTREMAINING]    [DECIMAL](5, 2) NULL,
     [NUMBERSREMAINING]    [INT] NULL,
     [CONTINUOUS]          [VARCHAR](3) NULL,
     [FETCHAHEAD]          [INT] NULL,
     [FETCHAHEADQTY]       [INT] NULL,
     [CLEANINTERVAL]       [NUMERIC](32, 16) NULL,
     [CLEANATACCESS]       [INT] NULL,
     [PARTITIONNAME]       [NVARCHAR](40) NULL,
     [NUMBERSEQUENCESCOPE] [BIGINT] NULL,
     [COMPANYID]           [NVARCHAR](8) NULL,
     [COMPANYNAME]         [NVARCHAR](40) NULL,
     [SHARED]              [VARCHAR](3) NULL,
     [LEGALENTITYNAME]     [NVARCHAR](4) NULL,
     [OPERATINGUNITTYPE]   [VARCHAR](19) NULL,
     [OPERATINGUNITNUMBER] [NVARCHAR](8) NULL,
     [FISCALCALENDAR]      [NVARCHAR](10) NULL,
     [FISCALCALENDARYEAR]  [NVARCHAR](10) NULL,
     [PERIOD]              [NVARCHAR](60) NULL,
     [FORMAT]              [NVARCHAR](80) NOT NULL
  )
ON [PRIMARY] 



GO
/****** Object:  Table [dbo].[AX_INDEX_DETAIL]    Script Date: 02/02/2011 13:38:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT *
               FROM   sys.objects
               WHERE  object_id = Object_id(N'[dbo].[AX_INDEX_DETAIL]')
                      AND type IN ( N'U' )) 
BEGIN
DROP TABLE [dbo].[AX_INDEX_DETAIL]
END
GO


CREATE TABLE [dbo].[AX_INDEX_DETAIL]
       (
          [STATS_TIME]        [DATETIME] NULL,
          [DATABASE_NAME]     [NVARCHAR](128) NOT NULL,
          [TABLE_NAME]        [NVARCHAR](128) NOT NULL,
          [INDEX_NAME]        [NVARCHAR](128) NOT NULL,
          [INDEX_ID]          [INT] NOT NULL,
          [INDEX_DESCRIPTION] [NVARCHAR](210) NOT NULL,
          [INDEX_KEYS]        [NVARCHAR](MAX) NOT NULL,
		  [APPLAYER] [nvarchar](3) NOT NULL
       )
     ON [PRIMARY] 
     

GO
/****** Object:  Table [dbo].[AX_BATCHSERVER_CONFIGURATION]    Script Date: 02/02/2011 13:38:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT *
               FROM   sys.objects
               WHERE  object_id = Object_id(N'[dbo].[AX_BATCHSERVER_CONFIGURATION]')
                      AND type IN ( N'U' )) 
BEGIN
DROP TABLE [dbo].[AX_BATCHSERVER_CONFIGURATION]
END
GO


CREATE TABLE [dbo].[AX_BATCHSERVER_CONFIGURATION]
  (
     [CLUSTERNAME]            [NVARCHAR](200) NOT NULL,
     [CLUSTERDESCRIPTION]     [NVARCHAR](1200) NOT NULL,
     [SERVERID]               [NVARCHAR](200) NOT NULL,
     [MAXSESSIONS]            [INT] NOT NULL,
     [ENABLEBATCH]            [INT] NOT NULL,
     [SCHEDULED START]        [DATETIME] NULL,
     [SCHEDULED END]          [DATETIME] NULL,
     [MAXBATCHSESSIONS]       [INT] NULL,
     [BATCHGROUP]             [NVARCHAR](20) NULL,
     [COMPANY]                [NVARCHAR](20) NULL,
     [BATCH JOB DESCRIPTION]  [NVARCHAR](200) NULL,
     [BATCH TASK DESCRIPTION] [NVARCHAR](200) NULL,
     [RUN AT]                 [VARCHAR](12) NOT NULL
  )
ON [PRIMARY] 


GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[AOS_REGISTRY]    Script Date: 02/02/2011 13:38:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT *
               FROM   sys.objects
               WHERE  object_id = Object_id(N'[dbo].[AOS_REGISTRY]')
                      AND type IN ( N'U' )) 
BEGIN
DROP TABLE [dbo].[AOS_REGISTRY]
END
GO


CREATE TABLE [dbo].[AOS_REGISTRY]
  (
     [SERVER_NAME]             [NVARCHAR](255) NOT NULL,
     [AX_MAJOR_VERSION]        [NVARCHAR](5) NOT NULL,
     [AOS_INSTANCE_NAME]       [NVARCHAR](255) NOT NULL,
     [AX_BUILD_NUMBER]         [NVARCHAR](25) NOT NULL,
     [AOS_CONFIGURATION_NAME]  [NVARCHAR](255) NOT NULL,
     [IS_CONFIGURATION_ACTIVE] [NVARCHAR](1) NOT NULL,
     [SETTING_NAME]            [NVARCHAR](255) NOT NULL,
     [SETTING_VALUE]           [NVARCHAR](MAX) NOT NULL
  )
ON [PRIMARY] 


GO
/****** Object:  Table [dbo].[AOS_EVENTLOG]    Script Date: 02/02/2011 13:38:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT *
               FROM   sys.objects
               WHERE  object_id = Object_id(N'[dbo].[AOS_EVENTLOG]')
                      AND type IN ( N'U' )) 
BEGIN
DROP TABLE [dbo].[AOS_EVENTLOG]
END
GO


CREATE TABLE [dbo].[AOS_EVENTLOG]
  (
     [TIME_WRITTEN] [DATETIME] NULL,
     [SERVER_NAME]  [NVARCHAR](255) NULL,
     [EVENT_CODE]   [INT] NULL,
     [EVENT_TYPE]   [NVARCHAR](255) NULL,
     [MESSAGE]      [NVARCHAR](MAX) NULL,
     [SOURCE_NAME]  [NVARCHAR](255) NULL
  )
ON [PRIMARY] 





GO

/****** Object:  Default [DF_AX_INDEX_DETAIL_INDEX_ID]    Script Date: 02/02/2011 13:38:20 ******/
IF NOT EXISTS (SELECT *
               FROM   sys.default_constraints
               WHERE  object_id = Object_id(N'[dbo].[DF_AX_INDEX_DETAIL_INDEX_ID]')
                      AND parent_object_id = Object_id(N'[dbo].[AX_INDEX_DETAIL]')) 
BEGIN
IF NOT EXISTS (SELECT *
               FROM   dbo.sysobjects
               WHERE  id = Object_id(N'[DF_AX_INDEX_DETAIL_INDEX_ID]')
                      AND TYPE = 'D') 
BEGIN
ALTER TABLE [dbo].[AX_INDEX_DETAIL] 
	ADD CONSTRAINT [DF_AX_INDEX_DETAIL_INDEX_ID] DEFAULT ((0)) FOR [INDEX_ID] 
END


END
GO

USE [DynamicsPerf]
GO

/****** Object:  Table [dbo].[AX_SQLSTORAGE]    Script Date: 04/19/2011 06:40:41 ******/
IF EXISTS (SELECT *
           FROM   sys.objects
           WHERE  object_id = Object_id(N'[dbo].[AX_SQLSTORAGE]')
                  AND type IN ( N'U' ))
  DROP TABLE [dbo].[AX_SQLSTORAGE] 

GO

USE [DynamicsPerf]
GO

/****** Object:  Table [dbo].[AX_SQLSTORAGE]    Script Date: 04/19/2011 06:40:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[AX_SQLSTORAGE]
  (
     [ID]         [INT] NOT NULL,
     [OBJECTTYPE] [INT] NOT NULL,
     [TABLEID]    [INT] NOT NULL,
     [INDEXID]    [INT] NOT NULL,
     [OVERRIDE]   [INT] NOT NULL,
     [PARM]       [NVARCHAR](25) NOT NULL,
     [VALUE]      [NVARCHAR](255) NOT NULL,
     [RECVERSION] [INT] NOT NULL,
     [RECID]      [BIGINT] NOT NULL
  )
ON [PRIMARY] 


GO



/****************************  END OF CREATE TABLES **************************************/

/***************************  START OF INDEXES ******************************************/

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE CLUSTERED INDEX IX_AX_INDEX_DETAIL
  ON AX_INDEX_DETAIL ( STATS_TIME ASC, DATABASE_NAME ASC, TABLE_NAME ASC, INDEX_NAME ASC )
  WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)

GO
CREATE CLUSTERED INDEX IX_AX_SQLTRACE
  ON AX_SQLTRACE ( STATS_TIME, DATABASE_NAME, CREATED_DATETIME, TRACE_CATEGORY )
  WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)


GO
/***************************************************************************
*
* 3/2/2012  REH   Turn on row compression for all DynamicsPerf indexes
*                   if compression is supported
*
*
****************************************************************************/
IF  (cast(serverproperty('Edition') as varchar(100)) like 'Enterprise%' or cast(serverproperty('Edition') as varchar(100)) like 'Developer%')
BEGIN
		DECLARE @INDEX_NAME SYSNAME
		DECLARE @TABLE_NAME SYSNAME
		DECLARE @SQL VARCHAR(MAX)


		DECLARE INDEXCURSOR CURSOR FOR
			SELECT	
					si.name, 
					so.name
			FROM	DynamicsPerf.sys.indexes si
			JOIN	DynamicsPerf.sys.sysindexes ii on si.object_id = ii.id and si.index_id = ii.indid
			JOIN	DynamicsPerf.sys.objects so on so.object_id = si.object_id
			JOIN	DynamicsPerf.sys.schemas ss on ss.schema_id = so.schema_id
			WHERE	so.type = 'U'
			AND		si.type > 0  --other than heap tables
			
			OPEN INDEXCURSOR

		FETCH INDEXCURSOR INTO 
			@INDEX_NAME		,
			@TABLE_NAME		
			
			
		WHILE @@FETCH_STATUS = 0
			BEGIN
			SELECT @SQL = 'ALTER INDEX ' + @INDEX_NAME + ' ON ' + @TABLE_NAME + 
			' REBUILD WITH (DATA_COMPRESSION = ROW)'
			
			EXEC (@SQL)
			
			FETCH NEXT FROM INDEXCURSOR INTO @INDEX_NAME,@TABLE_NAME
			END
			
			CLOSE INDEXCURSOR
			DEALLOCATE INDEXCURSOR
END



/***************************  END OF INDEXES ********************************************/



/*************************** START OF STORED PROCEDURES **********************************/

USE [DynamicsPerf]
GO

/****** Object:  StoredProcedure [dbo].[SET_AX_SQLTRACE]    Script Date: 02/28/2011 12:20:16 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SET_AX_SQLTRACE]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SET_AX_SQLTRACE]
GO

USE [DynamicsPerf]
GO

/****** Object:  StoredProcedure [dbo].[Set_ax_sqltrace]    Script Date: 02/28/2011 12:20:16 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[SET_AX_SQLTRACE] @DATABASE_NAME    NVARCHAR(128),
                                 @QUERY_TIME_LIMIT INT = 5000,
                                 @AX_ID            NVARCHAR(10) = NULL,
                                 @TRACE_STATUS     NVARCHAR(3) = 'ON', 
                                 @CLIENTACESSLOG   INT = 0
AS
  DECLARE @SQL NVARCHAR(1000),
          @RC  INT

  SET @RC = 0

  IF NOT EXISTS (SELECT *
                 FROM   sys.databases
                 WHERE  name = @DATABASE_NAME)
    BEGIN
        PRINT @DATABASE_NAME + ' DOES NOT EXIST'
        SET @RC = 1
        GOTO ERROR
    END

 IF (@CLIENTACESSLOG BETWEEN 1 AND 2 ) 
 BEGIN
	
             SET @SQL = 'UPDATE [' + @DATABASE_NAME + ']..USERINFO
				SET CLIENTACCESSLOGLEVEL  = ' + CAST(@CLIENTACESSLOG AS VARCHAR(1)) 

				IF @AX_ID IS NOT NULL 
						SET @SQL = @SQL + ' WHERE ID = ''' + @AX_ID + ''''
				EXEC (@SQL)
				GOTO ENDPROC --can't set accesslog and long running at same time
 END

  IF @TRACE_STATUS = 'ON'
    BEGIN
        
          SET @SQL = 'UPDATE [' + @DATABASE_NAME + ']..USERINFO
				SET QUERYTIMELIMIT = ' + Str(@QUERY_TIME_LIMIT) + ',
					DEBUGINFO =  268,
					TRACEINFO =  2048'
			IF @AX_ID IS NOT NULL	
			SET @SQL = @SQL + 	' WHERE ID = ''' + @AX_ID + ''''		
			
			END
  ELSE
    IF @TRACE_STATUS = 'OFF'
      BEGIN
          IF @AX_ID IS NULL
            SET @SQL = 'UPDATE [' + @DATABASE_NAME + ']..USERINFO
				SET QUERYTIMELIMIT = 0,
					DEBUGINFO =  12,
					TRACEINFO =  0'
					
			IF @AX_ID IS NOT NULL	
			SET @SQL = @SQL + 	' WHERE ID = ''' + @AX_ID + ''''	
        
      END
    ELSE
      PRINT 'Invalid @TRACE_STATUS option; must be ON or OFF'

  PRINT @SQL
  EXEC (@SQL)
 

 
  ENDPROC:

  ERROR:

  RETURN @RC


GO


USE [DynamicsPerf]
GO

/****** Object:  StoredProcedure [dbo].[SP_CAPTURESTATS_AX]    Script Date: 02/28/2011 12:31:55 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SP_CAPTURESTATS_AX]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SP_CAPTURESTATS_AX]
GO

USE [DynamicsPerf]
GO

/****** Object:  StoredProcedure [dbo].[SP_CAPTURESTATS_AX]    Script Date: 02/28/2011 12:31:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE	PROCEDURE [dbo].[SP_CAPTURESTATS_AX]
		@DATABASE_NAME	NVARCHAR(128),	
		@RUN_NAME		NVARCHAR(60) = NULL,
		@STATS_DATE		DATETIME,
		@LAST_STATS_DATE DATETIME,
		@DEBUG			NVARCHAR(1)='N'
 
AS

SET NOCOUNT ON
SET DATEFORMAT MDY

DECLARE
		@APP_BUILD		NVARCHAR(120),
		@KERNEL_BUILD	NVARCHAR(20),
		@RETURN_CODE	INT,
		@SQL			NVARCHAR(MAX),
		@PARM			NVARCHAR(500)		
		
		
SET @RETURN_CODE = 0
-- -----------------------------------------------------------------------------------------
-- Get kernel version information.
-- If used with prodcts other than  Dynamics AX, remove or comment the SP_EXEXCUTESQL below
-- -----------------------------------------------------------------------------------------

SET @SQL= 'SELECT TOP 1 @KERNEL_BUILD_OUT = KERNELBUILD FROM [' + @DATABASE_NAME + ']..SYSSETUPLOG WITH (NOLOCK) ORDER BY RECID DESC'
SET @PARM = '@KERNEL_BUILD_OUT NVARCHAR(20) OUTPUT' 

IF @DEBUG = 'Y' 
BEGIN
PRINT '@SQL= ' + @SQL
PRINT '@PARM= ' + @PARM
END

BEGIN TRY
    EXEC sp_executesql
      @SQL,
      @PARM,
      @KERNEL_BUILD_OUT = @KERNEL_BUILD OUTPUT
END TRY 

BEGIN CATCH
PRINT 'NOT A DYNAMICS AX DATABASE'
RETURN (0);
END CATCH

SET @RETURN_CODE = 0
-- -----------------------------------------------------------------------------------------
-- Get application version information.
-- If used with prodcts other than  Dynamics AX, remove or comment the SP_EXEXCUTESQL below
-- -----------------------------------------------------------------------------------------

SET @SQL= 'SELECT TOP 1 @APP_BUILD_OUT = VALUE FROM [' + @DATABASE_NAME + ']..SYSCONFIG WITH (NOLOCK) WHERE CONFIGTYPE = 4 AND ID = 6'
SET @PARM = '@APP_BUILD_OUT NVARCHAR(120) OUTPUT' 

IF @DEBUG = 'Y' 
BEGIN
PRINT '@SQL= ' + @SQL
PRINT '@PARM= ' + @PARM
END

BEGIN TRY
    EXEC sp_executesql
      @SQL,
      @PARM,
      @APP_BUILD_OUT = @APP_BUILD OUTPUT
END TRY 

BEGIN CATCH
PRINT 'NOT A DYNAMICS AX DATABASE'
RETURN (0);
END CATCH

UPDATE STATS_COLLECTION_SUMMARY SET DYNAMICS_VERSION = 'Appbuild = ' + @APP_BUILD + ' Kernel Build = ' + @KERNEL_BUILD  
WHERE RUN_NAME = @RUN_NAME AND DATABASE_NAME=@DATABASE_NAME


IF Substring(@APP_BUILD, 1, 1) BETWEEN N'3' AND N'4'

BEGIN TRY
PRINT 'STEP Insert AX3 SQL Trace table'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)
  BEGIN
      SET @SQL = 'SET DATEFORMAT MDY;
		INSERT INTO AX_SQLTRACE WITH (TABLOCK) 
		   (STATS_TIME
		   ,DATABASE_NAME
		   ,SQL_DURATION
		   ,TRACE_CATEGORY
		   ,SQL_TEXT
		   ,CALL_STACK
		   ,TRACE_EVENT_CODE
		   ,TRACE_EVENT_DESC
		   ,TRACE_EVENT_DETAILS
		   ,CONNECTION_TYPE
		   ,SQL_SESSION_ID
		   ,AX_CONNECTION_ID
		   ,IS_LOBS_INCLUDED
		   ,IS_MORE_DATA_PENDING
		   ,ROWS_AFFECTED
		   ,ROW_SIZE
		   ,ROWS_PER_FETCH
		   ,IS_SELECTED_FOR_UPDATE
		   ,IS_STARTED_WITHIN_TRANSACTION
		   ,SQL_TYPE
		   ,STATEMENT_ID
		   ,STATEMENT_REUSE_COUNT
		   ,DETAIL_TYPE
		   ,CREATED_DATETIME
		   ,AX_USER_ID)
		SELECT 
			''' + CONVERT(NVARCHAR(50), @STATS_DATE, 121) + ''',''' + @DATABASE_NAME + '''
			,TRACETIME
			,CATEGORY
			,STATEMENT
			,CALLSTACK
			,CODE
			,TEXT
			,TEXTDETAILS
			,CONNECTIONTYPE
			,CONNECTIONSPID
			,CONNECTIONID
			,ISLOBSINCLUDED
			,ISMOREDATAPENDING
			,ROWSAFFECTED
			,ROWSIZE
			,ROWSPERFETCH
			,ISSELECTEDFORUPDATE
			,ISSTARTEDWITHINTRANSACTION
			,STATEMENTTYPE
			,STATEMENTID
			,STATEMENTREUSECOUNT
			,DETAILTYPE
			,DATEADD(minute, DATEDIFF(minute,getutcdate(),getdate()), DATEADD(S, CREATEDTIME, CREATEDDATE))
			,CREATEDBY

		  
		FROM [' + @DATABASE_NAME + '].DBO.SYSTRACETABLESQL  WITH (NOLOCK)
		WHERE DATEADD(minute, DATEDIFF(minute,getutcdate(),getdate()), CREATEDDATETIME) >= ''' + CONVERT(NVARCHAR(24), @LAST_STATS_DATE, 121) + ''''
	+ ' AND DATEADD(D, 14, CREATEDDATE) >= ''' + CONVERT(NVARCHAR(24), GETDATE(), 121) + ''''
		IF @DEBUG = 'Y' 
		BEGIN
		PRINT '@SQL= ' + @SQL
		END

      EXEC (@SQL)

  END
  
            PRINT 'Completed Successfully'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)
            
            
UPDATE CAPTURE_LOG SET TEXT = TEXT + 'Inserted AX3/4 AX_SQLTRACE SUCCESSFULLY at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE

             
END TRY

BEGIN CATCH
PRINT 'Step failed to complete !!'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'FAILED TO insert AX3/4 AX_SQLTRACE at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE

END CATCH

ELSE

BEGIN TRY
PRINT 'STEP Insert AX2009 SQL Trace and Batch Tables'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

  IF Substring(@APP_BUILD, 1, 2) = N'5.'  OR Substring(@APP_BUILD, 1, 2) = N'6.'
    BEGIN
        SET @SQL = 'SET DATEFORMAT MDY;
		INSERT INTO AX_SQLTRACE WITH (TABLOCK) 
		   (STATS_TIME
		   ,DATABASE_NAME
		   ,SQL_DURATION
		   ,TRACE_CATEGORY
		   ,SQL_TEXT
		   ,CALL_STACK
		   ,TRACE_EVENT_CODE
		   ,TRACE_EVENT_DESC
		   ,TRACE_EVENT_DETAILS
		   ,CONNECTION_TYPE
		   ,SQL_SESSION_ID
		   ,AX_CONNECTION_ID
		   ,IS_LOBS_INCLUDED
		   ,IS_MORE_DATA_PENDING
		   ,ROWS_AFFECTED
		   ,ROW_SIZE
		   ,ROWS_PER_FETCH
		   ,IS_SELECTED_FOR_UPDATE
		   ,IS_STARTED_WITHIN_TRANSACTION
		   ,SQL_TYPE
		   ,STATEMENT_ID
		   ,STATEMENT_REUSE_COUNT
		   ,DETAIL_TYPE
		   ,CREATED_DATETIME
		   ,AX_USER_ID)
		SELECT 
			''' + CONVERT(NVARCHAR(50), @STATS_DATE, 121) + ''',''' + @DATABASE_NAME + '''
			,TRACETIME
			,CATEGORY
			,STATEMENT
			,CALLSTACK
			,CODE
			,TEXT
			,TEXTDETAILS
			,CONNECTIONTYPE
			,CONNECTIONSPID
			,CONNECTIONID
			,ISLOBSINCLUDED
			,ISMOREDATAPENDING
			,ROWSAFFECTED
			,ROWSIZE
			,ROWSPERFETCH
			,ISSELECTEDFORUPDATE
			,ISSTARTEDWITHINTRANSACTION
			,STATEMENTTYPE
			,STATEMENTID
			,STATEMENTREUSECOUNT
			,DETAILTYPE
			,DATEADD(minute, DATEDIFF(minute,getutcdate(),getdate()), CREATEDDATETIME)
			,CREATEDBY

		  
			FROM [' + @DATABASE_NAME + '].DBO.SYSTRACETABLESQL WITH (NOLOCK)
			WHERE DATEADD(minute, DATEDIFF(minute,getutcdate(),getdate()), CREATEDDATETIME) >= ''' + CONVERT(NVARCHAR(24), @LAST_STATS_DATE, 121) + ''''
			+ ' AND DATEADD(D, 14, CREATEDDATETIME) >= ''' + CONVERT(NVARCHAR(24), GETDATE(), 121) + ''''
	
		IF @DEBUG = 'Y' 
		BEGIN
		PRINT '@SQL= ' + @SQL
		END
		
		EXEC (@SQL)

        --Insert AX BATCH AND Server Configurations
                SET @SQL = '
					TRUNCATE TABLE AX_BATCHSERVER_CONFIGURATION                
					INSERT AX_BATCHSERVER_CONFIGURATION
						   SELECT SYSCLUSTERCONFIG.CLUSTERNAME,
							   SYSCLUSTERCONFIG.CLUSTERDESCRIPTION,
							   SYSSERVERCONFIG.SERVERID,
							   SYSSERVERCONFIG.MAXSESSIONS,
							   SYSSERVERCONFIG.ENABLEBATCH,
							   Dateadd(SECOND, BATCHSERVERCONFIG.STARTTIME, Dateadd(DAY, Datediff(DAY, 0, Getdate()), 0)),
							   Dateadd(SECOND, BATCHSERVERCONFIG.ENDTIME, Dateadd(DAY, Datediff(DAY, 0, Getdate()), 0))   ,
							   BATCHSERVERCONFIG.MAXBATCHSESSIONS,
							   BATCHSERVERGROUP.GROUPID,
							   BATCHJOB.COMPANY,
							   BATCHJOB.CAPTION,
							   BATCH.CAPTION,
							   CASE BATCH.RUNTYPE
								 WHEN 1 THEN '+quotename('Server','''')+'
								 ELSE '+quotename('Client','''')+'
							   END                                                                  
						FROM   [' + @DATABASE_NAME + '].DBO.SYSCLUSTERCONFIG
							   INNER JOIN [' + @DATABASE_NAME + '].DBO.SYSSERVERCONFIG
								 ON SYSSERVERCONFIG.CLUSTERREFRECID = SYSCLUSTERCONFIG.RECID
							   LEFT OUTER JOIN [' + @DATABASE_NAME + '].DBO.BATCHSERVERCONFIG
								 ON SYSSERVERCONFIG.SERVERID = BATCHSERVERCONFIG.SERVERID
							   LEFT OUTER JOIN [' + @DATABASE_NAME + '].DBO.BATCHSERVERGROUP
								 ON BATCHSERVERGROUP.SERVERID = SYSSERVERCONFIG.SERVERID
							   LEFT OUTER JOIN [' + @DATABASE_NAME + '].DBO.BATCH
								 ON BATCH.GROUPID = BATCHSERVERGROUP.GROUPID
							   LEFT OUTER JOIN [' + @DATABASE_NAME + '].DBO.BATCHJOB
								 ON BATCHJOB.RECID = BATCH.BATCHJOBID 
					 '
				IF @DEBUG = 'Y' 
				BEGIN
				PRINT '@SQL= ' + @SQL
				END
				
                EXEC (@SQL)
        --Insert AX SQLTRACE 
                SET @SQL = '
					TRUNCATE TABLE AX_SQLSTORAGE               
					INSERT AX_SQLSTORAGE
						   SELECT *                                                                
						FROM   [' + @DATABASE_NAME + '].DBO.SQLSTORAGE
							  
					 '
				IF @DEBUG = 'Y' 
				BEGIN
				PRINT '@SQL= ' + @SQL
				END
				
                EXEC (@SQL)
                                
             
                    
    END 
    
PRINT 'Completed Successfully'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'Inserted AX_SQLTRACE SUCCESSFULLY at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE

             
END TRY

BEGIN CATCH
PRINT 'Step failed to complete !!'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'FAILED TO Insert AX_SQLTRACE at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE



END CATCH 

-- -----------------------------------------------------------------------------------------
-- Dynamicaly build the SQL to retreive data from NUMBERSEQUENCE table.  
-- -----------------------------------------------------------------------------------------

BEGIN TRY
PRINT 'STEP Dynamics AX Number Sequences'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)


SET @SQL = '
IF  EXISTS (SELECT * FROM sys.synonyms WHERE name = N' + Quotename('DYN_SYSTABLES', '''') + ')
DROP SYNONYM [dbo].[DYN_SYSTABLES]

CREATE SYNONYM DYN_SYSTABLES
FOR [' + @DATABASE_NAME + '].sys.tables;'

IF @DEBUG = 'Y' 
BEGIN
PRINT '@SQL= ' + @SQL
END

EXEC(@SQL) 
SET @SQL = '
IF  EXISTS (SELECT * FROM sys.synonyms WHERE name = N' + Quotename('DYN_SYSCOLS', '''') + ')
DROP SYNONYM [dbo].[DYN_SYSCOLS]

CREATE SYNONYM DYN_SYSCOLS
FOR [' + @DATABASE_NAME + '].sys.columns;'

IF @DEBUG = 'Y' 
BEGIN
PRINT '@SQL= ' + @SQL
END

EXEC(@SQL)


IF EXISTS (SELECT * FROM DYN_SYSTABLES t INNER JOIN DYN_SYSCOLS c
ON t.object_id=c.object_id
WHERE t.name = 'NUMBERSEQUENCETABLE')

BEGIN


IF Substring(@APP_BUILD, 1, 1) BETWEEN N'4' AND N'5'
BEGIN 
		IF EXISTS (SELECT * FROM DYN_SYSTABLES t INNER JOIN DYN_SYSCOLS c
		ON t.object_id=c.object_id
		WHERE t.name = 'NUMBERSEQUENCETABLE' AND c.name = 'DATAAREAID') 
		BEGIN



			SET @SQL ='	 
				SET ANSI_WARNINGS OFF 
				INSERT INTO AX_NUM_SEQUENCES WITH (TABLOCK) '
				  + ' SELECT ''' + @RUN_NAME  + '''' + ','+'''' + CONVERT(NVARCHAR(24), @STATS_DATE, 121) + ''',' + '''' + @DATABASE_NAME + '''' 
			 + ',0, 
			 NUMBERSEQUENCE,
				   TXT,
				   LOWEST,
				   HIGHEST,
				   NEXTREC,
				   0,
				   0,
					CASE CONTINUOUS     WHEN 0 THEN ''No''
				 WHEN 1 THEN ''Yes'' END  ,
				   FETCHAHEAD,
				   FETCHAHEADQTY,
				   0,
				   0,
				   NULL,
				   NULL,
				   DATAAREAID,
				   NULL,
				   NULL,
				   NULL,
				   NULL,
				   NULL,
				   NULL,
				   NULL,
				   NULL,
				   FORMAT
			 FROM   [' + @DATABASE_NAME + ']..NUMBERSEQUENCETABLE (NOLOCK)'
			 END
			ELSE
			BEGIN
			SET @SQL ='	 INSERT INTO AX_NUM_SEQUENCES WITH (TABLOCK) '
				  + ' SELECT ''' + @RUN_NAME  + '''' + ','+'''' + CONVERT(NVARCHAR(24), @STATS_DATE, 121) + ''',' + '''' + @DATABASE_NAME + '''' 
			 + ',0, 
			 NUMBERSEQUENCE,
				   TXT,
				   LOWEST,
				   HIGHEST,
				   NEXTREC,
				   0,
				   0,
					CASE CONTINUOUS     WHEN 0 THEN ''No''
				 WHEN 1 THEN ''Yes'' END ,
				   FETCHAHEAD,
				   FETCHAHEADQTY,
				   0,
				   0,
				   NULL,
				   NULL,
				   DATAAREAID,
				   NULL,
				   NULL,
				   NULL,
				   NULL,
				   NULL,
				   NULL,
				   NULL,
				   NULL,
				   	NST.FORMAT
			 FROM   [' + @DATABASE_NAME + ']..NUMBERSEQUENCETABLE (NOLOCK)'
				END


END



IF Substring(@APP_BUILD, 1, 3) = '6.0'
BEGIN 
			SET @SQL ='	 INSERT INTO AX_NUM_SEQUENCES WITH (TABLOCK) '
			  + ' SELECT ''' + @RUN_NAME  + '''' + ','+'''' + CONVERT(NVARCHAR(24), @STATS_DATE, 121) + ''',' + '''' + @DATABASE_NAME + '''' 

			  +', NST.RecId
   , NST.NUMBERSEQUENCE AS [NumberSequence]
            , NST.TXT AS [Text]
			,NST.LOWEST
			,NST.HIGHEST
			,NST.NEXTREC
            , CAST ((CAST((NST.HIGHEST - NST.NEXTREC) AS DECIMAL(20,2))/(CAST((NST.HIGHEST - NST.LOWEST) AS DECIMAL(20,2))) * 100) AS DECIMAL(5,2)) AS [PercentRemaining]
            , NST.HIGHEST - NST.NEXTREC AS [NumbersRemaining]

   , CASE NST.CONTINUOUS
     WHEN 0 THEN ''No''
     WHEN 1 THEN ''Yes''       
    END [Continuous]
   , NST.FETCHAHEAD AS FetchAhead
   , NST.FETCHAHEADQTY AS FetchAheadQty
   , NST.CLEANINTERVAL AS CleanInterval
   , NST.CLEANATACCESS AS CleanAtAccess
            , ''N/A'' AS [PartitionName]
            , NST.NUMBERSEQUENCESCOPE
            , DA.ID [CompanyId]
            , DA.NAME [CompanyName]            
            , CASE DA.ISVIRTUAL
                        WHEN 0 THEN ''No''
                        WHEN 1 THEN ''Yes''       
                    END [Shared]
            , CI.DATAAREA [LegalEntityName]            
            , CASE OU.OMOPERATINGUNITTYPE
                        WHEN 0 THEN ''None''
                        WHEN 1 THEN ''Department''
                        WHEN 2 THEN ''Cost center''           
                        WHEN 3 THEN ''Value stream''
                        WHEN 4 THEN ''Business unit''
                        WHEN 5 THEN ''All operating units''
                        WHEN 6 THEN ''Retail channel''             
                    END [OperatingUnitType]
            , OU.OMOPERATINGUNITNUMBER [OperatingUnitNumber]
            , FC.CALENDARID [FiscalCalendar]
            , FCY.NAME [FiscalCalendarYear]
            , FCP.NAME [Period]
            ,NST.FORMAT
			FROM [' + @DATABASE_NAME + ']..NUMBERSEQUENCETABLE NST
        JOIN [' + @DATABASE_NAME + ']..NUMBERSEQUENCESCOPE NSS ON NSS.RECID = NST.NUMBERSEQUENCESCOPE    
      LEFT JOIN [' + @DATABASE_NAME + ']..DATAAREA DA ON NSS.DATAAREA = DA.ID   
      LEFT JOIN [' + @DATABASE_NAME + ']..COMPANYINFO CI ON NSS.LEGALENTITY = CI.RECID 
      LEFT JOIN [' + @DATABASE_NAME + ']..OMOPERATINGUNIT OU ON NSS.OPERATINGUNIT = OU.RECID
      LEFT JOIN [' + @DATABASE_NAME + ']..FISCALCALENDARPERIOD FCP ON NSS.FISCALCALENDARPERIOD = FCP.RECID
      LEFT JOIN [' + @DATABASE_NAME + ']..FISCALCALENDAR FC ON FC.RECID = FCP.FISCALCALENDAR
      LEFT JOIN [' + @DATABASE_NAME + ']..FISCALCALENDARYEAR FCY ON FCY.RECID = FCP.FISCALCALENDARYEAR
WHERE INUSE = 1'
END


IF Substring(@APP_BUILD, 1, 3) IN ( '6.2', '6.3')
BEGIN 
			SET @SQL ='	 INSERT INTO AX_NUM_SEQUENCES WITH (TABLOCK) '
			  + ' SELECT ''' + @RUN_NAME  + '''' + ','+'''' + CONVERT(NVARCHAR(24), @STATS_DATE, 121) + ''',' + '''' + @DATABASE_NAME + '''' 

			  +', NST.RecId
   , NST.NUMBERSEQUENCE AS [NumberSequence]
            , NST.TXT AS [Text]
			,NST.LOWEST
			,NST.HIGHEST
			,NST.NEXTREC

            , CAST ((CAST((NST.HIGHEST - NST.NEXTREC) AS DECIMAL(20,2))/(CAST((NST.HIGHEST - NST.LOWEST) AS DECIMAL(20,2))) * 100) AS DECIMAL(5,2)) AS [PercentRemaining]
            , NST.HIGHEST - NST.NEXTREC AS [NumbersRemaining]
   , CASE NST.CONTINUOUS
     WHEN 0 THEN ''No''
     WHEN 1 THEN ''Yes''       
    END [Continuous]
   , NST.FETCHAHEAD AS FetchAhead
   , NST.FETCHAHEADQTY AS FetchAheadQty
   , NST.CLEANINTERVAL AS CleanInterval
   , NST.CLEANATACCESS AS CleanAtAccess
            , P.NAME AS [PartitionName]
            , NST.NUMBERSEQUENCESCOPE
            , DA.ID [CompanyId]
            , DA.NAME [CompanyName]            
            , CASE DA.ISVIRTUAL
                        WHEN 0 THEN ''No''
                        WHEN 1 THEN ''Yes''       
                    END [Shared]
            , DI.DATAAREA [LegalEntityName]            
            , CASE DI.OMOPERATINGUNITTYPE
                        WHEN 0 THEN ''None''
                        WHEN 1 THEN ''Department''
                        WHEN 2 THEN ''Cost center''           
                        WHEN 3 THEN ''Value stream''
                        WHEN 4 THEN ''Business unit''
                        WHEN 5 THEN ''All operating units''
                        WHEN 6 THEN ''Retail channel''              
                    END [OperatingUnitType]
            , DI.OMOPERATINGUNITNUMBER [OperatingUnitNumber]
            , FC.CALENDARID [FiscalCalendar]
            , FCY.NAME [FiscalCalendarYear]
            , FCP.NAME [Period]
            ,NST.FORMAT
			FROM [' + @DATABASE_NAME + ']..NUMBERSEQUENCETABLE NST
      JOIN [' + @DATABASE_NAME + ']..PARTITIONS P ON  NST.PARTITION = P.RECID
      JOIN [' + @DATABASE_NAME + ']..NUMBERSEQUENCESCOPE NSS ON NSS.RECID = NST.NUMBERSEQUENCESCOPE      
      LEFT JOIN [' + @DATABASE_NAME + ']..DATAAREA DA ON NSS.DATAAREA = DA.ID  
      LEFT JOIN [' + @DATABASE_NAME + ']..DirpartyTable DI ON (NSS.LEGALENTITY = DI.RECID) OR (NSS.OPERATINGUNIT = DI.RECID)      
      LEFT JOIN [' + @DATABASE_NAME + ']..FISCALCALENDARPERIOD FCP ON NSS.FISCALCALENDARPERIOD = FCP.RECID
      LEFT JOIN [' + @DATABASE_NAME + ']..FISCALCALENDAR FC ON FC.RECID = FCP.FISCALCALENDAR
      LEFT JOIN [' + @DATABASE_NAME + ']..FISCALCALENDARYEAR FCY ON FCY.RECID = FCP.FISCALCALENDARYEAR
WHERE INUSE = 1'


END 


IF @DEBUG = 'Y' 
BEGIN
PRINT '@SQL= ' + @SQL
END

EXEC (@SQL) 
END

PRINT 'Completed Successfully'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'Inserted NUMBERSEQUENCETABLE SUCCESSFULLY at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE


END TRY

BEGIN CATCH
PRINT 'Step failed to complete !!'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'FAILED TO insert NUMBERSEQUENCETABLE SUCCESSFULLY at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE

END CATCH
-- -----------------------------------------------------------------------------------------
-- Dynamicaly build the SQL to retreive data from AOTTABLEPROPERTIES.  
-- -----------------------------------------------------------------------------------------

BEGIN TRY
PRINT 'STEP Dynamics AX AOT Table Properties'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

SET @SQL = 'IF EXISTS (SELECT * FROM [' + @DATABASE_NAME + '].sys.tables WHERE NAME = ''AOTTABLEPROPERTIES'') 
BEGIN
	 INSERT INTO AX_TABLE_DETAIL WITH (TABLOCK) ' + ' SELECT ' + '''' + CONVERT(NVARCHAR(24), @STATS_DATE, 121) + ''',' + '''' + @DATABASE_NAME + '''' + ',TABLENAME
	  ,TABID
      ,OCCENABLED
      ,CACHELOOKUP
      ,INSERTMETHODOVERRIDDEN
      ,UPDATEMETHODOVERRIDDEN
      ,DELETEMETHODOVERRIDDEN
      ,AOSVALIDATEINSERT
      ,AOSVALIDATEUPDATE
      ,AOSVALIDATEDELETE
      ,DATABASELOGINSERT
      ,DATABASELOGDELETE
      ,DATABASELOGUPDATE
      ,DATABASELOGRENAMEKEY
      ,EVENTINSERT
      ,EVENTDELETE
      ,EVENTUPDATE
      ,EVENTRENAMEKEY
	,TABLEGROUP
	,APPLAYER
	 FROM [' + @DATABASE_NAME + ']..AOTTABLEPROPERTIES  WITH (NOLOCK) 
	END'
	
IF @DEBUG = 'Y' 
BEGIN
PRINT '@SQL= ' + @SQL
END

EXEC (@SQL) 

PRINT 'Completed Successfully'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)


UPDATE CAPTURE_LOG SET TEXT = TEXT + 'Inserted AOTTABLEPROPERTIES SUCCESSFULLY at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE

END TRY

BEGIN CATCH
PRINT 'Step failed to complete !!'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'FAILED TO insert AOTTABLEPROPERTIES at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE

END CATCH

BEGIN TRY
PRINT 'STEP Dynamics AX AOT Index Properties'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)
SET @SQL = 'IF EXISTS (SELECT * FROM [' + @DATABASE_NAME + '].sys.tables WHERE NAME = ''AOTINDEXPROPERTIES'') 
BEGIN
	INSERT INTO AX_INDEX_DETAIL WITH (TABLOCK) 
	SELECT ' + '''' + CONVERT(NVARCHAR(24), @STATS_DATE, 121) + ''',' + +'''' + @DATABASE_NAME + '''' + ',
	T.TABLENAME,
	INDEXNAME,
	INDEX_ID = INDEXID,
	INDEX_DESCRIPTION = 
		CASE
			WHEN	I.INDEXNAME = T.CLUSTEREDINDEX THEN ''CLUSTERED''
			ELSE	''NONCLUSTERED''
		END +
		CASE
			WHEN	I.ALLOWDUPLICATES = 0 THEN '', UNIQUE''
			ELSE	''''
		END +
		CASE
			WHEN	I.INDEXNAME = T.PRIMARYKEY THEN '', PRIMARY KEY''
			ELSE	''''
		END,
		INDEX_KEYS = 
		CASE 
			WHEN T.DATAPERCOMPANY = 1 AND 0 < 
			(
				SELECT COUNT(*) FROM [' + @DATABASE_NAME + ']..AOTINDEXFIELDS F WITH (NOLOCK)
				WHERE	F.TABLENAME = I.TABLENAME
				AND		F.INDEXNAME = I.INDEXNAME
				AND		F.FIELDNAME = ''DATAAREAID''
			)	THEN ''''
			WHEN T.DATAPERCOMPANY = 1 THEN '' DATAAREAID,''
			ELSE ''''
		END +
	stuff	
			(
					
				(	
				SELECT '', '' + FIELDNAME
				FROM [' + @DATABASE_NAME + ']..AOTINDEXFIELDS F  WITH (NOLOCK)
				WHERE F.TABLENAME = I.TABLENAME
				AND FIELDNAME <> ''''
				AND F.INDEXNAME = I.INDEXNAME
				order	by FIELDPOSITION
				for		xml path('''')
				)
			,1,1,''''
			)
			,I.APPLAYER 
					

	FROM	[' + @DATABASE_NAME + ']..AOTTABLEPROPERTIES	T  WITH (NOLOCK),
			[' + @DATABASE_NAME + ']..AOTINDEXPROPERTIES	I  WITH (NOLOCK)
	WHERE	T.TABLENAME = I.TABLENAME
END'

IF @DEBUG = 'Y' 
BEGIN
PRINT '@SQL= ' + @SQL
END

EXEC (@SQL) 
PRINT 'Completed Successfully'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'Inserted AOTINDEXES SUCCESSFULLY at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE

END TRY

BEGIN CATCH
PRINT 'Step failed to complete !!'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'FAILED TO insert AOTINDEXES at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE

END CATCH

RETURN @RETURN_CODE
GO
/******************************* END OF STORED PROCEDURES ****************************************/



/****************************  START OF CREATE VIEWS **************************************/

USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[AX_TABLE_DETAIL_CURR_VW]    Script Date: 10/17/2011 15:24:39 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[AX_TABLE_DETAIL_CURR_VW]'))
DROP VIEW [dbo].[AX_TABLE_DETAIL_CURR_VW]
GO

USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[AX_TABLE_DETAIL_CURR_VW]    Script Date: 10/17/2011 15:24:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[AX_TABLE_DETAIL_CURR_VW]
AS
  SELECT RUN_NAME,
         S.STATS_TIME,
         SQL_VERSION,
         S.SQL_SERVER_STARTTIME,
		 DYNAMICS_VERSION,
         S.DATABASE_NAME,
         [TABLE_NAME],
        APPLICATION_LAYER = APPLAYER,

         [OCC_ENABLED],
         CACHE_LOOKUP = CASE CACHE_LOOKUP
                          WHEN 0 THEN 'None'
                          WHEN 1 THEN 'NotInTTS'
                          WHEN 2 THEN 'Found'
                          WHEN 3 THEN 'FoundAndEmpty'
                          WHEN 4 THEN 'EntireTable'
                        END,
		TABLE_GROUP = CASE TABLE_GROUP
                          WHEN 0 THEN 'Miscellaneous'
                          WHEN 1 THEN 'Parameter'
                          WHEN 2 THEN 'Group'
                          WHEN 3 THEN 'Main'
                          WHEN 4 THEN 'Transaction'
                          WHEN 5 THEN 'WorksheetHeader'
                          WHEN 6 THEN 'WorksheetLine'
                        END,
         [INSERT_METHOD_OVERRIDDEN],
         [UPDATE_METHOD_OVERRIDDEN],
         [DELETE_METHOD_OVERRIDDEN],
         [AOS_VALIDATE_INSERT],
         [AOS_VALIDATE_UPDATE],
         [AOS_VALIDATE_DELETE],
         [DATABASELOG_INSERT],
         [DATABASELOG_DELETE],
         [DATABASELOG_UPDATE],
         [DATABASELOG_RENAME_KEY],
         [EVENT_INSERT],
         [EVENT_DELETE],
         [EVENT_UPDATE],
         [EVENT_RENAME_KEY]
  FROM   STATS_COLLECTION_SUMMARY S WITH (NOLOCK)
         JOIN AX_TABLE_DETAIL D WITH (NOLOCK)
           ON S.STATS_TIME = D.STATS_TIME
              AND S.DATABASE_NAME = D.DATABASE_NAME
  WHERE  S.STATS_TIME = (SELECT MAX(STATS_TIME)
                         FROM   STATS_COLLECTION_SUMMARY)



GO



USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[AX_SQLTRACE_VW]    Script Date: 10/17/2011 15:24:17 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[AX_SQLTRACE_VW]'))
DROP VIEW [dbo].[AX_SQLTRACE_VW]
GO

USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[AX_SQLTRACE_VW]    Script Date: 10/17/2011 15:24:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE VIEW [dbo].[AX_SQLTRACE_VW]
AS
  SELECT RUN_NAME,
         S.DATABASE_NAME,
         SQL_VERSION,
         TRACE_CATEGORY = CASE TRACE_CATEGORY
                            WHEN 0 THEN 'Statement'
                            WHEN 1 THEN 'QueryTime'
                            WHEN 2 THEN 'Error'
                            WHEN 3 THEN 'Synchronize'
                            WHEN 4 THEN 'Deadlock'
                            WHEN 5 THEN 'Warning'
                            ELSE Str(TRACE_CATEGORY)
                          END,
         SQL_TYPE = CASE SQL_TYPE
                      WHEN 0 THEN 'UPDATE'
                      WHEN 1 THEN 'DELETE'
                      WHEN 2 THEN 'INSERT'
                      WHEN 3 THEN 'SELECT'
                      WHEN 4 THEN 'DDL'
                      WHEN 5 THEN 'PROC'
                      WHEN 6 THEN 'Other'
                      ELSE Str(SQL_TYPE)
                    END,
         SQL_TEXT,
         SQL_DURATION,
         CALL_STACK,
         TRACE_EVENT_CODE,
         TRACE_EVENT_DESC,
         TRACE_EVENT_DETAILS,
         CONNECTION_TYPE,
         SQL_SESSION_ID,
         AX_USER_ID,
         AX_CONNECTION_ID,
         IS_LOBS_INCLUDED,
         IS_MORE_DATA_PENDING,
         ROWS_AFFECTED,
         ROW_SIZE,
         ROWS_PER_FETCH,
         IS_SELECTED_FOR_UPDATE,
         IS_STARTED_WITHIN_TRANSACTION,
         STATEMENT_ID,
         STATEMENT_REUSE_COUNT,
         DETAIL_TYPE,
         CREATED_DATETIME
  FROM   AX_SQLTRACE T,
         STATS_COLLECTION_SUMMARY S
  WHERE  T.STATS_TIME = S.STATS_TIME
         AND T.DATABASE_NAME = S.DATABASE_NAME


GO




USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[AX_INDEX_DETAIL_CURR_VW]    Script Date: 10/17/2011 15:23:24 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[AX_INDEX_DETAIL_CURR_VW]'))
DROP VIEW [dbo].[AX_INDEX_DETAIL_CURR_VW]
GO

USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[AX_INDEX_DETAIL_CURR_VW]    Script Date: 10/17/2011 15:23:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[AX_INDEX_DETAIL_CURR_VW]
AS
  SELECT RUN_NAME,
         S.STATS_TIME,
         SQL_VERSION,
         S.SQL_SERVER_STARTTIME,
         DYNAMICS_VERSION,
         D.DATABASE_NAME,
         [TABLE_NAME],
         [INDEX_NAME],
         APPLICATION_LAYER = APPLAYER,
         [INDEX_DESCRIPTION],
         [INDEX_KEYS]
  FROM   STATS_COLLECTION_SUMMARY S WITH (NOLOCK)
         JOIN AX_INDEX_DETAIL D WITH (NOLOCK)
           ON S.STATS_TIME = D.STATS_TIME
              AND S.DATABASE_NAME = D.DATABASE_NAME
  WHERE  S.STATS_TIME = (SELECT MAX(STATS_TIME)
                         FROM   STATS_COLLECTION_SUMMARY)


GO




USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[AX_SERVER_CONFIGURATION_VW]    Script Date: 10/17/2011 15:22:46 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[AX_SERVER_CONFIGURATION_VW]'))
DROP VIEW [dbo].[AX_SERVER_CONFIGURATION_VW]
GO

USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[AX_SERVER_CONFIGURATION_VW]    Script Date: 10/17/2011 15:22:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[AX_SERVER_CONFIGURATION_VW] 
as
SELECT DISTINCT [CLUSTERNAME]
      ,[CLUSTERDESCRIPTION]
      ,[SERVERID]
      ,[MAXSESSIONS] AS MAX_CLIENT_SESSIONS
      ,CASE [ENABLEBATCH] WHEN 1 THEN 'YES' ELSE 'NO' END as IS_BATCH_ENABLED
      ,MAXBATCHSESSIONS AS MAX_BATCH_THREADS
      ,[SCHEDULED START] as BATCH_SERVER_START_TIME
      ,[SCHEDULED END] as BATCH_SERVER_STOP_TIME
      
  FROM [AX_BATCHSERVER_CONFIGURATION]


GO


USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[AX_NUM_SEQUENCES_VW]    Script Date: 10/17/2011 15:22:17 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[AX_NUM_SEQUENCES_VW]'))
DROP VIEW [dbo].[AX_NUM_SEQUENCES_VW]
GO

USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[AX_NUM_SEQUENCES_VW]    Script Date: 10/17/2011 15:22:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[AX_NUM_SEQUENCES_VW] 
AS
SELECT SQ.[RUN_NAME]
      ,SQ.[STATS_TIME]
      ,SQ.[DATABASE_NAME]
      ,[RECID]
      ,[NUMBERSEQUENCE]
      ,[TEXT]
      ,[FORMAT]
      ,[LOWEST]
      ,[HIGHEST]
      ,[NEXTREC]
      ,[PERCENTREMAINING]
      ,[NUMBERSREMAINING]
      ,[CONTINUOUS]
      ,[FETCHAHEAD]
      ,[FETCHAHEADQTY]
      ,[CLEANINTERVAL]
      ,[CLEANATACCESS]
      ,[PARTITIONNAME]
      ,[NUMBERSEQUENCESCOPE]
      ,[COMPANYID]
      ,[COMPANYNAME]
      ,[SHARED]
      ,[LEGALENTITYNAME]
      ,[OPERATINGUNITTYPE]
      ,[OPERATINGUNITNUMBER]
      ,[FISCALCALENDAR]
      ,[FISCALCALENDARYEAR]
      ,[PERIOD]
  FROM AX_NUM_SEQUENCES SQ
      INNER JOIN     STATS_COLLECTION_SUMMARY S WITH(NOLOCK)
  ON  SQ.STATS_TIME = S.STATS_TIME


GO


USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[AX_NUM_SEQUENCES_CURR_VW]    Script Date: 10/17/2011 15:21:57 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[AX_NUM_SEQUENCES_CURR_VW]'))
DROP VIEW [dbo].[AX_NUM_SEQUENCES_CURR_VW]
GO

USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[AX_NUM_SEQUENCES_CURR_VW]    Script Date: 10/17/2011 15:21:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[AX_NUM_SEQUENCES_CURR_VW] 
AS
SELECT SQ.[RUN_NAME]
      ,SQ.[STATS_TIME]
      ,SQ.[DATABASE_NAME]
      ,[RECID]
      ,[NUMBERSEQUENCE]
      ,[TEXT] 
      ,[FORMAT]
      ,[LOWEST]
      ,[HIGHEST]
      ,[NEXTREC]
      ,[PERCENTREMAINING]
      ,[NUMBERSREMAINING]
      ,[CONTINUOUS]
      ,[FETCHAHEAD]
      ,[FETCHAHEADQTY]
      ,[CLEANINTERVAL]
      ,[CLEANATACCESS]
      ,[PARTITIONNAME]
      ,[NUMBERSEQUENCESCOPE]
      ,[COMPANYID]
      ,[COMPANYNAME]
      ,[SHARED]
      ,[LEGALENTITYNAME]
      ,[OPERATINGUNITTYPE]
      ,[OPERATINGUNITNUMBER]
      ,[FISCALCALENDAR]
      ,[FISCALCALENDARYEAR]
      ,[PERIOD]
  FROM AX_NUM_SEQUENCES SQ
      INNER JOIN     STATS_COLLECTION_SUMMARY S WITH(NOLOCK)
  ON  SQ.STATS_TIME = S.STATS_TIME
  WHERE SQ.STATS_TIME = (SELECT MAX(STATS_TIME)
                             FROM   STATS_COLLECTION_SUMMARY)



GO

USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[AX_DATABASELOGGING_VW]    Script Date: 10/17/2011 16:54:55 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[AX_DATABASELOGGING_VW]'))
DROP VIEW [dbo].[AX_DATABASELOGGING_VW]
GO

USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[AX_DATABASELOGGING_VW]    Script Date: 10/17/2011 16:54:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[AX_DATABASELOGGING_VW] 
AS

SELECT T.TABLE_NAME,
       H.EQ_ROWS AS ROWS_LOGGED,
       T.DATABASELOG_UPDATE,
       T.DATABASELOG_DELETE,
       T.DATABASELOG_INSERT
FROM   AX_TABLE_DETAIL T
       INNER JOIN INDEX_HISTOGRAM H
         ON T.TABLE_ID = H.RANGE_HI_KEY
            AND H.COLUMN_NAME = 'TABLE_'
WHERE  H.TABLE_NAME = 'SYSDATABASELOG'



GO



USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[AX_BATCH_CONFIGURATION_VW]    Script Date: 10/17/2011 15:25:08 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[AX_BATCH_CONFIGURATION_VW]'))
DROP VIEW [dbo].[AX_BATCH_CONFIGURATION_VW]
GO

USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[AX_BATCH_CONFIGURATION_VW]    Script Date: 10/17/2011 15:25:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[AX_BATCH_CONFIGURATION_VW]
AS 

SELECT [SERVERID]
      ,[BATCHGROUP]
      ,[COMPANY]
      ,[BATCH JOB DESCRIPTION]
      ,[BATCH TASK DESCRIPTION]
      ,[RUN AT]
  FROM [AX_BATCHSERVER_CONFIGURATION]


GO


USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[HIDDEN_SCANS_VW]    Script Date: 10/17/2011 15:18:19 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[HIDDEN_SCANS_VW]'))
DROP VIEW [dbo].[HIDDEN_SCANS_VW]
GO

USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[HIDDEN_SCANS_VW]    Script Date: 10/17/2011 15:18:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[HIDDEN_SCANS_VW] AS
WITH XMLNAMESPACES ('http://schemas.microsoft.com/sqlserver/2004/07/showplan' AS sp)
SELECT *
FROM   (SELECT RUN_NAME,
               ROW_NUM,
               SQL_TEXT,
               CONVERT (NVARCHAR(MAX), index_node2.query('for $qplan in //sp:QueryPlan, $plist in $qplan/sp:ParameterList, $colref in $plist/sp:ColumnReference  return concat(string($colref/@Column),":",string($colref/@ParameterCompiledValue),",   "),"  "')) AS QUERY_PARAMETER_VALUES,
               QUERY_PLAN,
               Replace(Replace(index_node.value('(.//@Table)[1]', 'NVARCHAR(128)'), '[', ''), ']', '')                                                                                                                                                             AS TABLE_NAME,
               Replace(Replace(index_node.value('(.//@Index)[1]', 'NVARCHAR(128)'), '[', ''), ']', '')                                                                                                                                                             AS INDEX_NAME,
               CONVERT(NVARCHAR(MAX), index_node.query('for $seekpredicate in ./sp:SeekPredicates,
                                                            $rangecolumns in $seekpredicate//sp:RangeColumns,
                                                            $columnreference in $rangecolumns/sp:ColumnReference
                                        return string($columnreference/@Column)'))                                                                                                                                                                  AS SEEK_COLUMNS,
               EXECUTION_COUNT,
               TOTAL_ELAPSED_TIME,
               TOTAL_WORKER_TIME,
               AVG_ELAPSED_TIME,
               AVG_PHYSICAL_READS,
               AVG_LOGICAL_READS,
               AVG_LOGICAL_WRITES,
               LAST_ELAPSED_TIME,
               MIN_ELAPSED_TIME,
               MAX_ELAPSED_TIME,
               TOTAL_PHYSICAL_READS,
               LAST_PHYSICAL_READS,
               MIN_PHYSICAL_READS,
               MAX_PHYSICAL_READS,
               TOTAL_LOGICAL_READS,
               LAST_LOGICAL_READS,
               MIN_LOGICAL_READS,
               MAX_LOGICAL_READS,
               TOTAL_LOGICAL_WRITES,
               LAST_LOGICAL_WRITES,
               MIN_LOGICAL_WRITES,
               MAX_LOGICAL_WRITES,
               LAST_WORKER_TIME,
               MIN_WORKER_TIME,
               MAX_WORKER_TIME,
               QUERY_PLAN_TEXT,
               STATS_TIME,
               SQL_VERSION,
               COMMENT
        FROM   QUERY_STATS_VW
               OUTER APPLY QUERY_PLAN.nodes('//sp:RelOp/sp:IndexScan') AS SeekPredicates(index_node)
               CROSS APPLY QUERY_PLAN.nodes('//sp:Batch') AS Batch(index_node2)) A
		WHERE  SEEK_COLUMNS = 'DATAAREAID' OR SEEK_COLUMNS = 'PARTITION DATAAREAID' OR SEEK_COLUMNS = 'PARTITION'
 


GO

USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[HIDDEN_SCANS_CURR_VW]    Script Date: 10/17/2011 15:18:53 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[HIDDEN_SCANS_CURR_VW]'))
DROP VIEW [dbo].[HIDDEN_SCANS_CURR_VW]
GO

USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[HIDDEN_SCANS_CURR_VW]    Script Date: 10/17/2011 15:18:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[HIDDEN_SCANS_CURR_VW] AS
WITH XMLNAMESPACES ('http://schemas.microsoft.com/sqlserver/2004/07/showplan' AS sp)
SELECT *
FROM   (SELECT RUN_NAME,
               ROW_NUM,
               SQL_TEXT,
               CONVERT (NVARCHAR(MAX), index_node2.query('for $qplan in //sp:QueryPlan, $plist in $qplan/sp:ParameterList, $colref in $plist/sp:ColumnReference  return concat(string($colref/@Column),":",string($colref/@ParameterCompiledValue),",   "),"  "')) AS QUERY_PARAMETER_VALUES,
               QUERY_PLAN,
               Replace(Replace(index_node.value('(.//@Table)[1]', 'NVARCHAR(128)'), '[', ''), ']', '')                                                                                                                                                             AS TABLE_NAME,
               Replace(Replace(index_node.value('(.//@Index)[1]', 'NVARCHAR(128)'), '[', ''), ']', '')                                                                                                                                                             AS INDEX_NAME,
               CONVERT(NVARCHAR(MAX), index_node.query('for $seekpredicate in ./sp:SeekPredicates,
                                                            $rangecolumns in $seekpredicate//sp:RangeColumns,
                                                            $columnreference in $rangecolumns/sp:ColumnReference
                                        return string($columnreference/@Column)'))                                                                                                                                                                  AS SEEK_COLUMNS,
               EXECUTION_COUNT,
               TOTAL_ELAPSED_TIME,
               TOTAL_WORKER_TIME,
               AVG_ELAPSED_TIME,
               AVG_PHYSICAL_READS,
               AVG_LOGICAL_READS,
               AVG_LOGICAL_WRITES,
               LAST_ELAPSED_TIME,
               MIN_ELAPSED_TIME,
               MAX_ELAPSED_TIME,
               TOTAL_PHYSICAL_READS,
               LAST_PHYSICAL_READS,
               MIN_PHYSICAL_READS,
               MAX_PHYSICAL_READS,
               TOTAL_LOGICAL_READS,
               LAST_LOGICAL_READS,
               MIN_LOGICAL_READS,
               MAX_LOGICAL_READS,
               TOTAL_LOGICAL_WRITES,
               LAST_LOGICAL_WRITES,
               MIN_LOGICAL_WRITES,
               MAX_LOGICAL_WRITES,
               LAST_WORKER_TIME,
               MIN_WORKER_TIME,
               MAX_WORKER_TIME,
               QUERY_PLAN_TEXT,
               STATS_TIME,
               SQL_VERSION,
               COMMENT
        FROM   QUERY_STATS_CURR_VW
               OUTER APPLY QUERY_PLAN.nodes('//sp:RelOp/sp:IndexScan') AS SeekPredicates(index_node)
               CROSS APPLY QUERY_PLAN.nodes('//sp:Batch') AS Batch(index_node2)
        WHERE  QUERY_STATS_CURR_VW.STATS_TIME = (SELECT Max(STATS_TIME)
                                                 FROM   STATS_COLLECTION_SUMMARY
                                                 WHERE  QUERY_STATS_CURR_VW.RUN_NAME = STATS_COLLECTION_SUMMARY.RUN_NAME)) A
		WHERE  SEEK_COLUMNS = 'DATAAREAID' OR SEEK_COLUMNS = 'PARTITION DATAAREAID' OR SEEK_COLUMNS = 'PARTITION'


GO




/****************************  END OF CREATE VIEWS **************************************/




/****************************  Reminder Message  ***************************************/
PRINT ' '
PRINT ''
PRINT ''
PRINT ''
PRINT '        Please visit HTTP://BLOGS.MSDN.COM/AXINTHEFILED for inoformation on usage on this tool '
PRINT ''
PRINT ''
PRINT ''
PRINT ''
PRINT '        ******************************** NOTE *****************************************'
PRINT ' '
PRINT '        For Dynamics AX customers, please perform these additional steps: '
PRINT ' '
PRINT '          1-Import the AOTExport.xpo from the DynamicsPerf\Dynamics AX folder'
PRINT '              Be sure to run this class after importing into Dynamics AX'
PRINT ' '
PRINT '          2-Edit and run the AOSANALSIS.CMD in the DynamicsPerf\Dynamics AX folder  '
PRINT ' '
PRINT '          3-Deploy the Windows Perfmon Templates in the DynamicsPerf\Windows Perfmon Scripts folder'
PRINT ' '

