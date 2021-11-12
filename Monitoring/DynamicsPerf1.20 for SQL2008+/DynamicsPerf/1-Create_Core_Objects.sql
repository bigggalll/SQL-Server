

-- Copyright © Microsoft Corporation.  All rights reserved. 


-- THIS SCRIPT IS MADE AVAILABLE TO YOU WITHOUT ANY EXPRESS, IMPLIED OR STATUTORY WARRANTY, 
-- NOT EVEN THE IMPLIED WARRANTY OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE, 
-- OR THE WARRANTY OF TITLE OR NON-INFRINGEMENT.  
-- THE ENTIRE RISK OF THE USE OR THE RESULTS FROM THE USE OF THIS SCRIPT REMAINS WITH YOU





/**********************************************************************************************
*
*	PLEASE NOTE:
*
*  This script runs sp_configure to set the 'Blocked Processes Threshold' value to 5 seconds
*  
*  This script will create a database named DynamicsPerf in your default location for databases
*
*  This script will create SQL Jobs named DYNPERF_xxxxxxxxxxxx
*
*
*
*
************************************************************************************************/




SET NOCOUNT ON

USE [master]
GO

/****** Object:  Database [DynamicsPerf]    Script Date: 02/28/2011 12:28:47 ******/
IF  NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'DynamicsPerf')
BEGIN


CREATE DATABASE [DynamicsPerf] 
/***** The following commented lines are added to help setting the database files path an easier task to do. **/

--on
--(
--NAME = N'DynamicsPerf', FILENAME = 'D:\Data\DynamicsPerf.mdf'
--)
--log on
--(
--NAME = N'DynamicsPerf_log', FILENAME = 'D:\Data\DynamicsPerf_Log.ldf'
--)



ALTER DATABASE DynamicsPerf MODIFY FILE(NAME = N'DynamicsPerf', SIZE = 500MB , MAXSIZE = UNLIMITED, FILEGROWTH = 500MB )

ALTER DATABASE DynamicsPerf MODIFY FILE(NAME = N'DynamicsPerf_log', SIZE = 200MB , MAXSIZE = 2048GB , FILEGROWTH = 100MB )

--EXEC dbo.sp_dbcmptlevel @dbname=N'DynamicsPerf', @new_cmptlevel=100

--REH not needed for SQL 2008 and above
--IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
--begin
--EXEC [DynamicsPerf].[dbo].[sp_fulltext_database] @action = 'enable'
--end

ALTER DATABASE [DynamicsPerf] SET ANSI_NULL_DEFAULT OFF 

ALTER DATABASE [DynamicsPerf] SET ANSI_NULLS OFF 

ALTER DATABASE [DynamicsPerf] SET ANSI_PADDING OFF 

ALTER DATABASE [DynamicsPerf] SET ANSI_WARNINGS OFF 

ALTER DATABASE [DynamicsPerf] SET ARITHABORT OFF 

ALTER DATABASE [DynamicsPerf] SET AUTO_CLOSE OFF 

ALTER DATABASE [DynamicsPerf] SET AUTO_CREATE_STATISTICS ON 

ALTER DATABASE [DynamicsPerf] SET AUTO_SHRINK OFF 

ALTER DATABASE [DynamicsPerf] SET AUTO_UPDATE_STATISTICS ON 

ALTER DATABASE [DynamicsPerf] SET CURSOR_CLOSE_ON_COMMIT OFF 

ALTER DATABASE [DynamicsPerf] SET CURSOR_DEFAULT  GLOBAL 

ALTER DATABASE [DynamicsPerf] SET CONCAT_NULL_YIELDS_NULL OFF 

ALTER DATABASE [DynamicsPerf] SET NUMERIC_ROUNDABORT OFF 

ALTER DATABASE [DynamicsPerf] SET QUOTED_IDENTIFIER OFF 

ALTER DATABASE [DynamicsPerf] SET RECURSIVE_TRIGGERS OFF 

ALTER DATABASE [DynamicsPerf] SET  ENABLE_BROKER 

ALTER DATABASE [DynamicsPerf] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 

ALTER DATABASE [DynamicsPerf] SET DATE_CORRELATION_OPTIMIZATION OFF 

ALTER DATABASE [DynamicsPerf] SET TRUSTWORTHY OFF 

ALTER DATABASE [DynamicsPerf] SET READ_COMMITTED_SNAPSHOT ON

ALTER DATABASE [DynamicsPerf] SET ALLOW_SNAPSHOT_ISOLATION ON

ALTER DATABASE [DynamicsPerf] SET PARAMETERIZATION SIMPLE 

ALTER DATABASE [DynamicsPerf] SET  READ_WRITE 

ALTER DATABASE [DynamicsPerf] SET RECOVERY SIMPLE 

ALTER DATABASE [DynamicsPerf] SET  MULTI_USER 

ALTER DATABASE [DynamicsPerf] SET PAGE_VERIFY NONE  

ALTER DATABASE [DynamicsPerf] SET DB_CHAINING OFF 

END
GO






/************************* START OF CREATE TABLES  ***************************************/

USE [DynamicsPerf]
GO

/****** Object:  Table [dbo].[DATABASES_2_COLLECT]    Script Date: 09/22/2011 08:14:40 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DATABASES_2_COLLECT]') AND type in (N'U'))
DROP TABLE [dbo].[DATABASES_2_COLLECT]
GO

USE [DynamicsPerf]
GO

/****** Object:  Table [dbo].[DATABASES_2_COLLECT]    Script Date: 09/22/2011 08:14:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[DATABASES_2_COLLECT](
	[DATABASENAME] [sysname] NOT NULL
) ON [PRIMARY]

GO

USE [DynamicsPerf]
GO

/****** Object:  Table [dbo].[COLLECTIONDATABASES]    Script Date: 09/22/2011 08:15:22 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[COLLECTIONDATABASES]') AND type in (N'U'))
DROP TABLE [dbo].[COLLECTIONDATABASES]
GO

USE [DynamicsPerf]
GO

/****** Object:  Table [dbo].[COLLECTIONDATABASES]    Script Date: 09/22/2011 08:15:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[COLLECTIONDATABASES](
	[DATABASENAME] [sysname] NOT NULL
) ON [PRIMARY]

GO


USE [DynamicsPerf]
GO

/****** Object:  Table [dbo].[COLLECTIONDATABASES_PERF]    Script Date: 09/22/2011 08:15:22 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[COLLECTIONDATABASES_PERF]') AND type in (N'U'))
DROP TABLE [dbo].[COLLECTIONDATABASES_PERF]
GO

USE [DynamicsPerf]
GO

/****** Object:  Table [dbo].[COLLECTIONDATABASES_PERF]    Script Date: 09/22/2011 08:15:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[COLLECTIONDATABASES_PERF](
	[DATABASENAME] [sysname] NOT NULL
) ON [PRIMARY]

GO



USE [DynamicsPerf]
GO

/****** Object:  Table [dbo].[DYNAMICSPERF_SETUP]    Script Date: 03/14/2011 16:33:45 ******/
IF EXISTS (SELECT *
           FROM   sys.objects
           WHERE  object_id = Object_id(N'[dbo].[DYNAMICSPERF_SETUP]')
                  AND type IN ( N'U' ))
  DROP TABLE [dbo].[DYNAMICSPERF_SETUP] 

GO

USE [DynamicsPerf]
GO

/****** Object:  Table [dbo].[DYNAMICSPERF_SETUP]    Script Date: 03/14/2011 16:33:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[DYNAMICSPERF_SETUP](
	[VERSION] [nvarchar](256) NULL,
	[INSTALLED_DATE] [smalldatetime] NULL,
	[TRACE_FULL_PATH_NAME]   [nvarchar] (512) NULL
) ON [PRIMARY]

GO
INSERT [DynamicsPerf]..[DYNAMICSPERF_SETUP]
VALUES('1.20', GETDATE(), '') 



GO


USE [DynamicsPerf]
GO


/****** Object:  Table [dbo].[WAIT_STATS]    Script Date: 02/02/2011 13:38:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT *
               FROM   sys.objects
               WHERE  object_id = Object_id(N'[dbo].[WAIT_STATS]')
                      AND type IN ( N'U' )) 
BEGIN
DROP TABLE [dbo].[WAIT_STATS]
END
GO
CREATE TABLE [dbo].[WAIT_STATS]
  (
     [STATS_TIME]          [DATETIME] NOT NULL,
     [WAIT_TYPE]           [NVARCHAR](60) NOT NULL,
     [WAITING_TASKS_COUNT] [BIGINT] NOT NULL,
     [WAIT_TIME_MS]        [BIGINT] NOT NULL,
     [MAX_WAIT_TIME_MS]    [BIGINT] NOT NULL,
     [SIGNAL_WAIT_TIME_MS] [BIGINT] NOT NULL
  )
ON [PRIMARY] 


GO
/****** Object:  Table [dbo].[TRACEFLAGS]    Script Date: 02/02/2011 13:38:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT *
               FROM   sys.objects
               WHERE  object_id = Object_id(N'[dbo].[TRACEFLAGS]')
                      AND type IN ( N'U' )) 
BEGIN
DROP TABLE [dbo].[TRACEFLAGS]
END
GO
CREATE TABLE [dbo].[TRACEFLAGS]
  (
     [STATS_TIME] [DATETIME] NOT NULL,
     [TRACEFLAG]  [INT] NULL,
     [STATUS]     [BIT] NULL,
     [GLOBAL]     [BIT] NULL,
     [SESSIONS]   [BIT] NULL
  )
ON [PRIMARY] 


GO
/****** Object:  Table [dbo].[STATS_COLLECTION_SUMMARY]    Script Date: 02/02/2011 13:38:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
IF EXISTS (SELECT *
               FROM   sys.objects
               WHERE  object_id = Object_id(N'[dbo].[STATS_COLLECTION_SUMMARY]')
                      AND type IN ( N'U' )) 
BEGIN
DROP TABLE [dbo].[STATS_COLLECTION_SUMMARY]
END
GO
CREATE TABLE [dbo].[STATS_COLLECTION_SUMMARY]
  (
     [STATS_TIME]           [DATETIME] NOT NULL,
     [RUN_NAME]             [NVARCHAR](60) NOT NULL,
     [DATABASE_NAME]        [NVARCHAR](128) NOT NULL,
     [SQL_VERSION]          [NVARCHAR](MAX) NULL,
     [DYNAMICS_VERSION]     [NVARCHAR](MAX) NULL,
     [RUN_DESCRIPTION]      [VARCHAR](MAX) NULL,
     [SQL_SERVER_STARTTIME] [DATETIME] NULL,
     [STATS_COLLECTED]		[NVARCHAR] (1) NULL    --We're stats collected during this collection, using this to not collect stats so often to save time
  )
ON [PRIMARY] 




GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SQLErrorLog]    Script Date: 02/02/2011 13:38:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT *
               FROM   sys.objects
               WHERE  object_id = Object_id(N'[dbo].[SQLErrorLog]')
                      AND type IN ( N'U' )) 
BEGIN
DROP TABLE [dbo].[SQLErrorLog]
END
GO

CREATE TABLE [dbo].[SQLErrorLog]
  (
     [LOGDATE]     [DATETIME] NULL,
     [PROCESSINFO] [NVARCHAR](255) NULL,
     [LOGTEXT]     [NVARCHAR](MAX) NULL
  )
ON [PRIMARY] 


GO
/****** Object:  Table [dbo].[SQL_TRACE]    Script Date: 02/02/2011 13:38:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
IF EXISTS (SELECT *
               FROM   sys.objects
               WHERE  object_id = Object_id(N'[dbo].[SQL_TRACE]')
                      AND type IN ( N'U' )) 
BEGIN
DROP TABLE [dbo].[SQL_TRACE]
END
GO

CREATE TABLE [dbo].[SQL_TRACE]
  (
     [TEXTDATA]          [NTEXT] NULL,
     [BINARYDATA]        [IMAGE] NULL,
     [DATABASEID]        [INT] NULL,
     [TRANSACTIONID]     [BIGINT] NULL,
     [LINENUMBER]        [INT] NULL,
     [NTUSERNAME]        [NVARCHAR](256) NULL,
     [NTDOMAINNAME]      [NVARCHAR](256) NULL,
     [HOSTNAME]          [NVARCHAR](256) NULL,
     [CLIENTPROCESSID]   [INT] NULL,
     [APPLICATIONNAME]   [NVARCHAR](256) NULL,
     [LOGINNAME]         [NVARCHAR](256) NULL,
     [SPID]              [INT] NULL,
     [DURATION]          [BIGINT] NULL,
     [STARTTIME]         [DATETIME] NULL,
     [ENDTIME]           [DATETIME] NULL,
     [READS]             [BIGINT] NULL,
     [WRITES]            [BIGINT] NULL,
     [CPU]               [INT] NULL,
     [PERMISSIONS]       [BIGINT] NULL,
     [SEVERITY]          [INT] NULL,
     [EVENTSUBCLASS]     [INT] NULL,
     [OBJECTID]          [INT] NULL,
     [SUCCESS]           [INT] NULL,
     [INDEXID]           [INT] NULL,
     [INTEGERDATA]       [INT] NULL,
     [SERVERNAME]        [NVARCHAR](256) NULL,
     [EVENTCLASS]        [INT] NULL,
     [OBJECTTYPE]        [INT] NULL,
     [NESTLEVEL]         [INT] NULL,
     [STATE]             [INT] NULL,
     [ERROR]             [INT] NULL,
     [MODE]              [INT] NULL,
     [HANDLE]            [INT] NULL,
     [OBJECTNAME]        [NVARCHAR](256) NULL,
     [DATABASE_NAME]     [NVARCHAR](256) NULL,
     [FILENAME]          [NVARCHAR](256) NULL,
     [OWNERNAME]         [NVARCHAR](256) NULL,
     [ROLENAME]          [NVARCHAR](256) NULL,
     [TARGETUSERNAME]    [NVARCHAR](256) NULL,
     [DBUSERNAME]        [NVARCHAR](256) NULL,
     [LOGINSID]          [IMAGE] NULL,
     [TARGETLOGINNAME]   [NVARCHAR](256) NULL,
     [TARGETLOGINSID]    [IMAGE] NULL,
     [COLUMNPERMISSIONS] [INT] NULL,
     [LINKEDSERVERNAME]  [NVARCHAR](256) NULL,
     [PROVIDERNAME]      [NVARCHAR](256) NULL,
     [METHODNAME]        [NVARCHAR](256) NULL,
     [ROWCOUNTS]         [BIGINT] NULL,
     [REQUESTID]         [INT] NULL,
     [XACTSEQUENCE]      [BIGINT] NULL,
     [EVENTSEQUENCE]     [BIGINT] NULL,
     [BIGINTDATA1]       [BIGINT] NULL,
     [BIGINTDATA2]       [BIGINT] NULL,
     [GUID]              [UNIQUEIDENTIFIER] NULL,
     [INTEGERDATA2]      [INT] NULL,
     [OBJECTID2]         [BIGINT] NULL,
     [TYPE]              [INT] NULL,
     [OWNERID]           [INT] NULL,
     [PARENTNAME]        [NVARCHAR](256) NULL,
     [ISSYSTEM]          [INT] NULL,
     [OFFSET]            [INT] NULL,
     [SOURCEDATABASEID]  [INT] NULL,
     [SQLHANDLE]         [VARBINARY](64) NULL,
     [SESSIONLOGINNAME]  [NVARCHAR](256) NULL,
     [PLANHANDLE]        [VARBINARY](64) NULL
  )
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY] 


GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SQL_JOBS]    Script Date: 02/02/2011 13:38:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT *
               FROM   sys.objects
               WHERE  object_id = Object_id(N'[dbo].[SQL_JOBS]')
                      AND type IN ( N'U' )) 
BEGIN
DROP TABLE [dbo].[SQL_JOBS]
END
GO

CREATE TABLE [dbo].[SQL_JOBS]
  (
     [RUN_NAME]     [VARCHAR](60) NOT NULL,
     [STATS_TIME]   [DATETIME] NOT NULL,
     [JOBNAME]      [SYSNAME] NOT NULL,
     [SCHEDULENAME] [SYSNAME] NOT NULL,
     [FREQUENCY]    [NVARCHAR](MAX) NULL,
     [SUBFREQUENCY] [VARCHAR](24) NOT NULL,
     [SCHEDULETIME] [VARCHAR](13) NULL,
     [NEXTRUNDATE]  [VARCHAR](16) NULL,
     [STEP_ID]      [INT] NOT NULL,
     [STEP_NAME]    [SYSNAME] NOT NULL,
     [SUBSYSTEM]    [NVARCHAR](40) NOT NULL,
     [COMMAND]      [NVARCHAR](MAX) NULL
  )
ON [PRIMARY] 


GO
SET ANSI_PADDING OFF
GO


/****** Object:  Table [dbo].[SQL_DATABASES]    Script Date: 02/02/2011 13:38:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT *
               FROM   sys.objects
               WHERE  object_id = Object_id(N'[dbo].[SQL_DATABASES]')
                      AND type IN ( N'U' )) 
BEGIN
DROP TABLE [dbo].[SQL_DATABASES]
END
GO

CREATE TABLE [dbo].[SQL_DATABASES]
  (
     [RUN_NAME]                          [NVARCHAR](60) NOT NULL,
     [STATS_TIME]                        [DATETIME] NOT NULL,
     [DATABASE_NAME]                     [SYSNAME] NOT NULL,
     [DATABASE_ID]                       [INT] NOT NULL,
     [SOURCE_DATABASE_ID]                [INT] NULL,
     [OWNER_SID]                         [VARBINARY](85) NULL,
     [CREATE_DATE]                       [DATETIME] NOT NULL,
     [COMPATIBILITY_LEVEL]               [TINYINT] NOT NULL,
     [COLLATION_NAME]                    [SYSNAME] NULL,
     [USER_ACCESS]                       [TINYINT] NULL,
     [USER_ACCESS_DESC]                  [NVARCHAR](60) NULL,
     [IS_READ_ONLY]                      [BIT] NULL,
     [IS_AUTO_CLOSE_ON]                  [BIT] NOT NULL,
     [IS_AUTO_SHRINK_ON]                 [BIT] NULL,
     [STATE]                             [TINYINT] NULL,
     [STATE_DESC]                        [NVARCHAR](60) NULL,
     [IS_IN_STANDBY]                     [BIT] NULL,
     [IS_CLEANLY_SHUTDOWN]               [BIT] NULL,
     [IS_SUPPLEMENTAL_LOGGING_ENABLED]   [BIT] NULL,
     [SNAPSHOT_ISOLATION_STATE]          [TINYINT] NULL,
     [SNAPSHOT_ISOLATION_STATE_DESC]     [NVARCHAR](60) NULL,
     [IS_READ_COMMITTED_SNAPSHOT_ON]     [BIT] NULL,
     [RECOVERY_MODEL]                    [TINYINT] NULL,
     [RECOVERY_MODEL_DESC]               [NVARCHAR](60) NULL,
     [PAGE_VERIFY_OPTION]                [TINYINT] NULL,
     [PAGE_VERIFY_OPTION_DESC]           [NVARCHAR](60) NULL,
     [IS_AUTO_CREATE_STATS_ON]           [BIT] NULL,
     [IS_AUTO_UPDATE_STATS_ON]           [BIT] NULL,
     [IS_AUTO_UPDATE_STATS_ASYNC_ON]     [BIT] NULL,
     [IS_ANSI_NULL_DEFAULT_ON]           [BIT] NULL,
     [IS_ANSI_NULLS_ON]                  [BIT] NULL,
     [IS_ANSI_PADDING_ON]                [BIT] NULL,
     [IS_ANSI_WARNINGS_ON]               [BIT] NULL,
     [IS_ARITHABORT_ON]                  [BIT] NULL,
     [IS_CONCAT_NULL_YIELDS_NULL_ON]     [BIT] NULL,
     [IS_NUMERIC_ROUNDABORT_ON]          [BIT] NULL,
     [IS_QUOTED_IDENTIFIER_ON]           [BIT] NULL,
     [IS_RECURSIVE_TRIGGERS_ON]          [BIT] NULL,
     [IS_CURSOR_CLOSE_ON_COMMIT_ON]      [BIT] NULL,
     [IS_LOCAL_CURSOR_DEFAULT]           [BIT] NULL,
     [IS_FULLTEXT_ENABLED]               [BIT] NULL,
     [IS_TRUSTWORTHY_ON]                 [BIT] NULL,
     [IS_DB_CHAINING_ON]                 [BIT] NULL,
     [IS_PARAMETERIZATION_FORCED]        [BIT] NULL,
     [IS_MASTER_KEY_ENCRYPTED_BY_SERVER] [BIT] NOT NULL,
     [IS_PUBLISHED]                      [BIT] NOT NULL,
     [IS_SUBSCRIBED]                     [BIT] NOT NULL,
     [IS_MERGE_PUBLISHED]                [BIT] NOT NULL,
     [IS_DISTRIBUTOR]                    [BIT] NOT NULL,
     [IS_SYNC_WITH_BACKUP]               [BIT] NOT NULL,
     [SERVICE_BROKER_GUID]               [UNIQUEIDENTIFIER] NOT NULL,
     [IS_BROKER_ENABLED]                 [BIT] NOT NULL,
     [LOG_REUSE_WAIT]                    [TINYINT] NULL,
     [LOG_REUSE_WAIT_DESC]               [NVARCHAR](60) NULL,
     [IS_DATE_CORRELATION_ON]            [BIT] NOT NULL
  )
ON [PRIMARY] 


GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SQL_DATABASEFILES]    Script Date: 02/02/2011 13:38:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT *
               FROM   sys.objects
               WHERE  object_id = Object_id(N'[dbo].[SQL_DATABASEFILES]')
                      AND type IN ( N'U' )) 
BEGIN
DROP TABLE [dbo].[SQL_DATABASEFILES]
END
GO


CREATE TABLE [dbo].[SQL_DATABASEFILES]
  (
     [RUN_NAME]           [VARCHAR](60) NOT NULL,
     [STATS_TIME]         [DATETIME] NOT NULL,
     [DATABASE_NAME]      [SYSNAME] NOT NULL,
     [FILE_ID]			  [INT] NOT NULL, 
     [FILE_NAME]          [SYSNAME] NOT NULL,
     [PHYSICAL_NAME]      [NVARCHAR](512) NULL,
     [FILE_TYPE]          [VARCHAR](4) NULL,
     [DB_SIZE(MB)]        [INT] NULL,
     [DB_FREE(MB)]        [INT] NULL,
     [FREE_SPACE_%]       [DECIMAL](25, 0) NULL,
     [GROWTH_UNITS]       [VARCHAR](15) NULL,
     [GROW_MAX_SIZE(MB)]  [INT] NULL
  )
ON [PRIMARY] 


GO
SET ANSI_PADDING OFF
GO

USE [DynamicsPerf]
GO

/****** Object:  Table [dbo].[LOGINFO]    Script Date: 09/06/2011 18:15:39 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LOGINFO]') AND type in (N'U'))
DROP TABLE [dbo].[LOGINFO]
GO

USE [DynamicsPerf]
GO

/****** Object:  Table [dbo].[LOGINFO]    Script Date: 09/06/2011 18:15:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[LOGINFO](
	[DATABASE_NAME] [sysname] NOT NULL,
	[FILEID] [tinyint] NULL,
	[FILESIZE] [bigint] NULL,
	[STARTOFFSET] [bigint] NULL,
	[FSEQNO] [int] NULL,
	[STATUS] [tinyint] NULL,
	[PARITY] [tinyint] NULL,
	[CREATELSN] [numeric](25, 0) NULL
) ON [PRIMARY]

GO


/****** Object:  Table [dbo].[SQL_CONFIGURATION]    Script Date: 02/02/2011 13:38:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT *
               FROM   sys.objects
               WHERE  object_id = Object_id(N'[dbo].[SQL_CONFIGURATION]')
                      AND type IN ( N'U' )) 
BEGIN
DROP TABLE [SQL_CONFIGURATION]
END
GO

CREATE TABLE [dbo].[SQL_CONFIGURATION]
  (
     [RUN_NAME]     [NVARCHAR](60) NOT NULL,
     [STATS_TIME]   [DATETIME] NOT NULL,
     [NAME]         [NVARCHAR](35) NOT NULL,
     [MINIMUM]      [INT] NULL,
     [MAXIMUM]      [INT] NULL,
     [CONFIG_VALUE] [INT] NULL,
     [RUN_VALUE]    [INT] NULL
  )
ON [PRIMARY] 



GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SERVERINFO]    Script Date: 02/02/2011 13:38:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
IF EXISTS (SELECT *
               FROM   sys.objects
               WHERE  object_id = Object_id(N'[dbo].[SERVERINFO]')
                      AND type IN ( N'U' )) 
BEGIN
DROP TABLE [dbo].[SERVERINFO]
END
GO


CREATE TABLE [dbo].[SERVERINFO]
  (
     [RUN_NAME]               [VARCHAR](60) NOT NULL,
     [STATS_TIME]             [DATETIME] NOT NULL,
     [SQL_SERVER_STARTTIME]   [DATETIME] NOT NULL,
     [PHYSICALCOMPUTERNAME]   [SQL_VARIANT] NULL,
     [ISCLUSTERED]            [SQL_VARIANT] NULL,
     [MACHINENAME]            [SQL_VARIANT] NULL,
     [INSTANCENAME]           [SQL_VARIANT] NULL,
     [PRODUCTVERSION]         [SQL_VARIANT] NULL,
     [PRODUCTLEVEL]           [SQL_VARIANT] NULL,
     [EDITION]                [SQL_VARIANT] NULL,
     [ENGINEEDITION]          [SQL_VARIANT] NULL,
     [SQLCHARSET]             [SQL_VARIANT] NULL,
     [SQLCHARSETNAME]         [SQL_VARIANT] NULL,
     [SQLSORTORDER]           [SQL_VARIANT] NULL,
     [SQLSORTORDERNAME]       [SQL_VARIANT] NULL,
     [CPU_COUNT]              [INT] NOT NULL,
     [HYPERTHREAD_RATIO]      [INT] NOT NULL,
     [BPOOL_COMMITTED_MB]     [INT] NULL,
     [BPOOL_COMMIT_TARGET_MB] [INT] NULL,
     [BPOOL_VISIBLE_MB]       [INT] NULL,
     [PAGE_LIFE_EXPECTANCY]   [BIGINT] NOT NULL,
     [CURRENTSIZEOFTOKENCACHE(KB)] [BIGINT] NOT NULL
  )
ON [PRIMARY] 


GO
SET ANSI_PADDING OFF
GO


/****** Object:  Table [dbo].[QUERY_STATS]    Script Date: 02/02/2011 13:38:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
IF EXISTS (SELECT *
               FROM   sys.objects
               WHERE  object_id = Object_id(N'[dbo].[QUERY_STATS]')
                      AND type IN ( N'U' )) 
BEGIN
DROP TABLE [dbo].[QUERY_STATS]
END
GO

CREATE TABLE [dbo].[QUERY_STATS]
  (
     [STATS_TIME]             [DATETIME] NOT NULL,
     [DATABASE_NAME]          [NVARCHAR](128) NOT NULL,
     [SQL_HANDLE]             [VARBINARY](64) NOT NULL,
     [PLAN_HANDLE]            [BINARY](64) NOT NULL,
     [PLAN_GENERATION_NUM]    [BIGINT] NOT NULL,
     [CREATION_TIME]          [DATETIME] NOT NULL,
     [LAST_EXECUTION_TIME]    [DATETIME] NOT NULL,
     [EXECUTION_COUNT]        [BIGINT] NOT NULL,
     [TOTAL_WORKER_TIME]      [BIGINT] NOT NULL,
     [LAST_WORKER_TIME]       [BIGINT] NOT NULL,
     [MIN_WORKER_TIME]        [BIGINT] NOT NULL,
     [MAX_WORKER_TIME]        [BIGINT] NOT NULL,
     [TOTAL_PHYSICAL_READS]   [BIGINT] NOT NULL,
     [LAST_PHYSICAL_READS]    [BIGINT] NOT NULL,
     [MIN_PHYSICAL_READS]     [BIGINT] NOT NULL,
     [MAX_PHYSICAL_READS]     [BIGINT] NOT NULL,
     [TOTAL_LOGICAL_WRITES]   [BIGINT] NOT NULL,
     [LAST_LOGICAL_WRITES]    [BIGINT] NOT NULL,
     [MIN_LOGICAL_WRITES]     [BIGINT] NOT NULL,
     [MAX_LOGICAL_WRITES]     [BIGINT] NOT NULL,
     [TOTAL_LOGICAL_READS]    [BIGINT] NOT NULL,
     [LAST_LOGICAL_READS]     [BIGINT] NOT NULL,
     [MIN_LOGICAL_READS]      [BIGINT] NOT NULL,
     [MAX_LOGICAL_READS]      [BIGINT] NOT NULL,
     [TOTAL_CLR_TIME]         [BIGINT] NOT NULL,
     [LAST_CLR_TIME]          [BIGINT] NOT NULL,
     [MIN_CLR_TIME]           [BIGINT] NOT NULL,
     [MAX_CLR_TIME]           [BIGINT] NOT NULL,
     [TOTAL_ELAPSED_TIME]     [BIGINT] NOT NULL,
     [LAST_ELAPSED_TIME]      [BIGINT] NOT NULL,
     [MIN_ELAPSED_TIME]       [BIGINT] NOT NULL,
     [MAX_ELAPSED_TIME]       [BIGINT] NOT NULL,
     [QUERY_HASH]             [BINARY](8) NOT NULL,
     [QUERY_PLAN_HASH]        [BINARY](8) NOT NULL,
     [PLAN_HANDLE_INTERNAL]   [VARBINARY](64) NOT NULL,--Used to join internally vs. plan_handle, we want this column to be 0 on SQL2008 and above so we only join on query_plan_hash
     [ROW_NUM]                [BIGINT] IDENTITY(1, 1) NOT NULL,
     [TOTAL_ROWS]             [BIGINT] NOT NULL,
     [LAST_ROWS]              [BIGINT] NOT NULL,
     [MAX_ROWS]               [BIGINT] NOT NULL,
     [MIN_ROWS]               [BIGINT] NOT NULL,
     [AVG_TIME_ms]  AS (CONVERT([decimal](14,3),([TOTAL_ELAPSED_TIME]/[EXECUTION_COUNT])/(1000.000)))
  )
ON [PRIMARY] 



GO
SET ANSI_PADDING OFF
GO



/****** Object:  Table [dbo].[QUERY_TEXT]    Script Date: 011/13/2011 13:38:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
IF EXISTS (SELECT *
               FROM   sys.objects
               WHERE  object_id = Object_id(N'[dbo].[QUERY_TEXT]')
                      AND type IN ( N'U' )) 
BEGIN
DROP TABLE [dbo].[QUERY_TEXT]
END
GO

CREATE TABLE [dbo].[QUERY_TEXT]
  (
     [QUERY_HASH]             [BINARY](8) NOT NULL,
     [SQL_TEXT ]            [NVARCHAR](MAX) NULL,
  
  )
ON [PRIMARY] 



GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[QUERY_PLANS]    Script Date: 02/02/2011 13:38:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
IF  EXISTS (SELECT *
               FROM   sys.objects
               WHERE  object_id = Object_id(N'[dbo].[QUERY_PLANS]')
                      AND type IN ( N'U' )) 
BEGIN
DROP TABLE [dbo].[QUERY_PLANS]
END
GO 

CREATE TABLE [dbo].[QUERY_PLANS]
  (

     [QUERY_PLAN_HASH] [BINARY](8) NOT NULL,
     [QUERY_PLAN]      [XML] NULL,
     [SQL_PARMS]	   NVARCHAR(MAX) NULL,
     [MI_FLAG]		   [BIT] NULL)
     
ON [PRIMARY] 




GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[INDEX_USAGE_STATS]    Script Date: 02/02/2011 13:38:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT *
               FROM   sys.objects
               WHERE  object_id = Object_id(N'[dbo].[INDEX_USAGE_STATS]')
                      AND type IN ( N'U' )) 
BEGIN
DROP TABLE [dbo].[INDEX_USAGE_STATS]
END
GO


CREATE TABLE [dbo].[INDEX_USAGE_STATS]
  (
     [STATS_TIME]         [DATETIME] NOT NULL,
     [DATABASE_NAME]      [NVARCHAR](128) NOT NULL,
     [OBJECT_ID]          [INT] NOT NULL,
     [INDEX_ID]           [INT] NOT NULL,
     [USER_SEEKS]         [BIGINT] NOT NULL,
     [USER_SCANS]         [BIGINT] NOT NULL,
     [USER_LOOKUPS]       [BIGINT] NOT NULL,
     [USER_UPDATES]       [BIGINT] NOT NULL,
     [LAST_USER_SEEK]     [DATETIME] NULL,
     [LAST_USER_SCAN]     [DATETIME] NULL,
     [LAST_USER_LOOKUP]   [DATETIME] NULL,
     [LAST_USER_UPDATE]   [DATETIME] NULL,
     [SYSTEM_SEEKS]       [BIGINT] NOT NULL,
     [SYSTEM_SCANS]       [BIGINT] NOT NULL,
     [SYSTEM_LOOKUPS]     [BIGINT] NOT NULL,
     [SYSTEM_UPDATES]     [BIGINT] NOT NULL,
     [LAST_SYSTEM_SEEK]   [DATETIME] NULL,
     [LAST_SYSTEM_SCAN]   [DATETIME] NULL,
     [LAST_SYSTEM_LOOKUP] [DATETIME] NULL,
     [LAST_SYSTEM_UPDATE] [DATETIME] NULL
  )
ON [PRIMARY] 


GO
/****** Object:  Table [dbo].[INDEX_PHYSICAL_STATS]    Script Date: 02/02/2011 13:38:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT *
               FROM   sys.objects
               WHERE  object_id = Object_id(N'[dbo].[INDEX_PHYSICAL_STATS]')
                      AND type IN ( N'U' )) 
BEGIN
DROP TABLE [dbo].[INDEX_PHYSICAL_STATS]
END
GO 


CREATE TABLE [dbo].[INDEX_PHYSICAL_STATS]
  (
     [STATS_TIME]                   [DATETIME] NOT NULL,
     [DATABASE_NAME]                [NVARCHAR](128) NOT NULL,
     [OBJECT_ID]                    [INT] NOT NULL,
     [INDEX_ID]                     [INT] NOT NULL,
     [PARTITION_NUMBER]             [INT] NOT NULL,
     [INDEX_TYPE_DESC]              [NVARCHAR](60) NULL,
     [ALLOC_UNIT_TYPE_DESC]         [NVARCHAR](60) NULL,
     [INDEX_DEPTH]                  [TINYINT] NULL,
     [AVG_FRAGMENTATION_IN_PERCENT] [FLOAT] NULL,
     [FRAGMENT_COUNT]               [BIGINT] NULL,
     [AVG_FRAGMENT_SIZE_IN_PAGES]   [FLOAT] NULL
  )
ON [PRIMARY] 


GO
/****** Object:  Table [dbo].[INDEX_OPERATIONAL_STATS]    Script Date: 02/02/2011 13:38:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT *
               FROM   sys.objects
               WHERE  object_id = Object_id(N'[dbo].[INDEX_OPERATIONAL_STATS]')
                      AND type IN ( N'U' )) 
BEGIN
DROP TABLE [dbo].[INDEX_OPERATIONAL_STATS]
END
GO


CREATE TABLE [dbo].[INDEX_OPERATIONAL_STATS]
  (
     [STATS_TIME]                         [DATETIME] NOT NULL,
     [DATABASE_NAME]                      [NVARCHAR](128) NOT NULL,
     [OBJECT_ID]                          [INT] NOT NULL,
     [INDEX_ID]                           [INT] NOT NULL,
     [LEAF_INSERT_COUNT]                  [BIGINT] NOT NULL,
     [LEAF_DELETE_COUNT]                  [BIGINT] NOT NULL,
     [LEAF_UPDATE_COUNT]                  [BIGINT] NOT NULL,
     [LEAF_GHOST_COUNT]                   [BIGINT] NOT NULL,
     [NONLEAF_INSERT_COUNT]               [BIGINT] NOT NULL,
     [NONLEAF_DELETE_COUNT]               [BIGINT] NOT NULL,
     [NONLEAF_UPDATE_COUNT]               [BIGINT] NOT NULL,
     [LEAF_ALLOCATION_COUNT]              [BIGINT] NOT NULL,
     [NONLEAF_ALLOCATION_COUNT]           [BIGINT] NOT NULL,
     [LEAF_PAGE_MERGE_COUNT]              [BIGINT] NOT NULL,
     [NONLEAF_PAGE_MERGE_COUNT]           [BIGINT] NOT NULL,
     [RANGE_SCAN_COUNT]                   [BIGINT] NOT NULL,
     [SINGLETON_LOOKUP_COUNT]             [BIGINT] NOT NULL,
     [FORWARDED_FETCH_COUNT]              [BIGINT] NOT NULL,
     [LOB_FETCH_IN_PAGES]                 [BIGINT] NOT NULL,
     [LOB_FETCH_IN_BYTES]                 [BIGINT] NOT NULL,
     [LOB_ORPHAN_CREATE_COUNT]            [BIGINT] NOT NULL,
     [LOB_ORPHAN_INSERT_COUNT]            [BIGINT] NOT NULL,
     [ROW_OVERFLOW_FETCH_IN_PAGES]        [BIGINT] NOT NULL,
     [ROW_OVERFLOW_FETCH_IN_BYTES]        [BIGINT] NOT NULL,
     [COLUMN_VALUE_PUSH_OFF_ROW_COUNT]    [BIGINT] NOT NULL,
     [COLUMN_VALUE_PULL_IN_ROW_COUNT]     [BIGINT] NOT NULL,
     [ROW_LOCK_COUNT]                     [BIGINT] NOT NULL,
     [ROW_LOCK_WAIT_COUNT]                [BIGINT] NOT NULL,
     [ROW_LOCK_WAIT_IN_MS]                [BIGINT] NOT NULL,
     [PAGE_LOCK_COUNT]                    [BIGINT] NOT NULL,
     [PAGE_LOCK_WAIT_COUNT]               [BIGINT] NOT NULL,
     [PAGE_LOCK_WAIT_IN_MS]               [BIGINT] NOT NULL,
     [INDEX_LOCK_PROMOTION_ATTEMPT_COUNT] [BIGINT] NOT NULL,
     [INDEX_LOCK_PROMOTION_COUNT]         [BIGINT] NOT NULL,
     [PAGE_LATCH_WAIT_COUNT]              [BIGINT] NOT NULL,
     [PAGE_LATCH_WAIT_IN_MS]              [BIGINT] NOT NULL,
     [PAGE_IO_LATCH_WAIT_COUNT]           [BIGINT] NOT NULL,
     [PAGE_IO_LATCH_WAIT_IN_MS]           [BIGINT] NOT NULL
  )
ON [PRIMARY] 


GO
/****** Object:  Table [dbo].[INDEX_HISTOGRAM]    Script Date: 02/02/2011 13:38:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT *
               FROM   sys.objects
               WHERE  object_id = Object_id(N'[dbo].[INDEX_HISTOGRAM]')
                      AND type IN ( N'U' )) 
BEGIN
DROP TABLE [dbo].[INDEX_HISTOGRAM]
END
GO


CREATE TABLE [dbo].[INDEX_HISTOGRAM]
  (
     [DATABASE_NAME]       [SYSNAME] NOT NULL,
     [TABLE_NAME]          [SYSNAME] NOT NULL,
     [INDEX_NAME]          [SYSNAME] NOT NULL,
     [COLUMN_NAME]         [SYSNAME] NOT NULL,
     [RANGE_HI_KEY]        [SQL_VARIANT] NULL,
     [RANGE_ROWS]          [BIGINT] NULL,
     [EQ_ROWS]             [BIGINT] NULL,
     [DISTINCT_RANGE_ROWS] [BIGINT] NULL,
     [AVG_RANGE_ROWS]      [BIGINT] NULL
  )
ON [PRIMARY] 


GO
/****** Object:  Table [dbo].[INDEX_DETAIL]    Script Date: 02/02/2011 13:38:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT *
               FROM   sys.objects
               WHERE  object_id = Object_id(N'[dbo].[INDEX_DETAIL]')
                      AND type IN ( N'U' )) 
BEGIN
DROP TABLE [dbo].[INDEX_DETAIL]
END
GO


CREATE TABLE [dbo].[INDEX_DETAIL]
  (
     [STATS_TIME]        [DATETIME] NOT NULL,
     [DATABASE_NAME]     [NVARCHAR](128) NULL,
     [OBJECT_ID]         [INT] NULL,
     [INDEX_ID]          [INT] NULL,
     [TABLE_NAME]        [NVARCHAR](128) NULL,
     [INDEX_NAME]        [NVARCHAR](128) NULL,
     [INDEX_DESCRIPTION] [NVARCHAR](210) NULL,
     [INDEX_KEYS]        [NVARCHAR](MAX) NULL,
     [INCLUDED_COLUMNS]  [NVARCHAR](MAX) NULL,
     [PAGE_COUNT]        [BIGINT] NULL,
     [ROW_COUNT]         [BIGINT] NULL,
     [DATA_COMPRESSION]  [INT]
  )
ON [PRIMARY] 


GO
/****** Object:  Table [dbo].[INDEX_DENSITY_VECTOR]    Script Date: 02/02/2011 13:38:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT *
               FROM   sys.objects
               WHERE  object_id = Object_id(N'[dbo].[INDEX_DENSITY_VECTOR]')
                      AND type IN ( N'U' )) 
BEGIN
DROP TABLE [dbo].[INDEX_DENSITY_VECTOR]
END
GO


CREATE TABLE [dbo].[INDEX_DENSITY_VECTOR]
  (
     [DATABASE_NAME][SYSNAME] NOT NULL,
     [TABLENAME]    [SYSNAME] NOT NULL,
     [INDEXNAME]    [SYSNAME] NOT NULL,
     [DENSITY]      [FLOAT] NULL,
     [LENGTH]       [INT] NULL,
     [COLUMNS]      [NVARCHAR](MAX) NULL
  )
ON [PRIMARY] 


GO
/****** Object:  Table [dbo].[DISKSTATS]    Script Date: 02/02/2011 13:38:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
IF EXISTS (SELECT *
               FROM   sys.objects
               WHERE  object_id = Object_id(N'[dbo].[DISKSTATS]')
                      AND type IN ( N'U' )) 
BEGIN
DROP TABLE [dbo].[DISKSTATS]
END
GO


CREATE TABLE [dbo].[DISKSTATS]
  (
     [STATS_TIME]           [DATETIME] NOT NULL,
     [DATABASE_NAME]        [NVARCHAR](128) NULL,
     [DATABASE_ID]          [SMALLINT] NOT NULL,
     [FILE_ID]              [SMALLINT] NOT NULL,
     [SAMPLE_MS]            [INT] NOT NULL,
     [NUM_OF_READS]         [BIGINT] NOT NULL,
     [NUM_OF_BYTES_READ]    [BIGINT] NOT NULL,
     [IO_STALL_READ_MS]     [BIGINT] NOT NULL,
     [NUM_OF_WRITES]        [BIGINT] NOT NULL,
     [NUM_OF_BYTES_WRITTEN] [BIGINT] NOT NULL,
     [IO_STALL_WRITE_MS]    [BIGINT] NOT NULL,
     [IO_STALL]             [BIGINT] NOT NULL,
     [SIZE_ON_DISK_BYTES]   [BIGINT] NOT NULL,
     [FILE_HANDLE]          [VARBINARY](8) NOT NULL
  )
ON [PRIMARY] 

GO
USE [DynamicsPerf]
GO

/****** Object:  Table [dbo].[TRIGGER_TABLE]    Script Date: 05/10/2011 08:07:25 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TRIGGER_TABLE]') AND type in (N'U'))
DROP TABLE [dbo].[TRIGGER_TABLE]
GO

USE [DynamicsPerf]
GO

/****** Object:  Table [dbo].[TRIGGER_TABLE]    Script Date: 05/10/2011 08:07:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[TRIGGER_TABLE](
	[DATABASE_NAME] [nvarchar] (128) NOT NULL,
	[TABLE_NAME] [nvarchar](128) NOT NULL,
	[TRIGGER_NAME] [nvarchar](128) NOT NULL,
	[TRIGGER_TEXT] [nvarchar](max) NOT NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO



USE [DynamicsPerf]
GO

/****** Object:  Table [dbo].[BUFFER_DETAIL]    Script Date: 11/09/2011 13:53:35 ******/
IF EXISTS (SELECT *
           FROM   sys.objects
           WHERE  object_id = Object_id(N'[dbo].[BUFFER_DETAIL]')
                  AND type IN ( N'U' ))
  DROP TABLE [dbo].[BUFFER_DETAIL] 

GO

USE [DynamicsPerf]
GO

/****** Object:  Table [dbo].[BUFFER_DETAIL]    Script Date: 11/09/2011 13:53:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[BUFFER_DETAIL]
  (
     [RUN_NAME]      [NVARCHAR](60) NOT NULL,
     [STATS_TIME]    [DATETIME] NOT NULL,
     [DATABASE_NAME] [NVARCHAR](128) NULL,
     [SIZE_MB]       [BIGINT] NULL
  )
ON [PRIMARY] 


GO

SET ANSI_PADDING OFF
GO
GO
/****** Object:  Table [dbo].[BLOCKS]    Script Date: 02/02/2011 13:38:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
IF EXISTS (SELECT *
               FROM   sys.objects
               WHERE  object_id = Object_id(N'[dbo].[BLOCKS]')
                      AND type IN ( N'U' )) 
BEGIN
DROP TABLE [dbo].[BLOCKS]
END
GO


CREATE TABLE [dbo].[BLOCKS]
  (
     [BLOCKED_DTTM]             [DATETIME] NOT NULL,
     [BLOCKER_LOGIN]            [NVARCHAR](128) NULL,
     [BLOCKER_PROGRAM]          [NVARCHAR](128) NULL,
     [BLOCKER_HOSTNAME]         [NVARCHAR](128) NULL,
     [BLOCKED_LOGIN]            [NVARCHAR](128) NULL,
     [BLOCKED_PROGRAM]          [NVARCHAR](128) NULL,
     [BLOCKED_HOSTNAME]         [NVARCHAR](128) NULL,
     [BLOCKER_SESSION_ID]       [SMALLINT] NULL,
     [BLOCKER_CONTEXT_INFO]		[BINARY] (128) NULL,
     [BLOCKER_CONTEXT]          [NVARCHAR](MAX) NULL,
     [BLOCKER_TRAN_ISOLATION]   [VARCHAR](20) NULL,
     [BLOCKER_STATUS]           [VARCHAR](18) NULL,
     [BLOCKED_SESSION_ID]       [SMALLINT] NULL,
     [BLOCKED_CONTEXT_INFO]		[BINARY] (128) NULL,
     [BLOCKED_CONTEXT]          [NVARCHAR](MAX) NULL,
     [BLOCKED_TRAN_ISOLATION]   [VARCHAR](20) NULL,
     [TRANSACTION_ID]			[BIGINT] NULL,
     [WAIT_TIME]                [BIGINT] NULL,
     [LOCK_MODE]                [NVARCHAR](60) NULL,
     [LOCK_SIZE]                [NVARCHAR](6) NULL,
     [DATABASE_NAME]            [NVARCHAR](128) NULL,
     [ALLOW_SNAPSHOT_ISOLATION] [NVARCHAR](60) NULL,
     [READ_COMMITTED_SNAPSHOT]  [NVARCHAR](3) NULL,
     [OBJECT_NAME]              [NVARCHAR](128) NULL,
     [INDEX_ID]                 [INT] NULL,
     [BLOCKER_SQL]              [NVARCHAR](MAX) NULL,
     [BLOCKER_PLAN]             [XML] NULL,
     [BLOCKED_SQL]              [NVARCHAR](MAX) NULL,
     [BLOCKED_PLAN]             [XML] NULL
  )
ON [PRIMARY] 


GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[BLOCKED_PROCESS_INFO_SETUP]    Script Date: 02/02/2011 13:38:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT *
               FROM   sys.objects
               WHERE  object_id = Object_id(N'[dbo].[BLOCKED_PROCESS_INFO_SETUP]')
                      AND type IN ( N'U' )) 
BEGIN
DROP TABLE [dbo].[BLOCKED_PROCESS_INFO_SETUP]
END
GO


CREATE TABLE [dbo].[BLOCKED_PROCESS_INFO_SETUP]
  (
     [LAST_COLLECTION_TIME] [DATETIME] NULL
          
  )
ON [PRIMARY] 

GO

--REH put default record in
  INSERT [BLOCKED_PROCESS_INFO_SETUP] VALUES( '1/1/1900')
GO
/****** Object:  Table [dbo].[BLOCKED_PROCESS_INFO_PLANS]    Script Date: 02/02/2011 13:38:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
IF  EXISTS (SELECT *
               FROM   sys.objects
               WHERE  object_id = Object_id(N'[dbo].[BLOCKED_PROCESS_INFO_PLANS]')
                      AND type IN ( N'U' )) 
BEGIN
DROP TABLE [dbo].[BLOCKED_PROCESS_INFO_PLANS]
END
GO


--CREATE TABLE [dbo].[BLOCKED_PROCESS_INFO_PLANS]
--  (
--     [STATS_TIME]         [DATETIME] NOT NULL,
--     [TRANSACTIONID]      [BIGINT] NOT NULL,
--     [BLOCKED_SQL_HANDLE] [NVARCHAR](64) NULL,
--     [BLOCKER_SQL_HANDLE] [NVARCHAR](64) NULL,
--     [PLAN_HANDLE]        [VARBINARY](64) NOT NULL,
--     [QUERY_PLAN]         [XML] NULL
--  )
--ON [PRIMARY] 


GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[BLOCKED_PROCESS_INFO]    Script Date: 02/02/2011 13:38:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT *
               FROM   sys.objects
               WHERE  object_id = Object_id(N'[dbo].[BLOCKED_PROCESS_INFO]')
                      AND type IN ( N'U' )) 
BEGIN
DROP TABLE [dbo].[BLOCKED_PROCESS_INFO]
END
GO


CREATE TABLE [dbo].[BLOCKED_PROCESS_INFO]
  (
     [TRANSACTIONID]                 [BIGINT] NULL,
     [END_TIME]                      [DATETIME] NULL,
     [DATABASE_ID]                   [INT] NULL,
     [BLOCKED_SPID]                  [INT] NULL,
     [BLOCKED_SQL_TEXT]              [NVARCHAR](MAX) NULL,
     [WAIT_TIME]                     [INT] NULL,
     [WAIT_RESOURCE]                 [NVARCHAR](50) NULL,
     [LOCK_MODE_REQUESTED]           [NVARCHAR](50) NULL,
     [BLOCKED_TRANS_COUNT]           [INT] NULL,
     [BLOCKED_CLIENT_APP]            [NVARCHAR](50) NULL,
     [BLOCKED_HOST_NAME]             [NVARCHAR](50) NULL,
     [BLOCKED_ISOLATION_LEVEL]       [NVARCHAR](50) NULL,
     [BLOCKED_SQL_HANDLE]            [NVARCHAR](64) NULL,
     [BLOCKING_SPID]                 [INT] NULL,
     [BLOCKING_SQL_TEXT]             [NVARCHAR](MAX) NULL,
     [BLOCKING_SPID_STATUS]          [NVARCHAR](10) NULL,
     [BLOCKING_TRANS_COUNT]          [INT] NULL,
     [BLOCKING_LAST_BATCH_STARTED]   [DATETIME] NULL,
     [BLOCKING_LAST_BATCH_COMPLETED] [DATETIME] NULL,
     [BLOCKING_CLIENT_APP]           [NVARCHAR](50) NULL,
     [BLOCKING_HOST_NAME]            [NVARCHAR](50) NULL,
     [BLOCKING_ISOLATION_LEVEL]      [NVARCHAR](50) NULL,
     [BLOCKING_SQL_HANDLE]           [NVARCHAR](64) NULL
  )
ON [PRIMARY] 


GO
USE [DynamicsPerf]
GO

/****** Object:  Table [dbo].[PERF_INDEX_DETAIL]    Script Date: 03/02/2011 18:17:53 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PERF_INDEX_DETAIL]') AND type in (N'U'))
DROP TABLE [dbo].[PERF_INDEX_DETAIL]
GO

USE [DynamicsPerf]
GO

/****** Object:  Table [dbo].[PERF_INDEX_DETAIL]    Script Date: 03/02/2011 18:17:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PERF_INDEX_DETAIL](
	[STATS_TIME] [DATETIME] NOT NULL,
	[DATABASE_NAME] [NVARCHAR](128) NULL,
	[OBJECT_ID] [INT] NULL,
	[INDEX_ID] [INT] NULL,
	[TABLE_NAME] [NVARCHAR](128) NULL,
	[INDEX_NAME] [NVARCHAR](128) NULL,
	[PAGE_COUNT] [BIGINT] NULL,
	[ROW_COUNT] [BIGINT] NULL,
	[ROWS_LAST_HOUR] [BIGINT] NULL
) ON [PRIMARY]

GO

USE [DynamicsPerf]
GO

/****** Object:  Table [dbo].[INDEX_USAGE_STATS]    Script Date: 03/02/2011 18:18:49 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PERF_INDEX_USAGE_STATS]') AND type in (N'U'))
DROP TABLE [dbo].[PERF_INDEX_USAGE_STATS]
GO

USE [DynamicsPerf]
GO

/****** Object:  Table [dbo].[PERF_INDEX_USAGE_STATS]    Script Date: 03/02/2011 18:18:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PERF_INDEX_USAGE_STATS](
	[STATS_TIME] [DATETIME] NOT NULL,
	[DATABASE_NAME] [NVARCHAR](128) NOT NULL,
	[OBJECT_ID] [INT] NOT NULL,
	[INDEX_ID] [INT] NOT NULL,
	[USER_SEEKS] [BIGINT] NOT NULL,
	[USER_SCANS] [BIGINT] NOT NULL,
	[USER_LOOKUPS] [BIGINT] NOT NULL,
	[USER_UPDATES] [BIGINT] NOT NULL
) ON [PRIMARY]

GO


/****** Object:  Table [dbo].[PERF_DISKSTATS]    Script Date: 02/02/2011 13:38:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
IF EXISTS (SELECT *
               FROM   sys.objects
               WHERE  object_id = Object_id(N'[dbo].[PERF_DISKSTATS]')
                      AND type IN ( N'U' )) 
BEGIN
DROP TABLE [dbo].[PERF_DISKSTATS]
END
GO


CREATE TABLE [dbo].[PERF_DISKSTATS]
  (
     [STATS_TIME]           [DATETIME] NOT NULL,
     [DATABASE_NAME]        [NVARCHAR](128) NULL,
     [DATABASE_ID]          [SMALLINT] NOT NULL,
     [FILE_ID]              [SMALLINT] NOT NULL,
     [SAMPLE_MS]            [INT] NOT NULL,
     [NUM_OF_READS]         [BIGINT] NOT NULL,
     [NUM_OF_BYTES_READ]    [BIGINT] NOT NULL,
     [IO_STALL_READ_MS]     [BIGINT] NOT NULL,
     [NUM_OF_WRITES]        [BIGINT] NOT NULL,
     [NUM_OF_BYTES_WRITTEN] [BIGINT] NOT NULL,
     [IO_STALL_WRITE_MS]    [BIGINT] NOT NULL,
     [IO_STALL]             [BIGINT] NOT NULL,
     [SIZE_ON_DISK_BYTES]   [BIGINT] NOT NULL,
     [FILE_HANDLE]          [VARBINARY](8) NOT NULL
  )
ON [PRIMARY] 


GO
SET ANSI_PADDING OFF
GO


USE [DynamicsPerf]
GO


/****** Object:  Table [dbo].[PERF_WAIT_STATS]    Script Date: 02/02/2011 13:38:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT *
               FROM   sys.objects
               WHERE  object_id = Object_id(N'[dbo].[PERF_WAIT_STATS]')
                      AND type IN ( N'U' )) 
BEGIN
DROP TABLE [dbo].[PERF_WAIT_STATS]
END
GO
CREATE TABLE [dbo].[PERF_WAIT_STATS]
  (
     [STATS_TIME]          [SMALLDATETIME] NOT NULL,
     [WAIT_TYPE]           [NVARCHAR](60) NOT NULL,
     [WAITING_TASKS_COUNT] [BIGINT] NOT NULL,
     [WAIT_TIME_MS]        [BIGINT] NOT NULL,
     [MAX_WAIT_TIME_MS]    [BIGINT] NOT NULL,
     [SIGNAL_WAIT_TIME_MS] [BIGINT] NOT NULL
  )
ON [PRIMARY] 
GO


SET ANSI_PADDING OFF
GO

USE [DynamicsPerf]
GO

/****** Object:  Table [dbo].[SERVER_SERVICES]    Script Date: 09/08/2011 12:11:31 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SERVER_SERVICES]') AND type in (N'U'))
DROP TABLE [dbo].[SERVER_SERVICES]
GO

USE [DynamicsPerf]
GO

/****** Object:  Table [dbo].[SERVER_SERVICES]    Script Date: 09/08/2011 12:11:31 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SERVER_SERVICES](
	[SERVICENAME] [nvarchar](256) NOT NULL,
	[STARTUP] [nvarchar](256) NOT NULL,
	[STATUS] [nvarchar](256) NOT NULL,
	[PID] [int] NULL,
	[LAST_STARTUP_TIME] [datetimeoffset](7) NULL,
	[SERVICE_ACCOUNT] [nvarchar](256) NOT NULL,
	[CLUS] [nvarchar](1) NOT NULL
) ON [PRIMARY]

GO

USE [DynamicsPerf]
GO

/****** Object:  Table [dbo].[SERVER_DISKVOLUMES]    Script Date: 09/08/2011 12:14:34 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SERVER_DISKVOLUMES]') AND type in (N'U'))
DROP TABLE [dbo].[SERVER_DISKVOLUMES]
GO

USE [DynamicsPerf]
GO

/****** Object:  Table [dbo].[SERVER_DISKVOLUMES]    Script Date: 09/08/2011 12:14:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SERVER_DISKVOLUMES](
	[VOLUME_MOUNT_POINT] [nvarchar](256) NULL,
	[VOLUME_ID] [nvarchar](256) NULL,
	[LOGICAL_VOLUME_NAME] [nvarchar](256) NULL,
	[FILE_SYSTEM_TYPE] [nvarchar](256) NULL,
	[DRIVE_SIZE_MB] [bigint] NULL,
	[DRIVE_FREE_SPACE_MB] [bigint] NULL,
	[DRIVE_PERCENT_FREE] [decimal](5, 2) NULL,
	[SUPPORTS_COMPRESSION] [tinyint] NULL,
	[SUPPORTS_ALTERNATE_STREAMS] [tinyint] NULL,
	[SUPPORTS_SPARSE_FILES] [tinyint] NULL,
	[IS_READ_ONLY] [tinyint] NULL,
	[IS_COMPRESSED] [tinyint] NULL
) ON [PRIMARY]

GO


USE [DynamicsPerf]
GO

/****** Object:  Table [dbo].[SERVER_REGISTRY]    Script Date: 09/08/2011 12:19:40 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SERVER_REGISTRY]') AND type in (N'U'))
DROP TABLE [dbo].[SERVER_REGISTRY]
GO

USE [DynamicsPerf]
GO

/****** Object:  Table [dbo].[SERVER_REGISTRY]    Script Date: 09/08/2011 12:19:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SERVER_REGISTRY](
	[REGISTRY_KEY] [nvarchar](256) NULL,
	[VALUE_NAME] [nvarchar](256) NULL,
	[VALUE_DATA] [sql_variant] NULL
) ON [PRIMARY]

GO

USE [DynamicsPerf]
GO

/****** Object:  Table [dbo].[SERVER_OS_VERSION]    Script Date: 09/08/2011 13:13:40 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SERVER_OS_VERSION]') AND type in (N'U'))
DROP TABLE [dbo].[SERVER_OS_VERSION]
GO

USE [DynamicsPerf]
GO

/****** Object:  Table [dbo].[SERVER_OS_VERSION]    Script Date: 09/08/2011 13:13:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SERVER_OS_VERSION](
	[WINDOWS_RELEASE] [nvarchar](256) NOT NULL,
	[WINDOWS_SERVICE_PACK_LEVEL] [nvarchar](256) NOT NULL,
	[WINDOWS_SKU] [int] NULL,
	[OS_LANGUAGE_VERSION] [int] NOT NULL
) ON [PRIMARY]

GO

USE [DynamicsPerf]
GO

/****** Object:  Table [dbo].[CAPTURE_LOG]    Script Date: 10/19/2011 10:44:14 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CAPTURE_LOG]') AND type in (N'U'))
DROP TABLE [dbo].[CAPTURE_LOG]
GO

USE [DynamicsPerf]
GO

/****** Object:  Table [dbo].[CAPTURE_LOG]    Script Date: 10/19/2011 10:44:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CAPTURE_LOG](
	[STATS_TIME] [datetime] NOT NULL,
	[TEXT] [nvarchar](max) NOT NULL
) ON [PRIMARY]

GO


USE [DynamicsPerf]
GO

/****** Object:  Table [dbo].[COMMENTS]    Script Date: 01/20/2014 16:17:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
--REH  DO NOT EVER DROP THIS TABLE.  We want to always keep the comments. 
-- If we modify in the future then build ALTER TABLE code to manage the schema change

/****** Object:  Table [dbo].[COMMENTS]    Script Date: 5/22/2013 10:44:14 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[COMMENTS]') AND type in (N'U'))

CREATE TABLE [dbo].[COMMENTS]
  (
     [QUERY_HASH]   [BINARY](8) NOT NULL,
     [AX_ROW_NUM]   [BIGINT] NOT NULL,
     [CREATED_ON]   [SMALLDATETIME] NOT NULL,
     [MODIFIED_ON]  [SMALLDATETIME] NOT NULL,
     [CREATEDBY]    [NVARCHAR] (128) NULL,
     [MODIFIEDBY]   [NVARCHAR] (128) NULL,
     [TICKET_NUM]   [NVARCHAR](128) NULL,
     [COMPLETED]    [NVARCHAR] (1) NULL,
     [COMPLETED_ON] [SMALLDATETIME] NULL,
     [STATUS]       [NVARCHAR](max) NULL,
     [COMMENT]      [NVARCHAR](max) NOT NULL
  )
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY] 

GO

SET ANSI_PADDING OFF
GO


USE [DynamicsPerf]
GO

/****** Object:  Table [dbo].[DYNSYSINDEXES]    Script Date: 02/13/2014 09:46:50 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DYNSYSINDEXES]') AND type in (N'U'))
DROP TABLE [dbo].[DYNSYSINDEXES]
GO

USE [DynamicsPerf]
GO

/****** Object:  Table [dbo].[DYNSYSINDEXES]    Script Date: 02/13/2014 09:46:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[DYNSYSINDEXES](
	[DATABASE_NAME] [sysname] NULL,
	[OBJECT_ID] [int] NOT NULL,
	[NAME] [sysname] NULL,
	[INDEX_ID] [int] NOT NULL,
	[TYPE] [tinyint] NOT NULL,
	[TYPE_DESC] [nvarchar](60) NULL,
	[IS_UNIQUE] [bit] NULL,
	[DATA_SPACE_ID] [int] NOT NULL,
	[IGNORE_DUP_KEY] [bit] NULL,
	[IS_PRIMARY_KEY] [bit] NULL,
	[IS_UNIQUE_CONSTRAINT] [bit] NULL,
	[FILL_FACTOR] [tinyint] NOT NULL,
	[IS_PADDED] [bit] NULL,
	[IS_DISABLED] [bit] NULL,
	[IS_HYPOTHETICAL] [bit] NULL,
	[ALLOW_ROW_LOCKS] [bit] NULL,
	[ALLOW_PAGE_LOCKS] [bit] NULL,
	[HAS_FILTER] [bit] NULL,
	[FILTER_DEFINITION] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO


USE [DynamicsPerf]
GO

/****** Object:  Table [dbo].[DYNSYSOBJECTS]    Script Date: 02/13/2014 09:46:56 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DYNSYSOBJECTS]') AND type in (N'U'))
DROP TABLE [dbo].[DYNSYSOBJECTS]
GO

USE [DynamicsPerf]
GO

/****** Object:  Table [dbo].[DYNSYSOBJECTS]    Script Date: 02/13/2014 09:46:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[DYNSYSOBJECTS](
	[DATABASE_NAME] [sysname] NULL,
	[NAME] [sysname] NOT NULL,
	[OBJECT_ID] [int] NOT NULL,
	[PRINCIPAL_ID] [int] NULL,
	[SCHEMA_ID] [int] NOT NULL,
	[PARENT_OBJECT_ID] [int] NOT NULL,
	[TYPE] [char](2) NOT NULL,
	[TYPE_DESC] [nvarchar](60) NULL,
	[CREATE_DATE] [datetime] NOT NULL,
	[MODIFY_DATE] [datetime] NOT NULL,
	[IS_MS_SHIPPED] [bit] NOT NULL,
	[IS_PUBLISHED] [bit] NOT NULL,
	[IS_SCHEMA_PUBLISHED] [bit] NOT NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

USE [DynamicsPerf]
GO

/****** Object:  Table [dbo].[DYNSYSPARTITIONS]    Script Date: 02/13/2014 09:47:09 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DYNSYSPARTITIONS]') AND type in (N'U'))
DROP TABLE [dbo].[DYNSYSPARTITIONS]
GO

USE [DynamicsPerf]
GO

/****** Object:  Table [dbo].[DYNSYSPARTITIONS]    Script Date: 02/13/2014 09:47:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[DYNSYSPARTITIONS](
	[DATABASE_NAME] [sysname] NULL,
	[PARTITION_ID] [bigint] NOT NULL,
	[OBJECT_ID] [int] NOT NULL,
	[INDEX_ID] [int] NOT NULL,
	[PARTITION_NUMBER] [int] NOT NULL,
	[HOBT_ID] [bigint] NOT NULL,
	[ROWS] [bigint] NOT NULL,
	[FILESTREAM_FILEGROUP_ID] [smallint] NOT NULL,
	[DATA_COMPRESSION] [tinyint] NOT NULL,
	[DATA_COMPRESSION_DESC] [nvarchar](60) NULL
) ON [PRIMARY]

GO





/****************************  END OF CREATE TABLES **************************************/

/*************************** START OF INDEXES ********************************************/



/****** Object:  Index [IX_DYNSYSOBJECTS_CLUS]    Script Date: 02/13/2014 09:51:56 ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[DYNSYSOBJECTS]') AND name = N'IX_DYNSYSOBJECTS_CLUS')
DROP INDEX [IX_DYNSYSOBJECTS_CLUS] ON [dbo].[DYNSYSOBJECTS] WITH ( ONLINE = OFF )
GO


/****** Object:  Index [IX_DYNSYSOBJECTS_CLUS]    Script Date: 02/13/2014 09:51:56 ******/
CREATE CLUSTERED INDEX [IX_DYNSYSOBJECTS_CLUS] ON [dbo].[DYNSYSOBJECTS] 
(
	[DATABASE_NAME] ASC,
	[OBJECT_ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO


/****** Object:  Index [IX_DYNSYSINDEXES_CLUS]    Script Date: 02/13/2014 09:56:14 ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[DYNSYSINDEXES]') AND name = N'IX_DYNSYSINDEXES_CLUS')
DROP INDEX [IX_DYNSYSINDEXES_CLUS] ON [dbo].[DYNSYSINDEXES] WITH ( ONLINE = OFF )
GO


/****** Object:  Index [IX_DYNSYSINDEXES_CLUS]    Script Date: 02/13/2014 09:56:14 ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_DYNSYSINDEXES_CLUS] ON [dbo].[DYNSYSINDEXES] 
(
	[DATABASE_NAME] ASC,
	[OBJECT_ID] ASC,
	[INDEX_ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

USE [DynamicsPerf]
GO

/****** Object:  Index [IX_DYNSYSPARTITIONS_CLUS]    Script Date: 02/13/2014 09:58:02 ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[DYNSYSPARTITIONS]') AND name = N'IX_DYNSYSPARTITIONS_CLUS')
DROP INDEX [IX_DYNSYSPARTITIONS_CLUS] ON [dbo].[DYNSYSPARTITIONS] WITH ( ONLINE = OFF )
GO

USE [DynamicsPerf]
GO

/****** Object:  Index [IX_DYNSYSPARTITIONS_CLUS]    Script Date: 02/13/2014 09:58:03 ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_DYNSYSPARTITIONS_CLUS] ON [dbo].[DYNSYSPARTITIONS] 
(
	[DATABASE_NAME] ASC,
	[OBJECT_ID] ASC,
	[INDEX_ID] ASC,
	[PARTITION_ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO



/****** Object:  Index [PK_CAPTURE_LOG]    Script Date: 10/19/2011 10:45:59 ******/
CREATE UNIQUE CLUSTERED INDEX [PK_CAPTURE_LOG] ON [dbo].[CAPTURE_LOG] 
(
	[STATS_TIME] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]


/****** Object:  Index [PK_COMMENTS]    Script Date: 01/20/2014 16:27:18 ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[COMMENTS]') AND name = N'PK_COMMENTS')
DROP INDEX [PK_COMMENTS] ON [dbo].[COMMENTS] WITH ( ONLINE = OFF )
GO


/****** Object:  Index [PK_COMMENTS]    Script Date: 01/20/2014 16:27:18 ******/
CREATE CLUSTERED INDEX [PK_COMMENTS] ON [dbo].[COMMENTS] 
(
	[QUERY_HASH] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

/****** Object:  Index [NC1_COMMENTS]    Script Date: 01/20/2014 16:27:18 ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[COMMENTS]') AND name = N'NC1_COMMENTS')
DROP INDEX [NC1_COMMENTS] ON [dbo].[COMMENTS] WITH ( ONLINE = OFF )
GO


/****** Object:  Index [NC1_COMMENTS]    Script Date: 01/20/2014 16:27:18 ******/
CREATE  NONCLUSTERED INDEX [NC1_COMMENTS] ON [dbo].[COMMENTS] 
(
	[AX_ROW_NUM] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO


/****** Object:  Index [IX_INDEX_DETAIL]    Script Date: 08/27/2009 09:47:24 ******/
CREATE CLUSTERED INDEX [IX_INDEX_DETAIL]
  ON [dbo].[INDEX_DETAIL] ( [STATS_TIME] ASC, [DATABASE_NAME] ASC, [TABLE_NAME] ASC, [INDEX_NAME] ASC )
  WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]


CREATE CLUSTERED INDEX IX_OPERATIONAL_STATS
  ON INDEX_OPERATIONAL_STATS ( STATS_TIME ASC, DATABASE_NAME ASC, OBJECT_ID ASC, INDEX_ID ASC )
  WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)

CREATE CLUSTERED INDEX IX_INDEX_PHYSICAL_STATS
  ON INDEX_PHYSICAL_STATS ( STATS_TIME ASC, DATABASE_NAME ASC, OBJECT_ID ASC, INDEX_ID ASC, PARTITION_NUMBER ASC )
  WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)

CREATE UNIQUE CLUSTERED INDEX IX_INDEX_USAGE_STATS
  ON INDEX_USAGE_STATS ( STATS_TIME ASC, DATABASE_NAME ASC, OBJECT_ID ASC, INDEX_ID ASC )
  WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)


CREATE NONCLUSTERED INDEX IX_QUERY_PLANS_HASH
  ON QUERY_PLANS ( QUERY_PLAN_HASH ASC)
  WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)

 CREATE NONCLUSTERED INDEX IX_QUERY_MI_FLAG_PLAN_HANDLE
  ON QUERY_PLANS ( MI_FLAG ASC, QUERY_PLAN_HASH ASC )
  WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
  
 


CREATE UNIQUE CLUSTERED INDEX IX_QUERY_TEXT
  ON QUERY_TEXT ( QUERY_HASH ASC  )
  WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)

CREATE CLUSTERED INDEX IX_QUERY_STATS
  ON QUERY_STATS ( STATS_TIME ASC, DATABASE_NAME ASC, PLAN_HANDLE ASC )
  WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)

CREATE NONCLUSTERED INDEX IX_QUERY_STATS_PLAN_HASH
  ON QUERY_STATS ( STATS_TIME ASC, QUERY_PLAN_HASH ASC,  PLAN_HANDLE_INTERNAL ASC, QUERY_HASH ASC )
  WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)

CREATE NONCLUSTERED INDEX IX_QUERY_STATS_PLAN_HASH2
  ON QUERY_STATS ( PLAN_HANDLE_INTERNAL ASC, QUERY_PLAN_HASH ASC, STATS_TIME ASC, QUERY_HASH ASC )
  WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)


CREATE NONCLUSTERED INDEX [IX_QUERY_STATS_HASH] ON [dbo].[QUERY_STATS] 
(
		[QUERY_HASH] ASC,
		[STATS_TIME] ASC,
		[LAST_EXECUTION_TIME] ASC

)
 WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]


 CREATE UNIQUE CLUSTERED INDEX IX_STATS_COLLECTION_SUMMARY
  ON STATS_COLLECTION_SUMMARY ( RUN_NAME ASC, DATABASE_NAME ASC )
  WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)

 
CREATE  CLUSTERED INDEX IX_BUFFER_DETAIL
  ON BUFFER_DETAIL ( STATS_TIME ASC, DATABASE_NAME ASC )
  WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)

 
CREATE CLUSTERED INDEX IX_SQL_CONFIGS
  ON [SQL_CONFIGURATION] (  RUN_NAME ASC, STATS_TIME ASC  )
  WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)

 
CREATE CLUSTERED INDEX IX_SQL_DBS
  ON [SQL_DATABASES] ( RUN_NAME ASC, STATS_TIME ASC )
  WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)



CREATE CLUSTERED INDEX IX_SQL_DBFILES
  ON [SQL_DATABASEFILES] ( RUN_NAME ASC, STATS_TIME ASC )
  WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)

 
CREATE CLUSTERED INDEX IX_SQL_JOBS
  ON [SQL_JOBS] ( RUN_NAME ASC, STATS_TIME ASC )
  WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)

 
CREATE CLUSTERED INDEX [BLOCKS0]
  ON [dbo].[BLOCKS] ([BLOCKED_DTTM])
  WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  


CREATE NONCLUSTERED INDEX [BLOCKS1]
  ON [dbo].[BLOCKS] ( [BLOCKER_PROGRAM] ASC, [WAIT_TIME] ASC, [BLOCKER_STATUS] ASC )
  WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]



CREATE NONCLUSTERED INDEX [BLOCKS2]
  ON [dbo].[BLOCKS] ( [BLOCKED_PROGRAM] ASC, [WAIT_TIME] ASC, [BLOCKER_STATUS] ASC )
  WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]


CREATE NONCLUSTERED INDEX [BLOCKS3]
  ON [dbo].[BLOCKS] ( [DATABASE_NAME] ASC, [WAIT_TIME] ASC )
  WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]


CREATE NONCLUSTERED INDEX [BLOCKS4]
  ON [dbo].[BLOCKS] ( [OBJECT_NAME] ASC, [WAIT_TIME] ASC )
  WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]


/****** Object:  Index [IX_PERF_DISKSTATS_CLUSTER]    Script Date: 04/01/2011 07:43:38 ******/
CREATE CLUSTERED INDEX [IX_PERF_DISKSTATS_CLUSTER] ON [dbo].[PERF_DISKSTATS] 
(
	[STATS_TIME] ASC,
	[DATABASE_NAME] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]


/****** Object:  Index [IX_PERF_INDEX_DETAIL_CLUSTER]    Script Date: 04/01/2011 07:45:10 ******/
CREATE CLUSTERED INDEX [IX_PERF_INDEX_DETAIL_CLUSTER] ON [dbo].[PERF_INDEX_DETAIL] 
(
	[STATS_TIME] ASC,
	[DATABASE_NAME] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]

GO


/****** Object:  Index [PERF_IX99]    Script Date: 11/12/2012 14:22:16 ******/
CREATE NONCLUSTERED INDEX [PERF_IX99] ON [dbo].[PERF_INDEX_DETAIL] 
(
	[INDEX_ID] ASC,
	[ROW_COUNT] ASC
)
INCLUDE ( [STATS_TIME],
[DATABASE_NAME],
[OBJECT_ID]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE NONCLUSTERED INDEX IX_PERF_INDEX_DETAIL_NC1
  ON PERF_INDEX_DETAIL (ROW_COUNT, INDEX_ID, OBJECT_ID, DATABASE_NAME, STATS_TIME )

WHERE INDEX_ID <= 1 


GO
 
CREATE NONCLUSTERED INDEX [IX_PERF_INDEX_DETAIL_NC2]
  ON [dbo].[PERF_INDEX_DETAIL] ([INDEX_ID], [OBJECT_ID], [DATABASE_NAME], [STATS_TIME])
  INCLUDE ([ROW_COUNT]) 


GO

/****** Object:  Index [IX_PERF_INDEX_USAGE_STATS_CLUSTER]    Script Date: 04/01/2011 07:46:06 ******/
CREATE CLUSTERED INDEX [IX_PERF_INDEX_USAGE_STATS_CLUSTER] ON [dbo].[PERF_INDEX_USAGE_STATS] 
(
	[STATS_TIME] ASC,
	[DATABASE_NAME] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]


/****** Object:  Index [IX_PERF_WAIT_STATS_CLUSTER]    Script Date: 04/01/2011 07:47:16 ******/
CREATE CLUSTERED INDEX [IX_PERF_WAIT_STATS_CLUSTER] ON [dbo].[PERF_WAIT_STATS] 
(
	[STATS_TIME] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

/****** Object:  Index [IX_SQLErrorLog_CLUSTER]    Script Date: 04/01/2011 07:47:16 ******/
CREATE CLUSTERED INDEX IX_SQLErrorLog_CLUSTER ON [dbo].[SQLErrorLog] 
(
	[LOGDATE] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

/****** Object:  Index [IX_INDEX_HISTOGRAM_CLUSTER]    Script Date: 04/01/2011 07:47:16 ******/
CREATE CLUSTERED INDEX IX_INDEX_HISTOGRAM_CLUSTER ON [dbo].[INDEX_HISTOGRAM] 
(
	[TABLE_NAME] ASC,
	[COLUMN_NAME] ASC,
	[DATABASE_NAME] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
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
			
			--Need page compression on this table to get maximum space savings
			IF @TABLE_NAME = 'SQLErrorLog'
			BEGIN
			SELECT @SQL = 'ALTER INDEX ' + @INDEX_NAME + ' ON ' + @TABLE_NAME + 
			' REBUILD WITH (DATA_COMPRESSION = PAGE)'
			END
			ELSE
			BEGIN
			SELECT @SQL = 'ALTER INDEX ' + @INDEX_NAME + ' ON ' + @TABLE_NAME + 
			' REBUILD WITH (DATA_COMPRESSION = ROW)'
			END
			
			EXEC (@SQL)
			
			FETCH NEXT FROM INDEXCURSOR INTO @INDEX_NAME,@TABLE_NAME
			END
			
			CLOSE INDEXCURSOR
			DEALLOCATE INDEXCURSOR
			
			
			--REH Compress the QUERY_PLANS table that we removed the clustered index on
			ALTER TABLE dbo.QUERY_PLANS  REBUILD WITH ( DATA_COMPRESSION = ROW )
END






/*************************** END OF INDEXES ********************************************/

/************************** START OF TRIGGERS ******************************************/

USE [DynamicsPerf]
GO

/****** Object:  Trigger [BLOCKED_PROCESS_INFO_TRIGGER]    Script Date: 01/05/2011 16:28:38 ******/
IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[BLOCKED_PROCESS_INFO_TRIGGER]'))
DROP TRIGGER [dbo].[BLOCKED_PROCESS_INFO_TRIGGER]
GO

--USE [DynamicsPerf]
--GO

--/****** Object:  Trigger [dbo].[BLOCKED_PROCESS_INFO_TRIGGER]    Script Date: 01/05/2011 16:28:38 ******/
--SET ANSI_NULLS ON
--GO

--SET QUOTED_IDENTIFIER ON
--GO

---- =============================================
---- Author:		<Author,,Name>
---- Create date: <Create Date,,>
---- Description:	<Description,,>
---- =============================================
--CREATE TRIGGER [dbo].[BLOCKED_PROCESS_INFO_TRIGGER] 
--   ON  [dbo].[BLOCKED_PROCESS_INFO]
--   AFTER  INSERT
--AS 
--BEGIN
--	-- SET NOCOUNT ON added to prevent extra result sets from
--	-- interfering with SELECT statements.
--	SET NOCOUNT ON;
--	INSERT INTO BLOCKED_PROCESS_INFO_PLANS
--	SELECT GETDATE(),inserted.TRANSACTIONID, inserted.BLOCKED_SQL_HANDLE, '', --blocker sql handle,
--	BLOCKEDSSTATS.plan_handle, XMLPLAN.query_plan
--	FROM inserted 
	
--		INNER JOIN  sys.dm_exec_query_stats AS BLOCKEDSSTATS ON inserted.BLOCKED_SQL_HANDLE = BLOCKEDSSTATS.sql_handle 
--	    OUTER APPLY sys.dm_exec_query_plan(BLOCKEDSSTATS.plan_handle) AS XMLPLAN

--    -- Insert statements for trigger here

--END

GO

USE [DynamicsPerf]
GO

/****** Object:  Trigger [Calc_Rows_Added]    Script Date: 3/20/2014 3:44:57 PM ******/
IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[CALC_ROWS_ADDED]'))
DROP TRIGGER [dbo].[CALC_ROWS_ADDED]
GO

/****** Object:  Trigger [dbo].[Calc_Rows_Added]    Script Date: 3/20/2014 3:44:57 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[CALC_ROWS_ADDED] 
   ON  [dbo].[PERF_INDEX_DETAIL] 
   FOR INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
UPDATE PID
SET ROWS_LAST_HOUR = PID.ROW_COUNT - ISNULL(
                              (SELECT TOP 1 ROW_COUNT
                               FROM PERF_INDEX_DETAIL PID2
                               WHERE PID.DATABASE_NAME = PID2.DATABASE_NAME
                                 AND PID.OBJECT_ID = PID2.OBJECT_ID
								 AND PID.INDEX_ID = PID2.INDEX_ID
                                 AND PID2.STATS_TIME < PID.STATS_TIME
                               ORDER BY PID2.STATS_TIME DESC),0)
FROM PERF_INDEX_DETAIL PID
INNER JOIN INSERTED I ON PID.STATS_TIME = I.STATS_TIME
AND PID.DATABASE_NAME = I.DATABASE_NAME
AND PID.OBJECT_ID = I.OBJECT_ID



    -- Insert statements for trigger here

END

GO



/**************************** END OF TRIGGERS ********************************************************/



/*************************** START OF STORED PROCEDURES *********************************/

USE [DynamicsPerf]
GO

/****** Object:  StoredProcedure [dbo].[SP_LOGBLOCKS_MS]    Script Date: 02/28/2011 12:22:04 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SP_LOGBLOCKS_MS]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SP_LOGBLOCKS_MS]
GO

USE [DynamicsPerf]
GO

/****** Object:  StoredProcedure [dbo].[SP_LOGBLOCKS_MS]    Script Date: 02/28/2011 12:22:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_LOGBLOCKS_MS]
AS


SET nocount ON
SET DATEFORMAT MDY 


-- ***********************************************************************
-- Copyright © Microsoft Corporation.  All rights reserved. 
-- This script is made available to you without any express, implied or statutory warranty, 
-- not even the implied warranty of merchantability or fitness for a particular purpose, 
-- or the warranty of title or non-infringement.  
-- The entire risk of the use or the results from the use of this script remains with you.
-- ***********************************************************************

DECLARE @BLOCKED TABLE(
  BLOCKER_LOGIN          NVARCHAR(128),
  BLOCKER_PROGRAM        NVARCHAR(128),
  BLOCKER_HOSTNAME       NVARCHAR(128),
  BLOCKED_LOGIN          NVARCHAR(128),
  BLOCKED_PROGRAM        NVARCHAR(128),
  BLOCKED_HOSTNAME       NVARCHAR(128),
  BLOCKER_SESSION_ID     SMALLINT,
  BLOCKER_CONTEXT_INFO	 BINARY (128),
  BLOCKER_CONTEXT        NVARCHAR(MAX),
  BLOCKER_TRAN_ISOLATION NVARCHAR(20),
  BLOCKER_STATUS         NVARCHAR(18),
  BLOCKED_SESSION_ID     SMALLINT,
  BLOCKED_CONTEXT_INFO	 BINARY(128),
  BLOCKED_CONTEXT        NVARCHAR(MAX),
  BLOCKED_TRAN_ISOLATION NVARCHAR(20),
  TRANSACTION_ID		 BIGINT,
  WAIT_TIME              BIGINT,
  LOCK_MODE              NVARCHAR(60),
  LOCK_SIZE              NVARCHAR(6),
  DATABASE_NAME          NVARCHAR(128),
  OBJECT_NAME            NVARCHAR(128),
  INDEX_ID               INT,
  BLOCKER_SQL            NVARCHAR(MAX),
  BLOCKER_PLAN           XML,
  BLOCKED_SQL            NVARCHAR(MAX),
  BLOCKED_PLAN           XML ) 


DECLARE @BLOCKER_SESSION_ID     SMALLINT,
        @BLOCKER_CONTEXT        NVARCHAR(MAX),
        @BLOCKER_CONTEXT_INFO	BINARY(128),
        @BLOCKER_TRAN_ISOLATION NVARCHAR(20),
        @BLOCKER_STATUS         NVARCHAR(18),
        @BLOCKED_SESSION_ID     SMALLINT,
        @BLOCKED_CONTEXT        NVARCHAR(MAX),
        @BLOCKED_CONTEXT_INFO	BINARY(128),
        @BLOCKED_TRAN_ISOLATION NVARCHAR(20),
        @WAITTIME               BIGINT,
        @LOCK_MODE              NVARCHAR(60),
        @LOCK_SIZE              CHAR(6),
        @DATABASE_NAME          NVARCHAR(128),
        @ASSOCIATEDOBJECTID     BIGINT,
        @OBJECT_NAME            NVARCHAR(128),
        @INDEX_ID               INT,
        @BLOCKER_SQL            NVARCHAR(MAX),
        @BLOCKER_PLAN           XML,
        @BLOCKED_SQL            NVARCHAR(MAX),
        @BLOCKED_PLAN           XML,
        @SQL                    NVARCHAR(4000),
        @PARM                   NVARCHAR(500),
        @BLOCKED_LOGIN          NVARCHAR(128),
        @BLOCKED_PROGRAM        NVARCHAR(128),
        @BLOCKED_HOSTNAME       NVARCHAR(128),
        @BLOCKER_LOGIN          NVARCHAR(128),
        @BLOCKER_PROGRAM        NVARCHAR(128),
        @BLOCKER_HOSTNAME       NVARCHAR(128),
        @TRANSACTION_ID			BIGINT,
        @rows                   BIGINT 



SET NOCOUNT ON
SET DATEFORMAT MDY
--	-------------------------------------------------------------------------------------
--	Populate temporary table #BLOCKED from sysindexes for blocked and blocking processes
--	-------------------------------------------------------------------------------------
DECLARE BLOCKED CURSOR FOR
SELECT WAIT.blocking_session_id,
       WAIT.session_id,
       Rtrim(CONVERT(NVARCHAR(MAX), BLOCKED.context_info)),
       CASE BLOCKED.transaction_isolation_level
         WHEN 1 THEN 'Read Uncommitted'
         WHEN 2 THEN 'Read Committed'
         WHEN 3 THEN 'Repeatable Read'
         WHEN 4 THEN 'Serializable'
         WHEN 5 THEN 'Snapshot'
         ELSE Str(BLOCKED.transaction_isolation_level)
       END,
       WAIT.wait_duration_ms,
       WAIT.wait_type,
       CASE
         WHEN resource_description LIKE 'objectlock%' THEN 'Object'
         WHEN resource_description LIKE 'pagelock%' THEN 'Page'
         WHEN resource_description LIKE 'keylock%' THEN 'Key'
         WHEN resource_description LIKE 'ridlock%' THEN 'Row'
         ELSE 'N/A'
       END,
       Db_name(BLOCKED.database_id),
       CASE
         WHEN resource_description LIKE '%associatedObjectId%' THEN CONVERT(BIGINT, Substring (resource_description, Charindex('associatedObjectId=', resource_description)
                                                                                                                     + 19, ( Len(resource_description) + 1 ) - ( Charindex('associatedObjectId=', resource_description)
                                                                                                                                                                 + 19 )))
         ELSE 0
       END,
       BLOCKEDSQL.text,
       BLOCKEDPLAN.query_plan,
       BLOCKED.transaction_id
FROM   sys.dm_os_waiting_tasks WAIT
       INNER LOOP JOIN sys.dm_exec_requests AS BLOCKED
                    ON WAIT.session_id = BLOCKED.session_id
       OUTER APPLY sys.dm_exec_sql_text(BLOCKED.sql_handle) AS BLOCKEDSQL
       OUTER APPLY sys.dm_exec_query_plan(BLOCKED.plan_handle) AS BLOCKEDPLAN
WHERE  WAIT.wait_type LIKE 'LCK%' 


--AND			database_id = db_id()


OPEN BLOCKED

FETCH BLOCKED INTO 
	@BLOCKER_SESSION_ID		,
	@BLOCKED_SESSION_ID		,
	@BLOCKED_CONTEXT		, 
	@BLOCKED_TRAN_ISOLATION		,
	@WAITTIME				,
	@LOCK_MODE				,
	@LOCK_SIZE				,
	@DATABASE_NAME			,
	@ASSOCIATEDOBJECTID		,
	@BLOCKED_SQL			,
	@BLOCKED_PLAN			,
	@TRANSACTION_ID		

WHILE @@FETCH_STATUS = 0
	BEGIN
		IF EXISTS (SELECT * FROM sys.dm_exec_requests where session_id = @BLOCKER_SESSION_ID)
			
			BEGIN
				SELECT @BLOCKER_CONTEXT = '; Waiting on ' + wait_type,
                       @BLOCKER_TRAN_ISOLATION = CASE transaction_isolation_level
                                                   WHEN 1 THEN 'Read Uncommitted'
                                                   WHEN 2 THEN 'Read Committed'
                                                   WHEN 3 THEN 'Repeatable Read'
                                                   WHEN 4 THEN 'Serializable'
                                                   WHEN 5 THEN 'Snapshot'
                                                   ELSE Str(transaction_isolation_level)
                                                 END,
                       --	-------------------------------------------------------------------------------------
                       --	If blocking process is not waiting on a lock, it is a lead blocker
                       --	-------------------------------------------------------------------------------------
                       @BLOCKER_STATUS = CASE
                                           WHEN blocking_session_id = 0 THEN 'Lead Blocker'
                                           WHEN REQUESTS.session_id = blocking_session_id THEN 'Lead Blocker'
                                           ELSE 'In Blocking Chain'
                                         END,
                       @BLOCKER_SQL = BLOCKERSQL.text,
                       @BLOCKER_PLAN = query_plan
                FROM   sys.dm_exec_requests AS REQUESTS
                       OUTER APPLY sys.dm_exec_sql_text(sql_handle) AS BLOCKERSQL
                       OUTER APPLY sys.dm_exec_query_plan(plan_handle)
                WHERE  REQUESTS.session_id = @BLOCKER_SESSION_ID 
                
		END
	ELSE IF EXISTS (SELECT * FROM  sys.dm_exec_connections WHERE session_id = @BLOCKER_SESSION_ID)
--	-------------------------------------------------------------------------------------
--	If blocker does not have an active request, retrieve most recent information from
--      sys.dm_exec_connections.  
--	SQL txt is via sys.dm_exec_connections.most_recent_sql_handle
--	and the query plan via sys.dm_exec_query_stats.plan_handle
--	-------------------------------------------------------------------------------------
		BEGIN
			SELECT @BLOCKER_CONTEXT = '',
				   @BLOCKER_TRAN_ISOLATION = 'n/a',
				   @BLOCKER_STATUS = 'Lead Blocker',
				   @BLOCKER_SQL = text,
				   @BLOCKER_PLAN = query_plan
			FROM   sys.dm_exec_connections AS CONNECTIONS
				   OUTER APPLY sys.dm_exec_sql_text(CONNECTIONS.most_recent_sql_handle)
				   LEFT JOIN sys.dm_exec_query_stats AS QUERYSTATS
						  ON most_recent_sql_handle = sql_handle
				   OUTER APPLY sys.dm_exec_query_plan(QUERYSTATS.plan_handle)
			WHERE  session_id = @BLOCKER_SESSION_ID 


--	-------------------------------------------------------------------------------------
--	Retrieve blocker's session INFORMATION
--	-------------------------------------------------------------------------------------
			SELECT
			--	@BLOCKER_CONTEXT = '',
			@BLOCKER_TRAN_ISOLATION = CASE transaction_isolation_level
										WHEN 1 THEN 'Read Uncommitted'
										WHEN 2 THEN 'Read Committed'
										WHEN 3 THEN 'Repeatable Read'
										WHEN 4 THEN 'Serializable'
										WHEN 5 THEN 'Snapshot'
										ELSE Str(transaction_isolation_level)
									  END,
			@BLOCKER_LOGIN = login_name,
			@BLOCKER_PROGRAM = program_name,
			@BLOCKER_HOSTNAME = host_name
			FROM   sys.dm_exec_sessions
			WHERE  session_id = @BLOCKER_SESSION_ID 

		END
		
--	-------------------------------------------------------------------------------------
--	Determine User INformation 
--	-------------------------------------------------------------------------------------

			SELECT @BLOCKER_LOGIN = login_name,
				   @BLOCKER_PROGRAM = program_name,
				   @BLOCKER_HOSTNAME = host_name,
				   @BLOCKER_CONTEXT_INFO = context_info 
			FROM   sys.dm_exec_sessions
			WHERE  session_id = @BLOCKER_SESSION_ID

			SELECT @BLOCKED_LOGIN = login_name,
				   @BLOCKED_PROGRAM = program_name,
				   @BLOCKED_HOSTNAME = host_name,
				   @BLOCKED_CONTEXT_INFO = context_info
			FROM   sys.dm_exec_sessions
			WHERE  session_id = @BLOCKED_SESSION_ID 
			

			

		
--	-------------------------------------------------------------------------------------
--	Determine Object ID of lock request
--	-------------------------------------------------------------------------------------


	IF @LOCK_SIZE IN('Row','Key','Page')
		 BEGIN
			SET @SQL=	'USE ['+ @DATABASE_NAME + '] SELECT @OBJECT_NAME_OUT = OBJECT_NAME(object_id),@INDEX_ID_OUT = index_id, @rows_out = 0	FROM '+
						@DATABASE_NAME+
						'.sys.partitions PAR with (NOLOCK)  JOIN ' +@DATABASE_NAME+ + '.sys.sysobjects OBJ ON OBJ.ID = PAR.OBJECT_ID	WHERE partition_id = ' + cast(@ASSOCIATEDOBJECTID as varchar(MAX))
			SET	@PARM = '@OBJECT_NAME_OUT NVARCHAR(128) OUTPUT, @INDEX_ID_OUT INT OUTPUT,@rows_out bigint OUTPUT'

			EXEC sp_executesql	@SQL, 
								@PARM,
								@OBJECT_NAME_OUT    = @OBJECT_NAME OUTPUT,
								@INDEX_ID_OUT = @INDEX_ID OUTPUT,
								@rows_out = @rows OUTPUT
								
								--print @SQL
		END
	ELSE
		BEGIN
			SET @SQL=	'USE ['+ @DATABASE_NAME + '] SELECT @OBJECT_NAME_OUT  = name,@INDEX_ID_OUT = 0, @rows_out = 0	FROM '+
						@DATABASE_NAME+
						'.sys.objects with (NOLOCK)	WHERE object_id = '+ cast(@ASSOCIATEDOBJECTID as varchar(MAX))
			SET	@PARM = '@OBJECT_NAME_OUT NVARCHAR(128) OUTPUT, @INDEX_ID_OUT INT OUTPUT, @rows_out BIGINT OUTPUT'

			EXEC sp_executesql	@SQL, 
								@PARM,
								@OBJECT_NAME_OUT    = @OBJECT_NAME OUTPUT,
								@INDEX_ID_OUT		= @INDEX_ID OUTPUT,
								@rows_out = @rows OUTPUT
		END
		
		--print @SQL
--	-------------------------------------------------------------------------------------

		INSERT INTO @BLOCKED VALUES (
			@BLOCKER_LOGIN			,
			@BLOCKER_PROGRAM		,
			@BLOCKER_HOSTNAME		,
			@BLOCKED_LOGIN			,
			@BLOCKED_PROGRAM		,
			@BLOCKED_HOSTNAME		,
			@BLOCKER_SESSION_ID		,
			@BLOCKER_CONTEXT_INFO   ,
			@BLOCKER_CONTEXT		,
			@BLOCKER_TRAN_ISOLATION	,
			@BLOCKER_STATUS			,
			@BLOCKED_SESSION_ID		,
			@BLOCKED_CONTEXT_INFO   ,
			@BLOCKED_CONTEXT		,
			@BLOCKED_TRAN_ISOLATION	,
			@TRANSACTION_ID			,
			@WAITTIME				,
			@LOCK_MODE				,
			@LOCK_SIZE				,
			@DATABASE_NAME			,
			@OBJECT_NAME			,
			@INDEX_ID				,
			@BLOCKER_SQL			,
			@BLOCKER_PLAN			,
			@BLOCKED_SQL			,
			@BLOCKED_PLAN			)

	FETCH BLOCKED INTO 
		@BLOCKER_SESSION_ID		,
		@BLOCKED_SESSION_ID		,
		@BLOCKED_CONTEXT		, 
		@BLOCKED_TRAN_ISOLATION		,
		@WAITTIME				,
		@LOCK_MODE				,
		@LOCK_SIZE				,
		@DATABASE_NAME			,
		@ASSOCIATEDOBJECTID		,
		@BLOCKED_SQL			,
		@BLOCKED_PLAN			,
		@TRANSACTION_ID	
			
	END

DEALLOCATE BLOCKED;

--print @ASSOCIATEDOBJECTID


SELECT 
	GETDATE() AS BLOCKED_DTTM,
	BLOCKER_LOGIN			,
	BLOCKER_PROGRAM		,
	BLOCKER_HOSTNAME		,
	BLOCKED_LOGIN			,
	BLOCKED_PROGRAM		,
	BLOCKED_HOSTNAME		,
	BLOCKER_SESSION_ID		,
	BLOCKER_CONTEXT_INFO	,
	BLOCKER_CONTEXT	=
		CASE
				WHEN BLOCKER_CURSORS.properties IS NULL THEN BLOCKER_CONTEXT
				ELSE BLOCKER_CURSORS.properties+'; Dormant for '+ltrim(str(BLOCKER_CURSORS.dormant_duration))+' milleseconds'+BLOCKER_CONTEXT
		END,
	BLOCKER_TRAN_ISOLATION	,
	BLOCKER_STATUS			,
	BLOCKED_SESSION_ID		,
	BLOCKED_CONTEXT_INFO	,
	BLOCKED_CONTEXT			=
		CASE
				WHEN BLOCKED_CURSORS.properties IS NULL THEN BLOCKED_CONTEXT
				ELSE BLOCKED_CURSORS.properties+'; Dormant for '+ltrim(str(BLOCKED_CURSORS.dormant_duration))+' milleseconds'+BLOCKED_CONTEXT
		END,
	BLOCKED_TRAN_ISOLATION	,
	TRANSACTION_ID			,
	WAIT_TIME				,
	LOCK_MODE				,
	LOCK_SIZE				,
	DATABASE_NAME			,
	ALLOW_SNAPSHOT_ISOLATION = snapshot_isolation_state_desc,
	READ_COMMITTED_SNAPSHOT = 
		CASE is_read_committed_snapshot_on
			WHEN 0 THEN 'OFF'
			WHEN 1 THEN 'ON'
		END,
	OBJECT_NAME				,
	INDEX_ID				,
	BLOCKER_SQL = CASE
				WHEN BLOCKER_SQL LIKE 'FETCH API_CURSOR%' THEN isnull( BLOCKER_CURSORSQL.text, BLOCKER_SQL)
				WHEN BLOCKER_SQL IS NULL THEN BLOCKER_CURSORSQL.text
				ELSE BLOCKER_SQL
			END,
	BLOCKER_PLAN = CASE
				WHEN BLOCKER_SQL LIKE 'FETCH API_CURSOR%' THEN isnull (BLOCKER_CURSORPLAN.query_plan, BLOCKER_PLAN)
				WHEN BLOCKER_SQL IS NULL THEN BLOCKER_CURSORPLAN.query_plan
				ELSE BLOCKER_PLAN	
			END	,
	BLOCKED_SQL = CASE
				WHEN BLOCKED_SQL LIKE 'FETCH API_CURSOR%' THEN isnull('Cursor: '+BLOCKED_CURSORSQL.text, BLOCKED_SQL)
				ELSE	BLOCKED_SQL
			END,
	BLOCKED_PLAN = CASE
				WHEN BLOCKED_SQL LIKE 'FETCH API_CURSOR%' THEN isnull(BLOCKED_CURSORPLAN.query_plan, BLOCKED_PLAN)
				ELSE BLOCKED_PLAN	
			END
FROM	@BLOCKED
JOIN	sys.databases ON name = DATABASE_NAME COLLATE database_default
--	-------------------------------------------------------------------------------------
--	Special Handling for Cursors
--	If the blocking process is a cursor, get SQL text via  sys.dm_exec_cursors.sql_handle
--	and the query plan via sys.dm_exec_query_stats.plan_handle
--	-------------------------------------------------------------------------------------
OUTER APPLY		sys.dm_exec_cursors(BLOCKER_SESSION_ID) AS BLOCKER_CURSORS 

OUTER APPLY		sys.dm_exec_sql_text(BLOCKER_CURSORS.sql_handle) AS BLOCKER_CURSORSQL
LEFT JOIN		sys.dm_exec_query_stats AS BLOCKER_CURSORSTATS ON BLOCKER_CURSORSTATS.sql_handle = BLOCKER_CURSORS.sql_handle
OUTER APPLY		sys.dm_exec_query_plan(BLOCKER_CURSORSTATS.plan_handle) AS BLOCKER_CURSORPLAN
--	-------------------------------------------------------------------------------------
--	Special Handling for Cursors
--	If the blocked process is a cursor, get SQL text via  sys.dm_exec_cursors.sql_handle
--	and the query plan via sys.dm_exec_query_stats.plan_handle
--	-------------------------------------------------------------------------------------
OUTER APPLY		sys.dm_exec_cursors(BLOCKED_SESSION_ID) AS BLOCKED_CURSORS

OUTER APPLY		sys.dm_exec_sql_text(BLOCKED_CURSORS.sql_handle) AS BLOCKED_CURSORSQL
LEFT JOIN		sys.dm_exec_query_stats AS BLOCKED_CURSORSTATS ON BLOCKED_CURSORSTATS.sql_handle = BLOCKED_CURSORS.sql_handle
OUTER APPLY		sys.dm_exec_query_plan(BLOCKED_CURSORSTATS.plan_handle) AS BLOCKED_CURSORPLAN
--WHERE BLOCKER_CURSORS.is_open = 1
--AND		BLOCKED_CURSORS.is_open = 1
ORDER BY WAIT_TIME DESC


GO

USE [DynamicsPerf]
GO

/****** Object:  StoredProcedure [dbo].[SP_LOCKS_MS]    Script Date: 02/28/2011 12:22:42 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SP_LOCKS_MS]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SP_LOCKS_MS]
GO

USE [DynamicsPerf]
GO

/****** Object:  StoredProcedure [dbo].[SP_LOCKS_MS]    Script Date: 02/28/2011 12:22:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[SP_LOCKS_MS] @delay VARCHAR(10)
 AS

SET quoted_identifier OFF
--truncate table Dynamicsperf..blocks  --delete all previous records
DECLARE  @cmd NVARCHAR(100)



/****** Object:  Table [dbo].[BLOCKS]    Script Date: 04/17/2012 14:10:13 ******/
IF  OBJECT_ID('tempdb..#BLOCKS') IS NOT NULL
          DROP TABLE [dbo].[#BLOCKS]



CREATE TABLE [dbo].[#BLOCKS](
	[BLOCKED_DTTM] [datetime] NOT NULL,
	[BLOCKER_LOGIN] [nvarchar](128) NULL,
	[BLOCKER_PROGRAM] [nvarchar](128) NULL,
	[BLOCKER_HOSTNAME] [nvarchar](128) NULL,
	[BLOCKED_LOGIN] [nvarchar](128) NULL,
	[BLOCKED_PROGRAM] [nvarchar](128) NULL,
	[BLOCKED_HOSTNAME] [nvarchar](128) NULL,
	[BLOCKER_SESSION_ID] [smallint] NULL,
	[BLOCKER_CONTEXT_INFO] [binary](128) NULL,
	[BLOCKER_CONTEXT] [nvarchar](max) NULL,
	[BLOCKER_TRAN_ISOLATION] [varchar](20) NULL,
	[BLOCKER_STATUS] [varchar](18) NULL,
	[BLOCKED_SESSION_ID] [smallint] NULL,
	[BLOCKED_CONTEXT_INFO] [binary](128) NULL,
	[BLOCKED_CONTEXT] [nvarchar](max) NULL,
	[BLOCKED_TRAN_ISOLATION] [varchar](20) NULL,
	[TRANSACTION_ID] [bigint] NULL,
	[WAIT_TIME] [bigint] NULL,
	[LOCK_MODE] [nvarchar](60) NULL,
	[LOCK_SIZE] [nvarchar](6) NULL,
	[DATABASE_NAME] [nvarchar](128) NULL,
	[ALLOW_SNAPSHOT_ISOLATION] [nvarchar](60) NULL,
	[READ_COMMITTED_SNAPSHOT] [nvarchar](3) NULL,
	[OBJECT_NAME] [nvarchar](128) NULL,
	[INDEX_ID] [int] NULL,
	[BLOCKER_SQL] [nvarchar](max) NULL,
	[BLOCKER_PLAN] [xml] NULL,
	[BLOCKED_SQL] [nvarchar](max) NULL,
	[BLOCKED_PLAN] [xml] NULL
) ON [PRIMARY]

TOP_LOOP:
BEGIN TRY

TRUNCATE TABLE #BLOCKS

INSERT #BLOCKS
EXEC [SP_LOGBLOCKS_MS]



 MERGE DynamicsPerf..BLOCKS AS target
    USING (
SELECT 
	BLOCKED_DTTM,
	BLOCKER_LOGIN			,
	BLOCKER_PROGRAM		,
	BLOCKER_HOSTNAME		,
	BLOCKED_LOGIN			,
	BLOCKED_PROGRAM		,
	BLOCKED_HOSTNAME		,
	BLOCKER_SESSION_ID		,
	BLOCKER_CONTEXT_INFO	,
	BLOCKER_CONTEXT			,
	BLOCKER_TRAN_ISOLATION	,
	BLOCKER_STATUS			,
	BLOCKED_SESSION_ID		,
	BLOCKED_CONTEXT_INFO	,
	BLOCKED_CONTEXT			,
	BLOCKED_TRAN_ISOLATION	,
	TRANSACTION_ID			,
	WAIT_TIME				,
	LOCK_MODE				,
	LOCK_SIZE				,
	DATABASE_NAME			,
	ALLOW_SNAPSHOT_ISOLATION,
	READ_COMMITTED_SNAPSHOT ,
	OBJECT_NAME				,
	INDEX_ID				,
	BLOCKER_SQL				,
			
	BLOCKER_PLAN = BLOCKER_PLAN	,
	BLOCKED_SQL = 	BLOCKED_SQL ,
	BLOCKED_PLAN =  BLOCKED_PLAN	
				
FROM	#BLOCKS
) as source

ON (source.TRANSACTION_ID = target.TRANSACTION_ID 
AND source.BLOCKED_SESSION_ID = target.BLOCKED_SESSION_ID 
AND source.BLOCKER_SESSION_ID = target.BLOCKER_SESSION_ID)

    WHEN MATCHED THEN 
        UPDATE SET WAIT_TIME = source.WAIT_TIME, BLOCKED_DTTM = source.BLOCKED_DTTM
	WHEN NOT MATCHED THEN	
	    INSERT ([BLOCKED_DTTM]
           ,[BLOCKER_LOGIN]
           ,[BLOCKER_PROGRAM]
           ,[BLOCKER_HOSTNAME]
           ,[BLOCKED_LOGIN]
           ,[BLOCKED_PROGRAM]
           ,[BLOCKED_HOSTNAME]
           ,[BLOCKER_SESSION_ID]
           ,[BLOCKER_CONTEXT_INFO]
           ,[BLOCKER_CONTEXT]
           ,[BLOCKER_TRAN_ISOLATION]
           ,[BLOCKER_STATUS]
           ,[BLOCKED_SESSION_ID]
           ,[BLOCKED_CONTEXT_INFO]
           ,[BLOCKED_CONTEXT]
           ,[BLOCKED_TRAN_ISOLATION]
           ,[TRANSACTION_ID]
           ,[WAIT_TIME]
           ,[LOCK_MODE]
           ,[LOCK_SIZE]
           ,[DATABASE_NAME]
           ,[ALLOW_SNAPSHOT_ISOLATION]
           ,[READ_COMMITTED_SNAPSHOT]
           ,[OBJECT_NAME]
           ,[INDEX_ID]
           ,[BLOCKER_SQL]
           ,[BLOCKER_PLAN]
           ,[BLOCKED_SQL]
           ,[BLOCKED_PLAN])
           
           VALUES (source.[BLOCKED_DTTM]
           ,source.[BLOCKER_LOGIN]
           ,source.[BLOCKER_PROGRAM]
           ,source.[BLOCKER_HOSTNAME]
           ,source.[BLOCKED_LOGIN]
           ,source.[BLOCKED_PROGRAM]
           ,source.[BLOCKED_HOSTNAME]
           ,source.[BLOCKER_SESSION_ID]
           ,source.[BLOCKER_CONTEXT_INFO]
           ,source.[BLOCKER_CONTEXT]
           ,source.[BLOCKER_TRAN_ISOLATION]
           ,source.[BLOCKER_STATUS]
           ,source.[BLOCKED_SESSION_ID]
           ,source.[BLOCKED_CONTEXT_INFO]
           ,source.[BLOCKED_CONTEXT]
           ,source.[BLOCKED_TRAN_ISOLATION]
           ,source.[TRANSACTION_ID]
           ,source.[WAIT_TIME]
           ,source.[LOCK_MODE]
           ,source.[LOCK_SIZE]
           ,source.[DATABASE_NAME]
           ,source.[ALLOW_SNAPSHOT_ISOLATION]
           ,source.[READ_COMMITTED_SNAPSHOT]
           ,source.[OBJECT_NAME]
           ,source.[INDEX_ID]
           ,source.[BLOCKER_SQL]
           ,source.[BLOCKER_PLAN]
           ,source.[BLOCKED_SQL]
           ,source.[BLOCKED_PLAN]);
           
   

END TRY
BEGIN CATCH
 --ignore the error
END catch
 
SELECT @cmd = 'waitfor delay ' +Quotename(@delay,'''')
EXEC sp_executesql @cmd

GOTO TOP_LOOP


ABORT:
RETURN(0)


GO

USE [DynamicsPerf]
GO

/****** Object:  StoredProcedure [dbo].[SP_POPULATE_BLOCKED_PROCESS_INFO]    Script Date: 02/28/2011 12:23:00 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SP_POPULATE_BLOCKED_PROCESS_INFO]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SP_POPULATE_BLOCKED_PROCESS_INFO]
GO

USE [DynamicsPerf]
GO

/****** Object:  StoredProcedure [dbo].[SP_POPULATE_BLOCKED_PROCESS_INFO]    Script Date: 02/28/2011 12:23:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[SP_POPULATE_BLOCKED_PROCESS_INFO] (
                                                           @EMPTY_TABLE_FIRST    CHAR(1) = 'N')
AS 

BEGIN 

DECLARE @TRANSACTIONID BIGINT,
        @TEXTDATA      NVARCHAR(MAX),
        @END_TIME      DATETIME,
        @DATABASE_NAME NVARCHAR(128),
		@DATABASE_ID	INT, 
		@HANDLE		  VARCHAR(64),
		@TRACE_FULL_PATH_NAME NVARCHAR(255) = NULL
		
		
		--@TRACE_FULL_PATH_NAME VARCHAR(120) = 'C:\SQLTRACE\DYNAMICS_DEFAULT.trc',
		
SET @TRACE_FULL_PATH_NAME = (SELECT TRACE_FULL_PATH_NAME FROM DYNAMICSPERF_SETUP)

set nocount on

-- Don't use the DatabaseID from the trace to find the database_name, because the 
-- name we get from function DB_NAME() is invalid when not in the customer's environment

IF @EMPTY_TABLE_FIRST = 'Y' 
	TRUNCATE TABLE BLOCKED_PROCESS_INFO
	
--SET @DATABASE_NAME = (SELECT TOP 1 database_name FROM STATS_COLLECTION_SUMMARY)


DECLARE c1 CURSOR FOR

SELECT TransactionID,
       EndTime,
       TextData,
       DatabaseID
FROM   fn_trace_gettable(@TRACE_FULL_PATH_NAME, DEFAULT) F,
       sys.trace_events E, BLOCKED_PROCESS_INFO_SETUP S
WHERE  EventClass = trace_event_id
       AND name = 'Blocked process report' 
	   AND F.EndTime >= S.LAST_COLLECTION_TIME


OPEN c1
FETCH NEXT FROM c1 INTO @TRANSACTIONID, @END_TIME, @TEXTDATA, @DATABASE_ID

while @@fetch_status = 0
begin

INSERT INTO BLOCKED_PROCESS_INFO
VALUES (

	@TRANSACTIONID,
	CONVERT(DATETIME, @END_TIME),
	@DATABASE_ID,
	CONVERT(XML, @TEXTDATA).value('(blocked-process-report/blocked-process/process/@spid)[1]','INT'),
	convert(xml, @TEXTDATA).value('(blocked-process-report/blocked-process/process/inputbuf)[1]','nvarchar(max)'),
	convert(XML, @TEXTDATA).value('(blocked-process-report/blocked-process/process/@waittime)[1]','INT'),
	CONVERT(XML, @TEXTDATA).value('(blocked-process-report/blocked-process/process/@waitresource)[1]','nvarchar(50)'),
	CONVERT(XML, @TEXTDATA).value('(blocked-process-report/blocked-process/process/@lockMode)[1]','nvarchar(50)'),
	CONVERT(XML, @TEXTDATA).value('(blocked-process-report/blocked-process/process/@transcount)[1]','INT'),
	CONVERT(XML, @TEXTDATA).value('(blocked-process-report/blocked-process/process/@clientapp)[1]','nvarchar(50)'),
	CONVERT(XML, @TEXTDATA).value('(blocked-process-report/blocked-process/process/@hostname)[1]','nvarchar(50)'),
	CONVERT(XML, @TEXTDATA).value('(blocked-process-report/blocked-process/process/@isolationlevel)[1]','nvarchar(50)'),
	CONVERT(XML, @TEXTDATA).value('(blocked-process-report/blocked-process/process/executionStack/frame/@SQLhandle)[1]','VARCHAR(64)'),
	CONVERT(XML, @TEXTDATA).value('(blocked-process-report/blocking-process/process/@spid)[1]','INT'),
	convert(xml, @TEXTDATA).value('(blocked-process-report/blocking-process/process/inputbuf)[1]','nvarchar(max)'),
	CONVERT(XML, @TEXTDATA).value('(blocked-process-report/blocking-process/process/@status)[1]','NVARCHAR(10)'),
	CONVERT(XML, @TEXTDATA).value('(blocked-process-report/blocking-process/process/@transcount)[1]','INT'),
	CONVERT(XML, @TEXTDATA).value('(blocked-process-report/blocking-process/process/@lastbatchstarted)[1]','DATETIME'),
	CONVERT(XML, @TEXTDATA).value('(blocked-process-report/blocking-process/process/@lastbatchcompleted)[1]','DATETIME'),
	CONVERT(XML, @TEXTDATA).value('(blocked-process-report/blocking-process/process/@clientapp)[1]','nvarchar(50)'),
	CONVERT(XML, @TEXTDATA).value('(blocked-process-report/blocking-process/process/@hostname)[1]','nvarchar(50)'),
	CONVERT(XML, @TEXTDATA).value('(blocked-process-report/blocking-process/process/@isolationlevel)[1]','nvarchar(50)'),
	CONVERT(XML, @TEXTDATA).value('(blocked-process-report/blocking-process/process/executionStack/frame/@sqlhandle)[1]','VARCHAR(64)')
	)
	
	--Old Method at finding the Query Plan upon insertion of the blocked process report into DynamicsPerf
----BLOCKER QUERY PLAN(S)
--	SELECT @HANDLE = CONVERT(XML, @TEXTDATA).value('(blocked-process-report/blocked-process/process/executionStack/frame/@SQLhandle)[1]','VARCHAR(64)')
--	--PRINT 'BLOCKED'
--	--PRINT @HANDLE

	
--	INSERT INTO BLOCKED_PROCESS_INFO_PLANS
--	SELECT GETDATE(),@TRANSACTIONID, @HANDLE, 
--	'', --blocker sql handle,
--	BLOCKEDSTATS.plan_handle, XMLPLAN.query_plan
--	FROM  sys.dm_exec_query_stats AS BLOCKEDSTATS 
--	    OUTER APPLY sys.dm_exec_query_plan(BLOCKEDSTATS.plan_handle) AS XMLPLAN
--	    WHERE  BLOCKEDSTATS.sql_handle =  CONVERT(VARBINARY,@HANDLE,1)--have to do this explicit or it fails
	    
	    
----BLOCKED QUERY PLAN(S)

--	SELECT @HANDLE = 	CONVERT(XML, @TEXTDATA).value('(blocked-process-report/blocking-process/process/executionStack/frame/@SQLhandle)[1]','VARCHAR(64)')
----PRINT 'BLOCKING'
----PRINT @HANDLE		
--	INSERT INTO BLOCKED_PROCESS_INFO_PLANS
--	SELECT GETDATE(),@TRANSACTIONID, '', 
--	@HANDLE, --blocker sql handle,
--	BLOCKEDSTATS.plan_handle, XMLPLAN.query_plan
--	FROM  sys.dm_exec_query_stats AS BLOCKEDSTATS 
--	    OUTER APPLY sys.dm_exec_query_plan(BLOCKEDSTATS.plan_handle) AS XMLPLAN
--	    WHERE  BLOCKEDSTATS.sql_handle = CONVERT(VARBINARY,@HANDLE,1) --have to do this explicit or it fails

FETCH NEXT FROM c1 INTO @TRANSACTIONID, @END_TIME, @TEXTDATA, @DATABASE_ID
END
CLOSE c1
DEALLOCATE c1

UPDATE BLOCKED_PROCESS_INFO_SETUP SET LAST_COLLECTION_TIME = GETDATE()
END -- END PROCEDURE SP_POPULATE_BLOCKED_PROCESS_INFO 
 



GO

USE [DynamicsPerf]
GO

/****** Object:  StoredProcedure [dbo].[SP_PURGEBLOCKS]    Script Date: 02/28/2011 12:23:14 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SP_PURGEBLOCKS]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SP_PURGEBLOCKS]
GO

USE [DynamicsPerf]
GO

/****** Object:  StoredProcedure [dbo].[SP_PURGEBLOCKS]    Script Date: 02/28/2011 12:23:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_PURGEBLOCKS] @days INT
AS
  SELECT @days = @days * -1

DELETE DynamicsPerf..BLOCKS
WHERE  BLOCKED_DTTM <= Dateadd(dd, @days, Getdate())

DELETE FROM [DynamicsPerf].[dbo].[BLOCKED_PROCESS_INFO]

WHERE  END_TIME <= Dateadd(dd, @days, Getdate()) 

GO
USE [DynamicsPerf]
GO

/****** Object:  StoredProcedure [dbo].[SP_PURGESTATS]    Script Date: 07/19/2012 15:34:35 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SP_PURGESTATS]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SP_PURGESTATS]
GO

USE [DynamicsPerf]
GO

/****** Object:  StoredProcedure [dbo].[SP_PURGESTATS]    Script Date: 07/19/2012 15:34:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE	PROCEDURE [dbo].[SP_PURGESTATS] 
		@PURGE_DAYS		INT = 14,
		@DATABASE_NAME sysname = NULL
AS

SET NOCOUNT ON
SET DATEFORMAT MDY
DECLARE @PURGE_DATE smalldatetime

SET @PURGE_DAYS = @PURGE_DAYS * -1  --set to negative so we go back in time not forward in time


SET @PURGE_DATE = DATEADD(DD,@PURGE_DAYS,GETDATE())

IF @DATABASE_NAME IS NOT NULL
BEGIN
DELETE FROM INDEX_OPERATIONAL_STATS
WHERE  DATABASE_NAME = @DATABASE_NAME


DELETE FROM INDEX_PHYSICAL_STATS
WHERE  DATABASE_NAME = @DATABASE_NAME

DELETE FROM INDEX_OPERATIONAL_STATS
WHERE  DATABASE_NAME = @DATABASE_NAME

DELETE FROM QUERY_STATS
WHERE  DATABASE_NAME = @DATABASE_NAME


DELETE QT FROM QUERY_TEXT QT
WHERE NOT EXISTS (SELECT QUERY_HASH FROM QUERY_STATS QS 
	WHERE QS.QUERY_HASH = QT.QUERY_HASH)
	
DELETE QP FROM QUERY_PLANS QP
WHERE  NOT EXISTS (SELECT PLAN_HANDLE FROM QUERY_STATS QS 
	WHERE  QS.QUERY_PLAN_HASH=QP.QUERY_PLAN_HASH)
	


DELETE FROM STATS_COLLECTION_SUMMARY
WHERE  DATABASE_NAME = @DATABASE_NAME

DELETE FROM SERVERINFO
WHERE  NOT EXISTS (SELECT RUN_NAME FROM STATS_COLLECTION_SUMMARY SCS WHERE SCS.RUN_NAME = SERVERINFO.RUN_NAME)


DELETE FROM TRACEFLAGS
WHERE  NOT EXISTS (SELECT STATS_TIME FROM STATS_COLLECTION_SUMMARY SCS WHERE SCS.STATS_TIME = TRACEFLAGS.STATS_TIME)

DELETE FROM BUFFER_DETAIL
WHERE  NOT EXISTS (SELECT RUN_NAME FROM STATS_COLLECTION_SUMMARY SCS WHERE SCS.RUN_NAME = BUFFER_DETAIL.RUN_NAME)


DELETE FROM DISKSTATS
WHERE  DATABASE_NAME = @DATABASE_NAME

DELETE FROM PERF_DISKSTATS
WHERE  DATABASE_NAME = @DATABASE_NAME

DELETE FROM PERF_INDEX_DETAIL
WHERE  DATABASE_NAME = @DATABASE_NAME

DELETE FROM PERF_INDEX_USAGE_STATS
WHERE  DATABASE_NAME = @DATABASE_NAME



IF EXISTS (SELECT *
               FROM   sys.objects
               WHERE  object_id = Object_id(N'[dbo].[AX_INDEX_DETAIL]')
                      AND type IN ( N'U' )) 
BEGIN

DELETE FROM AX_INDEX_DETAIL
WHERE  DATABASE_NAME = @DATABASE_NAME

DELETE FROM AX_SQLTRACE
WHERE  DATABASE_NAME = @DATABASE_NAME

DELETE FROM AX_TABLE_DETAIL
WHERE  DATABASE_NAME = @DATABASE_NAME

DELETE FROM AX_NUM_SEQUENCES
WHERE  DATABASE_NAME = @DATABASE_NAME
END




END
ELSE
BEGIN

DELETE IO FROM INDEX_OPERATIONAL_STATS IO
WHERE  STATS_TIME <= @PURGE_DATE
AND STATS_TIME IN (SELECT STATS_TIME FROM STATS_COLLECTION_SUMMARY STATS WHERE STATS.STATS_TIME = IO.STATS_TIME AND STATS.RUN_NAME NOT LIKE 'BASE%')

AND NOT EXISTS(
SELECT DATABASE_NAME,
       SQL_SERVER_STARTTIME,
       max(STATS_TIME) as STATS_TIME
FROM   STATS_COLLECTION_SUMMARY SCS
WHERE  EXISTS (SELECT DISTINCT DATABASE_NAME,
                               SQL_SERVER_STARTTIME
               FROM   STATS_COLLECTION_SUMMARY SCS2
               WHERE  SCS2.DATABASE_NAME = SCS.DATABASE_NAME
                      AND SCS2.SQL_SERVER_STARTTIME = SCS.SQL_SERVER_STARTTIME)
GROUP  BY DATABASE_NAME,
          SQL_SERVER_STARTTIME
HAVING MAX(STATS_TIME) = IO.STATS_TIME
       AND DATABASE_NAME = IO.DATABASE_NAME   )
       
       

DELETE IPS FROM INDEX_PHYSICAL_STATS IPS
WHERE  STATS_TIME <= @PURGE_DATE
AND STATS_TIME IN (SELECT STATS_TIME FROM STATS_COLLECTION_SUMMARY STATS WHERE STATS.STATS_TIME = IPS.STATS_TIME AND STATS.RUN_NAME NOT LIKE 'BASE%')

AND NOT EXISTS(
SELECT DATABASE_NAME,
       SQL_SERVER_STARTTIME,
       max(STATS_TIME) as STATS_TIME
FROM   STATS_COLLECTION_SUMMARY SCS
WHERE  EXISTS (SELECT DISTINCT DATABASE_NAME,
                               SQL_SERVER_STARTTIME
               FROM   STATS_COLLECTION_SUMMARY SCS2
               WHERE  SCS2.DATABASE_NAME = SCS.DATABASE_NAME
                      AND SCS2.SQL_SERVER_STARTTIME = SCS.SQL_SERVER_STARTTIME)
      
GROUP  BY DATABASE_NAME,
          SQL_SERVER_STARTTIME
HAVING MAX(STATS_TIME) = IPS.STATS_TIME
       AND DATABASE_NAME = IPS.DATABASE_NAME   )
       
          
          
          

DELETE IUS FROM INDEX_USAGE_STATS IUS
WHERE STATS_TIME <= @PURGE_DATE
AND STATS_TIME IN (SELECT STATS_TIME FROM STATS_COLLECTION_SUMMARY STATS WHERE STATS.STATS_TIME = IUS.STATS_TIME AND STATS.RUN_NAME NOT LIKE 'BASE%')

AND NOT EXISTS(
SELECT DATABASE_NAME,
       SQL_SERVER_STARTTIME,
       max(STATS_TIME) as STATS_TIME
FROM   STATS_COLLECTION_SUMMARY SCS
WHERE  EXISTS (SELECT DISTINCT DATABASE_NAME,
                               SQL_SERVER_STARTTIME
               FROM   STATS_COLLECTION_SUMMARY SCS2
               WHERE  SCS2.DATABASE_NAME = SCS.DATABASE_NAME
                      AND SCS2.SQL_SERVER_STARTTIME = SCS.SQL_SERVER_STARTTIME)
      
GROUP  BY DATABASE_NAME,
          SQL_SERVER_STARTTIME
HAVING MAX(STATS_TIME) = IUS.STATS_TIME
       AND DATABASE_NAME = IUS.DATABASE_NAME  ) 
       
DELETE IOS FROM INDEX_OPERATIONAL_STATS IOS
WHERE STATS_TIME <= @PURGE_DATE
AND STATS_TIME IN (SELECT STATS_TIME FROM STATS_COLLECTION_SUMMARY STATS WHERE STATS.STATS_TIME = IOS.STATS_TIME AND STATS.RUN_NAME NOT LIKE 'BASE%')

AND NOT EXISTS(
SELECT DATABASE_NAME,
       SQL_SERVER_STARTTIME,
       max(STATS_TIME) as STATS_TIME
FROM   STATS_COLLECTION_SUMMARY SCS
WHERE  EXISTS (SELECT DISTINCT DATABASE_NAME,
                               SQL_SERVER_STARTTIME
               FROM   STATS_COLLECTION_SUMMARY SCS2
               WHERE  SCS2.DATABASE_NAME = SCS.DATABASE_NAME
                      AND SCS2.SQL_SERVER_STARTTIME = SCS.SQL_SERVER_STARTTIME)
       
GROUP  BY DATABASE_NAME,
          SQL_SERVER_STARTTIME
HAVING MAX(STATS_TIME) = IOS.STATS_TIME
       AND DATABASE_NAME = IOS.DATABASE_NAME  ) 
       
         

DELETE QS FROM QUERY_STATS QS
WHERE  STATS_TIME <= @PURGE_DATE
AND STATS_TIME IN (SELECT STATS_TIME FROM STATS_COLLECTION_SUMMARY STATS WHERE STATS.STATS_TIME = QS.STATS_TIME AND STATS.RUN_NAME NOT LIKE 'BASE%')

AND NOT EXISTS(
SELECT DATABASE_NAME,
       SQL_SERVER_STARTTIME,
       max(STATS_TIME) as STATS_TIME
FROM   STATS_COLLECTION_SUMMARY SCS
WHERE  EXISTS (SELECT DISTINCT DATABASE_NAME,
                               SQL_SERVER_STARTTIME
               FROM   STATS_COLLECTION_SUMMARY SCS2
               WHERE  SCS2.DATABASE_NAME = SCS.DATABASE_NAME
                      AND SCS2.SQL_SERVER_STARTTIME = SCS.SQL_SERVER_STARTTIME)
		
GROUP  BY DATABASE_NAME,
          SQL_SERVER_STARTTIME
HAVING MAX(STATS_TIME) = QS.STATS_TIME
       AND DATABASE_NAME = QS.DATABASE_NAME   )
       


DELETE QT FROM QUERY_TEXT QT
WHERE NOT EXISTS (SELECT QUERY_HASH FROM QUERY_STATS QS 
	WHERE QS.QUERY_HASH = QT.QUERY_HASH)
	

--REH Ver 1.1 Only remove the QUERY Plan once we have removed the QUERY STAT
--This allows us to keep only 1 copy of the Plan Handle and reduce our DB size if we are agressively collecting
DELETE QP FROM QUERY_PLANS QP
WHERE  NOT EXISTS (SELECT PLAN_HANDLE FROM QUERY_STATS QS 
	WHERE  QS.QUERY_PLAN_HASH=QP.QUERY_PLAN_HASH)

DELETE FROM WAIT_STATS
WHERE  STATS_TIME <= @PURGE_DATE
AND STATS_TIME IN (SELECT STATS_TIME FROM STATS_COLLECTION_SUMMARY STATS WHERE STATS.STATS_TIME = WAIT_STATS.STATS_TIME AND STATS.RUN_NAME NOT LIKE 'BASE%')


DELETE FROM BUFFER_DETAIL
WHERE  STATS_TIME <= @PURGE_DATE
AND STATS_TIME IN (SELECT STATS_TIME FROM STATS_COLLECTION_SUMMARY STATS WHERE STATS.STATS_TIME = BUFFER_DETAIL.STATS_TIME AND STATS.RUN_NAME NOT LIKE 'BASE%')


DELETE SC FROM SQL_CONFIGURATION SC
WHERE  STATS_TIME <= @PURGE_DATE
AND STATS_TIME IN (SELECT STATS_TIME FROM STATS_COLLECTION_SUMMARY STATS WHERE STATS.STATS_TIME = SC.STATS_TIME AND STATS.RUN_NAME NOT LIKE 'BASE%')

AND NOT EXISTS(
SELECT DATABASE_NAME,
       SQL_SERVER_STARTTIME,
       max(STATS_TIME) as STATS_TIME
FROM   STATS_COLLECTION_SUMMARY SCS
WHERE  EXISTS (SELECT DISTINCT DATABASE_NAME,
                               SQL_SERVER_STARTTIME
               FROM   STATS_COLLECTION_SUMMARY SCS2
               WHERE  SCS2.DATABASE_NAME = SCS.DATABASE_NAME
                      AND SCS2.SQL_SERVER_STARTTIME = SCS.SQL_SERVER_STARTTIME)
        
GROUP  BY DATABASE_NAME,
          SQL_SERVER_STARTTIME
HAVING MAX(STATS_TIME) = SC.STATS_TIME
          )
       
       

DELETE SD FROM SQL_DATABASEFILES SD
WHERE  STATS_TIME <= @PURGE_DATE
AND STATS_TIME IN (SELECT STATS_TIME FROM STATS_COLLECTION_SUMMARY STATS WHERE STATS.STATS_TIME = SD.STATS_TIME AND STATS.RUN_NAME NOT LIKE 'BASE%')

AND NOT EXISTS(
SELECT DATABASE_NAME,
       SQL_SERVER_STARTTIME,
       max(STATS_TIME) as STATS_TIME
FROM   STATS_COLLECTION_SUMMARY SCS
WHERE  EXISTS (SELECT DISTINCT DATABASE_NAME,
                               SQL_SERVER_STARTTIME
               FROM   STATS_COLLECTION_SUMMARY SCS2
               WHERE  SCS2.DATABASE_NAME = SCS.DATABASE_NAME
                      AND SCS2.SQL_SERVER_STARTTIME = SCS.SQL_SERVER_STARTTIME)
        
GROUP  BY DATABASE_NAME,
          SQL_SERVER_STARTTIME
HAVING MAX(STATS_TIME) = SD.STATS_TIME
       AND DATABASE_NAME = SD.DATABASE_NAME  ) 
       
       
       

DELETE SD FROM SQL_DATABASES SD
WHERE  STATS_TIME <= @PURGE_DATE
AND STATS_TIME IN (SELECT STATS_TIME FROM STATS_COLLECTION_SUMMARY STATS WHERE STATS.STATS_TIME = SD.STATS_TIME AND STATS.RUN_NAME NOT LIKE 'BASE%')

AND NOT EXISTS(
SELECT DATABASE_NAME,
       SQL_SERVER_STARTTIME,
       max(STATS_TIME) as STATS_TIME
FROM   STATS_COLLECTION_SUMMARY SCS
WHERE  EXISTS (SELECT DISTINCT DATABASE_NAME,
                               SQL_SERVER_STARTTIME
               FROM   STATS_COLLECTION_SUMMARY SCS2
               WHERE  SCS2.DATABASE_NAME = SCS.DATABASE_NAME
                      AND SCS2.SQL_SERVER_STARTTIME = SCS.SQL_SERVER_STARTTIME)
		
GROUP  BY DATABASE_NAME,
          SQL_SERVER_STARTTIME
HAVING MAX(STATS_TIME) = SD.STATS_TIME
       AND DATABASE_NAME = SD.DATABASE_NAME   )
       
          
          

DELETE SJ FROM SQL_JOBS SJ
WHERE  STATS_TIME <= @PURGE_DATE
AND STATS_TIME IN (SELECT STATS_TIME FROM STATS_COLLECTION_SUMMARY STATS WHERE STATS.STATS_TIME = SJ.STATS_TIME AND STATS.RUN_NAME NOT LIKE 'BASE%')

AND NOT EXISTS(
SELECT DATABASE_NAME,
       SQL_SERVER_STARTTIME,
       max(STATS_TIME) as STATS_TIME
FROM   STATS_COLLECTION_SUMMARY SCS
WHERE  EXISTS (SELECT DISTINCT DATABASE_NAME,
                               SQL_SERVER_STARTTIME
               FROM   STATS_COLLECTION_SUMMARY SCS2
               WHERE  SCS2.DATABASE_NAME = SCS.DATABASE_NAME
                      AND SCS2.SQL_SERVER_STARTTIME = SCS.SQL_SERVER_STARTTIME)
        
GROUP  BY DATABASE_NAME,
          SQL_SERVER_STARTTIME
HAVING MAX(STATS_TIME) = SJ.STATS_TIME
         )
       
       
DELETE SEL FROM SQLErrorLog SEL
WHERE  LOGDATE <= @PURGE_DATE



DELETE SS FROM STATS_COLLECTION_SUMMARY SS
WHERE  STATS_TIME <= @PURGE_DATE 
AND STATS_TIME IN (SELECT STATS_TIME FROM STATS_COLLECTION_SUMMARY STATS WHERE STATS.STATS_TIME = SS.STATS_TIME AND STATS.RUN_NAME NOT LIKE 'BASE%')

AND NOT EXISTS(
SELECT DATABASE_NAME,
       SQL_SERVER_STARTTIME,
       max(STATS_TIME) as STATS_TIME
FROM   STATS_COLLECTION_SUMMARY SCS
WHERE  EXISTS (SELECT DISTINCT DATABASE_NAME,
                               SQL_SERVER_STARTTIME
               FROM   STATS_COLLECTION_SUMMARY SCS2
               WHERE  SCS2.DATABASE_NAME = SCS.DATABASE_NAME
                      AND SCS2.SQL_SERVER_STARTTIME = SCS.SQL_SERVER_STARTTIME)
        
GROUP  BY DATABASE_NAME,
          SQL_SERVER_STARTTIME
HAVING MAX(STATS_TIME) = SS.STATS_TIME
       AND DATABASE_NAME = SS.DATABASE_NAME   )
       

DELETE FROM SERVERINFO
WHERE  NOT EXISTS (SELECT RUN_NAME FROM STATS_COLLECTION_SUMMARY SCS WHERE SCS.RUN_NAME = SERVERINFO.RUN_NAME AND SCS.RUN_NAME NOT LIKE 'BASE%')


       

DELETE FROM CAPTURE_LOG WHERE STATS_TIME <= @PURGE_DATE

DELETE TF FROM TRACEFLAGS TF
WHERE  STATS_TIME <= @PURGE_DATE
AND STATS_TIME IN (SELECT STATS_TIME FROM STATS_COLLECTION_SUMMARY STATS WHERE STATS.STATS_TIME = TF.STATS_TIME AND STATS.RUN_NAME NOT LIKE 'BASE%')

AND NOT EXISTS(
SELECT DATABASE_NAME,
       SQL_SERVER_STARTTIME,
       max(STATS_TIME) as STATS_TIME
FROM   STATS_COLLECTION_SUMMARY SCS
WHERE  EXISTS (SELECT DISTINCT DATABASE_NAME,
                               SQL_SERVER_STARTTIME
               FROM   STATS_COLLECTION_SUMMARY SCS2
               WHERE  SCS2.DATABASE_NAME = SCS.DATABASE_NAME
                      AND SCS2.SQL_SERVER_STARTTIME = SCS.SQL_SERVER_STARTTIME)
        
GROUP  BY DATABASE_NAME,
          SQL_SERVER_STARTTIME
HAVING MAX(STATS_TIME) = TF.STATS_TIME
         )
       

DELETE FROM DISKSTATS
WHERE  STATS_TIME <= @PURGE_DATE


DELETE PD FROM PERF_DISKSTATS PD
WHERE  STATS_TIME <= @PURGE_DATE
AND NOT EXISTS(
SELECT DATABASE_NAME,
       SQL_SERVER_STARTTIME,
       max(STATS_TIME) as STATS_TIME
FROM   STATS_COLLECTION_SUMMARY SCS
WHERE  EXISTS (SELECT DISTINCT DATABASE_NAME,
                               SQL_SERVER_STARTTIME
               FROM   STATS_COLLECTION_SUMMARY SCS2
               WHERE  SCS2.DATABASE_NAME = SCS.DATABASE_NAME
                      AND SCS2.SQL_SERVER_STARTTIME = SCS.SQL_SERVER_STARTTIME)
GROUP  BY DATABASE_NAME,
          SQL_SERVER_STARTTIME
HAVING MAX(STATS_TIME) = PD.STATS_TIME
       AND DATABASE_NAME = PD.DATABASE_NAME   )
       
       

DELETE FROM PERF_INDEX_DETAIL
WHERE  STATS_TIME <= DATEADD(DD,-730,@PURGE_DATE)

DELETE FROM PERF_INDEX_USAGE_STATS
WHERE  STATS_TIME <= DATEADD(DD,-730,@PURGE_DATE)

DELETE FROM PERF_WAIT_STATS
WHERE  STATS_TIME <= DATEADD(DD,-730,@PURGE_DATE)


IF EXISTS (SELECT *
               FROM   sys.objects
               WHERE  object_id = Object_id(N'[dbo].[AX_INDEX_DETAIL]')
                      AND type IN ( N'U' )) 
BEGIN

DELETE AD FROM AX_INDEX_DETAIL AD
WHERE  STATS_TIME <= @PURGE_DATE
AND STATS_TIME IN (SELECT STATS_TIME FROM STATS_COLLECTION_SUMMARY STATS WHERE STATS.STATS_TIME = AD.STATS_TIME AND STATS.RUN_NAME NOT LIKE 'BASE%')

AND NOT EXISTS(
SELECT DATABASE_NAME,
       SQL_SERVER_STARTTIME,
       max(STATS_TIME) as STATS_TIME
FROM   STATS_COLLECTION_SUMMARY SCS
WHERE  EXISTS (SELECT DISTINCT DATABASE_NAME,
                               SQL_SERVER_STARTTIME
               FROM   STATS_COLLECTION_SUMMARY SCS2
               WHERE  SCS2.DATABASE_NAME = SCS.DATABASE_NAME
                      AND SCS2.SQL_SERVER_STARTTIME = SCS.SQL_SERVER_STARTTIME)
        
GROUP  BY DATABASE_NAME,
          SQL_SERVER_STARTTIME
HAVING MAX(STATS_TIME) = AD.STATS_TIME
       AND DATABASE_NAME = AD.DATABASE_NAME   )
       
       

DELETE AXS FROM AX_SQLTRACE AXS
WHERE  STATS_TIME <= @PURGE_DATE

AND NOT EXISTS(
SELECT DATABASE_NAME,
       SQL_SERVER_STARTTIME,
       max(STATS_TIME) as STATS_TIME
FROM   STATS_COLLECTION_SUMMARY SCS
WHERE  EXISTS (SELECT DISTINCT DATABASE_NAME,
                               SQL_SERVER_STARTTIME
               FROM   STATS_COLLECTION_SUMMARY SCS2
               WHERE  SCS2.DATABASE_NAME = SCS.DATABASE_NAME
                      AND SCS2.SQL_SERVER_STARTTIME = SCS.SQL_SERVER_STARTTIME)
        
GROUP  BY DATABASE_NAME,
          SQL_SERVER_STARTTIME
HAVING MAX(STATS_TIME) = AXS.STATS_TIME
       AND DATABASE_NAME = AXS.DATABASE_NAME   )
       
       

DELETE AD FROM AX_TABLE_DETAIL AD
WHERE  STATS_TIME <= @PURGE_DATE
AND STATS_TIME IN (SELECT STATS_TIME FROM STATS_COLLECTION_SUMMARY STATS WHERE STATS.STATS_TIME = AD.STATS_TIME AND STATS.RUN_NAME NOT LIKE 'BASE%')

AND NOT EXISTS(
SELECT DATABASE_NAME,
       SQL_SERVER_STARTTIME,
       max(STATS_TIME) as STATS_TIME
FROM   STATS_COLLECTION_SUMMARY SCS
WHERE  EXISTS (SELECT DISTINCT DATABASE_NAME,
                               SQL_SERVER_STARTTIME
               FROM   STATS_COLLECTION_SUMMARY SCS2
               WHERE  SCS2.DATABASE_NAME = SCS.DATABASE_NAME
                      AND SCS2.SQL_SERVER_STARTTIME = SCS.SQL_SERVER_STARTTIME)
       
GROUP  BY DATABASE_NAME,
          SQL_SERVER_STARTTIME
HAVING MAX(STATS_TIME) = AD.STATS_TIME
       AND DATABASE_NAME = AD.DATABASE_NAME   )
       
       

DELETE ANS FROM AX_NUM_SEQUENCES ANS
WHERE  STATS_TIME <= @PURGE_DATE
AND STATS_TIME IN (SELECT STATS_TIME FROM STATS_COLLECTION_SUMMARY STATS WHERE STATS.STATS_TIME = ANS.STATS_TIME AND STATS.RUN_NAME NOT LIKE 'BASE%')

AND NOT EXISTS(
SELECT DATABASE_NAME,
       SQL_SERVER_STARTTIME,
       max(STATS_TIME) as STATS_TIME
FROM   STATS_COLLECTION_SUMMARY SCS
WHERE  EXISTS (SELECT DISTINCT DATABASE_NAME,
                               SQL_SERVER_STARTTIME
               FROM   STATS_COLLECTION_SUMMARY SCS2
               WHERE  SCS2.DATABASE_NAME = SCS.DATABASE_NAME
                      AND SCS2.SQL_SERVER_STARTTIME = SCS.SQL_SERVER_STARTTIME)
		
GROUP  BY DATABASE_NAME,
          SQL_SERVER_STARTTIME
HAVING MAX(STATS_TIME) = ANS.STATS_TIME
       AND DATABASE_NAME = ANS.DATABASE_NAME  ) 
       
       
       
END


END
ENDPROC:


GO




USE [DynamicsPerf]
GO

/****** Object:  StoredProcedure [dbo].[SP_SQLTRACE]    Script Date: 02/28/2011 12:23:40 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SP_SQLTRACE]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SP_SQLTRACE]
GO

USE [DynamicsPerf]
GO

/****** Object:  StoredProcedure [dbo].[SP_SQLTRACE]    Script Date: 02/28/2011 12:23:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- ***********************************************************************
-- ***********************************************************************
CREATE           PROCEDURE [dbo].[SP_SQLTRACE]
-- ***********************************************************************
-- ***********************************************************************
-- ***********************************************************************
-- This stored procedure is provided AS IS with no warranties and confers no rights.
-- ***********************************************************************
	
	@FILE_PATH 			NVARCHAR(200)	= 'C:\SQLTRACE',-- Location to write trace files.  Note: directory must exist before start of trace
	@TRACE_NAME  		NVARCHAR(40)	= 'DYNAMICS_DEFAULT', -- Trace name - becomes base of trace file name
	@DATABASE_NAME		NVARCHAR(128)	= NULL,			-- Name of database to trace; default (NULL) will trace all databases
	@TRACE_FILE_SIZE	BIGINT			= 10,			-- maximum trace file size - will rollover when reached
	@TRACE_FILE_COUNT	INT				= 100,			-- maximum numer of trace files  - will delete oldest when reached
	@TRACE_STOP  		NVARCHAR(1)		= 'N',			-- When set to 'Y' will stop the trace and exit
	@TRACE_RUN_HOURS  	SMALLINT		= 48, 			-- Number of hours to run trace
	@HOSTNAME			NVARCHAR(128)	= NULL,			--Hostname filter for trace		
	@DURATION_SECS			BIGINT			= 0				-- enables statment, rpc, batch trace by specified duration			


AS

SET NOCOUNT ON
SET DATEFORMAT MDY
--
-- Schedulable server-side trace script
--
--
-- This script can be used to start, run and manage several traces.
-- The trace name is used as unique identifier to represent trace, so make it meaningful.
-- When this script runs, it deletes the existing trace with the same filename,
-- and creates a new trace, adding a date/time extension to the trace file name
-- Change the following as appropriate:
--
--	DATA COLUMNS
--	EVENT CLASSES
--	FILTERS
--


-- -----------------------------------------------------------------------
-- Declare variables
-- -----------------------------------------------------------------------
DECLARE	@CMD			NVARCHAR(1000),	-- Used for command or sql strings
		@RC				INT,			-- Return status for stored procedures
		@ON				BIT,			-- Used as on bit for set event
		@TRACEID 		INT, 			-- Queue handle running trace queue
		@DATABASE_ID 	INT, 			-- DB ID to filter trace
		@EVENT_ID 		INT, 			-- Trace Event
		@COLUMN_ID 		INT, 			-- Trace Event Column
		@TRACE_STOPTIME	DATETIME, 		-- Trace will be set to stop 25 hours after starting
		@FILE_NAME 		NVARCHAR(245)	-- Trace file name
DECLARE	@EVENTS_VAR		TABLE(EVENT_ID INT PRIMARY KEY(EVENT_ID))

SET @ON				= 1
SET @TRACE_STOPTIME = DATEADD(HH, @TRACE_RUN_HOURS, GETDATE())

-- -----------------------------------------------------------------------
-- Edit parameters
-- -----------------------------------------------------------------------

IF @FILE_PATH LIKE '%\'
    BEGIN
		PRINT 'OMIT TRAILING \ FROM PATH NAME'
		SET @RC = 1
		GOTO ERROR
    END


IF @DATABASE_NAME IS NOT NULL
    BEGIN
		SELECT	@DATABASE_ID = database_id 
		FROM	sys.databases
		WHERE	name =  @DATABASE_NAME
		IF @@ROWCOUNT = 0
			BEGIN
				PRINT @DATABASE_NAME + ' DOES NOT EXIST'
				SET @RC = 1
				GOTO ERROR
			END
    END


-- -----------------------------------------------------------------------
-- Stop the trace queue if running
-- -----------------------------------------------------------------------
IF EXISTS	
	(
	SELECT	*
	FROM 	fn_trace_getinfo(DEFAULT)
	WHERE 	property = 2	-- TRACE FILE NAME
	AND		CONVERT(NVARCHAR(245),value)  LIKE '%\'+@TRACE_NAME+'%'
	)
    BEGIN
		SELECT	@TRACEID = traceid
		FROM 	fn_trace_getinfo(DEFAULT)
		WHERE 	property = 2	-- TRACE FILE NAME
		AND		CONVERT(VARCHAR(240),value)  LIKE '%\'+@TRACE_NAME+'%'
		EXEC @RC = sp_trace_setstatus @TRACEID, 0	-- STOPS SPECIFIED TRACE
		IF @RC = 0  PRINT 'SP_TRACE_SETSTATUS: STOPPED TRACE ID ' + STR(@TRACEID )
		IF @RC = 1  PRINT 'SP_TRACE_SETSTATUS: - UNKNOWN ERROR'
		IF @RC = 8  PRINT 'SP_TRACE_SETSTATUS: THE SPECIFIED STATUS IS NOT VALID'
		IF @RC = 9  PRINT 'SP_TRACE_SETSTATUS: THE SPECIFIED TRACE HANDLE IS NOT VALID'
		IF @RC = 13 PRINT 'SP_TRACE_SETSTATUS: OUT OF MEMORY'
		IF @RC <> 0 GOTO ERROR

		EXEC sp_trace_setstatus @TRACEID, 2 -- DELETE SPECIFIED TRACE

		IF @RC = 0  PRINT 'SP_TRACE_SETSTATUS: DELETED TRACE ID ' + STR(@TRACEID)
		IF @RC = 1  PRINT 'SP_TRACE_SETSTATUS: - UNKNOWN ERROR'
		IF @RC = 8  PRINT 'SP_TRACE_SETSTATUS: THE SPECIFIED STATUS IS NOT VALID'
		IF @RC = 9  PRINT 'SP_TRACE_SETSTATUS: THE SPECIFIED TRACE HANDLE IS NOT VALID'
		IF @RC = 13 PRINT 'SP_TRACE_SETSTATUS: OUT OF MEMORY'
		IF @RC <> 0 GOTO ERROR
    END


-- -----------------------------------------------------------------------
-- Stop trace and leave if requested via   @TRACE_STOP
-- -----------------------------------------------------------------------
IF @TRACE_STOP = 'Y' GOTO ENDPROC


-- -----------------------------------------------------------------------
-- Build the trace file name 
-- -----------------------------------------------------------------------

SELECT 	@FILE_NAME = 	@FILE_PATH 	+ '\' + @TRACE_NAME 				
PRINT 'FILE NAME = ' + @FILE_NAME+'.trc'

-- Convert @DURATION_SECS to appropriate time for sp_trace
IF @DURATION_SECS > 0
BEGIN
SET @DURATION_SECS = @DURATION_SECS * 1000000   -- convert to microseconds
END
-- -----------------------------------------------------------------------
-- Create trace
-- -----------------------------------------------------------------------


EXEC @RC = sp_trace_create
	@TRACEID OUTPUT, 	--	TRACE HANDLE - NEEDED FOR SUBSEQUENT TRACE OPERATIONS
	2, 					--	2 INDICATES FILE ROLLOVER
	@FILE_NAME,			--	FULL TRACE FILE NAME
	@TRACE_FILE_SIZE, 	--	MAXIMUM TRACE FILE SIZE BEFORE ROLLOVER
	@TRACE_STOPTIME,	--	TRACE STOP TIME
	@TRACE_FILE_COUNT	--	MAXIMUM TRACE FILE COUNT BEFORE OLDEST DELETED

IF @RC = 0  PRINT 'SP_TRACE_CREATE: CREATED TRACE ID ' + STR(@TRACEID )
IF @RC = 1  PRINT 'SP_TRACE_CREATE: - UNKNOWN ERROR'
IF @RC = 10 PRINT 'SP_TRACE_CREATE: INVALID OPTIONS'
IF @RC = 12 PRINT 'SP_TRACE_CREATE: FILE NAME ALREADY EXISTS; NEW TRACE NOT CREATED'
IF @RC = 13 PRINT 'SP_TRACE_CREATE: OUT OF MEMORY'
IF @RC = 14 PRINT 'SP_TRACE_CREATE: INVALID STOP TIME'
IF @RC = 15 PRINT 'SP_TRACE_CREATE: INVALID PARAMETERS'
IF @RC <> 0 
	BEGIN
		PRINT 'SP_TRACE_CREATE: Confirm that directory '+@FILE_PATH+ ' exists'
		GOTO ERROR
	END


-- -----------------------------------------------------------------------
-- Set trace events to capture
-- -----------------------------------------------------------------------
IF @DURATION_SECS > 0
	BEGIN
		INSERT INTO @EVENTS_VAR VALUES(10) --  Stored Procedures: RPC:Completed
		INSERT INTO @EVENTS_VAR VALUES(45) --  Stored Procedures: SP:StmtCompleted
		INSERT INTO @EVENTS_VAR VALUES(12) --  TSQL: SQL:BatchCompleted
		INSERT INTO @EVENTS_VAR VALUES(41) --  TSQL: SQL:StmtCompleted
		INSERT INTO @EVENTS_VAR VALUES(43) --  Stored Procedures: SP:Completed  
	END
ELSE
	BEGIN
		INSERT INTO @EVENTS_VAR VALUES(55)	-- Hash Warning
		-- INSERT INTO @EVENTS_VAR VALUES(58)	-- Auto Stats
		INSERT INTO @EVENTS_VAR VALUES(60)	-- Lock Escalation
		INSERT INTO @EVENTS_VAR VALUES(67)	-- Execution Warnings
		INSERT INTO @EVENTS_VAR VALUES(80)	-- Missing Join Predicate
		INSERT INTO @EVENTS_VAR VALUES(92)	-- Data File Grow
		INSERT INTO @EVENTS_VAR VALUES(93)	-- Log File Grow
		INSERT INTO @EVENTS_VAR VALUES(137)	-- Blocked Process Report
		INSERT INTO @EVENTS_VAR VALUES(148)	-- Deadlock Graph
		--REH added these in 1.10
		INSERT INTO @EVENTS_VAR VALUES(94) --  Database: Data File Auto Shrink
		INSERT INTO @EVENTS_VAR VALUES(95) --  Database: Log File Auto Shrink
		INSERT INTO @EVENTS_VAR VALUES(155) --  Full text: FT:Crawl Started
		INSERT INTO @EVENTS_VAR VALUES(156) --  Full text: FT:Crawl Stopped
		INSERT INTO @EVENTS_VAR VALUES(157) --  Full text: FT:Crawl Aborted
		INSERT INTO @EVENTS_VAR VALUES(115) --  Security Audit: Audit Backup/Restore Event
	END

-- -----------------------------------------------------------------------
-- INSERT INTO @EVENTS_VAR VALUES(165)	-- Performance Statistics
-- -----------------------------------------------------------------------

-- -----------------------------------------------------------------------
-- Remaining events are provided here and can be enabled by uncommenting
-- Use EXTREME CAUTION as continous tracing of these events can introduce
-- significant overhead.
-- -----------------------------------------------------------------------


 --INSERT INTO @EVENTS_VAR VALUES(10) --  Stored Procedures: RPC:Completed
-- INSERT INTO @EVENTS_VAR VALUES(11) --  Stored Procedures: RPC:Starting
--INSERT INTO @EVENTS_VAR VALUES(12) --  TSQL: SQL:BatchCompleted
-- INSERT INTO @EVENTS_VAR VALUES(13) --  TSQL: SQL:BatchStarting
-- INSERT INTO @EVENTS_VAR VALUES(14) --  Security Audit: Audit Login
-- INSERT INTO @EVENTS_VAR VALUES(15) --  Security Audit: Audit Logout
 --INSERT INTO @EVENTS_VAR VALUES(16) --  Errors and Warnings: Attention  ---reh
-- INSERT INTO @EVENTS_VAR VALUES(17) --  Sessions: ExistingConnection
-- INSERT INTO @EVENTS_VAR VALUES(18) --  Security Audit: Audit Server Starts And Stops
-- INSERT INTO @EVENTS_VAR VALUES(19) --  Transactions: DTCTransaction
-- INSERT INTO @EVENTS_VAR VALUES(20) --  Security Audit: Audit Login Failed
-- INSERT INTO @EVENTS_VAR VALUES(21) --  Errors and Warnings: EventLog
-- INSERT INTO @EVENTS_VAR VALUES(22) --  Errors and Warnings: ErrorLog
-- INSERT INTO @EVENTS_VAR VALUES(23) --  Locks: Lock:Released
-- INSERT INTO @EVENTS_VAR VALUES(24) --  Locks: Lock:Acquired
-- INSERT INTO @EVENTS_VAR VALUES(25) --  Locks: Lock:Deadlock
-- INSERT INTO @EVENTS_VAR VALUES(26) --  Locks: Lock:Cancel
-- INSERT INTO @EVENTS_VAR VALUES(27) --  Locks: Lock:Timeout
-- INSERT INTO @EVENTS_VAR VALUES(28) --  Performance: Degree of Parallelism (7.0 Insert)
 --INSERT INTO @EVENTS_VAR VALUES(33) --  Errors and Warnings: Exception   ---reh
-- INSERT INTO @EVENTS_VAR VALUES(34) --  Stored Procedures: SP:CacheMiss
-- INSERT INTO @EVENTS_VAR VALUES(35) --  Stored Procedures: SP:CacheInsert
-- INSERT INTO @EVENTS_VAR VALUES(36) --  Stored Procedures: SP:CacheRemove
-- INSERT INTO @EVENTS_VAR VALUES(37) --  Stored Procedures: SP:Recompile
-- INSERT INTO @EVENTS_VAR VALUES(38) --  Stored Procedures: SP:CacheHit
-- INSERT INTO @EVENTS_VAR VALUES(39) --  Stored Procedures: Deprecated
-- INSERT INTO @EVENTS_VAR VALUES(40) --  TSQL: SQL:StmtStarting
 --INSERT INTO @EVENTS_VAR VALUES(41) --  TSQL: SQL:StmtCompleted
-- INSERT INTO @EVENTS_VAR VALUES(42) --  Stored Procedures: SP:Starting
 --INSERT INTO @EVENTS_VAR VALUES(43) --  Stored Procedures: SP:Completed   
-- INSERT INTO @EVENTS_VAR VALUES(44) --  Stored Procedures: SP:StmtStarting
 --INSERT INTO @EVENTS_VAR VALUES(45) --  Stored Procedures: SP:StmtCompleted  
-- INSERT INTO @EVENTS_VAR VALUES(46) --  Objects: Object:Created
-- INSERT INTO @EVENTS_VAR VALUES(47) --  Objects: Object:Deleted
-- INSERT INTO @EVENTS_VAR VALUES(50) --  Transactions: SQLTransaction
-- INSERT INTO @EVENTS_VAR VALUES(51) --  Scans: Scan:Started
-- INSERT INTO @EVENTS_VAR VALUES(52) --  Scans: Scan:Stopped
-- INSERT INTO @EVENTS_VAR VALUES(53) --  Cursors: CursorOpen
-- INSERT INTO @EVENTS_VAR VALUES(54) --  Transactions: TransactionLog
-- INSERT INTO @EVENTS_VAR VALUES(59) --  Locks: Lock:Deadlock Chain
-- INSERT INTO @EVENTS_VAR VALUES(60)   --  Locks: Lock:escalation
-- INSERT INTO @EVENTS_VAR VALUES(61) --  OLEDB: OLEDB Errors
 --INSERT INTO @EVENTS_VAR VALUES(68) --  Performance: Showplan Text (Unencoded)  
-- INSERT INTO @EVENTS_VAR VALUES(69) --  Errors and Warnings: Sort Warnings
-- INSERT INTO @EVENTS_VAR VALUES(70) --  Cursors: CursorPrepare
-- INSERT INTO @EVENTS_VAR VALUES(71) --  TSQL: Prepare SQL
-- INSERT INTO @EVENTS_VAR VALUES(72) --  TSQL: Exec Prepared SQL
-- INSERT INTO @EVENTS_VAR VALUES(73) --  TSQL: Unprepare SQL
-- INSERT INTO @EVENTS_VAR VALUES(74) --  Cursors: CursorExecute
-- INSERT INTO @EVENTS_VAR VALUES(75) --  Cursors: CursorRecompile
-- INSERT INTO @EVENTS_VAR VALUES(76)	-- Cursor Conversion
-- INSERT INTO @EVENTS_VAR VALUES(77) --  Cursors: CursorUnprepare
-- INSERT INTO @EVENTS_VAR VALUES(78) --  Cursors: CursorClose
--INSERT INTO @EVENTS_VAR VALUES(79)	-- Missing Column Statistics
-- INSERT INTO @EVENTS_VAR VALUES(81) --  Server: Server Memory Change
-- INSERT INTO @EVENTS_VAR VALUES(82) --  User configurable: UserConfigurable:0
-- INSERT INTO @EVENTS_VAR VALUES(83) --  User configurable: UserConfigurable:1
-- INSERT INTO @EVENTS_VAR VALUES(84) --  User configurable: UserConfigurable:2
-- INSERT INTO @EVENTS_VAR VALUES(85) --  User configurable: UserConfigurable:3
-- INSERT INTO @EVENTS_VAR VALUES(86) --  User configurable: UserConfigurable:4
-- INSERT INTO @EVENTS_VAR VALUES(87) --  User configurable: UserConfigurable:5
-- INSERT INTO @EVENTS_VAR VALUES(88) --  User configurable: UserConfigurable:6
-- INSERT INTO @EVENTS_VAR VALUES(89) --  User configurable: UserConfigurable:7
-- INSERT INTO @EVENTS_VAR VALUES(90) --  User configurable: UserConfigurable:8
-- INSERT INTO @EVENTS_VAR VALUES(91) --  User configurable: UserConfigurable:9
-- INSERT INTO @EVENTS_VAR VALUES(94) --  Database: Data File Auto Shrink
-- INSERT INTO @EVENTS_VAR VALUES(95) --  Database: Log File Auto Shrink
-- INSERT INTO @EVENTS_VAR VALUES(96) --  Performance: Showplan Text
-- INSERT INTO @EVENTS_VAR VALUES(97) --  Performance: Showplan All
-- INSERT INTO @EVENTS_VAR VALUES(98) --  Performance: Showplan Statistics Profile
-- INSERT INTO @EVENTS_VAR VALUES(100) --  Stored Procedures: RPC Output Parameter
-- INSERT INTO @EVENTS_VAR VALUES(102) --  Security Audit: Audit Database Scope GDR Event
-- INSERT INTO @EVENTS_VAR VALUES(103) --  Security Audit: Audit Schema Object GDR Event
-- INSERT INTO @EVENTS_VAR VALUES(104) --  Security Audit: Audit Addlogin Event
-- INSERT INTO @EVENTS_VAR VALUES(105) --  Security Audit: Audit Login GDR Event
-- INSERT INTO @EVENTS_VAR VALUES(106) --  Security Audit: Audit Login Change Property Event
-- INSERT INTO @EVENTS_VAR VALUES(107) --  Security Audit: Audit Login Change Password Event
-- INSERT INTO @EVENTS_VAR VALUES(108) --  Security Audit: Audit Add Login to Server Role Event
-- INSERT INTO @EVENTS_VAR VALUES(109) --  Security Audit: Audit Add DB User Event
-- INSERT INTO @EVENTS_VAR VALUES(110) --  Security Audit: Audit Add Member to DB Role Event
-- INSERT INTO @EVENTS_VAR VALUES(111) --  Security Audit: Audit Add Role Event
-- INSERT INTO @EVENTS_VAR VALUES(112) --  Security Audit: Audit App Role Change Password Event
-- INSERT INTO @EVENTS_VAR VALUES(113) --  Security Audit: Audit Statement Permission Event
-- INSERT INTO @EVENTS_VAR VALUES(114) --  Security Audit: Audit Schema Object Access Event
-- INSERT INTO @EVENTS_VAR VALUES(115) --  Security Audit: Audit Backup/Restore Event
-- INSERT INTO @EVENTS_VAR VALUES(116) --  Security Audit: Audit DBCC Event
-- INSERT INTO @EVENTS_VAR VALUES(117) --  Security Audit: Audit Change Audit Event
-- INSERT INTO @EVENTS_VAR VALUES(118) --  Security Audit: Audit Object Derived Permission Event
-- INSERT INTO @EVENTS_VAR VALUES(119) --  OLEDB: OLEDB Call Event
-- INSERT INTO @EVENTS_VAR VALUES(120) --  OLEDB: OLEDB QueryInterface Event
-- INSERT INTO @EVENTS_VAR VALUES(121) --  OLEDB: OLEDB DataRead Event
-- INSERT INTO @EVENTS_VAR VALUES(122) --  Performance: Showplan XML
-- INSERT INTO @EVENTS_VAR VALUES(123) --  Performance: SQL:FullTextQuery
-- INSERT INTO @EVENTS_VAR VALUES(124) --  Broker: Broker:Conversation
-- INSERT INTO @EVENTS_VAR VALUES(125) --  Deprecation: Deprecation Announcement
-- INSERT INTO @EVENTS_VAR VALUES(126) --  Deprecation: Deprecation Final Support
-- INSERT INTO @EVENTS_VAR VALUES(127) --  Errors and Warnings: Exchange Spill Event
-- INSERT INTO @EVENTS_VAR VALUES(128) --  Security Audit: Audit Database Management Event
-- INSERT INTO @EVENTS_VAR VALUES(129) --  Security Audit: Audit Database Object Management Event
-- INSERT INTO @EVENTS_VAR VALUES(130) --  Security Audit: Audit Database Principal Management Event
-- INSERT INTO @EVENTS_VAR VALUES(131) --  Security Audit: Audit Schema Object Management Event
-- INSERT INTO @EVENTS_VAR VALUES(132) --  Security Audit: Audit Server Principal Impersonation Event
-- INSERT INTO @EVENTS_VAR VALUES(133) --  Security Audit: Audit Database Principal Impersonation Event
-- INSERT INTO @EVENTS_VAR VALUES(134) --  Security Audit: Audit Server Object Take Ownership Event
-- INSERT INTO @EVENTS_VAR VALUES(135) --  Security Audit: Audit Database Object Take Ownership Event
-- INSERT INTO @EVENTS_VAR VALUES(136) --  Broker: Broker:Conversation Group
-- INSERT INTO @EVENTS_VAR VALUES(138) --  Broker: Broker:Connection
-- INSERT INTO @EVENTS_VAR VALUES(139) --  Broker: Broker:Forwarded Message Sent
-- INSERT INTO @EVENTS_VAR VALUES(140) --  Broker: Broker:Forwarded Message Dropped
-- INSERT INTO @EVENTS_VAR VALUES(141) --  Broker: Broker:Message Classify
-- INSERT INTO @EVENTS_VAR VALUES(142) --  Broker: Broker:Transmission
-- INSERT INTO @EVENTS_VAR VALUES(143) --  Broker: Broker:Queue Disabled
-- INSERT INTO @EVENTS_VAR VALUES(144) --  Broker: Broker:Mirrored Route State Changed
-- INSERT INTO @EVENTS_VAR VALUES(146) --  Performance: Showplan XML Statistics Profile
-- INSERT INTO @EVENTS_VAR VALUES(149) --  Broker: Broker:Remote Message Acknowledgement
-- INSERT INTO @EVENTS_VAR VALUES(150) --  Server: Trace File Close
-- INSERT INTO @EVENTS_VAR VALUES(152) --  Security Audit: Audit Change Database Owner
-- INSERT INTO @EVENTS_VAR VALUES(153) --  Security Audit: Audit Schema Object Take Ownership Event
-- INSERT INTO @EVENTS_VAR VALUES(155) --  Full text: FT:Crawl Started
-- INSERT INTO @EVENTS_VAR VALUES(156) --  Full text: FT:Crawl Stopped
-- INSERT INTO @EVENTS_VAR VALUES(157) --  Full text: FT:Crawl Aborted
-- INSERT INTO @EVENTS_VAR VALUES(158) --  Security Audit: Audit Broker Conversation
-- INSERT INTO @EVENTS_VAR VALUES(159) --  Security Audit: Audit Broker Login
-- INSERT INTO @EVENTS_VAR VALUES(160) --  Broker: Broker:Message Undeliverable
-- INSERT INTO @EVENTS_VAR VALUES(161) --  Broker: Broker:Corrupted Message
-- INSERT INTO @EVENTS_VAR VALUES(162) --  Errors and Warnings: User Error Message
-- INSERT INTO @EVENTS_VAR VALUES(163) --  Broker: Broker:Activation
-- INSERT INTO @EVENTS_VAR VALUES(164) --  Objects: Object:Altered
-- INSERT INTO @EVENTS_VAR VALUES(166) --  TSQL: SQL:StmtRecompile
-- INSERT INTO @EVENTS_VAR VALUES(167) --  Database: Database Mirroring State Change
-- INSERT INTO @EVENTS_VAR VALUES(168) --  Performance: Showplan XML For Query Compile
-- INSERT INTO @EVENTS_VAR VALUES(169) --  Performance: Showplan All For Query Compile
-- INSERT INTO @EVENTS_VAR VALUES(170) --  Security Audit: Audit Server Scope GDR Event
-- INSERT INTO @EVENTS_VAR VALUES(171) --  Security Audit: Audit Server Object GDR Event
-- INSERT INTO @EVENTS_VAR VALUES(172) --  Security Audit: Audit Database Object GDR Event
-- INSERT INTO @EVENTS_VAR VALUES(173) --  Security Audit: Audit Server Operation Event
-- INSERT INTO @EVENTS_VAR VALUES(175) --  Security Audit: Audit Server Alter Trace Event
-- INSERT INTO @EVENTS_VAR VALUES(176) --  Security Audit: Audit Server Object Management Event
-- INSERT INTO @EVENTS_VAR VALUES(177) --  Security Audit: Audit Server Principal Management Event
-- INSERT INTO @EVENTS_VAR VALUES(178) --  Security Audit: Audit Database Operation Event
-- INSERT INTO @EVENTS_VAR VALUES(180) --  Security Audit: Audit Database Object Access Event
-- INSERT INTO @EVENTS_VAR VALUES(181) --  Transactions: TM: Begin Tran starting
-- INSERT INTO @EVENTS_VAR VALUES(182) --  Transactions: TM: Begin Tran completed
-- INSERT INTO @EVENTS_VAR VALUES(183) --  Transactions: TM: Promote Tran starting
-- INSERT INTO @EVENTS_VAR VALUES(184) --  Transactions: TM: Promote Tran completed
-- INSERT INTO @EVENTS_VAR VALUES(185) --  Transactions: TM: Commit Tran starting
-- INSERT INTO @EVENTS_VAR VALUES(186) --  Transactions: TM: Commit Tran completed
-- INSERT INTO @EVENTS_VAR VALUES(187) --  Transactions: TM: Rollback Tran starting
-- INSERT INTO @EVENTS_VAR VALUES(188) --  Transactions: TM: Rollback Tran completed
-- INSERT INTO @EVENTS_VAR VALUES(189) --  Locks: Lock:Timeout (timeout > 0)
-- INSERT INTO @EVENTS_VAR VALUES(190) --  Progress Report: Progress Report: Online Index Operation
-- INSERT INTO @EVENTS_VAR VALUES(191) --  Transactions: TM: Save Tran starting
-- INSERT INTO @EVENTS_VAR VALUES(192) --  Transactions: TM: Save Tran completed
-- INSERT INTO @EVENTS_VAR VALUES(193) --  Errors and Warnings: Background Job Error
-- INSERT INTO @EVENTS_VAR VALUES(194) --  OLEDB: OLEDB Provider Information
-- INSERT INTO @EVENTS_VAR VALUES(195) --  Server: Mount Tape
-- INSERT INTO @EVENTS_VAR VALUES(196) --  CLR: Assembly Load
-- INSERT INTO @EVENTS_VAR VALUES(198) --  TSQL: XQuery Static Type
-- INSERT INTO @EVENTS_VAR VALUES(199) --  Query Notifications: QN: Subscription
-- INSERT INTO @EVENTS_VAR VALUES(200) --  Query Notifications: QN: Parameter table
-- INSERT INTO @EVENTS_VAR VALUES(201) --  Query Notifications: QN: Template
-- INSERT INTO @EVENTS_VAR VALUES(202) --  Query Notifications: QN: Dynamics


-- -----------------------------------------------------------------------
-- Set the events and columns to capture.  
-- Join the list of events (@EVENTS_VAR) 
-- to their valid columns (from sys.trace_event_bindings) 
-- and execute sp_trace_setevent for each event/column combination
-- -----------------------------------------------------------------------
DECLARE SETEVENTS CURSOR FOR
	SELECT	trace_event_id, trace_column_id
	FROM	@EVENTS_VAR, sys.trace_event_bindings
	WHERE	EVENT_ID = trace_event_id
	ORDER BY 1,2

OPEN	SETEVENTS
FETCH	SETEVENTS INTO @EVENT_ID, @COLUMN_ID
WHILE	@@FETCH_STATUS = 0
	BEGIN
		exec sp_trace_setevent @TRACEID, @EVENT_ID, @COLUMN_ID, @ON
		FETCH	SETEVENTS INTO @EVENT_ID, @COLUMN_ID
	END
DEALLOCATE SETEVENTS


-- -----------------------------------------------------------------------
-- Set filters
-- -----------------------------------------------------------------------
IF @HOSTNAME IS NOT NULL
	EXEC sp_trace_setfilter @TRACEID, 7,0,6, @HOSTNAME
-- -----------------------------------------------------------------------
--  Filter on Database ID if Database Name is supplied
-- -----------------------------------------------------------------------

IF @DATABASE_NAME IS NOT NULL
	EXEC sp_trace_setfilter @TRACEID,  3, 0, 0, @DATABASE_ID

-- -----------------------------------------------------------------------
--   Applicationname not like 'sql profiler'
-- -----------------------------------------------------------------------
EXEC sp_trace_setfilter @TRACEID, 10, 0, 7, N'SQL PROFILER'


-- -----------------------------------------------------------------------
--   Database name not like 'DynamicsPerf'
-- -----------------------------------------------------------------------
EXEC sp_trace_setfilter @TRACEID, 35, 0, 7, N'DynamicsPerf%'

--  If@DURATION_SECS is specified, add events and set duration filter

IF @DURATION_SECS > 0
	BEGIN
		EXEC sp_trace_setfilter @TRACEID, 13, 0, 4, @DURATION_SECS
	END

-- -----------------------------------------------------------------------
--   Objectid >= 100 (excludes system objects)
-- -----------------------------------------------------------------------
--EXEC sp_trace_setfilter @TRACEID, 22, 0, 4, 100

-- -----------------------------------------------------------------------
-- Start the trace
-- -----------------------------------------------------------------------

EXEC @RC = sp_trace_setstatus @TRACEID, 1

IF @RC = 0  PRINT 'SP_TRACE_SETSTATUS: STARTED TRACE ID  ' + STR(@TRACEID )
IF @RC = 1  PRINT 'SP_TRACE_SETSTATUS: - UNKNOWN ERROR'
IF @RC = 8  PRINT 'SP_TRACE_SETSTATUS: THE SPECIFIED STATUS IS NOT VALID'
IF @RC = 9  PRINT 'SP_TRACE_SETSTATUS: THE SPECIFIED TRACE HANDLE IS NOT VALID'
IF @RC = 13 PRINT 'SP_TRACE_SETSTATUS: OUT OF MEMORY'

IF @DURATION_SECS > 0
	BEGIN
	PRINT ''
	--Don't update the trace file path as this is not our default trace we are creating
	END
ELSE
	BEGIN
		UPDATE DynamicsPerf..DYNAMICSPERF_SETUP SET TRACE_FULL_PATH_NAME = @FILE_PATH 	+ '\' + @TRACE_NAME +'.trc'
	END

ENDPROC:




ERROR:
RETURN @RC

GO


USE [DynamicsPerf]
GO

/****** Object:  StoredProcedure [dbo].[SP_CAPTURESTATS_CORE]    Script Date: 02/28/2011 13:15:10 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SP_CAPTURESTATS_CORE]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SP_CAPTURESTATS_CORE]
GO

USE [DynamicsPerf]
GO

/****** Object:  StoredProcedure [dbo].[SP_CAPTURESTATS_CORE]    Script Date: 02/28/2011 13:15:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE	PROCEDURE [dbo].[SP_CAPTURESTATS_CORE]
		@DATABASE_NAME	NVARCHAR(128),	
		@TOP_ROWS		INT = 0,
		@TOP_COLUMN		NVARCHAR(128) = 'total_elapsed_time',
		@RUN_NAME		NVARCHAR(60) = NULL,
		@INDEX_PHYSICAL_STATS 	NVARCHAR(1)= 'N',
		@STATS_DATE		DATETIME,
		@DEBUG			NVARCHAR(1) = 'N',
		@SKIP_STATS NVARCHAR(1) = 'Y'
AS

SET NOCOUNT ON
SET DATEFORMAT MDY

DECLARE 
		@LAST_STATS_DATE DATETIME,
		@SQL_VERSION	NVARCHAR(1000), 
		@DYNAMICS_VERSION NVARCHAR(MAX),
		@DATABASE_ID	INT,
		@RETURN_CODE	INT ,
		@SQL			NVARCHAR(MAX),
		@RUN_DESCRIPTION NVARCHAR(1000),
		@SQL_TOP_CLAUSE	NVARCHAR(128),
		@SQL_ORDERBY_CLAUSE	NVARCHAR(128),
		@PARM			NVARCHAR(500),
		@SQL_SERVER_STARTTIME DATETIME   

SET @RETURN_CODE = 0
SET @DYNAMICS_VERSION = 'Not a Dynamics Database'
SET @SQL_VERSION = @@VERSION




-- -----------------------------------------------------------------------------------------
-- Establish the clauses for the SQL that will collect data from the query stats DMV
-- If both TOP row count and a valid column to order by have been requested 
-- then we we will build TOP  and ORDER BY DESC clauses for the query on sys.dm_exec_query_stats.
-- -----------------------------------------------------------------------------------------
IF @TOP_ROWS	IS NULL SET @TOP_ROWS = 0
IF @TOP_COLUMN	IS NULL SET @TOP_COLUMN = ''

IF	@TOP_ROWS = 0 OR @TOP_COLUMN = ''
	BEGIN
		SET @SQL_TOP_CLAUSE = 'SELECT '
		SET @RUN_DESCRIPTION = 'N/A'
	END
ELSE
	SET	@SQL_TOP_CLAUSE = 'SELECT TOP '+STR(@TOP_ROWS)+' '
IF @TOP_ROWS = 0
    OR @TOP_COLUMN = ''
  SET @SQL_ORDERBY_CLAUSE = ' '
ELSE
  BEGIN
      IF @TOP_COLUMN NOT IN ( 'execution_count', 'total_worker_time', 'last_worker_time', 'min_worker_time',
                              'max_worker_time', 'total_physical_reads', 'last_physical_reads', 'min_physical_reads',
                              'max_physical_reads', 'total_logical_writes', 'last_logical_writes', 'min_logical_writes',
                              'max_logical_writes', 'total_logical_reads', 'last_logical_reads', 'min_logical_reads',
                              'max_logical_reads', 'total_clr_time', 'last_clr_time', 'min_clr_time',
                              'max_clr_time', 'total_elapsed_time', 'last_elapsed_time', 'min_elapsed_time', 'max_elapsed_time' )
        BEGIN
            PRINT @TOP_COLUMN + ' Is not valid as top column from sys.dm_exec_query_stats'

            GOTO ENDPROC
        END
      ELSE
        BEGIN
            SET @SQL_ORDERBY_CLAUSE = ' ORDER BY ' + @TOP_COLUMN + ' DESC  '
            SET @RUN_DESCRIPTION = @SQL_TOP_CLAUSE + 'sys.dm_exec_query_stats' + @SQL_ORDERBY_CLAUSE
        END
  END 

-- -----------------------------------------------------------------------------------------
-- If @RUN_NAME is not specified, just use current date/time
-- -----------------------------------------------------------------------------------------

If @RUN_NAME IS NULL
	SET @RUN_NAME = CONVERT(VARCHAR, @STATS_DATE,101)

SELECT @SQL_SERVER_STARTTIME = MIN(login_time) FROM sys.sysprocesses

IF @DEBUG = 'Y' 
BEGIN
PRINT '@STATS_DATE= ' + cast(@STATS_DATE as nvarchar(50))
PRINT '@RUN_NAME= ' + @RUN_NAME
PRINT '@DATABASE_NAME= ' + @DATABASE_NAME
PRINT '@SQL_SERVER_STARTTIME= ' + cast(@SQL_SERVER_STARTTIME as nvarchar(50))
END

--PRINT @STATS_DATE
--PRINT @RUN_NAME
--PRINT @DATABASE_NAME

--BEGIN TRANSACTION
-- -----------------------------------------------------------------------------------------
-- STATS_COLLECTION_SUMMARY will have one row for each time we execute SP_CAPTURESTATS
-- -----------------------------------------------------------------------------------------
BEGIN TRY
PRINT 'STEP Insert STATS_COLLECTION_SUMMARY record' + ' at ' + CONVERT(VARCHAR, GETDATE(),109)

DECLARE db_cursor CURSOR  LOCAL
FOR

SELECT DATABASENAME
FROM   DynamicsPerf..COLLECTIONDATABASES
ORDER  BY DATABASENAME 


/* Open the cursor */
/*if the cursor isn't open you will get an error when you fetch the record*/
OPEN db_cursor 

/* Get the first record */
/* you can FETCH NEXT, FIRST, LAST, PREVIOUS */
FETCH NEXT FROM db_cursor INTO @DATABASE_NAME

/* Verify that we got a record*/
/* status 0 means we got a good record*/

WHILE @@fetch_status = 0  /* no errors */
BEGIN /* Top of Loop */

INSERT INTO STATS_COLLECTION_SUMMARY
VALUES     ( @STATS_DATE,
             @RUN_NAME,
             @DATABASE_NAME,
             @SQL_VERSION,
             @DYNAMICS_VERSION,
             @RUN_DESCRIPTION,
             @SQL_SERVER_STARTTIME,
             'N') 
            
            
FETCH NEXT FROM db_cursor INTO @DATABASE_NAME
END  /*End of the loop */
CLOSE db_cursor  /*close the cursor to free memory in SQL*/
DEALLOCATE db_cursor /*Must deallocate the cursor to destroy it and free SQL resources*/
 
PRINT 'Completed Successfully'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'Inserted STATS_COLLECTION_SUMMARY SUCCESSFULLY at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE
             
END TRY

BEGIN CATCH
PRINT 'Step failed to complete !!' + ' at ' + CONVERT(VARCHAR, GETDATE(),109)
UPDATE CAPTURE_LOG SET TEXT = TEXT + 'FAILED TO insert STATS_COLLECTION_SUMMARY at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE
END CATCH


BEGIN TRY
PRINT 'STEP Insert INDEX_OPERATIONAL_STATS'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

DECLARE db_cursor CURSOR  LOCAL
FOR

SELECT DATABASENAME
FROM   DynamicsPerf..COLLECTIONDATABASES
ORDER  BY DATABASENAME 


/* Open the cursor */
/*if the cursor isn't open you will get an error when you fetch the record*/
OPEN db_cursor 

/* Get the first record */
/* you can FETCH NEXT, FIRST, LAST, PREVIOUS */
FETCH NEXT FROM db_cursor INTO @DATABASE_NAME

/* Verify that we got a record*/
/* status 0 means we got a good record*/

WHILE @@fetch_status = 0  /* no errors */
BEGIN /* Top of Loop */


SELECT @DATABASE_ID = database_id FROM sys.databases WITH (NOLOCK) WHERE name = @DATABASE_NAME

INSERT INTO INDEX_OPERATIONAL_STATS WITH (TABLOCK)
SELECT
	 @STATS_DATE AS current_datetime
	,@DATABASE_NAME
	,object_id
	,index_id
	,leaf_insert_count
	,leaf_delete_count
	,leaf_update_count
	,leaf_ghost_count
	,nonleaf_insert_count
	,nonleaf_delete_count
	,nonleaf_update_count
	,leaf_allocation_count
	,nonleaf_allocation_count
	,leaf_page_merge_count
	,nonleaf_page_merge_count
	,range_scan_count
	,singleton_lookup_count
	,forwarded_fetch_count
	,lob_fetch_in_pages
	,lob_fetch_in_bytes
	,lob_orphan_create_count
	,lob_orphan_insert_count
	,row_overflow_fetch_in_pages
	,row_overflow_fetch_in_bytes
	,column_value_push_off_row_count
	,column_value_pull_in_row_count
	,row_lock_count
	,row_lock_wait_count
	,row_lock_wait_in_ms
	,page_lock_count
	,page_lock_wait_count
	,page_lock_wait_in_ms
	,index_lock_promotion_attempt_count
	,index_lock_promotion_count
	,page_latch_wait_count
	,page_latch_wait_in_ms
	,page_io_latch_wait_count
	,page_io_latch_wait_in_ms
FROM sys.dm_db_index_operational_stats(@DATABASE_ID, NULL, NULL, NULL)
WHERE object_id > 99




FETCH NEXT FROM db_cursor INTO @DATABASE_NAME
END  /*End of the loop */
CLOSE db_cursor  /*close the cursor to free memory in SQL*/
DEALLOCATE db_cursor /*Must deallocate the cursor to destroy it and free SQL resources*/
 
			
			
PRINT 'Completed Successfully'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)
UPDATE CAPTURE_LOG SET TEXT = TEXT + 'Inserted INDEX_OPERATIONAL_STATS SUCCESSFULLY at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE
             
END TRY

BEGIN CATCH
PRINT 'Step failed to complete !!'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)
UPDATE CAPTURE_LOG SET TEXT = TEXT + 'FAILED TO insert INDEX_OPERATIONAL_STATS at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE

END CATCH

-- -----------------------------------------------------------------------------------------
-- Because sys.dm_db_index_physical_stats is more expensive to collect, it is enabled
-- by @INDEX_PHYSICAL_STATS set to 'Y'.  The default is 'N' which bypassed.
-- -----------------------------------------------------------------------------------------
IF @INDEX_PHYSICAL_STATS = 'Y'

BEGIN TRY
PRINT 'STEP Insert INDEX_PHYSICAL_STATS'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)


DECLARE db_cursor CURSOR  LOCAL
FOR

SELECT DATABASENAME
FROM   DynamicsPerf..COLLECTIONDATABASES
ORDER  BY DATABASENAME 


/* Open the cursor */
/*if the cursor isn't open you will get an error when you fetch the record*/
OPEN db_cursor 

/* Get the first record */
/* you can FETCH NEXT, FIRST, LAST, PREVIOUS */
FETCH NEXT FROM db_cursor INTO @DATABASE_NAME

/* Verify that we got a record*/
/* status 0 means we got a good record*/

WHILE @@fetch_status = 0  /* no errors */
BEGIN /* Top of Loop */

SELECT @DATABASE_ID = database_id FROM sys.databases WITH (NOLOCK) WHERE name = @DATABASE_NAME


	INSERT INTO INDEX_PHYSICAL_STATS WITH (TABLOCK)
	SELECT
		 @STATS_DATE
		,@DATABASE_NAME
		, object_id
		, index_id
		,partition_number
		,index_type_desc
		,alloc_unit_type_desc
		,index_depth
		,avg_fragmentation_in_percent
		,fragment_count
		,avg_fragment_size_in_pages
	FROM sys.dm_db_index_physical_stats(@DATABASE_ID, NULL, NULL, NULL,NULL)
	WHERE object_id > 99



FETCH NEXT FROM db_cursor INTO @DATABASE_NAME
END  /*End of the loop */
CLOSE db_cursor  /*close the cursor to free memory in SQL*/
DEALLOCATE db_cursor /*Must deallocate the cursor to destroy it and free SQL resources*/
 
			
PRINT 'Completed Successfully'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)
UPDATE CAPTURE_LOG SET TEXT = TEXT + 'Inserted INDEX_PHYSICAL_STATS SUCCESSFULLY at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE
             
             
END TRY

BEGIN CATCH
PRINT 'Step failed to complete !!'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)
UPDATE CAPTURE_LOG SET TEXT = TEXT + 'FAILED TO insert INDEX_PHYSICAL_STATS at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE

END CATCH
	
	

IF @LAST_STATS_DATE IS NULL 
	SET @LAST_STATS_DATE = '1900-01-01'
-- -----------------------------------------------------------------------------------------
-- Dynamicaly build the SQL to retreive data from sys.dm_exec_query_stats.  This is needed due
-- sdue to the variability in what we need to do: the parameterized TOP and ORDER BY clauses 
-- plus establishing the date /time from which stats are to be collected. 
-- -----------------------------------------------------------------------------------------

DECLARE @SQLversion VARCHAR(30)
SELECT @SQLversion = cast(SERVERPROPERTY('ProductVersion') as varchar(30))


DECLARE db_cursor CURSOR  LOCAL
FOR

SELECT DATABASENAME
FROM   DynamicsPerf..COLLECTIONDATABASES
ORDER  BY DATABASENAME 


/* Open the cursor */
/*if the cursor isn't open you will get an error when you fetch the record*/
OPEN db_cursor 

/* Get the first record */
/* you can FETCH NEXT, FIRST, LAST, PREVIOUS */
FETCH NEXT FROM db_cursor INTO @DATABASE_NAME

/* Verify that we got a record*/
/* status 0 means we got a good record*/

WHILE @@fetch_status = 0  /* no errors */
BEGIN /* Top of Loop */
--PRINT 'DATABASE ='+@DATABASE_NAME

--REH    Deal with LAST_STATS_DATE for each database, moved the code from sp_capturestats to here to support multiple database captures
									
									
SET @LAST_STATS_DATE = '1/1/1900' 									
									
SELECT TOP 1 @LAST_STATS_DATE = STATS_TIME
FROM   STATS_COLLECTION_SUMMARY WITH (NOLOCK)
WHERE  STATS_TIME < @STATS_DATE
       AND DATABASE_NAME = @DATABASE_NAME
ORDER  BY STATS_TIME DESC

--REH if we are doing a baseline capture @RUN_NAME like 'BASE%' then use 1/1/1900
IF @RUN_NAME LIKE 'BASE%' 
BEGIN 
SET @LAST_STATS_DATE = '1/1/1900' 	
END

IF @DEBUG = 'Y'
  BEGIN
      PRINT '@LAST_STATS_DATE='

      PRINT @LAST_STATS_DATE
  END 

SET @SQL = 'INSERT INTO QUERY_STATS WITH (TABLOCK) ' 
	+ @SQL_TOP_CLAUSE + 'min(''' + CONVERT(NVARCHAR(24), @STATS_DATE, 121) + '''),' 
	+ 'min(''' + @DATABASE_NAME + ''')' +
	+ ',
	min(sql_handle),
	min(plan_handle),max(plan_generation_num), min(creation_time),max(last_execution_time),
	sum(execution_count), 
	sum(total_worker_time), 
	avg(last_worker_time), 
	min(min_worker_time), 
	max(max_worker_time), 
	sum(total_physical_reads), 
	avg(last_physical_reads), 
	min(min_physical_reads), 
	max(max_physical_reads), 
	sum(total_logical_writes), 
	avg(last_logical_writes), 
	min(min_logical_writes), 
	max(max_logical_writes), 
	sum(total_logical_reads), 
	avg(last_logical_reads), 
	min(min_logical_reads), 
	max(max_logical_reads), 
	sum(total_clr_time), 
	avg(last_clr_time), 
	min(min_clr_time), 
	max(max_clr_time), 
	sum(total_elapsed_time), 
	avg(last_elapsed_time), 
	min(min_elapsed_time), 
	max(max_elapsed_time),
	query_hash,
	query_plan_hash,
	sum(0)' --SQL2008 this column should be 0 for plan_handle_internal, so we join internally only on query_plan_hash

  
  --REH SQL2008R2 SP1 and above added the rows columns to this dmv
IF Serverproperty('ProductVersion') >= '10.50.2500'
  BEGIN
      SELECT @SQL = @SQL + ',sum(total_rows), avg(last_rows), max(max_rows), min(min_rows)'
  END
ELSE
  BEGIN
      SELECT @SQL = @SQL + ',sum(0),sum(0),sum(0),sum(0)'
  END 

SELECT @SQL = @SQL + '  
FROM	sys.dm_exec_query_stats
OUTER	APPLY sys.dm_exec_plan_attributes (plan_handle)
WHERE	attribute = N''dbid'' 
AND		dB_name(CONVERT(INT,value)) = ''' + @DATABASE_NAME + '''' + ' AND last_execution_time >= ' + '''' + CONVERT(NVARCHAR(24), @LAST_STATS_DATE, 121) + '''' 
+ ' group by query_hash, query_plan_hash

' + @SQL_ORDERBY_CLAUSE



IF @DEBUG = 'Y' 
BEGIN
PRINT '@SQL= ' + @SQL
END


BEGIN TRY
PRINT 'STEP Insert QUERY_STATS for Database ' + @DATABASE_NAME
EXEC (@SQL) 
PRINT 'Completed Successfully'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'Inserted QUERY_STATS SUCCESSFULLY for Database ' + @DATABASE_NAME + ' at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE
             
END TRY



BEGIN CATCH
PRINT 'Step failed to complete !!'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'FAILED TO insert QUERY_STATS for Database ' + @DATABASE_NAME + ' at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE

END CATCH

--REH Insert the SQL_TEXT statements


SET @SQL = '
CREATE TABLE [#QUERY_TEXT]
  (
	 [ROW_NUM]				[INT] identity(1,1),
     [QUERY_HASH]             [BINARY](8) NOT NULL,
     [SQL_TEXT]            [NVARCHAR](MAX) NULL,
  
  )
  
INSERT INTO #QUERY_TEXT  WITH (TABLOCK) ' +'
SELECT  qs.query_hash,
SUBSTRING(st.text, (qs.statement_start_offset/2)+1, 
        ((CASE qs.statement_end_offset
          WHEN -1 THEN DATALENGTH(st.text)
         ELSE qs.statement_end_offset
         END - qs.statement_start_offset)/2) + 1)'

SELECT @SQL = @SQL + ' 
FROM	sys.dm_exec_query_stats AS qs
OUTER	APPLY sys.dm_exec_plan_attributes (qs.PLAN_HANDLE)
CROSS APPLY sys.dm_exec_sql_text(qs.SQL_HANDLE) AS st
WHERE	attribute = N''dbid'' 
AND		dB_name(CONVERT(INT,value)) = ''' + @DATABASE_NAME + '''' + ' AND last_execution_time >= ' + '''' + CONVERT(NVARCHAR(24), @LAST_STATS_DATE, 121) + '''' 
+ ' AND NOT EXISTS (SELECT QUERY_HASH FROM QUERY_TEXT qt WHERE qt.QUERY_HASH = qs.query_hash)'


SELECT @SQL = @SQL + ' 

DELETE QT FROM  #QUERY_TEXT QT WHERE ROW_NUM NOT IN
 (SELECT MIN(ROW_NUM) FROM #QUERY_TEXT GROUP BY QUERY_HASH)

INSERT QUERY_TEXT SELECT QUERY_HASH, SQL_TEXT FROM #QUERY_TEXT


DROP TABLE #QUERY_TEXT'



IF @DEBUG = 'Y' 
BEGIN
PRINT '@SQL= ' + @SQL
END



BEGIN TRY
PRINT 'STEP Insert SQL_TEXT for Database ' + @DATABASE_NAME
EXEC (@SQL) 
PRINT 'Completed Successfully'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'Inserted SQL_TEXT SUCCESSFULLY for Database ' + @DATABASE_NAME + ' at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE
             
END TRY



BEGIN CATCH

PRINT 'Step failed to complete !!'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'FAILED TO insert SQL_TEXT for Database ' + @DATABASE_NAME + ' at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE

END CATCH




FETCH NEXT FROM db_cursor INTO @DATABASE_NAME
END  /*End of the loop */
CLOSE db_cursor  /*close the cursor to free memory in SQL*/
DEALLOCATE db_cursor /*Must deallocate the cursor to destroy it and free SQL resources*/
 
						

BEGIN TRY
PRINT 'STEP Insert QUERY_PLANS'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

/******************************************************************************************
*
* We are using the PLAN_HANDLE_INTERNAL column for the join between Query_Stats
*    and QUERY_Plans.  This field should be 0x000 on SQL2008+ because we only 
*	 want to join on QUERY_PLAN_HASH so we keep unique copies of plans to reduce 
*	 database size.  We can't just 0 out the plan_handle in the insert of query_stats
*	 because we need that column in this query so we can actually look up the plan
*	 to insert it.
*
******************************************************************************************/

CREATE TABLE [dbo].[#QUERY_PLANS_TEMP]
  (
     [STATS_TIME]      [DATETIME]  NULL,
     [DATABASE_NAME]   [NVARCHAR](128)  NULL,
     [PLAN_HANDLE]     [BINARY](64)  NULL,
     [QUERY_PLAN_HASH] [BINARY](8)  NULL,
     [QUERY_PLAN]      [XML] NULL
  )



;WITH Query_Stats_CTE ( QUERY_PLAN_HASH)
AS
-- Define the CTE query.
(
    SELECT DISTINCT  QUERY_PLAN_HASH
    FROM QUERY_STATS as QS WHERE STATS_TIME = @STATS_DATE
                     AND     NOT EXISTS (SELECT 'X'
                                  FROM   QUERY_PLANS QP
                                  WHERE  QP.QUERY_PLAN_HASH = QS.QUERY_PLAN_HASH) 
)
INSERT [#QUERY_PLANS_TEMP]
SELECT @STATS_DATE,@DATABASE_NAME, 0X00, QUERY_PLAN_HASH,''  FROM Query_Stats_CTE

--print 'step 1'
--SELECT TOP 1 QS.PLAN_HANDLE, PLNS.plan_handle
--                       FROM   --QUERY_STATS QS
--							sys.dm_exec_cached_plans PLNS   --REH removed this code since we weren't using any columns from the PLNS table, this was a perf change 
--                              INNER JOIN QUERY_STATS QS
--                                ON QS.PLAN_HANDLE = PLNS.plan_handle
--                              OUTER APPLY sys.dm_exec_query_plan(PLNS.PLAN_HANDLE)
--                       WHERE
                       
--                       QS.STATS_TIME = @STATS_DATE  




UPDATE [#QUERY_PLANS_TEMP]
SET    [QUERY_PLAN] = (SELECT TOP 1 QUERY_PLAN
                       FROM   QUERY_STATS QS
							--sys.dm_exec_cached_plans PLNS   --REH removed this code since we weren't using any columns from the PLNS table, this was a perf change 
       --                       INNER JOIN QUERY_STATS QS
       --                         ON QS.PLAN_HANDLE = PLNS.plan_handle
                              OUTER APPLY sys.dm_exec_query_plan(QS.PLAN_HANDLE)
                       WHERE
                       T1.QUERY_PLAN_HASH = QS.QUERY_PLAN_HASH AND
                       QS.STATS_TIME = @STATS_DATE  )
                      --REH if the plan already exists dont insert a new one, only keep 1 copy of the plan

FROM [#QUERY_PLANS_TEMP] T1

DELETE FROM [#QUERY_PLANS_TEMP] WHERE QUERY_PLAN IS NULL

BEGIN TRY

;WITH XMLNAMESPACES ('http://schemas.microsoft.com/sqlserver/2004/07/showplan' AS sp)
INSERT INTO QUERY_PLANS WITH (TABLOCK)
SELECT * FROM (
SELECT     QT.[QUERY_PLAN_HASH],QT.[QUERY_PLAN],
 CONVERT (NVARCHAR(MAX), index_node.query('for $qplan in //sp:QueryPlan, $plist in $qplan/sp:ParameterList, $colref in $plist/sp:ColumnReference  return concat(string($colref/@Column),":",string($colref/@ParameterCompiledValue),",   "),"  "')) as SQL_PARAMS,
 CASE WHEN CAST(QT.QUERY_PLAN AS NVARCHAR(MAX)) LIKE '%MissingIndex%' THEN 1 ELSE 0 END as MI_FLAG
 
  FROM [#QUERY_PLANS_TEMP] QT
      OUTER APPLY QUERY_PLAN.nodes('//sp:Batch') AS Batch(index_node)
     
 ) as A;
END TRY


--REH if this fails then the parsing of the SQL_PARMS failed, just insert the plans again w/o the SQL_PARMS parsing

BEGIN CATCH

PRINT 'ERROR ON PARSING SQL PARMS'

;WITH XMLNAMESPACES ('http://schemas.microsoft.com/sqlserver/2004/07/showplan' AS sp)
INSERT INTO QUERY_PLANS WITH (TABLOCK)
SELECT * FROM (
SELECT      QT.[STATS_TIME],QT.[DATABASE_NAME],QT.[PLAN_HANDLE],QT.[QUERY_PLAN_HASH],QT.[QUERY_PLAN],
 '' as SQL_PARAMS,
 CASE WHEN CAST(QT.QUERY_PLAN AS NVARCHAR(MAX)) LIKE '%MissingIndex%' THEN 1 ELSE 0 END as MI_FLAG
  FROM [#QUERY_PLANS_TEMP] QT
       OUTER APPLY QUERY_PLAN.nodes('//sp:Batch') AS Batch(index_node)
     
WHERE QT.[QUERY_PLAN] IS NOT NULL ) as A;
END CATCH


DROP TABLE [#QUERY_PLANS_TEMP]
--(
--SELECT @STATS_DATE,
--		@DATABASE_NAME,
--		QS.PLAN_HANDLE_INTERNAL,
--		QS.QUERY_PLAN_HASH, 
--		query_plan
--FROM	sys.dm_exec_cached_plans PLNS
--INNER JOIN Query_Stats_CTE QS ON QS.PLAN_HANDLE = PLNS.plan_handle
--OUTER	APPLY sys.dm_exec_query_plan(PLNS.plan_handle)
--WHERE	
--		--REH if the plan already exists dont insert a new one, only keep 1 copy of the plan
--		 NOT EXISTS ( SELECT 'X'  FROM QUERY_PLANS QP WHERE  QP.PLAN_HANDLE = QS.PLAN_HANDLE_INTERNAL
--		AND QP.QUERY_PLAN_HASH = QS.QUERY_PLAN_HASH))
		
		





PRINT 'Completed Successfully'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'Inserted QUERY_PLANS SUCCESSFULLY at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE
             
END TRY

BEGIN CATCH
PRINT 'Step failed to complete !!'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'FAILED TO insert QUERY_PLANS at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE
    
END CATCH






BEGIN TRY
PRINT 'STEP Insert INDEX_USAGE_STATS'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)


DECLARE db_cursor CURSOR  LOCAL
FOR

SELECT DATABASENAME
FROM   DynamicsPerf..COLLECTIONDATABASES
ORDER  BY DATABASENAME 


/* Open the cursor */
/*if the cursor isn't open you will get an error when you fetch the record*/
OPEN db_cursor 

/* Get the first record */
/* you can FETCH NEXT, FIRST, LAST, PREVIOUS */
FETCH NEXT FROM db_cursor INTO @DATABASE_NAME

/* Verify that we got a record*/
/* status 0 means we got a good record*/

WHILE @@fetch_status = 0  /* no errors */
BEGIN /* Top of Loop */


SELECT @DATABASE_ID = database_id FROM sys.databases WITH (NOLOCK) WHERE name = @DATABASE_NAME

INSERT INTO INDEX_USAGE_STATS WITH (TABLOCK)
SELECT	@STATS_DATE,
		@DATABASE_NAME,
		object_id,
		index_id,
		user_seeks,
		user_scans,
		user_lookups,
		user_updates,
		last_user_seek,
		last_user_scan,
		last_user_lookup,
		last_user_update,
		system_seeks,
		system_scans,
		system_lookups,
		system_updates,
		last_system_seek,
		last_system_scan,
		last_system_lookup,
		last_system_update
FROM	sys.dm_db_index_usage_stats
WHERE 	database_id = @DATABASE_ID
AND 	object_id > 99

PRINT 'Completed Successfully'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)
  UPDATE CAPTURE_LOG SET TEXT = TEXT + 'Inserted INDEX_USAGE_STATS SUCCESSFULLY for ' +@DATABASE_NAME + ' at ' + CONVERT(VARCHAR, GETDATE(),109)+ ', ' 
WHERE STATS_TIME = @STATS_DATE

FETCH NEXT FROM db_cursor INTO @DATABASE_NAME
END  /*End of the loop */
CLOSE db_cursor  /*close the cursor to free memory in SQL*/
DEALLOCATE db_cursor /*Must deallocate the cursor to destroy it and free SQL resources*/
 
					             
END TRY

BEGIN CATCH
PRINT 'Step failed to complete !!'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)
UPDATE CAPTURE_LOG SET TEXT = TEXT + 'FAILED TO insert INDEX_USAGE_STATS at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE

END CATCH












BEGIN TRY
PRINT 'STEP Insert SYSOBJECTS tables'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)


DECLARE db_cursor CURSOR  LOCAL
FOR

SELECT DATABASENAME
FROM   DynamicsPerf..COLLECTIONDATABASES
ORDER  BY DATABASENAME 


/* Open the cursor */
/*if the cursor isn't open you will get an error when you fetch the record*/
OPEN db_cursor 

/* Get the first record */
/* you can FETCH NEXT, FIRST, LAST, PREVIOUS */
FETCH NEXT FROM db_cursor INTO @DATABASE_NAME

/* Verify that we got a record*/
/* status 0 means we got a good record*/

WHILE @@fetch_status = 0  /* no errors */
BEGIN /* Top of Loop */

		SET @SQL = 'DELETE FROM DYNSYSINDEXES WHERE DATABASE_NAME = ' + '''' + @DATABASE_NAME + '''' + ' INSERT INTO DYNSYSINDEXES 
		SELECT '+''''+ @DATABASE_NAME+''''+ ',[object_id],[name],[index_id],[type],[type_desc],[is_unique],[data_space_id]
			  ,[ignore_dup_key],[is_primary_key],[is_unique_constraint],[fill_factor],[is_padded]
			  ,[is_disabled],[is_hypothetical],[allow_row_locks],[allow_page_locks],[has_filter],[filter_definition]'

			SELECT @SQL = @SQL+'FROM	[' + @DATABASE_NAME + '].sys.indexes si'
			
		IF @DEBUG = 'Y' 
		BEGIN
		PRINT '@SQL= ' + @SQL
		END

		EXECUTE (@SQL) 


		SET @SQL = 'DELETE FROM DYNSYSOBJECTS WHERE DATABASE_NAME = ' + '''' + @DATABASE_NAME + '''' +'  INSERT INTO DYNSYSOBJECTS 
		SELECT '+''''+ @DATABASE_NAME+''''+ ',[name],[object_id] ,[principal_id],[schema_id],[parent_object_id]
      ,[type],[type_desc],[create_date],[modify_date],[is_ms_shipped],[is_published],[is_schema_published]'
			SELECT @SQL = @SQL+'FROM	[' + @DATABASE_NAME + '].sys.objects so'
			
		IF @DEBUG = 'Y' 
		BEGIN
		PRINT '@SQL= ' + @SQL
		END

		EXECUTE (@SQL) 

		SET @SQL = 'DELETE FROM DYNSYSPARTITIONS WHERE DATABASE_NAME = ' + '''' + @DATABASE_NAME + '''' +'  INSERT INTO DYNSYSPARTITIONS 
		SELECT '+''''+ @DATABASE_NAME+''''+ ',[partition_id],[object_id],[index_id],[partition_number]
      ,[hobt_id],[rows],[filestream_filegroup_id],[data_compression],[data_compression_desc]'
			SELECT @SQL = @SQL+'FROM	[' + @DATABASE_NAME + '].sys.partitions sp'
			
		IF @DEBUG = 'Y' 
		BEGIN
		PRINT '@SQL= ' + @SQL
		END

		EXECUTE (@SQL) 






PRINT 'Completed Successfully'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)
  UPDATE CAPTURE_LOG SET TEXT = TEXT + 'Inserted DYNSYSOBJECTS SUCCESSFULLY for ' +@DATABASE_NAME + ' at ' + CONVERT(VARCHAR, GETDATE(),109)+ ', ' 
WHERE STATS_TIME = @STATS_DATE

FETCH NEXT FROM db_cursor INTO @DATABASE_NAME
END  /*End of the loop */
CLOSE db_cursor  /*close the cursor to free memory in SQL*/
DEALLOCATE db_cursor /*Must deallocate the cursor to destroy it and free SQL resources*/
 
					             
END TRY

BEGIN CATCH
PRINT 'Step failed to complete !!'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)
UPDATE CAPTURE_LOG SET TEXT = TEXT + 'FAILED TO insert SYSOBJECTS at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE

END CATCH













BEGIN TRY 
PRINT 'STEP Insert WAIT_STATS'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

INSERT 	INTO WAIT_STATS WITH (TABLOCK)
SELECT 	@STATS_DATE, *
FROM 	sys.dm_os_wait_stats

PRINT 'Completed Successfully'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'Inserted WAIT_STATS SUCCESSFULLY at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE
 
             
END TRY

BEGIN CATCH
PRINT 'Step failed to complete !!'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'FAILED TO insert WAIT_STATS at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE
END CATCH


BEGIN TRY
PRINT 'STEP Insert INDEX_DETAIL'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)


DECLARE db_cursor CURSOR  LOCAL
FOR

SELECT DATABASENAME
FROM   DynamicsPerf..COLLECTIONDATABASES
ORDER  BY DATABASENAME 


/* Open the cursor */
/*if the cursor isn't open you will get an error when you fetch the record*/
OPEN db_cursor 

/* Get the first record */
/* you can FETCH NEXT, FIRST, LAST, PREVIOUS */
FETCH NEXT FROM db_cursor INTO @DATABASE_NAME

/* Verify that we got a record*/
/* status 0 means we got a good record*/

WHILE @@fetch_status = 0  /* no errors */
BEGIN /* Top of Loop */


SET @SQL = '
	INSERT INTO INDEX_DETAIL WITH (TABLOCK) 
	SELECT	''' + CONVERT(NVARCHAR(50), @STATS_DATE, 121) + ''',''' + @DATABASE_NAME + ''',

			si.object_id,
			si.index_id,
			so.name, 
			si.name,  
			si.type_desc+
			CASE
				WHEN is_unique = 1 THEN '', UNIQUE''
				ELSE ''''
			END
			+	
			CASE
				WHEN is_primary_key = 1 THEN '', PRIMARY KEY''
				ELSE ''''
			END
			+
			CASE
				WHEN has_filter = 1 THEN '', FILTERED''
				ELSE ''''
			END			
			
			,
	stuff	
		(
				
			(	
			SELECT '', '' + sc.name FROM	[' + @DATABASE_NAME + '].sys.index_columns sic
			JOIN	[' + @DATABASE_NAME + '].sys.columns sc on sc.column_id = sic.column_id
			WHERE	so.object_id = sic.object_id
			AND		sic.index_id = si.index_id
			AND		sc.object_id = so.object_id
			AND		sic.is_included_column=0
			order	by sic.key_ordinal
			for		xml path('''')
			)
		,1,1,''''
		)  AS key_columns,
	stuff
		(
			(
			SELECT	'', '' + sc.name FROM [' + @DATABASE_NAME + '].sys.index_columns sic
			JOIN	[' + @DATABASE_NAME + '].sys.columns sc on sc.column_id = sic.column_id
			WHERE	so.object_id = sic.object_id
			AND		sic.index_id = si.index_id
			AND		sc.object_id = so.object_id
			AND		sic.is_included_column=1
			ORDER BY sic.key_ordinal
			FOR XML path('''')
			)
		,1,1,''''
		)  AS included_columns,
	PS.DATA_SIZE AS PAGE_COUNT,
	PS.ROW_COUNT AS ROW_COUNT,
	sp.data_compression '
	

	SELECT @SQL = @SQL+'FROM	[' + @DATABASE_NAME + '].sys.indexes si
	JOIN	[' + @DATABASE_NAME + '].sys.sysindexes ii on si.object_id = ii.id and si.index_id = ii.indid
	JOIN	[' + @DATABASE_NAME + '].sys.objects so on so.object_id = si.object_id
	JOIN	[' + @DATABASE_NAME + '].sys.schemas ss on ss.schema_id = so.schema_id
	JOIN	[' + @DATABASE_NAME + '].sys.partitions sp on so.object_id = sp.object_id and sp.index_id = ii.indid
	INNER JOIN  (SELECT object_id, index_id,SUM(row_count) AS ROW_COUNT,SUM(in_row_data_page_count + lob_used_page_count + row_overflow_used_page_count) AS DATA_SIZE	FROM [' + @DATABASE_NAME + '].sys.dm_db_partition_stats GROUP BY  object_id, index_id) as PS ON PS.index_id = si.index_id and PS.object_id = si.object_id
	
	WHERE	so.type = ''U''
	AND		si.type > 0  --other than heap tables
	AND     sp.partition_number = 1  -- fix issue with partiioned tables multiplying the number or records we return
	UNION ALL 
	SELECT	''' + CONVERT(NVARCHAR(50), @STATS_DATE, 121) + ''',''' + @DATABASE_NAME + ''',
			si.object_id,
			si.index_id,
			so.name, 
			so.name, 
			''HEAP'',
			''N/A'', 
			''N/A'',
	PS.DATA_SIZE AS PAGE_COUNT,
	PS.ROW_COUNT AS ROW_COUNT,
	sp.data_compression '


	SELECT @SQL = @SQL+'		
	FROM	[' + @DATABASE_NAME + '].sys.indexes si
	JOIN	[' + @DATABASE_NAME + '].sys.sysindexes ii on si.object_id = ii.id and si.index_id = ii.indid
	JOIN	[' + @DATABASE_NAME + '].sys.objects so on so.object_id = si.object_id
	JOIN	[' + @DATABASE_NAME + '].sys.schemas ss on ss.schema_id = so.schema_id
	JOIN	[' + @DATABASE_NAME + '].sys.partitions sp on so.object_id = sp.object_id and sp.index_id = ii.indid
	INNER JOIN  (SELECT object_id, index_id,SUM(row_count) AS ROW_COUNT,SUM(in_row_data_page_count + lob_used_page_count + row_overflow_used_page_count) AS DATA_SIZE	FROM [' + @DATABASE_NAME + '].sys.dm_db_partition_stats GROUP BY  object_id, index_id) as PS ON PS.index_id = si.index_id and PS.object_id = si.object_id
	

	WHERE	so.type = ''U''
	AND		si.type = 0  
	AND     sp.partition_number = 1  -- fix issue with partiioned tables multiplying the number or records we return
	ORDER BY 1,2'

IF @DEBUG = 'Y' 
BEGIN
PRINT '@SQL= ' + @SQL
END

EXECUTE (@SQL) 



FETCH NEXT FROM db_cursor INTO @DATABASE_NAME
END  /*End of the loop */
CLOSE db_cursor  /*close the cursor to free memory in SQL*/
DEALLOCATE db_cursor /*Must deallocate the cursor to destroy it and free SQL resources*/
 
PRINT 'Completed Successfully'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)
UPDATE CAPTURE_LOG SET TEXT = TEXT + 'Inserted INDEX_DETAIL SUCCESSFULLY at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE
 
             
END TRY

BEGIN CATCH
PRINT 'Step failed to complete !!'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'FAILED TO insert INDEX_DETAIL at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE
 
  
END CATCH

BEGIN TRY
PRINT 'STEP Insert SQL data cache buffer'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)
--Insert Buffer information
;
INSERT INTO [DynamicsPerf]..BUFFER_DETAIL

SELECT @RUN_NAME,
       CONVERT(NVARCHAR(50), @STATS_DATE, 121),
       CASE
         WHEN database_id = 32767 THEN 'resourceDb'
         ELSE Cast(Db_name(database_id) AS NVARCHAR(128))
       END,

        COUNT(*)*8/1024 
FROM   sys.dm_os_buffer_descriptors WITH(nolock)
GROUP BY database_id


PRINT 'Completed Successfully'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'Inserted BUFFER_DETAIL SUCCESSFULLY at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE
 
      
             
END TRY

BEGIN CATCH
PRINT 'Step failed to complete !!'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'FAILED TO insert BUFFER_DETAIL at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE
 
    
END CATCH


--Insert Database information

BEGIN TRY
PRINT 'STEP Insert SQL Databases information'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)
SET @SQL = '
	INSERT INTO [DynamicsPerf]..SQL_DATABASES SELECT ''' + @RUN_NAME + ''',
	''' + CONVERT(NVARCHAR(50), @STATS_DATE, 121) + ''',
	[name]
      ,[database_id]
      ,[source_database_id]
      ,[owner_sid]
      ,[create_date]
      ,[compatibility_level]
      ,[collation_name]
      ,[user_access]
      ,[user_access_desc]
      ,[is_read_only]
      ,[is_auto_close_on]
      ,[is_auto_shrink_on]
      ,[state]
      ,[state_desc]
      ,[is_in_standby]
      ,[is_cleanly_shutdown]
      ,[is_supplemental_logging_enabled]
      ,[snapshot_isolation_state]
      ,[snapshot_isolation_state_desc]
      ,[is_read_committed_snapshot_on]
      ,[recovery_model]
      ,[recovery_model_desc]
      ,[page_verify_option]
      ,[page_verify_option_desc]
      ,[is_auto_create_stats_on]
      ,[is_auto_update_stats_on]
      ,[is_auto_update_stats_async_on]
      ,[is_ansi_null_default_on]
      ,[is_ansi_nulls_on]
      ,[is_ansi_padding_on]
      ,[is_ansi_warnings_on]
      ,[is_arithabort_on]
      ,[is_concat_null_yields_null_on]
      ,[is_numeric_roundabort_on]
      ,[is_quoted_identifier_on]
      ,[is_recursive_triggers_on]
      ,[is_cursor_close_on_commit_on]
      ,[is_local_cursor_default]
      ,[is_fulltext_enabled]
      ,[is_trustworthy_on]
      ,[is_db_chaining_on]
      ,[is_parameterization_forced]
      ,[is_master_key_encrypted_by_server]
      ,[is_published]
      ,[is_subscribed]
      ,[is_merge_published]
      ,[is_distributor]
      ,[is_sync_with_backup]
      ,[service_broker_guid]
      ,[is_broker_enabled]
      ,[log_reuse_wait]
      ,[log_reuse_wait_desc]
      ,[is_date_correlation_on]
	FROM sys.databases '

IF @DEBUG = 'Y' 
BEGIN
PRINT '@SQL= ' + @SQL
END

EXECUTE (@SQL) 
PRINT 'Completed Successfully'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'Inserted SQL_DATABASES SUCCESSFULLY at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE
 
 
             
END TRY

BEGIN CATCH
PRINT 'Step failed to complete !!'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'FAILED TO insert SQL_DATABASES SUCCESSFULLY at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE
 
END CATCH

--Insert SQL configuration

BEGIN TRY
PRINT 'STEP Insert SQL Configurations'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

SET @SQL = '
	INSERT INTO [DynamicsPerf]..SQL_CONFIGURATION SELECT ''' + @RUN_NAME + ''',
	''' + CONVERT(NVARCHAR(50), @STATS_DATE, 121) + ''', 
      name,
      convert(int, minimum) as minimum,
      convert(int, maximum) as maximum,
      convert(int, isnull(value, value_in_use)) as config_value,
      convert(int, value_in_use) as run_value
from  sys.configurations
order by lower(name)'

IF @DEBUG = 'Y' 
BEGIN
PRINT '@SQL= ' + @SQL
END

EXECUTE (@SQL) 
PRINT 'Completed Successfully'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'Inserted SQL_CONFIGURATION SUCCESSFULLY at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE
 
 
             
END TRY

BEGIN CATCH
PRINT 'Step failed to complete !!'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'FAILED TO insert SQL_CONFIGURATION at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE
 
END CATCH



BEGIN TRY
PRINT 'STEP Insert SQL Database File Information'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

IF EXISTS (SELECT name FROM tempdb..sysobjects WHERE name = '##Results')  
   BEGIN  
       DROP TABLE ##Results  
   END 
    
CREATE TABLE ##Results
  (
     [Database Name]         SYSNAME,
     [File Name]             SYSNAME,
     [Physical Name]         NVARCHAR(260),
     [File Type]             VARCHAR(4),
     [Total Size in Mb]      INT,
     [Available Space in Mb] INT,
     [Growth Units]          VARCHAR(15),
     [max File Size in Mb]   INT,
     [file_id]				 INT
  ) 

SELECT @SQL =  
'USE [?] INSERT INTO ##Results([Database Name], [File Name], [Physical Name],  
[File Type], [Total Size in Mb], [Available Space in Mb],  
[Growth Units], [max File Size in Mb], [file_id])  
SELECT DB_NAME(), 
[name] AS [File Name],  
physical_name AS [Physical Name],  
[File Type] =  
CASE type 
WHEN 0 THEN ''Data'''  
+ 
           'WHEN 1 THEN ''Log''' 
+ 
       'END, 
[Total Size in Mb] = 
CASE ceiling([size]/128)  
WHEN 0 THEN 1 
ELSE ceiling([size]/128) 
END, 
[Available Space in Mb] =  
CASE ceiling([size]/128) 
WHEN 0 THEN (1 - CAST(FILEPROPERTY([name], ''SpaceUsed''' + ') as int) /128) 
ELSE (([size]/128) - CAST(FILEPROPERTY([name], ''SpaceUsed''' + ') as int) /128) 
END, 
[Growth Units]  =  
CASE [is_percent_growth]  
WHEN 1 THEN CAST(growth AS varchar(20)) + ''%''' 
+ 
           'ELSE CAST(growth/128 AS varchar(20)) + ''Mb''' 
+ 
       'END, 
[max File Size in Mb] =  
CASE [max_size] 
WHEN -1 THEN NULL 
WHEN 268435456 THEN NULL 
ELSE [max_size] 
END ,
[file_id]
FROM sys.database_files
ORDER BY [File Type], [file_id]' 

--Print the command to be issued against all databases 
--PRINT @SQL 

IF @DEBUG = 'Y' 
BEGIN
PRINT '@SQL= ' + @SQL
END

--Run the command against each database 
EXEC sp_MSforeachdb @SQL 
--PRINT @SQL
--UPDATE ##Results SET [Free Space %] = [Available Space in Mb]/[Total Size in Mb] * 100 
--print 'Results Table'
--select * from ##Results

INSERT INTO [DynamicsPerf]..SQL_DATABASEFILES
SELECT @RUN_NAME                                                                           AS [RUN_NAME],
       CONVERT(NVARCHAR(50), @STATS_DATE, 121)                                             AS [STATS_TIME],
       [Database Name],
       [file_id],
       [File Name],
       [Physical Name],
       [File Type],
       [Total Size in Mb]                                                                  AS [DB Size (Mb)],
       [Available Space in Mb]                                                             AS [DB Free (Mb)],
       Ceiling(CAST([Available Space in Mb] AS DECIMAL(10, 1)) / [Total Size in Mb] * 100) AS [Free Space %],
       [Growth Units],
       [max File Size in Mb]                                                               AS [Grow max Size (Mb)]
FROM   ##Results
--Return the Results  

DROP TABLE ##Results

PRINT 'Completed Successfully'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'Inserted SQL_DATABASES SUCCESSFULLY at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE
 
             
END TRY

BEGIN CATCH
PRINT 'Step failed to complete !!'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'FAILED TO insert SQL_DATABASES at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE
 
      
END CATCH


BEGIN TRY
PRINT 'STEP Insert SQL Virtual Log Files Information'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

DECLARE @ADHOC INT


IF Substring(@SQLversion, 1, 3) = '10.'
BEGIN
SET @ADHOC = (SELECT cast(value as int) FROM sys.configurations WHERE name = 'Ad Hoc Distributed Queries');

exec sp_configure 'Ad Hoc Distributed Queries',1
RECONFIGURE WITH OVERRIDE

TRUNCATE TABLE LOGINFO  -- Clear the table out each time we collect

SELECT @SQL =  
'USE [?]



INSERT  DynamicsPerf..LOGINFO
SELECT ''?'', FileId,FileSize,StartOffset,FSeqNo,Status,Parity,CreateLSN FROM 
OPENROWSET('+QUOTENAME('SQLNCLI','''')+', '
+QUOTENAME('Server=' + cast(Serverproperty('MachineName') as varchar(128))+ISNULL('\'+cast(Serverproperty('InstanceName')as varchar(128)),'')
       +';Database='+'?'+';Trusted_Connection=yes;','''')+','

+
'''set fmtonly OFF;exec(''''DBCC LOGINFO WITH NO_INFOMSGS'''')'''+ ') AS a'



--Print the command to be issued against all databases 
--PRINT @SQL 

IF @DEBUG = 'Y' 
BEGIN
PRINT '@SQL= ' + @SQL
END



--Run the command against each database 
EXEC sp_MSforeachdb  @command1=@SQL 
                    --,@command2=@SQL2

					
exec sp_configure 'Ad Hoc Distributed Queries',@ADHOC
RECONFIGURE WITH OVERRIDE

END

ELSE
BEGIN
SET @ADHOC = (SELECT cast(value as int) FROM sys.configurations WHERE name = 'Ad Hoc Distributed Queries');

exec sp_configure 'Ad Hoc Distributed Queries',1
RECONFIGURE WITH OVERRIDE

TRUNCATE TABLE LOGINFO  -- Clear the table out each time we collect

SELECT @SQL =  
'
INSERT  DynamicsPerf..LOGINFO
SELECT ''?'', FileId,FileSize,StartOffset,FSeqNo,Status,Parity,CreateLSN FROM 
OPENROWSET('+QUOTENAME('SQLNCLI','''')+', '
+QUOTENAME('Server=' + cast(serverproperty('MachineName') as varchar(128))+ISNULL('\'+cast(serverproperty('InstanceName') as varchar(128)),'')
       +';Database='+'?'+';Trusted_Connection=yes;','''')+','

+
'''exec(''''DBCC LOGINFO'''') 
with result sets ((q char, FileId int, FileSize bigint, StartOffset bigint, FSeqNo int, Status tinyint, Parity tinyint, CreateLSN numeric(25,0) ))
'''+ ') AS a'


--Print the command to be issued against all databases 
--PRINT @SQL 

IF @DEBUG = 'Y' 
BEGIN
PRINT '@SQL= ' + @SQL
END



--Run the command against each database 
EXEC sp_MSforeachdb  @command1=@SQL 
                    --,@command2=@SQL2

					
exec sp_configure 'Ad Hoc Distributed Queries',@ADHOC
RECONFIGURE WITH OVERRIDE

END

PRINT 'Completed Successfully'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'Inserted VLF LOG SUCCESSFULLY at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE
 
             
END TRY

BEGIN CATCH
PRINT 'Step failed to complete !!'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

--REH set this back so we dont leave it in incorrect state
exec sp_configure 'Ad Hoc Distributed Queries',@ADHOC
RECONFIGURE WITH OVERRIDE

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'FAILED TO insert VLF LOG at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE
 
    
END CATCH


BEGIN TRY
PRINT 'STEP Insert SQL Job(s) Information'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

DECLARE @weekDay TABLE (
  mask      INT,
  maskValue VARCHAR(32)); 

INSERT INTO @weekDay
SELECT 1, 'Sunday'  UNION All
SELECT 2, 'Monday'  UNION All
SELECT 4, 'Tuesday'  UNION All
SELECT 8, 'Wednesday'  UNION All
SELECT 16, 'Thursday'  UNION All
SELECT 32, 'Friday'  UNION All
SELECT 64, 'Saturday';
 
WITH myCTE
AS(
 SELECT sched.name                                                                                     AS 'scheduleName',
        sched.schedule_id,
        jobsched.job_id,
        CASE
          WHEN sched.freq_type = 1 THEN 'Once'
          WHEN sched.freq_type = 4
               AND sched.freq_interval = 1 THEN 'Daily'
          WHEN sched.freq_type = 4 THEN 'Every ' + CAST(sched.freq_interval AS VARCHAR(5)) + ' days'
          WHEN sched.freq_type = 8 THEN REPLACE(REPLACE(REPLACE((SELECT maskValue
                                                                 FROM   @weekDay AS x
                                                                 WHERE  sched.freq_interval & x.mask <> 0
                                                                 ORDER  BY mask
                                                                 FOR XML RAW), '"/><row maskValue="', ', '), '<row maskValue="', ''), '"/>', '') + CASE
                                                                                                                                                     WHEN sched.freq_recurrence_factor <> 0
                                                                                                                                                          AND sched.freq_recurrence_factor = 1 THEN '; weekly'
                                                                                                                                                     WHEN sched.freq_recurrence_factor <> 0 THEN '; every ' + CAST(sched.freq_recurrence_factor AS VARCHAR(10)) + ' weeks'
                                                                                                                                                   END
          WHEN sched.freq_type = 16 THEN 'On day ' + CAST(sched.freq_interval AS VARCHAR(10)) + ' of every ' + CAST(sched.freq_recurrence_factor AS VARCHAR(10)) + ' months'
          WHEN sched.freq_type = 32 THEN CASE
                                           WHEN sched.freq_relative_interval = 1 THEN 'First'
                                           WHEN sched.freq_relative_interval = 2 THEN 'Second'
                                           WHEN sched.freq_relative_interval = 4 THEN 'Third'
                                           WHEN sched.freq_relative_interval = 8 THEN 'Fourth'
                                           WHEN sched.freq_relative_interval = 16 THEN 'Last'
                                         END + CASE
                                                 WHEN sched.freq_interval = 1 THEN ' Sunday'
                                                 WHEN sched.freq_interval = 2 THEN ' Monday'
                                                 WHEN sched.freq_interval = 3 THEN ' Tuesday'
                                                 WHEN sched.freq_interval = 4 THEN ' Wednesday'
                                                 WHEN sched.freq_interval = 5 THEN ' Thursday'
                                                 WHEN sched.freq_interval = 6 THEN ' Friday'
                                                 WHEN sched.freq_interval = 7 THEN ' Saturday'
                                                 WHEN sched.freq_interval = 8 THEN ' Day'
                                                 WHEN sched.freq_interval = 9 THEN ' Weekday'
                                                 WHEN sched.freq_interval = 10 THEN ' Weekend'
                                               END + CASE
                                                       WHEN sched.freq_recurrence_factor <> 0
                                                            AND sched.freq_recurrence_factor = 1 THEN '; monthly'
                                                       WHEN sched.freq_recurrence_factor <> 0 THEN '; every ' + CAST(sched.freq_recurrence_factor AS VARCHAR(10)) + ' months'
                                                     END
          WHEN sched.freq_type = 64 THEN 'StartUp'
          WHEN sched.freq_type = 128 THEN 'Idle'
        END                                                                                            AS 'frequency',
        Isnull('Every ' + CAST(sched.freq_subday_interval AS VARCHAR(10)) + CASE
                                                                              WHEN sched.freq_subday_type = 2 THEN ' seconds'
                                                                              WHEN sched.freq_subday_type = 4 THEN ' minutes'
                                                                              WHEN sched.freq_subday_type = 8 THEN ' hours'
                                                                            END, 'Once')               AS 'subFrequency',
        Replicate('0', 6 - Len(sched.active_start_time)) + CAST(sched.active_start_time AS VARCHAR(6)) AS 'startTime',
        Replicate('0', 6 - Len(sched.active_end_time)) + CAST(sched.active_end_time AS VARCHAR(6))     AS 'endTime',
        Replicate('0', 6 - Len(jobsched.next_run_time)) + CAST(jobsched.next_run_time AS VARCHAR(6))   AS 'nextRunTime',
        CAST(jobsched.next_run_date AS CHAR(8))                                                        AS 'nextRunDate'
 FROM   msdb.dbo.sysschedules AS sched
        JOIN msdb.dbo.sysjobschedules AS jobsched
          ON sched.schedule_id = jobsched.schedule_id
 WHERE  sched.enabled = 1 
 
)

INSERT INTO SQL_JOBS
SELECT @RUN_NAME                                                                                                                                                                                                      AS [RUN_NAME],
       CONVERT(NVARCHAR(50), @STATS_DATE, 121)                                                                                                                                                                        AS [STATS_TIME],
       job.name                                                                                                                                                                                                       AS 'jobName',
       sched.scheduleName,
       sched.frequency,
       sched.subFrequency,
       Substring(sched.startTime, 1, 2) + ':' + Substring(sched.startTime, 3, 2) + ' - ' + Substring(sched.endTime, 1, 2) + ':' + Substring(sched.endTime, 3, 2)                                                      AS 'scheduleTime' -- HH:MM
       ,
       Substring(sched.nextRunDate, 1, 4) + '/' + Substring(sched.nextRunDate, 5, 2) + '/' + Substring(sched.nextRunDate, 7, 2) + ' ' + Substring(sched.nextRunTime, 1, 2) + ':' + Substring(sched.nextRunTime, 3, 2) AS 'nextRunDate'
       /* Note: the sysjobschedules table refreshes every 20 min, 
         so nextRunDate may be out of date */
       ,
       steps.step_id,
       steps.step_name,
       steps.subsystem,
       steps.command
FROM   msdb.dbo.sysjobs AS job
       JOIN myCTE AS sched
         ON job.job_id = sched.job_id
       INNER JOIN msdb.dbo.sysjobsteps steps
         ON steps.job_id = job.job_id
WHERE  job.enabled = 1 -- do not display disabled jobs
ORDER  BY nextRunDate 

PRINT 'Completed Successfully'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'Inserted SQL_JOBS SUCCESSFULLY at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE
 
             
END TRY

BEGIN CATCH
PRINT 'Step failed to complete !!'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'FAILED TO inserted SQL_JOBS at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE
 
END CATCH

--Insert Server Information
--Needs updating to support SQL 2005

BEGIN TRY
PRINT 'STEP Insert SERVERINFO table'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)


SELECT @SQL = '

INSERT INTO SERVERINFO WITH (TABLOCK)
SELECT '+QUOTENAME(@RUN_NAME,'''')

SELECT @SQL = @SQL + ',
       '+ QUOTENAME(CONVERT(NVARCHAR(50), @STATS_DATE, 121),'''') +',
       '+QUOTENAME(@SQL_SERVER_STARTTIME,'''')+',
       Serverproperty(''ComputerNamePhysicalNetBIOS'') AS PhysicalComputerName,
       Serverproperty(''IsClustered'')                 AS IsClustered,
       Serverproperty(''MachineName'')                 AS MachineName,
       Serverproperty(''InstanceName'')                AS InstanceName,
       Serverproperty(''ProductVersion'')              AS ProductVersion,
       Serverproperty(''ProductLevel'')                AS ProductLevel,
       Serverproperty(''Edition'')                     AS Edition,
       Serverproperty(''EngineEdition'')               AS EngineEdition,
       Serverproperty(''SqlCharSet'')                  AS SqlCharSet,
       Serverproperty(''SqlCharSetName'')              AS SqlCharSetName,
       Serverproperty(''SqlSortOrder'')                AS SqlSortOrder,
       Serverproperty(''SqlSortOrderName'')            AS SqlSortOrderName,
       cpu_count,
       hyperthread_ratio,'

	   IF Serverproperty('ProductVersion') >= '11.0'
	   BEGIN
	   SELECT @SQL = @SQL +'
       committed_kb / 1024                     AS Bpool_Committed_MB,
       committed_target_kb / 1024                 AS Bpool_Commit_Target_MB,
       visible_target_kb / 1024                       AS Bpool_Visible_MB,
       cntr_value                                    AS Page_Life_Expectancy,
       (SELECT SUM(pages_kb) FROM sys.dm_os_memory_clerks WHERE name = ''TokenAndPermUserStore'') AS [CurrentSizeOfTokenCache(kb)]
	   '
		END
		ELSE
		BEGIN
		SELECT  @SQL = @SQL + 'bpool_committed / 1024 * 8                    AS Bpool_Committed_MB,
       bpool_commit_target / 1024 * 8                AS Bpool_Commit_Target_MB,
       bpool_visible / 1024 * 8                      AS Bpool_Visible_MB,
       cntr_value                                    AS Page_Life_Expectancy,
       (SELECT SUM(single_pages_kb + multi_pages_kb) FROM sys.dm_os_memory_clerks WHERE name = ''TokenAndPermUserStore'') AS [CurrentSizeOfTokenCache(kb)]
	   '
		END

SELECT @SQL = @SQL + '
FROM   sys.dm_os_sys_info,
       sys.dm_os_performance_counters
WHERE  counter_name = ''Page life expectancy''
       AND ( object_name = ''SQLServer:Buffer Manager''
              OR object_name LIKE ''%'' + CAST(Serverproperty(''InstanceName'') AS VARCHAR(50)) + '':Buffer Manager%'' ) '



IF @DEBUG = 'Y' 
BEGIN
PRINT '@SQL= ' + @SQL
END

EXEC( @SQL)

PRINT 'Completed Successfully at ' + CONVERT(VARCHAR, GETDATE(),109)



UPDATE CAPTURE_LOG SET TEXT = TEXT + 'Inserted SERVERINFO SUCCESSFULLY at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE
 
             
END TRY

BEGIN CATCH
PRINT 'Step failed to complete !!'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'FAILED TO insert SERVERINFO at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE
 
END CATCH


BEGIN TRY
PRINT 'STEP Insert SERVER_REGISTRY table'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)


IF Serverproperty('ProductVersion') >= '10.50.2500'
BEGIN
TRUNCATE TABLE SERVER_REGISTRY
INSERT SERVER_REGISTRY
SELECT registry_key,
       value_name,
       value_data FROM sys.dm_server_registry; 
END

       
PRINT 'Completed Successfully'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'Inserted SERVER_REGISTRY SUCCESSFULLY at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE
 
             
END TRY

BEGIN CATCH
PRINT 'Step failed to complete !!'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'FAILED TO insert SERVER_REGISTRY at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE
 
END CATCH



BEGIN TRY
PRINT 'STEP Insert SERVER_DISKVOLUMES table'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

TRUNCATE TABLE SERVER_DISKVOLUMES

IF Serverproperty('ProductVersion') >= '10.50.2500'
BEGIN
INSERT SERVER_DISKVOLUMES
SELECT DISTINCT vs.volume_mount_point,-- e.g. C:\   
                vs.volume_id,
                vs.logical_volume_name,
                vs.file_system_type,-- e.g. NTFS
                vs.total_bytes / 1024 / 1024,
                vs.available_bytes / 1024 / 1024,
                CONVERT(DECIMAL(5, 2), vs.available_bytes * 100.0 / vs.total_bytes),
                vs.supports_compression,
                vs.supports_alternate_streams,
                vs.supports_sparse_files,
                vs.is_read_only,
                vs.is_compressed
FROM   sys.sysaltfiles AS f
       CROSS APPLY sys.dm_os_volume_stats(f.dbid, f.fileid) AS vs
WHERE  f.dbid < 32767
ORDER  BY 7 DESC 
END

PRINT 'Completed Successfully'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)
UPDATE CAPTURE_LOG SET TEXT = TEXT + 'Inserted SERVER_DISKVOLUMES SUCCESSFULLY at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE
 
             
END TRY

BEGIN CATCH
PRINT 'Step failed to complete !!'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'FAILED TO insert SERVER_DISKVOLUMES at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE
 
END CATCH




--BEGIN TRY
--PRINT 'STEP Insert SERVER_SERVICES table'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)
--TRUNCATE TABLE SERVER_SERVICES

--IF Serverproperty('ProductVersion') >= '10.50.2500'
--BEGIN
--INSERT SERVER_SERVICES
--SELECT servicename,
--       startup_type_desc,
--       status_desc,
--       process_id,
--       last_startup_time,
--       service_account,
--       is_clustered
--FROM   sys.dm_server_services; 
--END
          

--PRINT 'Completed Successfully'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

--UPDATE CAPTURE_LOG SET TEXT = TEXT + 'Inserted SERVER_SERVICES SUCCESSFULLY at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
--WHERE STATS_TIME = @STATS_DATE
 
             
--END TRY

--BEGIN CATCH
--PRINT 'Step failed to complete !!'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

--UPDATE CAPTURE_LOG SET TEXT = TEXT + 'FAILED TO insert SERVER_SERVICES at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
--WHERE STATS_TIME = @STATS_DATE
 
--END CATCH



BEGIN TRY
PRINT 'STEP Insert SERVER_OS_VERSION table'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)
TRUNCATE TABLE SERVER_OS_VERSION

IF Serverproperty('ProductVersion') >= '10.50.2500'
BEGIN
INSERT SERVER_OS_VERSION

SELECT windows_release,
       windows_service_pack_level,
       windows_sku,
       os_language_version  FROM sys.dm_os_windows_info; 
END
          

PRINT 'Completed Successfully'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'Inserted SERVER_OS_VERSION SUCCESSFULLY at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE

             
END TRY

BEGIN CATCH
PRINT 'Step failed to complete !!'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'FAILED TO insert SERVER_OS_VERSION at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE
 
END CATCH

--Insert Database Triggers information

BEGIN TRY
PRINT 'STEP Insert Databases Triggers information'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)


DECLARE db_cursor CURSOR  LOCAL
FOR

SELECT DATABASENAME
FROM   DynamicsPerf..COLLECTIONDATABASES
ORDER  BY DATABASENAME 


/* Open the cursor */
/*if the cursor isn't open you will get an error when you fetch the record*/
OPEN db_cursor 

/* Get the first record */
/* you can FETCH NEXT, FIRST, LAST, PREVIOUS */
FETCH NEXT FROM db_cursor INTO @DATABASE_NAME

/* Verify that we got a record*/
/* status 0 means we got a good record*/

WHILE @@fetch_status = 0  /* no errors */
BEGIN /* Top of Loop */


SET @SQL = '
USE '+@DATABASE_NAME+'
DELETE FROM [DynamicsPerf]..TRIGGER_TABLE WHERE DATABASE_NAME = '''+@DATABASE_NAME+'''
DECLARE @triggername NVARCHAR(128)
DECLARE @triggertable NVARCHAR(128) 
DECLARE @schemaname NVARCHAR(128) 


CREATE TABLE #TempTrigger
  (
     TRIGGER_TEXT VARCHAR(max)
  ) 

DECLARE tnames_cursor CURSOR FOR
  SELECT t.name, SCH.name,
         p.name AS tablename
  FROM   ['+@DATABASE_NAME+']..sysobjects t
         INNER JOIN ['+@DATABASE_NAME+']..sysobjects p
           ON t.parent_obj = p.id
			 INNER JOIN ['+@DATABASE_NAME+'].sys.schemas SCH
           ON t.uid = SCH.schema_id
  WHERE  t.type = ''TR''

OPEN tnames_cursor

FETCH NEXT FROM tnames_cursor INTO @triggername,@schemaname, @triggertable

WHILE ( @@FETCH_STATUS <> -1 )
  BEGIN
      IF ( @@FETCH_STATUS <> -2 )
        BEGIN
        SELECT @schemaname = @schemaname + ''.''
            INSERT #TempTrigger
            EXEC (''sp_helptext [''  + @schemaname + @triggername +'']'' )

            INSERT [DynamicsPerf]..TRIGGER_TABLE
            SELECT '''+@DATABASE_NAME+''',
                   @triggertable ,
                   @triggername  ,
                   *
            FROM   #TempTrigger

            TRUNCATE TABLE #TempTrigger
        END

      FETCH NEXT FROM tnames_cursor INTO @triggername, @schemaname, @triggertable
  END

DEALLOCATE tnames_cursor 
DROP TABLE #TempTrigger



	'

IF @DEBUG = 'Y' 
BEGIN
PRINT '@SQL= ' + @SQL
END

EXECUTE (@SQL) 
PRINT 'Completed Successfully'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

FETCH NEXT FROM db_cursor INTO @DATABASE_NAME
END  /*End of the loop */
CLOSE db_cursor  /*close the cursor to free memory in SQL*/
DEALLOCATE db_cursor /*Must deallocate the cursor to destroy it and free SQL resources*/
 
 
 
UPDATE CAPTURE_LOG SET TEXT = TEXT + 'Inserted TRIGGERS SUCCESSFULLY at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE

									             
END TRY

BEGIN CATCH
PRINT 'Step failed to complete !!'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'FAILED TO insert TRIGGERS at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE

END CATCH


 -- Capture Statistics Information
 
 --Delete any existing records, we are only keeping 1 set of stats per database
 
 BEGIN TRY
 PRINT 'STEP Insert SQL Statistics information'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)
 IF @SKIP_STATS='Y'  GOTO SKIPSTATS
 
--REH added check so we dont collect stats more then 1 time per day to reduce time to collect data

DECLARE @LAST_STATS_COLLECTION_DATE DATETIME 



IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[#TableStats]'))
BEGIN 
DROP TABLE #TableStats
END


CREATE TABLE #TableStats
  (
     Density FLOAT,
     Length  INT NULL,
     columns NVARCHAR(2078)
  ) 
  


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[##TableHistogram]'))
 BEGIN
DROP TABLE #TableHistogram
END

CREATE TABLE #TableHistogram
  (
     Range_HI_Key        SQL_VARIANT,
     Range_Rows          BIGINT NULL,
     EQ_Rows             BIGINT,
     Distinct_Range_Rows BIGINT,
     Avg_Range_Rows      BIGINT
  ) 



DECLARE db_cursor CURSOR  LOCAL
FOR

SELECT DATABASENAME
FROM   DynamicsPerf..COLLECTIONDATABASES
ORDER  BY DATABASENAME 


/* Open the cursor */
/*if the cursor isn't open you will get an error when you fetch the record*/
OPEN db_cursor 

/* Get the first record */
/* you can FETCH NEXT, FIRST, LAST, PREVIOUS */
FETCH NEXT FROM db_cursor INTO @DATABASE_NAME

/* Verify that we got a record*/
/* status 0 means we got a good record*/

WHILE @@fetch_status = 0  /* no errors */
BEGIN /* Top of Loop */



TRUNCATE TABLE #TableStats
TRUNCATE TABLE #TableHistogram

SET @LAST_STATS_COLLECTION_DATE = NULL

SET @LAST_STATS_COLLECTION_DATE =
	 ISNULL((SELECT MAX(STATS_TIME) FROM STATS_COLLECTION_SUMMARY WHERE DATABASE_NAME = @DATABASE_NAME AND STATS_COLLECTED = 'Y'),'1/1/1900')



IF @DEBUG = 'Y'
BEGIN
PRINT 'DATABASE = ' + @DATABASE_NAME
PRINT '@LAST_STATS_COLLECTION_DATE = ' + CAST(@LAST_STATS_COLLECTION_DATE AS VARCHAR(50))
END

--reh We only want to collect stats on Sunday or if we have never collected them
IF (DATEPART(DW, GETDATE()) = 1 AND DATEDIFF(DD,@LAST_STATS_COLLECTION_DATE, GETDATE()) >0)
OR @LAST_STATS_COLLECTION_DATE = '1/1/1900'
BEGIN
 
 DELETE FROM INDEX_DENSITY_VECTOR WHERE DATABASE_NAME = @DATABASE_NAME
 DELETE FROM INDEX_HISTOGRAM WHERE DATABASE_NAME = @DATABASE_NAME

DECLARE @tablename sysname
DECLARE @indexname sysname
DECLARE @colname sysname
DECLARE @schemaname sysname


--Create synonyms for the database
SET @SQL = '
IF  EXISTS (SELECT * FROM sys.synonyms WHERE name = N' + Quotename('DYN_SYSOBJECTS', '''') + ')
DROP SYNONYM [dbo].[DYN_SYSOBJECTS]

CREATE SYNONYM DYN_SYSOBJECTS
FOR [' + @DATABASE_NAME + '].sys.sysobjects;'

IF @DEBUG = 'Y' 
BEGIN
PRINT '@SQL= ' + @SQL
END

EXEC(@SQL) 


SET @SQL = '
IF  EXISTS (SELECT * FROM sys.synonyms WHERE name = N' + Quotename('DYN_SYSSTATS', '''') + ')
DROP SYNONYM [dbo].[DYN_SYSSTATS]

CREATE SYNONYM DYN_SYSSTATS
FOR [' + @DATABASE_NAME + '].sys.stats;'

IF @DEBUG = 'Y' 
BEGIN
PRINT '@SQL= ' + @SQL
END

EXEC(@SQL) 

SET @SQL = '
IF  EXISTS (SELECT * FROM sys.synonyms WHERE name = N' + Quotename('DYN_SYSSTATSCOL', '''') + ')
DROP SYNONYM [dbo].[DYN_SYSSTATSCOL]

CREATE SYNONYM DYN_SYSSTATSCOL
FOR [' + @DATABASE_NAME + '].sys.stats_columns;'

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

SET @SQL = '
IF  EXISTS (SELECT * FROM sys.synonyms WHERE name = N' + Quotename('DYN_SYSSCHEMA', '''') + ')
DROP SYNONYM [dbo].[DYN_SYSSCHEMA]

CREATE SYNONYM DYN_SYSSCHEMA
FOR [' + @DATABASE_NAME + '].sys.schemas;'

IF @DEBUG = 'Y' 
BEGIN
PRINT '@SQL= ' + @SQL
END

EXEC(@SQL) 

SET @SQL = '
IF  EXISTS (SELECT * FROM sys.synonyms WHERE name = N' + Quotename('DYN_SYSINDEXES', '''') + ')
DROP SYNONYM [dbo].[DYN_SYSINDEXES]

CREATE SYNONYM DYN_SYSINDEXES
FOR [' + @DATABASE_NAME + '].sys.indexes;'

IF @DEBUG = 'Y' 
BEGIN
PRINT '@SQL= ' + @SQL
END

EXEC(@SQL) 

SET @SQL = '
IF  EXISTS (SELECT * FROM sys.synonyms WHERE name = N' + Quotename('DYN_SYSINDEXCOLS', '''') + ')
DROP SYNONYM [dbo].[DYN_SYSINDEXCOLS]

CREATE SYNONYM DYN_SYSINDEXCOLS
FOR [' + @DATABASE_NAME + '].sys.index_columns;'

IF @DEBUG = 'Y' 
BEGIN
PRINT '@SQL= ' + @SQL
END

EXEC(@SQL) 

DECLARE table_cursor CURSOR
   FOR SELECT O.name,
              ST.name,
              C.name,
              SCH.name
       FROM   DYN_SYSOBJECTS O
              INNER JOIN DYN_SYSSTATS ST
                      ON O.id = ST.object_id
              INNER JOIN DYN_SYSSTATSCOL AS SC
                      ON ST.object_id = SC.object_id
                         AND ST.stats_id = SC.stats_id
              INNER JOIN DYN_SYSCOLS AS C
                      ON SC.object_id = C.object_id
                         AND C.column_id = SC.column_id
              INNER JOIN DYN_SYSSCHEMA AS SCH
                      ON O.uid = SCH.schema_id
       WHERE  O.xtype = 'u'
              AND SC.stats_column_id = 1
              AND C.system_type_id <> 189
              AND SCH.name <> 'sys' --remove timestamps, incompatiable with sql_variant datatype we used
              AND ( ST.auto_created = 1
               OR ST.user_created = 1)
       UNION ALL
       SELECT O.name,
              ST.name,
              C.name,
              SCH.name
       FROM   DYN_SYSOBJECTS O
              INNER JOIN DYN_SYSSTATS ST
                      ON O.id = ST.object_id
              INNER JOIN DYN_SYSSTATSCOL AS SC
                      ON ST.object_id = SC.object_id
                         AND ST.stats_id = SC.stats_id
              INNER JOIN DYN_SYSCOLS AS C
                      ON SC.object_id = C.object_id
                         AND C.column_id = SC.column_id
              INNER JOIN DYN_SYSSCHEMA AS SCH
                      ON O.uid = SCH.schema_id
       WHERE  O.xtype = 'u'
              AND SC.stats_column_id = 1
              AND C.system_type_id <> 189
              AND SCH.name <> 'sys' --remove timestamps, incompatiable with sql_variant datatype we used
              AND (ST.auto_created = 0
              AND ST.user_created = 0 )
       

/* Open the cursor */
/*if the cursor isn't open you will get an error when you fetch the record*/
OPEN table_cursor 

/* Get the first record */
/* you can FETCH NEXT, FIRST, LAST, PREVIOUS */
FETCH NEXT FROM table_cursor INTO @tablename, @indexname, @colname, @schemaname

/* Verify that we got a record*/
/* status 0 means we got a good record*/



WHILE @@fetch_status = 0  /* no errors */
BEGIN /* Top of Loop */
--	print @tablename + '    ' + @indexname
	SELECT @SQL = 'DBCC SHOW_STATISTICS('+'''' +@DATABASE_NAME +'.'+@schemaname+'.' +@tablename + '''' +',' +QUOTENAME(@indexname,'''')+') WITH DENSITY_VECTOR, NO_INFOMSGS'
		
		IF @DEBUG = 'Y' 
		BEGIN
		PRINT '@SQL= ' + @SQL
		END
		
	Begin Try
	INSERT  #TableStats	
	EXEC  (@SQL	) --DBCC SHOW_STATISTICS DENSITY VECTOR
	
	End Try
	Begin Catch
	 --ignore the error
	End catch
	
	insert  INDEX_DENSITY_VECTOR SELECT @DATABASE_NAME,@tablename,@indexname,* FROM #TableStats
	truncate table #TableStats
	
	SELECT @SQL = 'DBCC SHOW_STATISTICS('+'''' +@DATABASE_NAME +'.'+@schemaname+'.' +@tablename + '''' +',' +QUOTENAME(@indexname,'''')+') WITH HISTOGRAM, NO_INFOMSGS'
		
		IF @DEBUG = 'Y' 
		BEGIN
		PRINT '@SQL= ' + @SQL
		END
	
	Begin Try

	INSERT  #TableHistogram	
	EXEC  (@SQL	) --DBCC SHOW_STATISTICS HISTOGRAM
	
	End Try
	Begin Catch
	 --ignore the error
	End catch

	
	INSERT  INDEX_HISTOGRAM SELECT @DATABASE_NAME,@tablename,@indexname,@colname,* FROM #TableHistogram
	TRUNCATE TABLE #TableHistogram
	/* Get the next record */
	FETCH NEXT FROM table_cursor INTO @tablename,@indexname,@colname,@schemaname
END  /*End of the loop */
CLOSE table_cursor  /*close the cursor to free memory in SQL*/
DEALLOCATE table_cursor /*Must deallocate the cursor to destroy it and free SQL resources*/

UPDATE STATS_COLLECTION_SUMMARY SET STATS_COLLECTED = 'Y' WHERE RUN_NAME = @RUN_NAME AND DATABASE_NAME = @DATABASE_NAME


END


PRINT 'Completed Collecting Statistics Successfully for ' +@DATABASE_NAME+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'Inserted STATISTICS SUCCESSFULLY for ' + @DATABASE_NAME + ' at ' + CONVERT(VARCHAR, GETDATE(),109)+ ', ' 
WHERE STATS_TIME = @STATS_DATE



FETCH NEXT FROM db_cursor INTO @DATABASE_NAME
END  /*End of the loop */
CLOSE db_cursor  /*close the cursor to free memory in SQL*/
DEALLOCATE db_cursor /*Must deallocate the cursor to destroy it and free SQL resources*/


SKIPSTATS:
PRINT 'Completed Collecting Statistics Successfully '

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'Inserted STATISTICS SUCCESSFULLY at ' + CONVERT(VARCHAR, GETDATE(),109)+ ', ' 
WHERE STATS_TIME = @STATS_DATE
              
END TRY

BEGIN CATCH
PRINT 'Step failed to complete !!'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'FAILED TO insert STATISTICS at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE

END CATCH

--REH Added 11/9/2010  Capture Trace flag information

BEGIN TRY
PRINT 'STEP Insert SQL Trace Flag Options'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)
CREATE TABLE #TRACEFLAGS
  (
     TRACEFLAG    INT,
     STATUS       BIT,
     GLOBAL       BIT,
     SESSIONS     BIT
  ) 
SET @SQL = 'DBCC TRACESTATUS(-1) WITH NO_INFOMSGS '

IF @DEBUG = 'Y' 
BEGIN
PRINT '@SQL= ' + @SQL
END


INSERT  #TRACEFLAGS
EXEC (@SQL)

INSERT TRACEFLAGS 
SELECT @STATS_DATE,*  FROM #TRACEFLAGS

PRINT 'Completed Successfully'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'Inserted TRACE_FLAGS SUCCESSFULLY at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE

             
END TRY

BEGIN CATCH
PRINT 'Step failed to complete !!'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'FAILED TO insert TRACE_FLAGS at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE

END CATCH


BEGIN TRY
PRINT 'STEP Insert Virtual I/O Stats'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

INSERT DISKSTATS
SELECT  @STATS_DATE AS STATS_TIME ,
DB_NAME(database_id) AS DATABASENAME, 
database_id,file_id, sample_ms, num_of_reads,num_of_bytes_read, io_stall_read_ms, num_of_writes, num_of_bytes_written,io_stall_write_ms, io_stall, size_on_disk_bytes, file_handle
    FROM sys.dm_io_virtual_file_stats (NULL, NULL)

PRINT 'Completed Successfully'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'Inserted VIRTUAL_I/O SUCCESSFULLY at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE

             
END TRY

BEGIN CATCH
PRINT 'Step failed to complete !!'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'FAILED TO Insert VIRTUAL_I/O at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE


END CATCH



--Capture SQL Error LOG


BEGIN TRY
PRINT 'STEP Insert SQL Error Logs'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

DECLARE @version VARCHAR(30)
SELECT @version = cast(SERVERPROPERTY('ProductVersion') as varchar(30))

IF @DEBUG = 'Y' 
BEGIN
PRINT '@VERSION= ' + @version
END


IF Substring(@version, 1, 2) = '9.'
  BEGIN --Check SQL2005 build
      IF @version < '9.00.4230'
        GOTO ENDERRORLOG --xp_readerrorlog might fail, skip this step
  END 
IF Substring(@version, 1, 2) = '10'
  BEGIN --Check SQL2008 build
      IF @version < '10.0.2734'
        GOTO ENDERRORLOG --xp_readerrorlog might fail, skip this step
  END 

--REH  Figure out the last time we captured for any database and use the newest capture
SET @LAST_STATS_DATE = '1/1/1900' 									
									
SELECT TOP 1 @LAST_STATS_DATE = STATS_TIME
FROM   STATS_COLLECTION_SUMMARY WITH (NOLOCK)
WHERE STATS_TIME < @STATS_DATE  --Not the current collection or it won't grab anything
ORDER  BY STATS_TIME DESC

DECLARE @STARTDATE VARCHAR(30), @ENDDATE VARCHAR(30)
SELECT @STARTDATE = CONVERT(varchar(30),@LAST_STATS_DATE,25)
SELECT @ENDDATE = CONVERT(varchar(30),@STATS_DATE,25)

IF CAST(@STARTDATE AS SMALLDATETIME) < DATEADD(D,-14, GETDATE()) 
BEGIN
SELECT @STARTDATE = CONVERT(varchar(30),DATEADD(D,-14,GETDATE()),25)

END



CREATE TABLE #ErrorLog
  (
     LogDate     DATETIME,
     ProcessInfo NVARCHAR(255),
     LogText     NVARCHAR(MAX)
  ); 


INSERT INTO #ErrorLog (
   [LogDate],
   [ProcessInfo],
   [LogText]
)

EXEC xp_readerrorlog 0,1,NULL,NULL,@STARTDATE, @ENDDATE, 'ASC'

INSERT INTO SQLErrorLog 
SELECT * FROM #ErrorLog 
DROP TABLE #ErrorLog;  

ENDERRORLOG:
PRINT 'Completed Successfully'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'Inserted SQL_ERROR_LOG SUCCESSFULLY at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE

             
END TRY

BEGIN CATCH
PRINT 'Step failed to complete !!'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'FAILED TO Insert SQL_ERROR_LOG at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE

END CATCH
ENDPROC:



RETURN @RETURN_CODE



GO




USE [DynamicsPerf]
GO

/****** Object:  StoredProcedure [dbo].[SP_CAPTURESTATS]    Script Date: 02/28/2011 12:31:55 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SP_CAPTURESTATS]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SP_CAPTURESTATS]
GO

USE [DynamicsPerf]
GO

/****** Object:  StoredProcedure [dbo].[SP_CAPTURESTATS]    Script Date: 02/28/2011 12:31:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE	PROCEDURE [dbo].[SP_CAPTURESTATS]
		@DATABASE_NAME	NVARCHAR(128),	
		@TOP_ROWS		INT = 0,
		@TOP_COLUMN		NVARCHAR(128) = 'total_elapsed_time',
		@RUN_NAME		NVARCHAR(60) = NULL,
		@INDEX_PHYSICAL_STATS 	NCHAR(1)= 'N',
		@SKIP_STATS NVARCHAR(1)='Y',
		@DEBUG			NVARCHAR(1)= 'N'  
AS

SET NOCOUNT ON
SET DATEFORMAT MDY

DECLARE @STATS_DATE		SMALLDATETIME, 
		@SQL_VERSION	NVARCHAR(1000), 
		@DYNAMICS_VERSION NVARCHAR(MAX),
		@DATABASE_ID	INT,
		@RETURN_CODE	INT,
		@SQL			NVARCHAR(MAX),
		@RUN_DESCRIPTION NVARCHAR(1000),
		@SQL_TOP_CLAUSE	NVARCHAR(128),
		@SQL_ORDERBY_CLAUSE	NVARCHAR(128),
		@PARM			NVARCHAR(500),
		@SQL_SERVER_STARTTIME DATETIME,
		@RC INT
		

				
	SET @STATS_DATE = GETDATE()
	WHILE DATEDIFF(MINUTE,ISNULL((SELECT MAX(STATS_TIME) FROM STATS_COLLECTION_SUMMARY),'1/1/1900'),@STATS_DATE)<1 --reh wait 1 minute so we don't create a duplicate record error
	BEGIN 
		WAITFOR DELAY '00:00:10'	
			
		SET @STATS_DATE = GETDATE()
	END 
	
	IF @RUN_NAME IS NULL SET @RUN_NAME = CONVERT(VARCHAR, @STATS_DATE)
	-- -----------------------------------------------------------------------------------------
-- We will only want to capture query stats and query plans that have executed at least once 
-- since the last time SP_CAPTURESTATS was run, which is determine by retreiving the previous 
-- STATS_TIME from STATS_COLLECTION_SUMMARY.
-- If this is the first time SP_CAPTURESTATS has been executed, we set an arbitrarily low 
-- date (1900-01-01) from which to collect query stats
-- -----------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------------
--
--  Insert Capture_log entry with paramater values used for the run
--
----------------------------------------------------------------------------------------------

INSERT CAPTURE_LOG  SELECT @STATS_DATE, '@DATABASE_NAME = ' + ISNULL(@DATABASE_NAME,'ALL') + '  @RUN_NAME = ' + @RUN_NAME + ' @DEBUG = ' + @DEBUG + '  '


SET @RETURN_CODE = 0

TRUNCATE TABLE COLLECTIONDATABASES


IF @DATABASE_NAME IS NULL
BEGIN
INSERT COLLECTIONDATABASES SELECT * FROM DATABASES_2_COLLECT
END
ELSE
BEGIN
INSERT COLLECTIONDATABASES VALUES(@DATABASE_NAME)
END


DECLARE db_cursor CURSOR  LOCAL
FOR

SELECT DATABASENAME
FROM   DynamicsPerf..COLLECTIONDATABASES
ORDER  BY DATABASENAME 


/* Open the cursor */
/*if the cursor isn't open you will get an error when you fetch the record*/
OPEN db_cursor 

/* Get the first record */
/* you can FETCH NEXT, FIRST, LAST, PREVIOUS */
FETCH NEXT FROM db_cursor INTO @DATABASE_NAME

/* Verify that we got a record*/
/* status 0 means we got a good record*/

WHILE @@fetch_status = 0  /* no errors */
BEGIN /* Top of Loop */

SELECT @DATABASE_ID = database_id FROM sys.databases WITH (NOLOCK) WHERE name = @DATABASE_NAME
IF @@ROWCOUNT = 0
	BEGIN
		PRINT 'DATABASE '+@DATABASE_NAME+' DOES NOT EXIST'
		GOTO ENDPROC
	END
	
	
FETCH NEXT FROM db_cursor INTO @DATABASE_NAME
END  /*End of the loop */
CLOSE db_cursor  /*close the cursor to free memory in SQL*/
DEALLOCATE db_cursor /*Must deallocate the cursor to destroy it and free SQL resources*/
 
					
	

BEGIN TRY
PRINT 'STARTING CORE DATA COLLECTION'
PRINT ''
EXECUTE @RC = [DynamicsPerf].[dbo].[SP_CAPTURESTATS_CORE] 
   @DATABASE_NAME
  ,@TOP_ROWS
  ,@TOP_COLUMN
  ,@RUN_NAME
  ,@INDEX_PHYSICAL_STATS
  ,@STATS_DATE
  ,@DEBUG
  ,@SKIP_STATS  
  PRINT ''
  PRINT 'SUCCESSFULLY CAPTURED CORE DATA'
  PRINT ''
END TRY 

BEGIN CATCH
PRINT 'ERROR WHILE COLLECTING CORE DATA !!!!!!!!!!!!!!'

END CATCH

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SP_CAPTURESTATS_AX]') AND type in (N'P', N'PC'))
BEGIN


DECLARE @LAST_STATS_DATE DATETIME

DECLARE db_cursor CURSOR  LOCAL
FOR

SELECT DATABASENAME
FROM   DynamicsPerf..COLLECTIONDATABASES
ORDER  BY DATABASENAME 


/* Open the cursor */
/*if the cursor isn't open you will get an error when you fetch the record*/
OPEN db_cursor 

/* Get the first record */
/* you can FETCH NEXT, FIRST, LAST, PREVIOUS */
FETCH NEXT FROM db_cursor INTO @DATABASE_NAME

/* Verify that we got a record*/
/* status 0 means we got a good record*/

WHILE @@fetch_status = 0  /* no errors */
BEGIN /* Top of Loop */


SET @LAST_STATS_DATE = '1/1/1900' 									
									
SELECT TOP 1 @LAST_STATS_DATE = STATS_TIME
FROM   STATS_COLLECTION_SUMMARY WITH (NOLOCK)
WHERE  STATS_TIME < @STATS_DATE
       AND DATABASE_NAME = @DATABASE_NAME
ORDER  BY STATS_TIME DESC


BEGIN TRY
PRINT 'STARTING DYNAMICS AX DATA COLLECTION FOR DATABASE '+@DATABASE_NAME
EXECUTE @RC = [DynamicsPerf].[dbo].[SP_CAPTURESTATS_AX] 
   @DATABASE_NAME
  ,@RUN_NAME
  ,@STATS_DATE
 , @LAST_STATS_DATE  
  ,@DEBUG
  PRINT ''
  PRINT 'SUCCESSFULLY CAPTURED DYNAMICS AX DATA'
  PRINT ''
END TRY 

BEGIN CATCH
PRINT ''
PRINT 'ERROR WHILE COLLECTING DYNAMICS AX DATA !!!!!!!!!!!!!!!!'
PRINT ''

END CATCH


FETCH NEXT FROM db_cursor INTO @DATABASE_NAME
END  /*End of the loop */
CLOSE db_cursor  /*close the cursor to free memory in SQL*/
DEALLOCATE db_cursor /*Must deallocate the cursor to destroy it and free SQL resources*/
 
			



END
ENDPROC:
PRINT 'RUN NAME = '+ @RUN_NAME



GO

USE [DynamicsPerf]
GO

/****** Object:  StoredProcedure [dbo].[SP_CAPTURESTATS_PERF]    Script Date: 02/28/2011 12:31:55 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SP_CAPTURESTATS_PERF]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SP_CAPTURESTATS_PERF]
GO

USE [DynamicsPerf]
GO

/****** Object:  StoredProcedure [dbo].[SP_CAPTURESTATS_PERF]    Script Date: 02/28/2011 12:31:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
 


CREATE	PROCEDURE [dbo].[SP_CAPTURESTATS_PERF]
		@DATABASE_NAME	NVARCHAR(128),	
		@DEBUG			NVARCHAR(1)= 'N'  
AS

SET NOCOUNT ON
SET DATEFORMAT MDY


DECLARE @STATS_DATE SMALLDATETIME ,
		@DATABASE_ID INT,
		@SQL  NVARCHAR(MAX)
		
SET @STATS_DATE  = GETDATE()


TRUNCATE TABLE COLLECTIONDATABASES_PERF

IF @DATABASE_NAME IS NULL
BEGIN
INSERT COLLECTIONDATABASES_PERF SELECT * FROM DATABASES_2_COLLECT
END
ELSE
BEGIN
INSERT COLLECTIONDATABASES_PERF VALUES(@DATABASE_NAME)
END


DECLARE db_cursor CURSOR  LOCAL
FOR

SELECT DATABASENAME
FROM   DynamicsPerf..COLLECTIONDATABASES_PERF
ORDER  BY DATABASENAME 


/* Open the cursor */
/*if the cursor isn't open you will get an error when you fetch the record*/
OPEN db_cursor 

/* Get the first record */
/* you can FETCH NEXT, FIRST, LAST, PREVIOUS */
FETCH NEXT FROM db_cursor INTO @DATABASE_NAME

/* Verify that we got a record*/
/* status 0 means we got a good record*/

WHILE @@fetch_status = 0  /* no errors */
BEGIN /* Top of Loop */


		
SELECT @DATABASE_ID = database_id FROM sys.databases WITH (NOLOCK) WHERE name = @DATABASE_NAME


BEGIN TRY
PRINT 'STEP Insert PERF_INDEX_STATS for Database ' + @DATABASE_NAME

SET @SQL = '
	INSERT INTO PERF_INDEX_DETAIL WITH (TABLOCK) 
	SELECT	''' + CONVERT(NVARCHAR(50), @STATS_DATE, 121) + ''',''' + @DATABASE_NAME + ''',

			si.object_id,
			si.index_id,
			so.name, 
			si.name,  
			PS.DATA_SIZE AS PAGE_COUNT,
			PS.ROW_COUNT AS ROW_COUNT,
			0


	FROM	[' + @DATABASE_NAME + '].sys.indexes si
	JOIN	[' + @DATABASE_NAME + '].sys.sysindexes ii on si.object_id = ii.id and si.index_id = ii.indid
	JOIN	[' + @DATABASE_NAME + '].sys.objects so on so.object_id = si.object_id
	JOIN	[' + @DATABASE_NAME + '].sys.schemas ss on ss.schema_id = so.schema_id
	INNER JOIN  (SELECT object_id, index_id,SUM(row_count) AS ROW_COUNT,SUM(in_row_data_page_count + lob_used_page_count + row_overflow_used_page_count) AS DATA_SIZE	FROM [' + @DATABASE_NAME + '].sys.dm_db_partition_stats GROUP BY  object_id, index_id) as PS ON PS.index_id = si.index_id and PS.object_id = si.object_id

	WHERE	so.type = ''U''
	AND		si.type = 1  --CLUSTERED INDEXES ONLY
	UNION ALL 
	SELECT	''' + CONVERT(NVARCHAR(50), @STATS_DATE, 121) + ''',''' + @DATABASE_NAME + ''',
			si.object_id,
			si.index_id,
			so.name, 
			so.name, 
			PS.DATA_SIZE AS PAGE_COUNT,
			PS.ROW_COUNT AS ROW_COUNT,
			0
	FROM	[' + @DATABASE_NAME + '].sys.indexes si
	JOIN	[' + @DATABASE_NAME + '].sys.sysindexes ii on si.object_id = ii.id and si.index_id = ii.indid
	JOIN	[' + @DATABASE_NAME + '].sys.objects so on so.object_id = si.object_id
	JOIN	[' + @DATABASE_NAME + '].sys.schemas ss on ss.schema_id = so.schema_id
	INNER JOIN  (SELECT object_id, index_id,SUM(row_count) AS ROW_COUNT,SUM(in_row_data_page_count + lob_used_page_count + row_overflow_used_page_count) AS DATA_SIZE	FROM [' + @DATABASE_NAME + '].sys.dm_db_partition_stats GROUP BY  object_id, index_id) as PS ON PS.index_id = si.index_id and PS.object_id = si.object_id

	WHERE	so.type = ''U''
	AND		si.type = 0  --HEAP TABLE
	ORDER BY 1,2'

IF @DEBUG = 'Y' 
BEGIN
PRINT '@SQL= ' + @SQL
END

EXECUTE (@SQL) 

PRINT 'Completed Successfully'
             
END TRY

BEGIN CATCH
PRINT 'Step failed to complete !!'
END CATCH




BEGIN TRY
PRINT 'STEP Insert PERF_INDEX_USAGE_STATS for Database ' + @DATABASE_NAME
INSERT INTO PERF_INDEX_USAGE_STATS WITH (TABLOCK)
SELECT	@STATS_DATE,
		@DATABASE_NAME,
		object_id,
		index_id,
		user_seeks,
		user_scans,
		user_lookups,
		user_updates
FROM	sys.dm_db_index_usage_stats
WHERE 	database_id = @DATABASE_ID
AND 	object_id > 99

PRINT 'Completed Successfully'
             
END TRY

BEGIN CATCH
PRINT 'Step failed to complete !!'
END CATCH



FETCH NEXT FROM db_cursor INTO @DATABASE_NAME
END  /*End of the loop */
CLOSE db_cursor  /*close the cursor to free memory in SQL*/
DEALLOCATE db_cursor /*Must deallocate the cursor to destroy it and free SQL resources*/
 

BEGIN TRY
PRINT 'STEP Insert Virtual I/O Stats'

INSERT PERF_DISKSTATS
SELECT  @STATS_DATE AS STATS_TIME ,
DB_NAME(database_id) AS DATABASENAME, 
database_id,file_id, sample_ms, num_of_reads,num_of_bytes_read, io_stall_read_ms, num_of_writes, num_of_bytes_written,io_stall_write_ms, io_stall, size_on_disk_bytes, file_handle
    FROM sys.dm_io_virtual_file_stats (NULL, NULL)

PRINT 'Completed Successfully'
             
END TRY

BEGIN CATCH
PRINT 'Step failed to complete !!'
END CATCH

BEGIN TRY 
PRINT 'STEP Insert WAIT_STATS'

INSERT 	INTO PERF_WAIT_STATS WITH (TABLOCK)
SELECT 	@STATS_DATE, *
FROM 	sys.dm_os_wait_stats

PRINT 'Completed Successfully'
             
END TRY

BEGIN CATCH
PRINT 'Step failed to complete !!'
END CATCH


GO



/****** Object:  StoredProcedure [dbo].[SP_PARSE_PLAN]    Script Date: 03/16/2012 17:04:12 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SP_PARSE_PLAN]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SP_PARSE_PLAN]
GO



/****** Object:  StoredProcedure [dbo].[SP_PARSE_PLAN]    Script Date: 03/16/2012 17:04:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].[SP_PARSE_PLAN] 
      @QUERY_PLAN_HASH_V VARCHAR(18),
      @STATS_TIME DATETIME,
      @DATABASE_NAME    NVARCHAR(128)
AS BEGIN

declare @QUERY_PLAN_HASH varbinary(8);

select @QUERY_PLAN_HASH = cast('' as xml).value('xs:hexBinary( substring(sql:variable("@QUERY_PLAN_HASH_V"), sql:column("t.pos")) )', 'varbinary(8)')

from (select case substring(@QUERY_PLAN_HASH_V, 1, 2) when '0x' then 3 else 0 end) as t(pos);

WITH XMLNAMESPACES ('http://schemas.microsoft.com/sqlserver/2004/07/showplan' AS sp)

  SELECT    

            REPLICATE('------', 
                    coalesce(index_node.value('(../../@NodeId)[1]', 'INT'),-1)+1) +
            index_node.value('(./@LogicalOp)[1]', 'NVARCHAR(128)') as LOGICAL_OPERATOR,
            index_node.value('(./@PhysicalOp)[1]', 'NVARCHAR(128)') as PHYSICAL_OPERATOR,
            COALESCE(REPLACE(REPLACE(index_node.value('(./*/sp:Object/@Table)[1]', 'NVARCHAR(128)'), '[',''),']',''), '') as TABLE_NAME,
            COALESCE( REPLACE(REPLACE(index_node.value('(./*/sp:Object/@Index)[1]', 'NVARCHAR(128)'), '[',''),']',''), '') as INDEX_NAME,


            index_node.value('(./@EstimateRows)[1]', 'FLOAT') as ESTIMATED_ROWS,
            index_node.value('(./@EstimateIO)[1]', 'FLOAT') as ESTIMATED_IO,
            index_node.value('(./@EstimateCPU)[1]', 'FLOAT') as ESTIMATED_CPU
  FROM QUERY_PLANS
  OUTER APPLY QUERY_PLAN.nodes('//sp:RelOp') as Operators(index_node)
  
  WHERE QUERY_PLAN_HASH =  @QUERY_PLAN_HASH

  
 END

GO

/****** Object:  StoredProcedure [dbo].[SP_PARSE_PLAN_BASE]     Script Date: 03/16/2012 17:04:12 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SP_PARSE_PLAN_BASE]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SP_PARSE_PLAN_BASE] 
GO

/****** Object:  StoredProcedure [dbo].[SP_PARSE_PLAN_BASE]    Script Date: 2/10/2014 3:43:27 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_PARSE_PLAN_BASE] 
      @QUERY_PLAN_HASH_B VARCHAR(18)

AS BEGIN

declare @QUERY_PLAN_HASH_BASE varbinary(8);

select @QUERY_PLAN_HASH_BASE = cast('' as xml).value('xs:hexBinary( substring(sql:variable("@QUERY_PLAN_HASH_B"), sql:column("t.pos")) )', 'varbinary(8)')

from (select case substring(@QUERY_PLAN_HASH_B, 1, 2) when '0x' then 3 else 0 end) as t(pos);

WITH XMLNAMESPACES ('http://schemas.microsoft.com/sqlserver/2004/07/showplan' AS sp)

  SELECT    

            REPLICATE('------', 
                    coalesce(index_node.value('(../../@NodeId)[1]', 'INT'),-1)+1) +
            index_node.value('(./@LogicalOp)[1]', 'NVARCHAR(128)') as LOGICAL_OPERATOR,
            index_node.value('(./@PhysicalOp)[1]', 'NVARCHAR(128)') as PHYSICAL_OPERATOR,
            COALESCE(REPLACE(REPLACE(index_node.value('(./*/sp:Object/@Table)[1]', 'NVARCHAR(128)'), '[',''),']',''), '') as TABLE_NAME,
            COALESCE( REPLACE(REPLACE(index_node.value('(./*/sp:Object/@Index)[1]', 'NVARCHAR(128)'), '[',''),']',''), '') as INDEX_NAME,


            index_node.value('(./@EstimateRows)[1]', 'FLOAT') as ESTIMATED_ROWS,
            index_node.value('(./@EstimateIO)[1]', 'FLOAT') as ESTIMATED_IO,
            index_node.value('(./@EstimateCPU)[1]', 'FLOAT') as ESTIMATED_CPU
  FROM QUERY_PLANS
  OUTER APPLY QUERY_PLAN.nodes('//sp:RelOp') as Operators(index_node)
  
  WHERE QUERY_PLAN_HASH =  @QUERY_PLAN_HASH_BASE

  
 END

GO


/****** Object:  StoredProcedure [dbo].[SP_PARSE_PLAN_COMPARE]      Script Date: 03/16/2012 17:04:12 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SP_PARSE_PLAN_COMPARE]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SP_PARSE_PLAN_COMPARE] 

GO


/****** Object:  StoredProcedure [dbo].[SP_PARSE_PLAN_COMPARE]    Script Date: 2/10/2014 3:43:56 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


 CREATE PROCEDURE [dbo].[SP_PARSE_PLAN_COMPARE] 
      @QUERY_PLAN_HASH_C VARCHAR(18)

AS BEGIN

declare @QUERY_PLAN_HASH_COMPARE varbinary(8);

select @QUERY_PLAN_HASH_COMPARE = cast('' as xml).value('xs:hexBinary( substring(sql:variable("@QUERY_PLAN_HASH_C"), sql:column("t.pos")) )', 'varbinary(8)')

from (select case substring(@QUERY_PLAN_HASH_C, 1, 2) when '0x' then 3 else 0 end) as t(pos);

WITH XMLNAMESPACES ('http://schemas.microsoft.com/sqlserver/2004/07/showplan' AS sp)

  SELECT    

            REPLICATE('------', 
                    coalesce(index_node.value('(../../@NodeId)[1]', 'INT'),-1)+1) +
            index_node.value('(./@LogicalOp)[1]', 'NVARCHAR(128)') as LOGICAL_OPERATOR,
            index_node.value('(./@PhysicalOp)[1]', 'NVARCHAR(128)') as PHYSICAL_OPERATOR,
            COALESCE(REPLACE(REPLACE(index_node.value('(./*/sp:Object/@Table)[1]', 'NVARCHAR(128)'), '[',''),']',''), '') as TABLE_NAME,
            COALESCE( REPLACE(REPLACE(index_node.value('(./*/sp:Object/@Index)[1]', 'NVARCHAR(128)'), '[',''),']',''), '') as INDEX_NAME,


            index_node.value('(./@EstimateRows)[1]', 'FLOAT') as ESTIMATED_ROWS,
            index_node.value('(./@EstimateIO)[1]', 'FLOAT') as ESTIMATED_IO,
            index_node.value('(./@EstimateCPU)[1]', 'FLOAT') as ESTIMATED_CPU
  FROM QUERY_PLANS
  OUTER APPLY QUERY_PLAN.nodes('//sp:RelOp') as Operators(index_node)
  
  WHERE QUERY_PLAN_HASH =  @QUERY_PLAN_HASH_COMPARE

  
 END

GO







/****** Object:  StoredProcedure [dbo].[SP_INDEX_CHANGES]    Script Date: 2/11/2014 7:54:09 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SP_INDEX_CHANGES]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SP_INDEX_CHANGES]
GO



GO

/****** Object:  StoredProcedure [dbo].[SP_INDEX_CHANGES]    Script Date: 2/11/2014 7:52:21 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_INDEX_CHANGES]
@BASELINE AS VARCHAR(128),
@COMPARISON_RUN_NAME AS VARCHAR(128)
AS 

SELECT * FROM (
SELECT V1.DATABASE_NAME,V1.TABLE_NAME, V1.INDEX_NAME, 'INDEX CHANGED' AS DIFFERENCE FROM 
INDEX_STATS_VW V1 
INNER JOIN INDEX_STATS_VW V2
ON V1.DATABASE_NAME = V2.DATABASE_NAME 
AND V1.TABLE_NAME = V2.TABLE_NAME 
AND V1.INDEX_NAME = V2.INDEX_NAME 
AND V1.INDEX_KEYS <> V2.INDEX_KEYS
WHERE V1.RUN_NAME = @BASELINE AND V2.RUN_NAME = @COMPARISON_RUN_NAME

UNION

SELECT V1.DATABASE_NAME,V1.TABLE_NAME, V1.INDEX_NAME, 'INDEX DELETED' AS DIFFERENCE FROM 
INDEX_STATS_VW V1 
WHERE NOT EXISTS (SELECT INDEX_NAME FROM 
 INDEX_STATS_VW V2
WHERE   V1.DATABASE_NAME = V2.DATABASE_NAME 
AND V1.TABLE_NAME = V2.TABLE_NAME 
AND V1.INDEX_NAME = V2.INDEX_NAME 
AND  V2.RUN_NAME = @COMPARISON_RUN_NAME) 
AND  V1.RUN_NAME = @BASELINE

UNION

SELECT V2.DATABASE_NAME,V2.TABLE_NAME, V2.INDEX_NAME, 'INDEX ADDED' AS DIFFERENCE FROM 
INDEX_STATS_VW V2 
WHERE NOT EXISTS (SELECT INDEX_NAME FROM 
 INDEX_STATS_VW V1
WHERE   V1.DATABASE_NAME = V2.DATABASE_NAME 
AND V1.TABLE_NAME = V2.TABLE_NAME 
AND V1.INDEX_NAME = V2.INDEX_NAME 
AND  V1.RUN_NAME = @BASELINE) 
AND   V2.RUN_NAME = @COMPARISON_RUN_NAME ) AS A
ORDER BY A.DATABASE_NAME,A.TABLE_NAME
GO





GO
/*************************** END OF STORED PROCEDURES ************************************/

/*************************** START OF FUNCTIONS (VIEWS DEPENDENCIES) *********************/
USE [DynamicsPerf]
GO

/****** Object:  UserDefinedFunction [dbo].[Fn_getDBName]    Script Date: 02/28/2011 12:25:04 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Fn_getDBName]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[Fn_getDBName]
GO

USE [DynamicsPerf]
GO

/****** Object:  UserDefinedFunction [dbo].[Fn_getDBName]    Script Date: 02/28/2011 12:25:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[Fn_getDBName] (@DBID smallint)
RETURNS sysname
WITH EXECUTE AS CALLER
AS
BEGIN
return (select top 1 DATABASE_NAME from SQL_DATABASES where  DATABASE_ID = @DBID)
END;


GO

USE [DynamicsPerf]
GO

/****** Object:  UserDefinedFunction [dbo].[FN_RETURN_AXID_FROM_CONTEXT]    Script Date: 11/21/2013 1:39:58 PM ******/

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FN_RETURN_AXID_FROM_CONTEXT]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FN_RETURN_AXID_FROM_CONTEXT]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO




CREATE FUNCTION [dbo].[FN_RETURN_AXID_FROM_CONTEXT] (@CONTEXT_INFO AS VARBINARY(128))
RETURNS NVARCHAR(8)
WITH EXECUTE AS CALLER
AS
	BEGIN
		DECLARE	@CONTEXT_INFO_CHAR	VARCHAR(128),
						@AXID								NVARCHAR(8)
		SET @CONTEXT_INFO_CHAR = CAST(@CONTEXT_INFO AS VARCHAR(128))
		SET @CONTEXT_INFO_CHAR = LTRIM(@CONTEXT_INFO_CHAR)

		IF CHARINDEX(' ', @CONTEXT_INFO_CHAR,1) > 1
			SET @AXID = SUBSTRING(@CONTEXT_INFO_CHAR, 1, (CHARINDEX(' ', @CONTEXT_INFO_CHAR,1)-1))
		ELSE
			SET @AXID='N\A'

      RETURN ( @AXID );
  END







GO
USE [DynamicsPerf]
GO


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FN_RETURN_AXSESSION_FROM_CONTEXT]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FN_RETURN_AXSESSION_FROM_CONTEXT]
GO

/****** Object:  UserDefinedFunction [dbo].[FN_RETURN_AXSESSION_FROM_CONTEXT]    Script Date: 11/21/2013 1:40:09 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO




CREATE FUNCTION [dbo].[FN_RETURN_AXSESSION_FROM_CONTEXT] (@CONTEXT_INFO AS VARBINARY(128))
RETURNS NVARCHAR(8)
WITH EXECUTE AS CALLER
AS
	BEGIN
		DECLARE	@CONTEXT_INFO_CHAR	VARCHAR(128),
						@AXSESSION					NVARCHAR(8),
						@SESSION_START_POS	INT			

		SET @CONTEXT_INFO_CHAR = CAST(@CONTEXT_INFO AS VARCHAR(128))
		SET @CONTEXT_INFO_CHAR = LTRIM(@CONTEXT_INFO_CHAR)
		SET @SESSION_START_POS = CHARINDEX(' ', @CONTEXT_INFO_CHAR,1)+1

		IF @SESSION_START_POS > 1
			SET @AXSESSION = SUBSTRING(@CONTEXT_INFO_CHAR, @SESSION_START_POS, (CHARINDEX(' ', @CONTEXT_INFO_CHAR,@SESSION_START_POS)-(@SESSION_START_POS)))
		ELSE 
			SET @AXSESSION = 'N\A'

    RETURN ( @AXSESSION );
  END


GO
/*************************** END OF FUNCTIONS (VIEW DEPENDENCIES *************************/



/****************************  START OF VIEWS ********************************************/

USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[BLOCKED_PROCESS_VW]    Script Date: 10/17/2011 15:26:23 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[BLOCKED_PROCESS_VW]'))
DROP VIEW [dbo].[BLOCKED_PROCESS_VW]
GO

USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[BLOCKED_PROCESS_VW]    Script Date: 10/17/2011 15:26:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[BLOCKED_PROCESS_VW]
AS
 SELECT
END_TIME,
BLOCKED_SQL,
BLOCKED_SPID,
[WAIT_TIME(MS)],
WAIT_RESOURCE,
LOCK_MODE_REQUESTED,
BLOCKED_TRANS_COUNT,
BLOCKED_CLIENT_APP,
BLOCKED_HOST_NAME,
BLOCKED_ISOLATION_LEVEL,
BLOCKING_SQL,
BLOCKING_SPID,
BLOCKING_SPID_STATUS,
BLOCKING_TRANS_COUNT,
BLOCKING_LAST_BATCH_STARTED,
BLOCKING_LAST_BATCH_COMPLETED,
BLOCKING_CLIENT_APP,
BLOCKING_HOST_NAME,
BLOCKING_ISOLATION_LEVEL,
ObjectID


 FROM 
(
	SELECT	
	CONVERT(DATETIME, EndTime) AS END_TIME,
	convert(xml, TextData).value('(blocked-process-report/blocked-process/process/@spid)[1]','INT')						AS BLOCKED_SPID,
	convert(xml, TextData).value('(blocked-process-report/blocked-process/process/inputbuf)[1]','nvarchar(max)')		AS BLOCKED_SQL,
	convert(xml, TextData).value('(blocked-process-report/blocked-process/process/@waittime)[1]','INT')					AS [WAIT_TIME(MS)],
	convert(xml, TextData).value('(blocked-process-report/blocked-process/process/@waitresource)[1]','nvarchar(50)')	AS WAIT_RESOURCE,
	convert(xml, TextData).value('(blocked-process-report/blocked-process/process/@lockMode)[1]','nvarchar(50)')		AS LOCK_MODE_REQUESTED,
	convert(xml, TextData).value('(blocked-process-report/blocked-process/process/@transcount)[1]','INT')				AS BLOCKED_TRANS_COUNT,
	convert(xml, TextData).value('(blocked-process-report/blocked-process/process/@clientapp)[1]','nvarchar(50)')		AS BLOCKED_CLIENT_APP,
	convert(xml, TextData).value('(blocked-process-report/blocked-process/process/@hostname)[1]','nvarchar(50)')		AS BLOCKED_HOST_NAME,
	convert(xml, TextData).value('(blocked-process-report/blocked-process/process/@isolationlevel)[1]','nvarchar(50)')	AS BLOCKED_ISOLATION_LEVEL,
	convert(xml, TextData).value('(blocked-process-report/blocked-process/process/executionStack/frame/@SQLhandle)[1]','NVARCHAR(64)') as BLOCKED_SQL_HANDLE,
	convert(xml, TextData).value('(blocked-process-report/blocking-process/process/@spid)[1]','INT')					AS BLOCKING_SPID,
	convert(xml, TextData).value('(blocked-process-report/blocking-process/process/inputbuf)[1]','nvarchar(max)')		AS BLOCKING_SQL,
	convert(xml, TextData).value('(blocked-process-report/blocking-process/process/@status)[1]','NVARCHAR(10)')			AS BLOCKING_SPID_STATUS,
	convert(xml, TextData).value('(blocked-process-report/blocking-process/process/@transcount)[1]','INT')				AS BLOCKING_TRANS_COUNT,
	convert(xml, TextData).value('(blocked-process-report/blocking-process/process/@lastbatchstarted)[1]','DATETIME')	AS BLOCKING_LAST_BATCH_STARTED,
	convert(xml, TextData).value('(blocked-process-report/blocking-process/process/@lastbatchcompleted)[1]','DATETIME') AS BLOCKING_LAST_BATCH_COMPLETED,
	convert(xml, TextData).value('(blocked-process-report/blocking-process/process/@clientapp)[1]','nvarchar(50)')		AS BLOCKING_CLIENT_APP,
	convert(xml, TextData).value('(blocked-process-report/blocking-process/process/@hostname)[1]','nvarchar(50)')		AS BLOCKING_HOST_NAME,
	convert(xml, TextData).value('(blocked-process-report/blocking-process/process/@isolationlevel)[1]','nvarchar(50)') AS BLOCKING_ISOLATION_LEVEL,
	convert(xml, TextData).value('(blocked-process-report/blocking-process/process/executionStack/frame/@SQLhandle)[1]','NVARCHAR(64)') as BLOCKING_SQL_HANDLE,
	ObjectID
	FROM fn_trace_gettable(
	ISNULL(
	(SELECT TRACE_FULL_PATH_NAME FROM DYNAMICSPERF_SETUP)
	,(SELECT TOP 1 path FROM sys.traces WHERE path like '%DYNAMICS_DEFAULT%'))
	, default) F,
	sys.trace_events E
	WHERE EventClass = trace_event_id
	and name = 'Blocked process report'
)	AS Trace


GO


USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[DEFAULT_TRC_VW]    Script Date: 10/17/2011 15:26:46 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[DEFAULT_TRC_VW]'))
DROP VIEW [dbo].[DEFAULT_TRC_VW]
GO

USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[DEFAULT_TRC_VW]    Script Date: 10/17/2011 15:26:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[DEFAULT_TRC_VW] AS
SELECT E.NAME, F.*
	FROM fn_trace_gettable(
	ISNULL(
	(SELECT TRACE_FULL_PATH_NAME FROM DYNAMICSPERF_SETUP)
	,(SELECT TOP 1 path FROM sys.traces WHERE path like '%DYNAMICS_DEFAULT%'))
	, default) F,
      sys.trace_events E
      WHERE EventClass = trace_event_id


GO

USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[DISKSTATS_VW]    Script Date: 10/17/2011 15:27:07 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[DISKSTATS_VW]'))
DROP VIEW [dbo].[DISKSTATS_VW]
GO

USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[DISKSTATS_VW]    Script Date: 10/17/2011 15:27:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[DISKSTATS_VW]
AS
SELECT D.*
FROM   DISKSTATS D
       INNER JOIN STATS_COLLECTION_SUMMARY S
         ON D.STATS_TIME = S.STATS_TIME 
          

GO

USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[DISKSTATS_CURR_VW]    Script Date: 10/17/2011 15:27:24 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[DISKSTATS_CURR_VW]'))
DROP VIEW [dbo].[DISKSTATS_CURR_VW]
GO

USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[DISKSTATS_CURR_VW]    Script Date: 10/17/2011 15:27:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[DISKSTATS_CURR_VW]
AS
SELECT D.*
FROM   DISKSTATS D
       INNER JOIN STATS_COLLECTION_SUMMARY S
         ON D.STATS_TIME = S.STATS_TIME 
           WHERE D.STATS_TIME = (SELECT MAX(STATS_TIME)
                             FROM   STATS_COLLECTION_SUMMARY)


GO

USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[SQL_DATABASES_VW]    Script Date: 10/17/2011 15:27:54 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[SQL_DATABASES_VW]'))
DROP VIEW [dbo].[SQL_DATABASES_VW]
GO

USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[SQL_DATABASES_VW]    Script Date: 10/17/2011 15:27:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[SQL_DATABASES_VW]
AS
  SELECT DISTINCT S.[RUN_NAME],
         C.[DATABASE_NAME],
         [DATABASE_ID],
         [RECOVERY_MODEL_DESC],
         [IS_READ_COMMITTED_SNAPSHOT_ON],
         [CREATE_DATE],
         [COMPATIBILITY_LEVEL],
         [COLLATION_NAME],
         [IS_READ_ONLY],
         [IS_AUTO_CLOSE_ON],
         [IS_AUTO_SHRINK_ON],
         [STATE],
         [STATE_DESC],
         [IS_IN_STANDBY],
         [IS_CLEANLY_SHUTDOWN],
         [IS_SUPPLEMENTAL_LOGGING_ENABLED],
         [SNAPSHOT_ISOLATION_STATE],
         [SNAPSHOT_ISOLATION_STATE_DESC],
         [USER_ACCESS],
         [USER_ACCESS_DESC],
         [SOURCE_DATABASE_ID],
         [OWNER_SID],
         [RECOVERY_MODEL],
         [PAGE_VERIFY_OPTION],
         [PAGE_VERIFY_OPTION_DESC],
         [IS_AUTO_CREATE_STATS_ON],
         [IS_AUTO_UPDATE_STATS_ON],
         [IS_AUTO_UPDATE_STATS_ASYNC_ON],
         [IS_ANSI_NULL_DEFAULT_ON],
         [IS_ANSI_NULLS_ON],
         [IS_ANSI_PADDING_ON],
         [IS_ANSI_WARNINGS_ON],
         [IS_ARITHABORT_ON],
         [IS_CONCAT_NULL_YIELDS_NULL_ON],
         [IS_NUMERIC_ROUNDABORT_ON],
         [IS_QUOTED_IDENTIFIER_ON],
         [IS_RECURSIVE_TRIGGERS_ON],
         [IS_CURSOR_CLOSE_ON_COMMIT_ON],
         [IS_LOCAL_CURSOR_DEFAULT],
         [IS_FULLTEXT_ENABLED],
         [IS_TRUSTWORTHY_ON],
         [IS_DB_CHAINING_ON],
         [IS_PARAMETERIZATION_FORCED],
         [IS_MASTER_KEY_ENCRYPTED_BY_SERVER],
         [IS_PUBLISHED],
         [IS_SUBSCRIBED],
         [IS_MERGE_PUBLISHED],
         [IS_DISTRIBUTOR],
         [IS_SYNC_WITH_BACKUP],
         [SERVICE_BROKER_GUID],
         [IS_BROKER_ENABLED],
         [LOG_REUSE_WAIT],
         [LOG_REUSE_WAIT_DESC],
         [IS_DATE_CORRELATION_ON],
          S.[STATS_TIME]
  FROM   [dbo].[SQL_DATABASES] C,
         STATS_COLLECTION_SUMMARY S WITH(NOLOCK)
  WHERE  C.STATS_TIME = S.STATS_TIME


GO

USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[SQL_DATABASES_CURR_VW]    Script Date: 10/17/2011 15:28:10 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[SQL_DATABASES_CURR_VW]'))
DROP VIEW [dbo].[SQL_DATABASES_CURR_VW]
GO

USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[SQL_DATABASES_CURR_VW]    Script Date: 10/17/2011 15:28:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[SQL_DATABASES_CURR_VW]
AS
  SELECT DISTINCT S.[RUN_NAME],
         C.[DATABASE_NAME],
         [DATABASE_ID],
         [RECOVERY_MODEL_DESC],
         [IS_READ_COMMITTED_SNAPSHOT_ON],
         [CREATE_DATE],
         [COMPATIBILITY_LEVEL],
         [COLLATION_NAME],
         [IS_READ_ONLY],
         [IS_AUTO_CLOSE_ON],
         [IS_AUTO_SHRINK_ON],
         [STATE],
         [STATE_DESC],
         [IS_IN_STANDBY],
         [IS_CLEANLY_SHUTDOWN],
         [IS_SUPPLEMENTAL_LOGGING_ENABLED],
         [SNAPSHOT_ISOLATION_STATE],
         [SNAPSHOT_ISOLATION_STATE_DESC],
         [USER_ACCESS],
         [USER_ACCESS_DESC],
         [SOURCE_DATABASE_ID],
         [OWNER_SID],
         [RECOVERY_MODEL],
         [PAGE_VERIFY_OPTION],
         [PAGE_VERIFY_OPTION_DESC],
         [IS_AUTO_CREATE_STATS_ON],
         [IS_AUTO_UPDATE_STATS_ON],
         [IS_AUTO_UPDATE_STATS_ASYNC_ON],
         [IS_ANSI_NULL_DEFAULT_ON],
         [IS_ANSI_NULLS_ON],
         [IS_ANSI_PADDING_ON],
         [IS_ANSI_WARNINGS_ON],
         [IS_ARITHABORT_ON],
         [IS_CONCAT_NULL_YIELDS_NULL_ON],
         [IS_NUMERIC_ROUNDABORT_ON],
         [IS_QUOTED_IDENTIFIER_ON],
         [IS_RECURSIVE_TRIGGERS_ON],
         [IS_CURSOR_CLOSE_ON_COMMIT_ON],
         [IS_LOCAL_CURSOR_DEFAULT],
         [IS_FULLTEXT_ENABLED],
         [IS_TRUSTWORTHY_ON],
         [IS_DB_CHAINING_ON],
         [IS_PARAMETERIZATION_FORCED],
         [IS_MASTER_KEY_ENCRYPTED_BY_SERVER],
         [IS_PUBLISHED],
         [IS_SUBSCRIBED],
         [IS_MERGE_PUBLISHED],
         [IS_DISTRIBUTOR],
         [IS_SYNC_WITH_BACKUP],
         [SERVICE_BROKER_GUID],
         [IS_BROKER_ENABLED],
         [LOG_REUSE_WAIT],
         [LOG_REUSE_WAIT_DESC],
         [IS_DATE_CORRELATION_ON],
          S.[STATS_TIME]
  FROM   [dbo].[SQL_DATABASES] C,
         STATS_COLLECTION_SUMMARY S WITH(NOLOCK)
  WHERE  C.STATS_TIME = S.STATS_TIME
         AND C.STATS_TIME = (SELECT MAX(STATS_TIME)
                             FROM   STATS_COLLECTION_SUMMARY)


GO

USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[SQL_JOBS_VW]    Script Date: 10/17/2011 15:28:31 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[SQL_JOBS_VW]'))
DROP VIEW [dbo].[SQL_JOBS_VW]
GO

USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[SQL_JOBS_VW]    Script Date: 10/17/2011 15:28:31 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[SQL_JOBS_VW]
AS
  SELECT DISTINCT S.[RUN_NAME],
         [JOBNAME],
         [SCHEDULENAME],
         [FREQUENCY],
         [SUBFREQUENCY],
         [SCHEDULETIME],
         [NEXTRUNDATE],
         [STEP_ID],
         [STEP_NAME],
         [SUBSYSTEM],
         [COMMAND],
         S.[STATS_TIME]
  FROM   [dbo].[SQL_JOBS] C,
         STATS_COLLECTION_SUMMARY S WITH(NOLOCK)
  WHERE  C.STATS_TIME = S.STATS_TIME


GO

USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[SQL_JOBS_CURR_VW]    Script Date: 10/17/2011 15:28:50 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[SQL_JOBS_CURR_VW]'))
DROP VIEW [dbo].[SQL_JOBS_CURR_VW]
GO

USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[SQL_JOBS_CURR_VW]    Script Date: 10/17/2011 15:28:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[SQL_JOBS_CURR_VW]
AS
  SELECT DISTINCT S.[RUN_NAME],
         [JOBNAME],
         [SCHEDULENAME],
         [FREQUENCY],
         [SUBFREQUENCY],
         [SCHEDULETIME],
         [NEXTRUNDATE],
         [STEP_ID],
         [STEP_NAME],
         [SUBSYSTEM],
         [COMMAND],
         S.[STATS_TIME]
  FROM   [dbo].[SQL_JOBS] C,
         STATS_COLLECTION_SUMMARY S WITH(NOLOCK)
  WHERE  C.STATS_TIME = S.STATS_TIME
  
         AND C.STATS_TIME = (SELECT MAX(STATS_TIME)
                             FROM   STATS_COLLECTION_SUMMARY)


GO

USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[SQL_DATABASEFILES_VW]    Script Date: 10/17/2011 15:29:06 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[SQL_DATABASEFILES_VW]'))
DROP VIEW [dbo].[SQL_DATABASEFILES_VW]
GO

USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[SQL_DATABASEFILES_VW]    Script Date: 10/17/2011 15:29:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[SQL_DATABASEFILES_VW]
AS
  SELECT DISTINCT S.[RUN_NAME],
         C.[DATABASE_NAME],
         [FILE_NAME],
         [PHYSICAL_NAME],
         [FILE_TYPE],
         [DB_SIZE(MB)],
         [DB_FREE(MB)],
         [FREE_SPACE_%],
         [GROWTH_UNITS],
         [GROW_MAX_SIZE(MB)],
         S.[STATS_TIME]
  FROM   [dbo].[SQL_DATABASEFILES] C,
         STATS_COLLECTION_SUMMARY S WITH(NOLOCK)
  WHERE  C.STATS_TIME = S.STATS_TIME



GO

USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[SQL_DATABASEFILES_CURR_VW]    Script Date: 10/17/2011 15:29:19 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[SQL_DATABASEFILES_CURR_VW]'))
DROP VIEW [dbo].[SQL_DATABASEFILES_CURR_VW]
GO

USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[SQL_DATABASEFILES_CURR_VW]    Script Date: 10/17/2011 15:29:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[SQL_DATABASEFILES_CURR_VW]
AS
  SELECT DISTINCT S.[RUN_NAME],
         C.[DATABASE_NAME],
         [FILE_NAME],
         [PHYSICAL_NAME],
         [FILE_TYPE],
         [DB_SIZE(MB)],
         [DB_FREE(MB)],
         [FREE_SPACE_%],
         [GROWTH_UNITS],
         [GROW_MAX_SIZE(MB)],
         S.[STATS_TIME]
  FROM   [dbo].[SQL_DATABASEFILES] C,
         STATS_COLLECTION_SUMMARY S WITH(NOLOCK)
  WHERE  C.STATS_TIME = S.STATS_TIME
         AND C.STATS_TIME = (SELECT MAX(STATS_TIME)
                             FROM   STATS_COLLECTION_SUMMARY)


GO

USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[SQL_CONFIGURATION_VW]    Script Date: 10/17/2011 15:29:36 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[SQL_CONFIGURATION_VW]'))
DROP VIEW [dbo].[SQL_CONFIGURATION_VW]
GO

USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[SQL_CONFIGURATION_VW]    Script Date: 10/17/2011 15:29:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[SQL_CONFIGURATION_VW]
AS
  SELECT DISTINCT S.[RUN_NAME],
         S.[STATS_TIME],
         S.SQL_SERVER_STARTTIME,
         [NAME],
         [MINIMUM],
         [MAXIMUM],
         [CONFIG_VALUE],
         [RUN_VALUE]
  FROM   [dbo].[SQL_CONFIGURATION] C,
         STATS_COLLECTION_SUMMARY S WITH(NOLOCK)
  WHERE  C.STATS_TIME = S.STATS_TIME


GO

USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[SQL_CONFIGURATION_CURR_VW]    Script Date: 10/17/2011 15:29:51 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[SQL_CONFIGURATION_CURR_VW]'))
DROP VIEW [dbo].[SQL_CONFIGURATION_CURR_VW]
GO

USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[SQL_CONFIGURATION_CURR_VW]    Script Date: 10/17/2011 15:29:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[SQL_CONFIGURATION_CURR_VW]
AS
  SELECT DISTINCT S.[RUN_NAME],
         S.[STATS_TIME],
         S.SQL_SERVER_STARTTIME,
         [NAME],
         [MINIMUM],
         [MAXIMUM],
         [CONFIG_VALUE],
         [RUN_VALUE]
  FROM   [dbo].[SQL_CONFIGURATION] C,
         STATS_COLLECTION_SUMMARY S WITH(NOLOCK)
  WHERE  C.STATS_TIME = S.STATS_TIME
         AND C.STATS_TIME = (SELECT MAX(STATS_TIME)
                             FROM   STATS_COLLECTION_SUMMARY)


GO

USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[INDEX_STATS_VW]    Script Date: 10/17/2011 15:30:10 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[INDEX_STATS_VW]'))
DROP VIEW [dbo].[INDEX_STATS_VW]
GO

USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[INDEX_STATS_VW]    Script Date: 10/17/2011 15:30:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[INDEX_STATS_VW]
AS
  SELECT RUN_NAME,
         S.SQL_SERVER_STARTTIME,
         S.DATABASE_NAME,
         D.TABLE_NAME,
         D.INDEX_NAME,
         INDEX_DESCRIPTION,
         D.DATA_COMPRESSION,
         INDEX_KEYS,
         INCLUDED_COLUMNS,
         USER_SEEKS,
         USER_SCANS,
         USER_LOOKUPS,
         USER_UPDATES,
         RANGE_SCAN_COUNT,
         PAGE_COUNT,
         ROW_COUNT,
         SINGLETON_LOOKUP_COUNT,
         FORWARDED_FETCH_COUNT,
         INDEX_DEPTH,
         AVG_FRAGMENTATION_IN_PERCENT,
         FRAGMENT_COUNT,
         ROW_LOCK_WAIT_IN_MS,
         PAGE_LOCK_WAIT_IN_MS,
         INDEX_LOCK_PROMOTION_ATTEMPT_COUNT,
         INDEX_LOCK_PROMOTION_COUNT,
         PAGE_LATCH_WAIT_IN_MS,
         PAGE_IO_LATCH_WAIT_IN_MS,
         LEAF_INSERT_COUNT,
         LEAF_DELETE_COUNT,
         LEAF_UPDATE_COUNT,
         LEAF_GHOST_COUNT,
         NONLEAF_INSERT_COUNT,
         NONLEAF_DELETE_COUNT,
         NONLEAF_UPDATE_COUNT,
         LEAF_ALLOCATION_COUNT,
         NONLEAF_ALLOCATION_COUNT,
         LEAF_PAGE_MERGE_COUNT,
         NONLEAF_PAGE_MERGE_COUNT,
         LOB_FETCH_IN_PAGES,
         LOB_FETCH_IN_BYTES,
         LOB_ORPHAN_CREATE_COUNT,
         LOB_ORPHAN_INSERT_COUNT,
         ROW_OVERFLOW_FETCH_IN_PAGES,
         ROW_OVERFLOW_FETCH_IN_BYTES,
         COLUMN_VALUE_PUSH_OFF_ROW_COUNT,
         COLUMN_VALUE_PULL_IN_ROW_COUNT,
         ROW_LOCK_COUNT,
         ROW_LOCK_WAIT_COUNT,
         PAGE_LOCK_COUNT,
         PAGE_LOCK_WAIT_COUNT,
         PAGE_LATCH_WAIT_COUNT,
         PAGE_IO_LATCH_WAIT_COUNT,
         S.STATS_TIME,
         SQL_VERSION
  FROM   STATS_COLLECTION_SUMMARY S WITH (NOLOCK)
         JOIN INDEX_DETAIL D WITH (NOLOCK)
           ON S.STATS_TIME = D.STATS_TIME
              AND S.DATABASE_NAME = D.DATABASE_NAME
         LEFT JOIN INDEX_USAGE_STATS U WITH (NOLOCK)
           ON U.STATS_TIME = D.STATS_TIME
              AND U.DATABASE_NAME = D.DATABASE_NAME
              AND U.OBJECT_ID = D.OBJECT_ID
              AND U.INDEX_ID = D.INDEX_ID
         LEFT JOIN INDEX_PHYSICAL_STATS P WITH (NOLOCK)
           ON D.STATS_TIME = P.STATS_TIME
              AND D.DATABASE_NAME = P.DATABASE_NAME
              AND D.OBJECT_ID = P.OBJECT_ID
              AND D.INDEX_ID = P.INDEX_ID
         LEFT JOIN INDEX_OPERATIONAL_STATS O WITH (NOLOCK)
           ON D.STATS_TIME = O.STATS_TIME
              AND D.DATABASE_NAME = O.DATABASE_NAME
              AND D.OBJECT_ID = O.OBJECT_ID
              AND D.INDEX_ID = O.INDEX_ID


GO

USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[INDEX_STATS_CURR_VW]    Script Date: 10/17/2011 15:30:28 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[INDEX_STATS_CURR_VW]'))
DROP VIEW [dbo].[INDEX_STATS_CURR_VW]
GO

USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[INDEX_STATS_CURR_VW]    Script Date: 10/17/2011 15:30:28 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[INDEX_STATS_CURR_VW]
AS
  SELECT RUN_NAME,
         S.SQL_SERVER_STARTTIME,
         S.DATABASE_NAME,
         D.TABLE_NAME,
         D.INDEX_NAME,
         INDEX_DESCRIPTION,
         D.DATA_COMPRESSION,
         INDEX_KEYS,
         INCLUDED_COLUMNS,
         USER_SEEKS,
         USER_SCANS,
         USER_LOOKUPS,
         USER_UPDATES,
         RANGE_SCAN_COUNT,
         PAGE_COUNT,
         ROW_COUNT,
         SINGLETON_LOOKUP_COUNT,
         FORWARDED_FETCH_COUNT,
         INDEX_DEPTH,
         AVG_FRAGMENTATION_IN_PERCENT,
         FRAGMENT_COUNT,
         ROW_LOCK_WAIT_IN_MS,
         PAGE_LOCK_WAIT_IN_MS,
         INDEX_LOCK_PROMOTION_ATTEMPT_COUNT,
         INDEX_LOCK_PROMOTION_COUNT,
         PAGE_LATCH_WAIT_IN_MS,
         PAGE_IO_LATCH_WAIT_IN_MS,
         LEAF_INSERT_COUNT,
         LEAF_DELETE_COUNT,
         LEAF_UPDATE_COUNT,
         LEAF_GHOST_COUNT,
         NONLEAF_INSERT_COUNT,
         NONLEAF_DELETE_COUNT,
         NONLEAF_UPDATE_COUNT,
         LEAF_ALLOCATION_COUNT,
         NONLEAF_ALLOCATION_COUNT,
         LEAF_PAGE_MERGE_COUNT,
         NONLEAF_PAGE_MERGE_COUNT,
         LOB_FETCH_IN_PAGES,
         LOB_FETCH_IN_BYTES,
         LOB_ORPHAN_CREATE_COUNT,
         LOB_ORPHAN_INSERT_COUNT,
         ROW_OVERFLOW_FETCH_IN_PAGES,
         ROW_OVERFLOW_FETCH_IN_BYTES,
         COLUMN_VALUE_PUSH_OFF_ROW_COUNT,
         COLUMN_VALUE_PULL_IN_ROW_COUNT,
         ROW_LOCK_COUNT,
         ROW_LOCK_WAIT_COUNT,
         PAGE_LOCK_COUNT,
         PAGE_LOCK_WAIT_COUNT,
         PAGE_LATCH_WAIT_COUNT,
         PAGE_IO_LATCH_WAIT_COUNT,
         S.STATS_TIME,
         SQL_VERSION
  FROM   STATS_COLLECTION_SUMMARY S WITH (NOLOCK)
         JOIN INDEX_DETAIL D WITH (NOLOCK)
           ON S.STATS_TIME = D.STATS_TIME
              AND S.DATABASE_NAME = D.DATABASE_NAME
              AND S.STATS_TIME = (SELECT MAX(STATS_TIME)
                                  FROM   STATS_COLLECTION_SUMMARY)
         LEFT JOIN INDEX_USAGE_STATS U WITH (NOLOCK)
           ON U.STATS_TIME = D.STATS_TIME
              AND U.DATABASE_NAME = D.DATABASE_NAME
              AND U.OBJECT_ID = D.OBJECT_ID
              AND U.INDEX_ID = D.INDEX_ID
         LEFT JOIN INDEX_PHYSICAL_STATS P WITH (NOLOCK)
           ON D.STATS_TIME = P.STATS_TIME
              AND D.DATABASE_NAME = P.DATABASE_NAME
              AND D.OBJECT_ID = P.OBJECT_ID
              AND D.INDEX_ID = P.INDEX_ID
         LEFT JOIN INDEX_OPERATIONAL_STATS O WITH (NOLOCK)
           ON D.STATS_TIME = O.STATS_TIME
              AND D.DATABASE_NAME = O.DATABASE_NAME
              AND D.OBJECT_ID = O.OBJECT_ID
              AND D.INDEX_ID = O.INDEX_ID


GO

USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[BUFFER_DETAIL_VW]    Script Date: 10/17/2011 15:30:47 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[BUFFER_DETAIL_VW]'))
DROP VIEW [dbo].[BUFFER_DETAIL_VW]
GO

--USE [DynamicsPerf]
--GO

--/****** Object:  View [dbo].[BUFFER_DETAIL_VW]    Script Date: 10/17/2011 15:30:47 ******/
--SET ANSI_NULLS ON
--GO

--SET QUOTED_IDENTIFIER ON
--GO


--CREATE VIEW [dbo].[BUFFER_DETAIL_VW]
--AS
--SELECT TOP 100 PERCENT B.RUN_NAME,
--       B.STATS_TIME,
--       B.DATABASE_NAME,
--       Count(*)            AS PAGES,
--       COUNT(*)*8/1024      AS SIZE_MB

--FROM   BUFFER_DETAIL B,
--       STATS_COLLECTION_SUMMARY S WITH(NOLOCK)
--  WHERE  B.STATS_TIME = S.STATS_TIME
        
--GROUP  BY B.RUN_NAME,
--          B.STATS_TIME,
--          B.DATABASE_NAME

--ORDER  BY 
--		  B.RUN_NAME,
--          B.STATS_TIME,
--	      5 desc

--GO


USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[BUFFER_DETAIL_CURR_VW]    Script Date: 03/19/2012 09:55:38 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[BUFFER_DETAIL_CURR_VW]'))
DROP VIEW [dbo].[BUFFER_DETAIL_CURR_VW]
GO

USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[BUFFER_DETAIL_CURR_VW]    Script Date: 03/19/2012 09:55:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[BUFFER_DETAIL_CURR_VW]
AS
SELECT TOP 100 PERCENT B.RUN_NAME,
       B.STATS_TIME,
       B.DATABASE_NAME,
       0            AS PAGES,
       B.SIZE_MB  

FROM   BUFFER_DETAIL B,
       STATS_COLLECTION_SUMMARY S WITH(NOLOCK)
  WHERE  B.STATS_TIME = S.STATS_TIME
         AND S.STATS_TIME = (SELECT MAX(STATS_TIME)
                             FROM   STATS_COLLECTION_SUMMARY)
GROUP  BY B.RUN_NAME,
          B.STATS_TIME,
          B.DATABASE_NAME,
          B.SIZE_MB

ORDER  BY 
		  B.RUN_NAME,
          B.STATS_TIME,
	      5 desc



GO

USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[BLOCKS_VW]    Script Date: 01/20/2014 22:34:53 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[BLOCKS_VW]'))
DROP VIEW [dbo].[BLOCKS_VW]
GO

USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[BLOCKS_VW]    Script Date: 01/20/2014 22:34:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[BLOCKS_VW]
AS

SELECT [BLOCKED_DTTM]
      ,[BLOCKER_LOGIN]
      ,[BLOCKER_PROGRAM]
      ,[BLOCKER_HOSTNAME]
      ,[BLOCKED_LOGIN]
      ,[BLOCKED_PROGRAM]
      ,[BLOCKED_HOSTNAME]
      ,[BLOCKER_SESSION_ID]
      ,dbo.FN_RETURN_AXSESSION_FROM_CONTEXT(BLOCKER_CONTEXT_INFO) AS BLOCKER_AX_SESSION_ID
      ,dbo.FN_RETURN_AXID_FROM_CONTEXT(BLOCKER_CONTEXT_INFO)      AS BLOCKER_AX_USER_ID
      ,cast([BLOCKER_CONTEXT_INFO]  as nvarchar(128)) as BLOCKER_CONTEXT_INFO
      ,[BLOCKER_CONTEXT]
      ,[BLOCKER_TRAN_ISOLATION]
      ,[BLOCKER_STATUS]
      ,[BLOCKED_SESSION_ID]
      ,dbo.FN_RETURN_AXSESSION_FROM_CONTEXT(BLOCKER_CONTEXT_INFO) AS BLOCKED_AX_SESSION_ID
      ,dbo.FN_RETURN_AXID_FROM_CONTEXT(BLOCKER_CONTEXT_INFO)      AS BLOCKED_AX_USER_ID
      ,cast([BLOCKED_CONTEXT_INFO]  as nvarchar(128)) as BLOCKED_CONTEXT_INFO
      ,[BLOCKED_CONTEXT]
      ,[BLOCKED_TRAN_ISOLATION]
      ,[TRANSACTION_ID]
      ,[WAIT_TIME]
      ,[LOCK_MODE]
      ,[LOCK_SIZE]
      ,[DATABASE_NAME]
      ,[ALLOW_SNAPSHOT_ISOLATION]
      ,[READ_COMMITTED_SNAPSHOT]
      ,[OBJECT_NAME]
      ,[INDEX_ID]
      ,[BLOCKER_SQL]
      ,[BLOCKER_PLAN]
      ,[BLOCKED_SQL]
      ,[BLOCKED_PLAN]
  FROM [DynamicsPerf].[dbo].[BLOCKS]

GO



USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[BLOCKED_PROCESS_INFO_VW]    Script Date: 10/17/2011 15:31:20 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[BLOCKED_PROCESS_INFO_VW]'))
DROP VIEW [dbo].[BLOCKED_PROCESS_INFO_VW]
GO

USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[BLOCKED_PROCESS_INFO_VW]    Script Date: 10/17/2011 15:31:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[BLOCKED_PROCESS_INFO_VW] AS
SELECT
END_TIME,
DATABASE_NAME,
BLOCKED_SPID,
WAIT_TIME,
WAIT_RESOURCE,
LOCK_MODE_REQUESTED,
BLOCKED_TRANS_COUNT,
BLOCKED_CLIENT_APP,
BLOCKED_HOST_NAME,
BLOCKED_ISOLATION_LEVEL,
BLOCKED_SQL_TEXT ,
BLOCKED_SQL_HANDLE,
BLOCKING_SPID,
BLOCKING_SPID_STATUS,
BLOCKING_TRANS_COUNT,
BLOCKING_LAST_BATCH_STARTED,
BLOCKING_LAST_BATCH_COMPLETED,
BLOCKING_CLIENT_APP,
BLOCKING_HOST_NAME,
BLOCKING_ISOLATION_LEVEL,
BLOCKING_SQL_TEXT, 
BLOCKING_SQL_HANDLE


 FROM
(
	
SELECT V1.[TRANSACTIONID]
      , V1.[END_TIME]
      , dbo.Fn_getDBName(V1.DATABASE_ID) as [DATABASE_NAME]
      , V1.[BLOCKED_SPID]
      , V1.[BLOCKED_SQL_TEXT]
      , V1.[WAIT_TIME]
      , V1.[WAIT_RESOURCE]
      , V1.[LOCK_MODE_REQUESTED]
      , V1.[BLOCKED_TRANS_COUNT]
      , V1.[BLOCKED_CLIENT_APP]
      , V1.[BLOCKED_HOST_NAME]
      , V1.[BLOCKED_ISOLATION_LEVEL]
      , V1.[BLOCKED_SQL_HANDLE]
      , V1.[BLOCKING_SPID]
      , V1.[BLOCKING_SQL_TEXT]
      , V1.[BLOCKING_SPID_STATUS]
      , V1.[BLOCKING_TRANS_COUNT]
      , V1.[BLOCKING_LAST_BATCH_STARTED]
      , V1.[BLOCKING_LAST_BATCH_COMPLETED]
      , V1.[BLOCKING_CLIENT_APP]
      , V1.[BLOCKING_HOST_NAME]
      , V1.[BLOCKING_ISOLATION_LEVEL]
      , V1.[BLOCKING_SQL_HANDLE]

FROM   BLOCKED_PROCESS_INFO V1
       JOIN (SELECT TRANSACTIONID  AS TRANSACTIONID,
                    MAX(WAIT_TIME) AS WAIT_TIME
             FROM   BLOCKED_PROCESS_INFO T
             GROUP  BY TRANSACTIONID) V2
         ON V1.TRANSACTIONID = V2.TRANSACTIONID
            AND V1.WAIT_TIME = V2.WAIT_TIME 

)	AS TRACE



GO


/****** Object:  View [dbo].[QUERY_STATS_VW]    Script Date: 02/02/2011 14:19:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[QUERY_STATS_VW]'))
DROP VIEW QUERY_STATS_VW
GO

CREATE VIEW [dbo].[QUERY_STATS_VW]
AS
WITH XMLNAMESPACES ('http://schemas.microsoft.com/sqlserver/2004/07/showplan' AS sp)
SELECT S.RUN_NAME,
       S.DATABASE_NAME,
       CREATION_TIME                                         AS COMPILED_TIME,
       EXECUTION_COUNT,
       EXECUTION_COUNT / CASE (DATEDIFF(HOUR,CREATION_TIME, S.STATS_TIME))
       WHEN 0 THEN 1 ELSE (DATEDIFF(HOUR,CREATION_TIME, S.STATS_TIME)) END AS EXECUTION_PER_HOUR,
       Cast(TOTAL_ELAPSED_TIME / 1000.000 AS DECIMAL(14, 3)) AS TOTAL_ELAPSED_TIME,
       Q.AVG_TIME_ms AS AVG_ELAPSED_TIME,
       Cast(MAX_ELAPSED_TIME / 1000.000 AS DECIMAL(14, 3))   AS MAX_ELAPSED_TIME,
       AVG_LOGICAL_READS = TOTAL_LOGICAL_READS / EXECUTION_COUNT,
       Cast(TOTAL_ELAPSED_TIME / 1000.000 AS DECIMAL(14, 3)) - Cast(TOTAL_WORKER_TIME / 1000.000 AS DECIMAL(14, 3))  AS TOTAL_WAIT_TIME,
       AVG_ROWS_RETURNED = TOTAL_ROWS / EXECUTION_COUNT,
       QT.SQL_TEXT                                           AS SQL_TEXT,
       QP.SQL_PARMS                                          AS QUERY_PARAMETER_VALUES,
       QUERY_PLAN,
       Q.ROW_NUM,
       Q.QUERY_HASH,
       TOTAL_ROWS,
       MAX_ROWS,
       MIN_ROWS,
       PLAN_GENERATION_NUM,
       LAST_EXECUTION_TIME,
       Cast(TOTAL_WORKER_TIME / 1000.000 AS DECIMAL(14, 3))  AS TOTAL_WORKER_TIME,
       AVG_PHYSICAL_READS = TOTAL_PHYSICAL_READS / EXECUTION_COUNT,
       AVG_LOGICAL_WRITES = TOTAL_LOGICAL_WRITES / EXECUTION_COUNT,
       Cast(LAST_ELAPSED_TIME / 1000.000 AS DECIMAL(14, 3))  AS LAST_ELAPSED_TIME,
       Cast(MIN_ELAPSED_TIME / 1000.000 AS DECIMAL(14, 3))   AS MIN_ELAPSED_TIME,
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
       Cast(LAST_WORKER_TIME / 1000.000 AS DECIMAL(14, 3))   AS LAST_WORKER_TIME,
       Cast(MIN_WORKER_TIME / 1000.000 AS DECIMAL(14, 3))    AS MIN_WORKER_TIME,
       Cast(MAX_WORKER_TIME / 1000.000 AS DECIMAL(14, 3))    AS MAX_WORKER_TIME,
       QUERY_PLAN_TEXT = CONVERT(NVARCHAR(MAX), QUERY_PLAN),
       S.STATS_TIME,
       SQL_VERSION,
       S.SQL_SERVER_STARTTIME,
       Q.QUERY_PLAN_HASH,
       C.COMMENT
FROM   QUERY_STATS Q WITH (NOLOCK)
       INNER JOIN QUERY_PLANS QP WITH (NOLOCK)
               ON QP.QUERY_PLAN_HASH = Q.QUERY_PLAN_HASH
       CROSS APPLY QUERY_PLAN.nodes('//sp:Batch') AS Batch(index_node)
       INNER JOIN STATS_COLLECTION_SUMMARY S WITH (NOLOCK)
               ON Q.STATS_TIME = S.STATS_TIME
                  AND Q.DATABASE_NAME = S.DATABASE_NAME
       LEFT OUTER JOIN QUERY_TEXT QT
                    ON Q.QUERY_HASH = QT.QUERY_HASH
                       
       LEFT OUTER JOIN COMMENTS C
                    ON Q.QUERY_HASH = C.QUERY_HASH 

GO
/****** Object:  View [dbo].[QUERY_STATS_CURR_VW]    Script Date: 02/02/2011 14:19:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[QUERY_STATS_CURR_VW]'))
DROP VIEW QUERY_STATS_CURR_VW
GO

CREATE VIEW [dbo].[QUERY_STATS_CURR_VW]
AS

WITH XMLNAMESPACES ('http://schemas.microsoft.com/sqlserver/2004/07/showplan' AS sp)
SELECT S.RUN_NAME,
       S.DATABASE_NAME,
       CREATION_TIME                                         AS COMPILED_TIME,
       EXECUTION_COUNT,
       EXECUTION_COUNT / CASE (DATEDIFF(HOUR,CREATION_TIME, S.STATS_TIME))
       WHEN 0 THEN 1 ELSE (DATEDIFF(HOUR,CREATION_TIME, S.STATS_TIME)) END AS EXECUTION_PER_HOUR,
       Cast(TOTAL_ELAPSED_TIME / 1000.000 AS DECIMAL(14, 3)) AS TOTAL_ELAPSED_TIME,
       Q.AVG_TIME_ms AS AVG_ELAPSED_TIME,
       Cast(MAX_ELAPSED_TIME / 1000.000 AS DECIMAL(14, 3))   AS MAX_ELAPSED_TIME,
       AVG_LOGICAL_READS = TOTAL_LOGICAL_READS / EXECUTION_COUNT,
       Cast(TOTAL_ELAPSED_TIME / 1000.000 AS DECIMAL(14, 3)) - Cast(TOTAL_WORKER_TIME / 1000.000 AS DECIMAL(14, 3))  AS TOTAL_WAIT_TIME,
       AVG_ROWS_RETURNED = TOTAL_ROWS / EXECUTION_COUNT,
       QT.SQL_TEXT                                           AS SQL_TEXT,
       QP.SQL_PARMS                                          AS QUERY_PARAMETER_VALUES,
       QUERY_PLAN,
       Q.ROW_NUM,
       Q.QUERY_HASH,
       TOTAL_ROWS,
       MAX_ROWS,
       MIN_ROWS,
       PLAN_GENERATION_NUM,
       Q.LAST_EXECUTION_TIME,
       Cast(TOTAL_WORKER_TIME / 1000.000 AS DECIMAL(14, 3))  AS TOTAL_WORKER_TIME,
       AVG_PHYSICAL_READS = TOTAL_PHYSICAL_READS / EXECUTION_COUNT,
       AVG_LOGICAL_WRITES = TOTAL_LOGICAL_WRITES / EXECUTION_COUNT,
       Cast(LAST_ELAPSED_TIME / 1000.000 AS DECIMAL(14, 3))  AS LAST_ELAPSED_TIME,
       Cast(MIN_ELAPSED_TIME / 1000.000 AS DECIMAL(14, 3))   AS MIN_ELAPSED_TIME,
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
       Cast(LAST_WORKER_TIME / 1000.000 AS DECIMAL(14, 3))   AS LAST_WORKER_TIME,
       Cast(MIN_WORKER_TIME / 1000.000 AS DECIMAL(14, 3))    AS MIN_WORKER_TIME,
       Cast(MAX_WORKER_TIME / 1000.000 AS DECIMAL(14, 3))    AS MAX_WORKER_TIME,
       QUERY_PLAN_TEXT = CONVERT(NVARCHAR(MAX), QUERY_PLAN),
       S.STATS_TIME,
       SQL_VERSION,
       S.SQL_SERVER_STARTTIME,
       Q.QUERY_PLAN_HASH,
       C.COMMENT
FROM   (SELECT QS2.DATABASE_NAME,
               QUERY_HASH,
               max(QS2.STATS_TIME)          AS STATS_TIME,
               max(LAST_EXECUTION_TIME) AS LAST_EXECUTION_TIME
        FROM   QUERY_STATS QS2
		INNER JOIN STATS_COLLECTION_SUMMARY S2 WITH (NOLOCK)
               ON QS2.STATS_TIME = S2.STATS_TIME
                  AND QS2.DATABASE_NAME = S2.DATABASE_NAME AND S2.RUN_NAME NOT LIKE 'BASE%'
        GROUP  BY QS2.DATABASE_NAME,
                  QUERY_HASH) AS A
       INNER LOOP JOIN QUERY_STATS Q WITH (NOLOCK)
                    ON A.DATABASE_NAME = Q.DATABASE_NAME
                       AND A.QUERY_HASH = Q.QUERY_HASH
                       AND A.LAST_EXECUTION_TIME = Q.LAST_EXECUTION_TIME
                       AND A.STATS_TIME = Q.STATS_TIME
       INNER JOIN QUERY_PLANS QP WITH (NOLOCK)
               ON QP.QUERY_PLAN_HASH = Q.QUERY_PLAN_HASH
       INNER JOIN STATS_COLLECTION_SUMMARY S WITH (NOLOCK)
               ON Q.STATS_TIME = S.STATS_TIME
                  AND Q.DATABASE_NAME = S.DATABASE_NAME
                  
       LEFT OUTER JOIN QUERY_TEXT QT
                    ON Q.QUERY_HASH = QT.QUERY_HASH
                        
	   LEFT OUTER JOIN COMMENTS C ON Q.QUERY_HASH = C.QUERY_HASH

GO

/****** Object:  View [dbo].[USER_SCANS_VW]    Script Date: 02/02/2011 14:19:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[USER_SCANS_VW]'))
DROP VIEW USER_SCANS_VW
GO
USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[USER_SCANS_VW]    Script Date: 10/17/2011 15:03:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[USER_SCANS_VW] AS
WITH XMLNAMESPACES ('http://schemas.microsoft.com/sqlserver/2004/07/showplan' AS sp)
SELECT *
FROM 
(
SELECT RUN_NAME,
       DATABASE_NAME,
       ROW_NUM,
       QUERY_HASH,
       EXECUTION_COUNT,
       TOTAL_ELAPSED_TIME,
       AVG_ELAPSED_TIME,
       AVG_LOGICAL_READS,
       SQL_TEXT,
       CONVERT (NVARCHAR(MAX), index_node2.query('for $qplan in //sp:QueryPlan, $plist in $qplan/sp:ParameterList, $colref in $plist/sp:ColumnReference  return concat(string($colref/@Column),":",string($colref/@ParameterCompiledValue),",   "),"  "')) AS QUERY_PARAMETER_VALUES,
       QUERY_PLAN,
       index_node.value('(.//@PhysicalOp)[1]', 'NVARCHAR(128)')                                                                                                                                                                                            AS PHYSICAL_OPERATOR,
       Replace(Replace(index_node.value('(.//@Table)[1]', 'NVARCHAR(128)'), '[', ''), ']', '')                                                                                                                                                             AS TABLE_NAME,
       Replace(Replace(index_node.value('(.//@Index)[1]', 'NVARCHAR(128)'), '[', ''), ']', '')                                                                                                                                                             AS INDEX_NAME,
       Replace(CONVERT(NVARCHAR(MAX), index_node.query('for $indexscan in ./sp:IndexScan,
										$predicate in $indexscan/sp:Predicate,
										$columnreference in $predicate//sp:ColumnReference
                                        return string($columnreference/@Column)')), ' ', ', ')                                                                                                                                                      AS PREDICATE_COLUMNS,
       TOTAL_WORKER_TIME,
       AVG_PHYSICAL_READS,
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
       OUTER APPLY QUERY_PLAN.nodes('//sp:RelOp') AS Operators(index_node)
       CROSS APPLY QUERY_PLAN.nodes('//sp:Batch') AS Batch(index_node2) 

) A
WHERE PHYSICAL_OPERATOR LIKE '%Index_Scan%'
UNION ALL
SELECT *
FROM 
(
SELECT RUN_NAME,
       DATABASE_NAME,
       ROW_NUM,
       QUERY_HASH,
       EXECUTION_COUNT,
       TOTAL_ELAPSED_TIME,
       AVG_ELAPSED_TIME,
       AVG_LOGICAL_READS,
       SQL_TEXT,
       CONVERT (NVARCHAR(MAX), index_node2.query('for $qplan in //sp:QueryPlan, $plist in $qplan/sp:ParameterList, $colref in $plist/sp:ColumnReference  return concat(string($colref/@Column),":",string($colref/@ParameterCompiledValue),",   "),"  "')) AS QUERY_PARAMETER_VALUES,
       QUERY_PLAN,
       index_node.value('(.//@PhysicalOp)[1]', 'NVARCHAR(128)')                                                                                                                                                                                            AS PHYSICAL_OPERATOR,
       Replace(Replace(index_node.value('(.//@Table)[1]', 'NVARCHAR(128)'), '[', ''), ']', '')                                                                                                                                                             AS TABLE_NAME,
       Replace(Replace(index_node.value('(.//@Index)[1]', 'NVARCHAR(128)'), '[', ''), ']', '')                                                                                                                                                             AS INDEX_NAME,
       Replace(CONVERT(NVARCHAR(MAX), index_node.query('for $indexscan in ./sp:IndexScan,
										$predicate in $indexscan/sp:Predicate,
										$columnreference in $predicate//sp:ColumnReference
                                        return string($columnreference/@Column)')), ' ', ', ')                                                                                                                                                      AS PREDICATE_COLUMNS,
       TOTAL_WORKER_TIME,
       AVG_PHYSICAL_READS,
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
       OUTER APPLY QUERY_PLAN.nodes('//sp:RelOp') AS Operators(index_node)
       CROSS APPLY QUERY_PLAN.nodes('//sp:Batch') AS Batch(index_node2) 

) A
WHERE PHYSICAL_OPERATOR LIKE '%Table Scan%'


GO


GO
/****** Object:  View [dbo].[USER_SCANS_CURR_VW]    Script Date: 02/02/2011 14:19:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[USER_SCANS_CURR_VW]'))
DROP VIEW USER_SCANS_CURR_VW
GO
USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[USER_SCANS_CURR_VW]    Script Date: 10/17/2011 15:05:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[USER_SCANS_CURR_VW] AS
WITH XMLNAMESPACES ('http://schemas.microsoft.com/sqlserver/2004/07/showplan' AS sp)
SELECT *
FROM 
(
SELECT RUN_NAME,
       DATABASE_NAME,
       ROW_NUM,
       QUERY_HASH,
       EXECUTION_COUNT,
       TOTAL_ELAPSED_TIME,
       AVG_ELAPSED_TIME,
       AVG_LOGICAL_READS,
       SQL_TEXT,
       CONVERT (NVARCHAR(MAX), index_node2.query('for $qplan in //sp:QueryPlan, $plist in $qplan/sp:ParameterList, $colref in $plist/sp:ColumnReference  return concat(string($colref/@Column),":",string($colref/@ParameterCompiledValue),",   "),"  "')) AS QUERY_PARAMETER_VALUES,
       QUERY_PLAN,
       index_node.value('(.//@PhysicalOp)[1]', 'NVARCHAR(128)')                                                                                                                                                                                            AS PHYSICAL_OPERATOR,
       Replace(Replace(index_node.value('(.//@Table)[1]', 'NVARCHAR(128)'), '[', ''), ']', '')                                                                                                                                                             AS TABLE_NAME,
       Replace(Replace(index_node.value('(.//@Index)[1]', 'NVARCHAR(128)'), '[', ''), ']', '')                                                                                                                                                             AS INDEX_NAME,
       Replace(CONVERT(NVARCHAR(MAX), index_node.query('for $indexscan in ./sp:IndexScan,
										$predicate in $indexscan/sp:Predicate,
										$columnreference in $predicate//sp:ColumnReference
                                        return string($columnreference/@Column)')), ' ', ', ')                                                                                                                                                      AS PREDICATE_COLUMNS,
       TOTAL_WORKER_TIME,
       AVG_PHYSICAL_READS,
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
       OUTER APPLY QUERY_PLAN.nodes('//sp:RelOp') AS Operators(index_node)
       CROSS APPLY QUERY_PLAN.nodes('//sp:Batch') AS Batch(index_node2) 


) A
WHERE PHYSICAL_OPERATOR LIKE '%Index_Scan%'
UNION ALL
SELECT *
FROM 
(
SELECT RUN_NAME,
       DATABASE_NAME,
       ROW_NUM,
       QUERY_HASH,
       EXECUTION_COUNT,
       TOTAL_ELAPSED_TIME,
       AVG_ELAPSED_TIME,
       AVG_LOGICAL_READS,
       SQL_TEXT,
       CONVERT (NVARCHAR(MAX), index_node2.query('for $qplan in //sp:QueryPlan, $plist in $qplan/sp:ParameterList, $colref in $plist/sp:ColumnReference  return concat(string($colref/@Column),":",string($colref/@ParameterCompiledValue),",   "),"  "')) AS QUERY_PARAMETER_VALUES,
       QUERY_PLAN,
       index_node.value('(.//@PhysicalOp)[1]', 'NVARCHAR(128)')                                                                                                                                                                                            AS PHYSICAL_OPERATOR,
       Replace(Replace(index_node.value('(.//@Table)[1]', 'NVARCHAR(128)'), '[', ''), ']', '')                                                                                                                                                             AS TABLE_NAME,
       Replace(Replace(index_node.value('(.//@Index)[1]', 'NVARCHAR(128)'), '[', ''), ']', '')                                                                                                                                                             AS INDEX_NAME,
       Replace(CONVERT(NVARCHAR(MAX), index_node.query('for $indexscan in ./sp:IndexScan,
										$predicate in $indexscan/sp:Predicate,
										$columnreference in $predicate//sp:ColumnReference
                                        return string($columnreference/@Column)')), ' ', ', ')                                                                                                                                                      AS PREDICATE_COLUMNS,
       TOTAL_WORKER_TIME,
       AVG_PHYSICAL_READS,
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
       OUTER APPLY QUERY_PLAN.nodes('//sp:RelOp') AS Operators(index_node)
       CROSS APPLY QUERY_PLAN.nodes('//sp:Batch') AS Batch(index_node2) 


) A
WHERE PHYSICAL_OPERATOR LIKE '%Table Scan%'

GO


GO
/****** Object:  View [dbo].[MISSING_INDEXES_VW]    Script Date: 02/02/2011 14:19:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[MISSING_INDEXES_VW]'))
DROP VIEW MISSING_INDEXES_VW
GO
USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[MISSING_INDEXES_VW]    Script Date: 10/17/2011 15:06:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[MISSING_INDEXES_VW] AS

WITH XMLNAMESPACES ('http://schemas.microsoft.com/sqlserver/2004/07/showplan' AS sp)
SELECT S.RUN_NAME,
       S.DATABASE_NAME,
       CREATION_TIME                                                                                                                                                                                                                                      AS COMPILED_TIME,
       EXECUTION_COUNT,
       EXECUTION_COUNT / CASE (DATEDIFF(HOUR,CREATION_TIME, S.STATS_TIME))
       WHEN 0 THEN 1 ELSE (DATEDIFF(HOUR,CREATION_TIME, S.STATS_TIME)) END AS EXECUTION_PER_HOUR,
        Cast(TOTAL_ELAPSED_TIME / 1000.000 AS DECIMAL(14, 3))                                                                                                                                                                                              AS TOTAL_ELAPSED_TIME,
       Q.AVG_TIME_ms as AVG_ELAPSED_TIME,
       Cast(MAX_ELAPSED_TIME / 1000.000 AS DECIMAL(14, 3))                                                                                                                                                                                                AS MAX_ELAPSED_TIME,
       AVG_LOGICAL_READS = TOTAL_LOGICAL_READS / EXECUTION_COUNT,
       AVG_ROWS_RETURNED = TOTAL_ROWS / EXECUTION_COUNT,
       QT.SQL_TEXT                                                                                                                                                                                                                                        AS SQL_TEXT,
       CONVERT (NVARCHAR(MAX), index_node.query('for $qplan in //sp:QueryPlan, $plist in $qplan/sp:ParameterList, $colref in $plist/sp:ColumnReference  return concat(string($colref/@Column),":",string($colref/@ParameterCompiledValue),",   "),"  "')) AS QUERY_PARAMETER_VALUES,
       QUERY_PLAN,
       index_nodeS.value('(../@Impact)[1]', 'float')                                                                                                                                                                                                      AS INDEX_IMPACT,
       Replace(Replace(index_nodeS.value('(./@Table)[1]', 'NVARCHAR(128)'), '[', ''), ']', '')                                                                                                                                                            AS TABLE_NAME,
       Replace(Replace(Replace(CONVERT(NVARCHAR(max), index_nodeS.query('for $colgroup in ./sp:ColumnGroup,
                                                $col in $colgroup/sp:Column
                                                where $colgroup/@Usage = "EQUALITY"
                                                return string($col/@Name)')), '] [', ', '), '[', ''), ']', '')                                                                                                                                     AS EQUALITY_COLUMNS,
       Replace(Replace(Replace(CONVERT(NVARCHAR(max), index_nodeS.query('for $colgroup in ./sp:ColumnGroup,
                                                $col in $colgroup/sp:Column
                                                where $colgroup/@Usage = "INEQUALITY"
                                                return string($col/@Name)')), '] [', ', '), '[', ''), ']', '')                                                                                                                                     AS INEQUALITY_COLUMNS,
       Replace(Replace(Replace(CONVERT(NVARCHAR(max), index_nodeS.query('for $colgroup in .//sp:ColumnGroup,
                                                $col in $colgroup/sp:Column
                                                where $colgroup/@Usage = "INCLUDE"
                                                return string($col/@Name)')), '] [', ', '), '[', ''), ']', '')                                                                                                                                     AS INCLUDED_COLUMNS,
       Q.ROW_NUM,
       Q.QUERY_HASH,
       TOTAL_ROWS,
       MAX_ROWS,
       MIN_ROWS,
       PLAN_GENERATION_NUM,
       LAST_EXECUTION_TIME,
       Cast(TOTAL_WORKER_TIME / 1000.000 AS DECIMAL(14, 3))                                                                                                                                                                                               AS TOTAL_WORKER_TIME,
       AVG_PHYSICAL_READS = TOTAL_PHYSICAL_READS / EXECUTION_COUNT,
       AVG_LOGICAL_WRITES = TOTAL_LOGICAL_WRITES / EXECUTION_COUNT,
       Cast(LAST_ELAPSED_TIME / 1000.000 AS DECIMAL(14, 3))                                                                                                                                                                                               AS LAST_ELAPSED_TIME,
       Cast(MIN_ELAPSED_TIME / 1000.000 AS DECIMAL(14, 3))                                                                                                                                                                                                AS MIN_ELAPSED_TIME,
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
       Cast(LAST_WORKER_TIME / 1000.000 AS DECIMAL(14, 3))                                                                                                                                                                                                AS LAST_WORKER_TIME,
       Cast(MIN_WORKER_TIME / 1000.000 AS DECIMAL(14, 3))                                                                                                                                                                                                 AS MIN_WORKER_TIME,
       Cast(MAX_WORKER_TIME / 1000.000 AS DECIMAL(14, 3))                                                                                                                                                                                                 AS MAX_WORKER_TIME,
       QUERY_PLAN_TEXT = CONVERT(NVARCHAR(MAX), QUERY_PLAN),
       S.STATS_TIME,
       SQL_VERSION,
       S.SQL_SERVER_STARTTIME,
       Q.QUERY_PLAN_HASH,
       C.COMMENT
FROM   QUERY_STATS Q WITH (NOLOCK)
       INNER JOIN QUERY_PLANS QP WITH (NOLOCK)
               ON QP.QUERY_PLAN_HASH = Q.QUERY_PLAN_HASH
       CROSS APPLY QP.QUERY_PLAN.nodes('//sp:MissingIndexes/sp:MissingIndexGroup/sp:MissingIndex') AS missing_indexes(index_nodeS)
       CROSS APPLY QUERY_PLAN.nodes('//sp:Batch') AS Batch(index_node)
       INNER JOIN STATS_COLLECTION_SUMMARY S WITH (NOLOCK)
               ON Q.STATS_TIME = S.STATS_TIME
                  AND Q.DATABASE_NAME = S.DATABASE_NAME
       LEFT OUTER JOIN QUERY_TEXT QT
                    ON Q.QUERY_HASH = QT.QUERY_HASH
                      
       LEFT OUTER JOIN COMMENTS C
                    ON Q.QUERY_HASH = C.QUERY_HASH 

GO


GO
/****** Object:  View [dbo].[MISSING_INDEXES_CURR_VW]    Script Date: 02/02/2011 14:19:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[MISSING_INDEXES_CURR_VW]'))
DROP VIEW MISSING_INDEXES_CURR_VW
GO
USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[MISSING_INDEXES_CURR_VW]    Script Date: 10/17/2011 15:07:28 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[MISSING_INDEXES_CURR_VW] AS


WITH XMLNAMESPACES ('http://schemas.microsoft.com/sqlserver/2004/07/showplan' AS sp)
SELECT S.RUN_NAME,
       S.DATABASE_NAME,
       CREATION_TIME                                                                                                  AS COMPILED_TIME,
       EXECUTION_COUNT,
       EXECUTION_COUNT / CASE (DATEDIFF(HOUR,CREATION_TIME, S.STATS_TIME))
       WHEN 0 THEN 1 ELSE (DATEDIFF(HOUR,CREATION_TIME, S.STATS_TIME)) END AS EXECUTION_PER_HOUR,
        Cast(TOTAL_ELAPSED_TIME / 1000.000 AS DECIMAL(14, 3))                                                          AS TOTAL_ELAPSED_TIME,
       Q.AVG_TIME_ms as AVG_ELAPSED_TIME,
       Cast(MAX_ELAPSED_TIME / 1000.000 AS DECIMAL(14, 3))                                                            AS MAX_ELAPSED_TIME,
       AVG_LOGICAL_READS = TOTAL_LOGICAL_READS / EXECUTION_COUNT,
       AVG_ROWS_RETURNED = TOTAL_ROWS / EXECUTION_COUNT,
       QT.SQL_TEXT                                                                                                    AS SQL_TEXT,
       QP.SQL_PARMS                                                                                                   AS QUERY_PARAMETER_VALUES,
       QUERY_PLAN,
       index_nodeS.value('(../@Impact)[1]', 'float')                                                                  AS INDEX_IMPACT,
       Replace(Replace(index_nodeS.value('(./@Table)[1]', 'NVARCHAR(128)'), '[', ''), ']', '')                        AS TABLE_NAME,
       Replace(Replace(Replace(CONVERT(NVARCHAR(max), index_nodeS.query('for $colgroup in ./sp:ColumnGroup,
                                                $col in $colgroup/sp:Column
                                                where $colgroup/@Usage = "EQUALITY"
                                                return string($col/@Name)')), '] [', ', '), '[', ''), ']', '') AS EQUALITY_COLUMNS,
       Replace(Replace(Replace(CONVERT(NVARCHAR(max), index_nodeS.query('for $colgroup in ./sp:ColumnGroup,
                                                $col in $colgroup/sp:Column
                                                where $colgroup/@Usage = "INEQUALITY"
                                                return string($col/@Name)')), '] [', ', '), '[', ''), ']', '') AS INEQUALITY_COLUMNS,
       Replace(Replace(Replace(CONVERT(NVARCHAR(max), index_nodeS.query('for $colgroup in .//sp:ColumnGroup,
                                                $col in $colgroup/sp:Column
                                                where $colgroup/@Usage = "INCLUDE"
                                                return string($col/@Name)')), '] [', ', '), '[', ''), ']', '') AS INCLUDED_COLUMNS,
       Q.ROW_NUM,
       Q.QUERY_HASH,
       TOTAL_ROWS,
       MAX_ROWS,
       MIN_ROWS,
       PLAN_GENERATION_NUM,
       Q.LAST_EXECUTION_TIME,
       Cast(TOTAL_WORKER_TIME / 1000.000 AS DECIMAL(14, 3))                                                           AS TOTAL_WORKER_TIME,
       AVG_PHYSICAL_READS = TOTAL_PHYSICAL_READS / EXECUTION_COUNT,
       AVG_LOGICAL_WRITES = TOTAL_LOGICAL_WRITES / EXECUTION_COUNT,
       Cast(LAST_ELAPSED_TIME / 1000.000 AS DECIMAL(14, 3))                                                           AS LAST_ELAPSED_TIME,
       Cast(MIN_ELAPSED_TIME / 1000.000 AS DECIMAL(14, 3))                                                            AS MIN_ELAPSED_TIME,
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
       Cast(LAST_WORKER_TIME / 1000.000 AS DECIMAL(14, 3))                                                            AS LAST_WORKER_TIME,
       Cast(MIN_WORKER_TIME / 1000.000 AS DECIMAL(14, 3))                                                             AS MIN_WORKER_TIME,
       Cast(MAX_WORKER_TIME / 1000.000 AS DECIMAL(14, 3))                                                             AS MAX_WORKER_TIME,
       QUERY_PLAN_TEXT = CONVERT(NVARCHAR(MAX), QUERY_PLAN),
       S.STATS_TIME,
       SQL_VERSION,
       S.SQL_SERVER_STARTTIME,
       Q.QUERY_PLAN_HASH,
       C.COMMENT
FROM   QUERY_STATS Q WITH (NOLOCK)
       INNER JOIN (SELECT QS2.DATABASE_NAME,
               QUERY_HASH,
               max(QS2.STATS_TIME)          AS STATS_TIME,
               max(LAST_EXECUTION_TIME) AS LAST_EXECUTION_TIME
        FROM   QUERY_STATS QS2
		INNER JOIN STATS_COLLECTION_SUMMARY S2 WITH (NOLOCK)
               ON QS2.STATS_TIME = S2.STATS_TIME
                  AND QS2.DATABASE_NAME = S2.DATABASE_NAME AND S2.RUN_NAME NOT LIKE 'BASE%'
        GROUP  BY QS2.DATABASE_NAME,
                  QUERY_HASH) AS A
               ON A.DATABASE_NAME = Q.DATABASE_NAME
                  AND A.QUERY_HASH = Q.QUERY_HASH
                  AND A.LAST_EXECUTION_TIME = Q.LAST_EXECUTION_TIME
                  AND A.STATS_TIME = Q.STATS_TIME
       INNER JOIN QUERY_PLANS QP WITH (NOLOCK)
               ON  QP.QUERY_PLAN_HASH = Q.QUERY_PLAN_HASH
                  AND MI_FLAG = 1 --Missing Index Flag = True
       CROSS APPLY QP.QUERY_PLAN.nodes('//sp:MissingIndexes/sp:MissingIndexGroup/sp:MissingIndex') AS missing_indexes(index_nodeS)
       INNER JOIN STATS_COLLECTION_SUMMARY S WITH (NOLOCK)
               ON Q.STATS_TIME = S.STATS_TIME
                  AND Q.DATABASE_NAME = S.DATABASE_NAME
       LEFT OUTER JOIN QUERY_TEXT QT
                    ON Q.QUERY_HASH = QT.QUERY_HASH
                      
       LEFT OUTER JOIN COMMENTS C
                    ON Q.QUERY_HASH = C.QUERY_HASH 

GO

USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[PERF_HOURLY_IOSTATS]    Script Date: 04/02/2011 11:41:19 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[PERF_HOURLY_IOSTATS_VW]'))
DROP VIEW [dbo].[PERF_HOURLY_IOSTATS_VW]
GO

USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[PERF_HOURLY_IOSTATS]    Script Date: 04/02/2011 11:41:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*********  PERF DATA Virtual I/O change ************************/
CREATE VIEW [dbo].[PERF_HOURLY_IOSTATS_VW]
AS
  WITH PERF_IO_STATS
       AS (SELECT E.STATS_TIME,
                  E.DATABASE_NAME,
                  E.FILE_ID,
                  CASE
                    WHEN ( E.NUM_OF_READS - START.NUM_OF_READS ) = 0 THEN 0
                    ELSE ( E.IO_STALL_READ_MS - START.IO_STALL_READ_MS ) / ( E.NUM_OF_READS - START.NUM_OF_READS )
                  END                                                                                                                                                                   AS Read_Latency,
                  CASE
                    WHEN ( E.NUM_OF_WRITES - START.NUM_OF_WRITES ) = 0 THEN 0
                    ELSE ( E.IO_STALL_WRITE_MS - START.IO_STALL_WRITE_MS ) / ( E.NUM_OF_WRITES - START.NUM_OF_WRITES )
                  END                                                                                                                                                                   AS Write_Latency,
                  CASE
                    WHEN ( E.NUM_OF_READS - START.NUM_OF_READS ) = 0 THEN 0
                    ELSE ( E.NUM_OF_BYTES_READ - START.NUM_OF_BYTES_READ ) / ( E.NUM_OF_READS - START.NUM_OF_READS )
                  END                                                                                                                                                                   AS Avg_Bytes_Per_Read,
                  CASE
                    WHEN ( E.NUM_OF_WRITES - START.NUM_OF_WRITES ) = 0 THEN 0
                    ELSE ( E.NUM_OF_BYTES_WRITTEN - START.NUM_OF_BYTES_WRITTEN ) / ( E.NUM_OF_WRITES - START.NUM_OF_WRITES )
                  END                                                                                                                                                                   AS Avg_Bytes_Per_Written,
                  CONVERT(DEC(14, 2), (E.NUM_OF_READS - START.NUM_OF_READS) / Datediff(S, START.STATS_TIME, E.STATS_TIME) * 1.00)                                                       AS [Mb_Reads/sec],-- Or divide by 3600 if we're sure of duration
                  CONVERT(DEC(14, 2), (E.NUM_OF_BYTES_READ - START.NUM_OF_BYTES_READ) / 1048576.0)                                                                                      AS Tot_MB_Read_Last_Hour,
                  CONVERT(DEC(14, 2), (E.NUM_OF_BYTES_READ - START.NUM_OF_BYTES_READ) / 1048576.0 / Datediff(S, START.STATS_TIME, E.STATS_TIME) * 1.00)                                 AS [MB_Read_Last_Hour/sec],
                  CONVERT(DEC(14, 2), (E.NUM_OF_WRITES - START.NUM_OF_WRITES) / Datediff(S, START.STATS_TIME, E.STATS_TIME) * 1.00)                                                     AS [Mb_Writes/sec],
                  CONVERT(DEC(14, 2), (E.NUM_OF_BYTES_WRITTEN - START.NUM_OF_BYTES_WRITTEN) / 1048576.0)                                                                                AS Tot_MB_Written_Last_Hour,
                  CONVERT(DEC(14, 2), (E.NUM_OF_BYTES_WRITTEN - START.NUM_OF_BYTES_WRITTEN) / 1048576.0 / Datediff(S, START.STATS_TIME, E.STATS_TIME) * 1.00)                           AS [MB_Written_Last_Hour/sec],
                  E.NUM_OF_READS - START.NUM_OF_READS                                                                                                                                   AS Num_of_Reads,
                  E.NUM_OF_WRITES - START.NUM_OF_WRITES                                                                                                                                 AS Num_of_Writes,
                  E.IO_STALL_READ_MS - START.IO_STALL_READ_MS                                                                                                                           AS Read_IO_Stalls_MS_Last_Hour,
                  E.IO_STALL_WRITE_MS - START.IO_STALL_WRITE_MS                                                                                                                         AS Write_IO_Stalls_MS_Last_Hour,
                  Rank() OVER (partition BY E.STATS_TIME ORDER BY E.STATS_TIME DESC, ( (E.IO_STALL_READ_MS+E.IO_STALL_WRITE_MS)-(START.IO_STALL_READ_MS+START.IO_STALL_WRITE_MS)) DESC) AS Rank
           FROM   PERF_DISKSTATS E
                  INNER JOIN PERF_DISKSTATS START
                    ON START.DATABASE_NAME = E.DATABASE_NAME
                       AND START.FILE_ID = E.FILE_ID
                       AND START.STATS_TIME = (SELECT max(STATS_TIME)
                                               FROM   PERF_DISKSTATS D
                                               WHERE  D.STATS_TIME < E.STATS_TIME))
  SELECT *, (SELECT TOP 1 F.[PHYSICAL_NAME] FROM SQL_DATABASEFILES F WHERE F.[DATABASE_NAME] = S.DATABASE_NAME
  AND F.[FILE_ID] = S.FILE_ID) AS [PHYSICAL_NAME]
  FROM   PERF_IO_STATS S
  
  


GO


USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[PERF_IOSTATS]    Script Date: 04/02/2011 11:41:19 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[PERF_IOSTATS_VW]'))
DROP VIEW [dbo].[PERF_IOSTATS_VW]
GO

USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[PERF_IOSTATS]    Script Date: 04/02/2011 11:41:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*********  PERF DATA Virtual I/O change ************************/
CREATE VIEW [dbo].[PERF_IOSTATS_VW] AS
WITH PERF_IO_STATS
     AS (SELECT E.STATS_TIME,
                E.DATABASE_NAME,
                E.FILE_ID,
                CASE WHEN (E.NUM_OF_READS - START.NUM_OF_READS) = 0 THEN 0 ELSE (E.IO_STALL_READ_MS - START.IO_STALL_READ_MS)  / (E.NUM_OF_READS - START.NUM_OF_READS)	END																				  AS READ_LATENCY,
                CASE WHEN (E.NUM_OF_WRITES - START.NUM_OF_WRITES)=0 THEN 0 ELSE (E.IO_STALL_WRITE_MS - START.IO_STALL_WRITE_MS)  / (E.NUM_OF_WRITES - START.NUM_OF_WRITES)	END																			  AS WRITE_LATENCY,
                CASE WHEN (E.NUM_OF_READS - START.NUM_OF_READS)=0 THEN 0 ELSE (E.NUM_OF_BYTES_READ - START.NUM_OF_BYTES_READ) / (E.NUM_OF_READS - START.NUM_OF_READS) END AS AVG_BYTES_PER_READ,
                CASE WHEN (E.NUM_OF_WRITES - START.NUM_OF_WRITES)=0 THEN 0 ELSE (E.NUM_OF_BYTES_WRITTEN - START.NUM_OF_BYTES_WRITTEN) / (E.NUM_OF_WRITES - START.NUM_OF_WRITES) END AS AVG_BYTES_PER_WRITTEN,
                
                E.NUM_OF_READS - START.NUM_OF_READS	AS NUM_OF_READS,
                E.NUM_OF_WRITES - START.NUM_OF_WRITES AS NUM_OF_WRITES,
                E.IO_STALL_READ_MS - START.IO_STALL_READ_MS                                                                                                                           AS READ_IO_STALLS_MS_LAST,
                E.IO_STALL_WRITE_MS - START.IO_STALL_WRITE_MS                                                                                                                         AS WRITE_IO_STALLS_MS_LAST,
                Rank() OVER (partition BY E.STATS_TIME ORDER BY E.STATS_TIME DESC, ( (E.IO_STALL_READ_MS+E.IO_STALL_WRITE_MS)-(START.IO_STALL_READ_MS+START.IO_STALL_WRITE_MS)) DESC) AS RANK
         FROM   DISKSTATS E
                INNER JOIN DISKSTATS START
                  ON START.DATABASE_NAME = E.DATABASE_NAME
                     AND START.FILE_ID = E.FILE_ID
                     AND START.STATS_TIME <= DATEADD(MINUTE, -58,E.STATS_TIME) AND START.STATS_TIME >= DATEADD(MINUTE, -62,E.STATS_TIME)
                     --AND START.STATS_TIME = (SELECT max(STATS_TIME)
                     --                        FROM   DISKSTATS D
                     --                        WHERE  D.STATS_TIME < E.STATS_TIME)
                                             )
SELECT *
FROM   PERF_IO_STATS 


GO

USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[PERF_HOURLY_ROWDATA]    Script Date: 04/02/2011 11:42:47 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[PERF_HOURLY_ROWDATA_VW]'))
DROP VIEW [dbo].[PERF_HOURLY_ROWDATA_VW]
GO

USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[PERF_HOURLY_ROWDATA]    Script Date: 04/02/2011 11:42:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*********  PERF DATA Row Count change ************************/
CREATE VIEW [dbo].[PERF_HOURLY_ROWDATA_VW]
AS
  
  WITH ROWSRANK
       AS (SELECT A.STATS_TIME,
                  A.DATABASE_NAME,
                  A.TABLE_NAME,
                  A.ROWS_LAST_HOUR,
                  Dense_rank()
                    OVER (
                      partition BY A.STATS_TIME
                      ORDER BY A.STATS_TIME DESC, A.DATABASE_NAME DESC, ( ROWS_LAST_HOUR) DESC) AS RANK
           FROM   PERF_INDEX_DETAIL A WHERE A.INDEX_ID < 2)  --REH Only need clustered or heap index

  SELECT TOP 100 PERCENT STATS_TIME,
                         DATABASE_NAME = CASE
                                           WHEN Grouping(DATABASE_NAME) = 1 THEN 'NULL'
                                           ELSE DATABASE_NAME
                                         END,
                         ROWRANK = CASE
                                     WHEN Grouping(RANK) = 1 THEN 9999
                                     ELSE RANK
                                   END,
                         TABLE_NAME,
                         sum(ROWS_LAST_HOUR) AS ROWS_ADDED
  FROM   ROWSRANK
  GROUP  BY STATS_TIME,
            DATABASE_NAME,
            RANK,
            TABLE_NAME WITH ROLLUP
  ORDER  BY STATS_TIME DESC,
            DATABASE_NAME,
            RANK,
            TABLE_NAME 


GO

USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[PERF_HOURLY_WAITSTATS]    Script Date: 04/02/2011 11:43:44 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[PERF_HOURLY_WAITSTATS_VW]'))
DROP VIEW [dbo].[PERF_HOURLY_WAITSTATS_VW]
GO

USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[PERF_HOURLY_WAITSTATS]    Script Date: 04/02/2011 11:43:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*********  PERF DATA Wait Stats change ************************/
CREATE VIEW [dbo].[PERF_HOURLY_WAITSTATS_VW]
AS
  WITH PERF_WAITSTATS
       AS (SELECT E.STATS_TIME,
                  E.WAIT_TYPE,
                  E.WAITING_TASKS_COUNT - START.WAITING_TASKS_COUNT                                                                 AS WAITING_TASKS_LAST_HOUR,
                  E.WAIT_TIME_MS - START.WAIT_TIME_MS                                                                               AS WAIT_TIME_MS_LAST_HOUR,
                  Cast (( E.WAIT_TIME_MS - START.WAIT_TIME_MS ) / ( CASE
                                                                      WHEN ( E.WAITING_TASKS_COUNT = START.WAITING_TASKS_COUNT ) THEN 1.0
                                                                      ELSE ( E.WAITING_TASKS_COUNT - START.WAITING_TASKS_COUNT ) * 1.0
                                                                    END ) AS NUMERIC (10, 0))                                       AS AVG_WAIT_TIME_MS_LAST_HOUR,
                  E.SIGNAL_WAIT_TIME_MS - START.SIGNAL_WAIT_TIME_MS                                                                 AS SIGNAL_WAIT_TIME_MS_LAST_HOUR,
                  Cast (( E.SIGNAL_WAIT_TIME_MS - START.SIGNAL_WAIT_TIME_MS ) / ( CASE
                                                                                    WHEN ( E.WAITING_TASKS_COUNT = START.WAITING_TASKS_COUNT ) THEN 1.0
                                                                                    ELSE ( E.WAITING_TASKS_COUNT - START.WAITING_TASKS_COUNT ) * 1.0
                                                                                  END ) AS NUMERIC (10, 0))                         AS AVG_SIGNAL_WAIT_TIME_MS_LAST_HOUR,
                  Cast ((( E.SIGNAL_WAIT_TIME_MS - START.SIGNAL_WAIT_TIME_MS )) * 100. / ( CASE
                                                                                             WHEN ( E.WAIT_TIME_MS = START.WAIT_TIME_MS ) THEN 1
                                                                                             ELSE ( E.WAIT_TIME_MS - START.WAIT_TIME_MS )
                                                                                           END ) AS NUMERIC (10, 0))                AS RATIO_SIGNAL_WAIT_TIME_TO_WAITTIME_LAST_HOUR,
                  Rank() OVER (partition BY E.STATS_TIME ORDER BY E.STATS_TIME DESC, ( (E.WAIT_TIME_MS)-(START.WAIT_TIME_MS)) DESC) AS RANK
           FROM   PERF_WAIT_STATS E
                  INNER JOIN PERF_WAIT_STATS START
                    ON START.WAIT_TYPE = E.WAIT_TYPE
                    AND START.STATS_TIME <= DATEADD(MINUTE, -58,E.STATS_TIME) AND START.STATS_TIME >= DATEADD(MINUTE, -62,E.STATS_TIME)
                       --AND START.STATS_TIME = (SELECT max(STATS_TIME)
                       --                        FROM   PERF_WAIT_STATS D
                       --                        WHERE  D.STATS_TIME < E.STATS_TIME)
                       )
  SELECT *
  FROM   PERF_WAITSTATS 

GO

USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[INDEX_OPS_VW]    Script Date: 08/25/2011 15:24:15 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[INDEX_OPS_VW]'))
DROP VIEW [dbo].[INDEX_OPS_VW]
GO

USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[INDEX_OPS]    Script Date: 08/25/2011 15:24:16 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[INDEX_OPS_VW]
AS

(SELECT RUN_NAME,DATABASE_NAME, TABLE_NAME,ROW_COUNT,

       ISNULL(SUM(USER_SEEKS + USER_SCANS + USER_LOOKUPS),0)                AS TOTALREADOPERATIONS,
       ISNULL(SUM(USER_UPDATES),0)                                          AS TOTALWRITEOPERATIONS

FROM   INDEX_STATS_VW /*sys.dm_db_index_usage_stats*/
GROUP  BY RUN_NAME,DATABASE_NAME,TABLE_NAME,ROW_COUNT)

GO

USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[SERVER_OS_VERSION_VW]    Script Date: 09/08/2011 14:55:11 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[SERVER_OS_VERSION_VW]'))
DROP VIEW [dbo].[SERVER_OS_VERSION_VW]
GO

USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[SERVER_OS_VERSION_VW]    Script Date: 09/08/2011 14:55:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[SERVER_OS_VERSION_VW]
AS

SELECT [WINDOWS_RELEASE]
      ,[WINDOWS_SERVICE_PACK_LEVEL]
      ,
      
      CASE [WINDOWS_SKU]
      WHEN 1  THEN 'Ultimate'
      WHEN 2  THEN 'Home Basic'
      WHEN 3 THEN 'Home Premium'
      WHEN 4 THEN 'Client Enterprise'
      WHEN 5 THEN 'Home Basic N'
      WHEN 16 THEN 'Business N'
	  WHEN 18 THEN 'HPC'
	  WHEN 8 THEN 'SERVER DATACENTER(FULL EDITION)'
	  WHEN 12 THEN 'SERVER DATACENTER(CORE INSTALL)'
	  WHEN 39 THEN 'SERVER DATACENTER W/O Hyper-V(CORE INSTALL)'
	  WHEN 37 THEN 'SERVER DATACENTER W/O Hyper-V(FULL INSTALL)'
	  WHEN 27 THEN 'Enterprise N'
	  WHEN 10 THEN 'Server Enterprise (full installation)'
	  WHEN 14 THEN 'Server Enterprise (core installation)'
	  WHEN 41 THEN 'Server Enterprise without Hyper-V (core installation) '
	  WHEN 15 THEN 'Server Enterprise for Itanium-based Systems'
	  WHEN 38 THEN 'Server Enterprise without Hyper-V (full installation)'
	  WHEN 26 THEN 'Home Premium N'
	  WHEN 42 THEN 'Microsoft Hyper-V Server'
	  WHEN 30 THEN 'Windows Essential Business Server Management Server'
	  WHEN 32 THEN 'Windows Essential Business Server Messaging Server'
	  WHEN 31 THEN 'Windows Essential Business Server Security Server'
	  WHEN 48 THEN 'Professional'
	  WHEN 49 THEN 'Professional N'
	  WHEN 24 THEN 'Windows Server 2008 for Windows Essential Server Solutions'
	  WHEN 35 THEN 'Windows Server 2008 without Hyper-V for Windows Essential Server Solutions'
	  WHEN 33 THEN 'Server Foundation'
	  WHEN 34 THEN 'Windows Home Server 2011'
	  WHEN 50 THEN 'Windows Small Business Server 2011 Essentials'
	  WHEN 19 THEN 'Windows Storage Server 2008 R2 Essentials'
	  WHEN 9 THEN 'Windows Small Business Server'
	  WHEN 56 THEN 'Windows MultiPoint Server'
	  WHEN 7 THEN 'Server Standard (full installation)'
	  WHEN 13 THEN 'Server Standard (core installation)'
	  WHEN 40 THEN 'Server Standard without Hyper-V (core installation)'
	  WHEN 36 THEN 'Server Standard without Hyper-V (full installation)'
	  WHEN 11 THEN 'Starter'
	  WHEN 47 THEN 'Starter N'
	  WHEN 23 THEN 'Storage Server Enterprise'
	  WHEN 20 THEN 'Storage Server Express'
	  WHEN 21 THEN 'Storage Server Standard'
	  WHEN 22 THEN 'Storage Server Workgroup'
	  WHEN 28 THEN 'Ultimate N'
	  WHEN 17 THEN 'Web Server (full installation)'
	  WHEN 29 THEN 'Web Server (core installation)'
	  ELSE 'Unknown'
	  
	  
      END
      AS [WINDOWS_SKU]
      ,
      CASE [OS_LANGUAGE_VERSION]
WHEN  1078	THEN 'Afrikaans - South Africa'
WHEN 1052	THEN 'Albanian - Albania'
WHEN 1156	THEN 'Alsatian'
WHEN 1118	THEN 'Amharic - Ethiopia'
WHEN 1025	THEN 'Arabic - Saudi Arabia'
WHEN 5121	THEN 'Arabic - Algeria'
WHEN 15361	THEN 'Arabic - Bahrain'
WHEN 3073	THEN 'Arabic - Egypt'
WHEN 2049	THEN 'Arabic - Iraq'
WHEN 11265	THEN 'Arabic - Jordan'
WHEN 13313	THEN 'Arabic - Kuwait'
WHEN 12289	THEN 'Arabic - Lebanon'
WHEN 4097	THEN 'Arabic - Libya'
WHEN 6145	THEN 'Arabic - Morocco'
WHEN 8193	THEN 'Arabic - Oman'
WHEN 16385	THEN 'Arabic - Qatar'
WHEN 10241	THEN 'Arabic - Syria'
WHEN 7169	THEN 'Arabic - Tunisia'
WHEN 14337	THEN 'Arabic - U.A.E.'
WHEN 9217	THEN 'Arabic - Yemen'
WHEN 1067	THEN 'Armenian - Armenia'
WHEN 1101	THEN 'Assamese'
WHEN 2092	THEN 'Azeri (Cyrillic)'
WHEN 1068	THEN 'Azeri (Latin)'
WHEN 1133	THEN 'Bashkir'
WHEN 1069	THEN 'Basque'
WHEN 1059	THEN 'Belarusian'
WHEN 1093	THEN 'Bengali (India)'
WHEN 2117	THEN 'Bengali (Bangladesh)'
WHEN 5146	THEN 'Bosnian (Bosnia/Herzegovina)'
WHEN 1150	THEN 'Breton'
WHEN 1026	THEN 'Bulgarian'
WHEN 1109	THEN 'Burmese'
WHEN 1027	THEN 'Catalan'
WHEN 1116	THEN 'Cherokee - United States'
WHEN 2052	THEN 'Chinese - Peoples Republic of China'
WHEN 4100	THEN 'Chinese - Singapore'
WHEN 1028	THEN 'Chinese - Taiwan'
WHEN 3076	THEN 'Chinese - Hong Kong SAR'
WHEN 5124	THEN 'Chinese - Macao SAR'
WHEN 1155	THEN 'Corsican'
WHEN 1050	THEN 'Croatian'
WHEN 4122	THEN 'Croatian (Bosnia/Herzegovina)'
WHEN 1029	THEN 'Czech'
WHEN 1030	THEN 'Danish'
WHEN 1164	THEN 'Dari'
WHEN 1125	THEN 'Divehi'
WHEN 1043	THEN 'Dutch - Netherlands'
WHEN 2067	THEN 'Dutch - Belgium'
WHEN 1126	THEN 'Edo'
WHEN 1033	THEN 'English - United States'
WHEN 2057	THEN 'English - United Kingdom'
WHEN 3081	THEN 'English - Australia'
WHEN 10249	THEN 'English - Belize'
WHEN 4105	THEN 'English - Canada'
WHEN 9225	THEN 'English - Caribbean'
WHEN 15369	THEN 'English - Hong Kong SAR'
WHEN 16393	THEN 'English - India'
WHEN 14345	THEN 'English - Indonesia'
WHEN 6153	THEN 'English - Ireland'
WHEN 8201	THEN 'English - Jamaica'
WHEN 17417	THEN 'English - Malaysia'
WHEN 5129	THEN 'English - New Zealand'
WHEN 13321	THEN 'English - Philippines'
WHEN 18441	THEN 'English - Singapore'
WHEN 7177	THEN 'English - South Africa'
WHEN 11273	THEN 'English - Trinidad'
WHEN 12297	THEN 'English - Zimbabwe'
WHEN 1061	THEN 'Estonian'
WHEN 1080	THEN 'Faroese'
WHEN 1065	THEN 'Farsi'
WHEN 1124	THEN 'Filipino'
WHEN 1035	THEN 'Finnish'
WHEN 1036	THEN 'French - France'
WHEN 2060	THEN 'French - Belgium'
WHEN 11276	THEN 'French - Cameroon'
WHEN 3084	THEN 'French - Canada'
WHEN 9228	THEN 'French - Democratic Rep. of Congo'
WHEN 12300	THEN 'French - Cote d Ivoire'
WHEN 15372	THEN 'French - Haiti'
WHEN 5132	THEN 'French - Luxembourg'
WHEN 13324	THEN 'French - Mali'
WHEN 6156	THEN 'French - Monaco'
WHEN 14348	THEN 'French - Morocco'
WHEN 58380	THEN 'French - North Africa'
WHEN 8204	THEN 'French - Reunion'
WHEN 10252	THEN 'French - Senegal'
WHEN 4108	THEN 'French - Switzerland'
WHEN 7180	THEN 'French - West Indies'
WHEN 1122	THEN 'Frisian - Netherlands'
WHEN 1127	THEN 'Fulfulde - Nigeria'
WHEN 1071	THEN 'FYRO Macedonian'
WHEN 1110	THEN 'Galician'
WHEN 1079	THEN 'Georgian'
WHEN 1031	THEN 'German - Germany'
WHEN 3079	THEN 'German - Austria'
WHEN 5127	THEN 'German - Liechtenstein'
WHEN 4103	THEN 'German - Luxembourg'
WHEN 2055	THEN 'German - Switzerland'
WHEN 1032	THEN 'Greek'
WHEN 1135	THEN 'Greenlandic'
WHEN 1140	THEN 'Guarani - Paraguay'
WHEN 1095	THEN 'Gujarati'
WHEN 1128	THEN 'Hausa - Nigeria'
WHEN 1141	THEN 'Hawaiian - United States'
WHEN 1037	THEN 'Hebrew'
WHEN 1081	THEN 'Hindi'
WHEN 1038	THEN 'Hungarian'
WHEN 1129	THEN 'Ibibio - Nigeria'
WHEN 1039	THEN 'Icelandic'
WHEN 1136	THEN 'Igbo - Nigeria'
WHEN 1057	THEN 'Indonesian'
WHEN 1117	THEN 'Inuktitut'
WHEN 2108	THEN 'Irish'
WHEN 1040	THEN 'Italian - Italy'
WHEN 2064	THEN 'Italian - Switzerland'
WHEN 1041	THEN 'Japanese'
WHEN 1158	THEN 'K iche'
WHEN 1099	THEN 'Kannada'
WHEN 1137	THEN 'Kanuri - Nigeria'
WHEN 2144	THEN 'Kashmiri'
WHEN 1120	THEN 'Kashmiri (Arabic)'
WHEN 1087	THEN 'Kazakh'
WHEN 1107	THEN 'Khmer'
WHEN 1159	THEN 'Kinyarwanda'
WHEN 1111	THEN 'Konkani'
WHEN 1042	THEN 'Korean'
WHEN 1088	THEN 'Kyrgyz (Cyrillic)'
WHEN 1108	THEN 'Lao'
WHEN 1142	THEN 'Latin'
WHEN 1062	THEN 'Latvian'
WHEN 1063	THEN 'Lithuanian'
WHEN 1134	THEN 'Luxembourgish'
WHEN 1086	THEN 'Malay - Malaysia'
WHEN 2110	THEN 'Malay - Brunei Darussalam'
WHEN 1100	THEN 'Malayalam'
WHEN 1082	THEN 'Maltese'
WHEN 1112	THEN 'Manipuri'
WHEN 1153	THEN 'Maori - New Zealand'
WHEN 1146	THEN 'Mapudungun'
WHEN 1102	THEN 'Marathi'
WHEN 1148	THEN 'Mohawk'
WHEN 1104	THEN 'Mongolian (Cyrillic)'
WHEN 2128	THEN 'Mongolian (Mongolian)'
WHEN 1121	THEN 'Nepali'
WHEN 2145	THEN 'Nepali - India'
WHEN 1044	THEN 'Norwegian (Bokmål)'
WHEN 2068	THEN 'Norwegian (Nynorsk)'
WHEN 1154	THEN 'Occitan'
WHEN 1096	THEN 'Oriya'
WHEN 1138	THEN 'Oromo'
WHEN 1145	THEN 'Papiamentu'
WHEN 1123	THEN 'Pashto'
WHEN 1045	THEN 'Polish'
WHEN 1046	THEN 'Portuguese - Brazil'
WHEN 2070	THEN 'Portuguese - Portugal'
WHEN 1094	THEN 'Punjabi'
WHEN 2118	THEN 'Punjabi (Pakistan)'
WHEN 1131	THEN 'Quecha - Bolivia'
WHEN 2155	THEN 'Quecha - Ecuador'
WHEN 3179	THEN 'Quecha - Peru'
WHEN 1047	THEN 'Rhaeto-Romanic'
WHEN 1048	THEN 'Romanian'
WHEN 2072	THEN 'Romanian - Moldava'
WHEN 1049	THEN 'Russian'
WHEN 2073	THEN 'Russian - Moldava'
WHEN 1083	THEN 'Sami (Lappish)'
WHEN 1103	THEN 'Sanskrit'
WHEN 1084	THEN 'Scottish Gaelic'
WHEN 1132	THEN 'Sepedi'
WHEN 3098	THEN 'Serbian (Cyrillic)'
WHEN 2074	THEN 'Serbian (Latin)'
WHEN 1113	THEN 'Sindhi - India'
WHEN 2137	THEN 'Sindhi - Pakistan'
WHEN 1115	THEN 'Sinhalese - Sri Lanka'
WHEN 1051	THEN 'Slovak'
WHEN 1060	THEN 'Slovenian'
WHEN 1143	THEN 'Somali'
WHEN 1070	THEN 'Sorbian'
WHEN 3082	THEN 'Spanish - Spain (Modern Sort)'
WHEN 1034	THEN 'Spanish - Spain (Traditional Sort)'
WHEN 11274	THEN 'Spanish - Argentina'
WHEN 16394	THEN 'Spanish - Bolivia'
WHEN 13322	THEN 'Spanish - Chile'
WHEN 9226	THEN 'Spanish - Colombia'
WHEN 5130	THEN 'Spanish - Costa Rica'
WHEN 7178	THEN 'Spanish - Dominican Republic'
WHEN 12298	THEN 'Spanish - Ecuador'
WHEN 17418	THEN 'Spanish - El Salvador'
WHEN 4106	THEN 'Spanish - Guatemala'
WHEN 18442	THEN 'Spanish - Honduras'
WHEN 22538	THEN 'Spanish - Latin America'
WHEN 2058	THEN 'Spanish - Mexico'
WHEN 19466	THEN 'Spanish - Nicaragua'
WHEN 6154	THEN 'Spanish - Panama'
WHEN 15370	THEN 'Spanish - Paraguay'
WHEN 10250	THEN 'Spanish - Peru'
WHEN 20490	THEN 'Spanish - Puerto Rico'
WHEN 21514	THEN 'Spanish - United States'
WHEN 14346	THEN 'Spanish - Uruguay'
WHEN 8202	THEN 'Spanish - Venezuela'
WHEN 1072	THEN 'Sutu'
WHEN 1089	THEN 'Swahili'
WHEN 1053	THEN 'Swedish'
WHEN 2077	THEN 'Swedish - Finland'
WHEN 1114	THEN 'Syriac'
WHEN 1064	THEN 'Tajik'
WHEN 1119	THEN 'Tamazight (Arabic)'
WHEN 2143	THEN 'Tamazight (Latin)'
WHEN 1097	THEN 'Tamil'
WHEN 1092	THEN 'Tatar'
WHEN 1098	THEN 'Telugu'
WHEN 1054	THEN 'Thai'
WHEN 2129	THEN 'Tibetan - Bhutan'
WHEN 1105	THEN 'Tibetan - Peoples Republic of China'
WHEN 2163	THEN 'Tigrigna - Eritrea'
WHEN 1139	THEN 'Tigrigna - Ethiopia'
WHEN 1073	THEN 'Tsonga'
WHEN 1074	THEN 'Tswana'
WHEN 1055	THEN 'Turkish'
WHEN 1090	THEN 'Turkmen'
WHEN 1152	THEN 'Uighur - China'
WHEN 1058	THEN 'Ukrainian'
WHEN 1056	THEN 'Urdu'
WHEN 2080	THEN 'Urdu - India'
WHEN 2115	THEN 'Uzbek (Cyrillic)'
WHEN 1091	THEN 'Uzbek (Latin)'
WHEN 1075	THEN 'Venda'
WHEN 1066	THEN 'Vietnamese'
WHEN 1106	THEN 'Welsh'
WHEN 1160	THEN 'Wolof'
WHEN 1076	THEN 'Xhosa'
WHEN 1157	THEN 'Yakut'
WHEN 1157	THEN 'Yakut'
WHEN 1144	THEN 'Yi'
WHEN 1085	THEN 'Yiddish'
WHEN 1130	THEN 'Yoruba'
WHEN 1077	THEN 'Zulu'
WHEN 1279	THEN 'HID (Human Interface Device)'

      END AS OS_LANGUAGE
  FROM [SERVER_OS_VERSION]

GO

USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[ACTIVITY_MONITOR_VW]    Script Date: 04/03/2012 14:29:36 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[ACTIVITY_MONITOR_VW]'))
DROP VIEW [dbo].[ACTIVITY_MONITOR_VW]
GO

USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[ACTIVITY_MONITOR_VW]    Script Date: 04/03/2012 14:29:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[ACTIVITY_MONITOR_VW] 
AS
SELECT r.session_id                                         AS SPID,
         se.host_name                                         AS HOSTNAME,
         se.login_name                                        AS LOGIN_NAME,
         Db_name(r.database_id)                               AS DATABASE_NAME,
         r.status                                             AS STATUS,
         r.command                                            AS COMMAND,
         r.cpu_time                                           AS CPU_TIME,
         r.total_elapsed_time                                 AS TOTAL_ELAPSED_TIME,
         r.reads                                              AS READS,
         r.logical_reads                                      AS LOGICAL_READS,
         r.writes                                             AS WRITES,
         dbo.FN_RETURN_AXSESSION_FROM_CONTEXT(r.context_info) AS AX_SESSION_ID,
         dbo.FN_RETURN_AXID_FROM_CONTEXT(r.context_info)      AS AX_USER_ID,
         Cast(r.context_info AS VARCHAR(128))                 AS CONTEXT_INFO,
         s.text                                               AS SQL_TEXT,
         p.query_plan                                         AS QUERY_PLAN,
         SQL_CURSORSQL.text                                   AS CURSOR_SQL_TEXT,
         SQL_CURSORPLAN.query_plan                            AS CURSOR_QUERY_PLAN,
         r.wait_time										  AS WAIT_TIME,
         r.wait_type										  AS WAIT_TYPE,
         r.open_transaction_count							  AS OPEN_TRANS_COUNT,
         r.estimated_completion_time						  AS ESTIMATED_COMPLETION_TIME,
         
         TSU.TEMPDBUSEROBJECTSALLOCATED                       AS TEMPDB_USER_OBJECTS_ALLOCATED,
         TSU.TEMPDBUSEROBJECTSDEALLOCATED                     AS TEMPDB_USER_OBJECTS_DEALLOCATED,
         TSU.TEMPDBINTERNALOBJECTSALLOCATED                   AS TEMPDB_INTERNAL_OBJECTS_ALLOCATED,
         TSU.TEMPDBINTERNALOBJECTSDEALLOCATED                 AS TEMPDB_INTERNAL_OBJECTS_DEALLOCATED
  FROM   sys.dm_exec_requests r
         INNER JOIN sys.dm_exec_sessions se
                 ON r.session_id = se.session_id
         OUTER APPLY sys.dm_exec_sql_text(r.sql_handle) s
         OUTER APPLY sys.dm_exec_query_plan(r.plan_handle) p
         OUTER APPLY sys.dm_exec_cursors(r.session_id) AS SQL_CURSORS
         OUTER APPLY sys.dm_exec_sql_text(SQL_CURSORS.sql_handle) AS SQL_CURSORSQL
         LEFT JOIN sys.dm_exec_query_stats AS SQL_CURSORSTATS
                ON SQL_CURSORSTATS.sql_handle = SQL_CURSORS.sql_handle
         OUTER APPLY sys.dm_exec_query_plan(SQL_CURSORSTATS.plan_handle) AS SQL_CURSORPLAN
         LEFT JOIN (SELECT SESSIONID = session_id,
                           REQUESTID = request_id,
                           TEMPDBUSEROBJECTSALLOCATED = sum (user_objects_alloc_page_count),
                           TEMPDBUSEROBJECTSDEALLOCATED = sum(user_objects_dealloc_page_count),
                           TEMPDBINTERNALOBJECTSALLOCATED = sum (internal_objects_alloc_page_count),
                           TEMPDBINTERNALOBJECTSDEALLOCATED = sum (internal_objects_dealloc_page_count)
                    FROM   sys.dm_db_task_space_usage
                    GROUP  BY session_id,
                              request_id) AS TSU
                ON TSU.SESSIONID = r.session_id
                   AND TSU.REQUESTID = r.request_id
  -- -------------------------------------------------------------------------------------
  WHERE  r.session_id <> @@SPID
         AND se.is_user_process = 1 
  

GO


USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[CURSOR_ACTIVITY_VW]    Script Date: 10/25/2012 15:02:06 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[CURSOR_ACTIVITY_VW]'))
DROP VIEW [dbo].[CURSOR_ACTIVITY_VW]
GO

USE [DynamicsPerf]
GO

/****** Object:  View [dbo].[CURSOR_ACTIVITY_VW]    Script Date: 10/25/2012 15:02:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[CURSOR_ACTIVITY_VW]
AS
SELECT A.[updated_time]                       AS UPDATED_TIME,
       A.[creation_time]                      AS CREATION_TIME,
       A.[dormant_duration]                   AS LAST_RUN_MS,
       A.[reads]                              AS READS,
       A.[writes]                             AS WRITES,
       A.[hostname]                           AS HOSTNAME,
       A.[loginame]                           AS LOGIN_NAME,
       A.[text]                               AS SQL_TEXT,
       A.[collectiontime]                     AS COLLECTION_TIME,
       --SQL_CURSORPLAN.[query_plan],
       A.[session_id]                         AS SQL_SPID,
       A.[cursor_id]                          AS CURSOR_ID,
       A.[name]                               AS NAME,
       A.[properties]                         AS PROPERTIES,
       A.[sql_handle]                         AS SQL_HANDLE,
       A.[statement_start_offset]             AS STATEMENT_START_OFFSET,
       A.[statement_end_offset]               AS STATEMENT_END_OFFSET,
       A.[plan_generation_num]				  AS PLAN_NUMBER,
       A.[is_open]                            AS OPEN_FLAG,
       A.[is_async_population]                AS IS_ASYNC_POP_FLAG,
       A.[is_close_on_commit]                 AS IS_CLOSE_ON_COMMIT_FLAG,
       A.[fetch_status]                       AS FETCH_STATUS,
       A.[fetch_buffer_size]                  AS FETCH_BUFFER_SIZE,
       A.[fetch_buffer_start]                 AS FETCH_BUFFER_START,
       A.[ansi_position]                      AS ANSI_POSITION,
       A.[worker_time]                        AS CPU_TIME,
       A.[plan_handle]                        AS PLAN_HANDLE,
       A.[query_hash]                         AS QUERY_HASH,
       A.[query_plan_hash]                    AS QUERY_PLAN_HASH,
       Cast(A.[context_info] AS VARCHAR(128)) AS CONTEXT_INFO
FROM   (SELECT DISTINCT Sysdatetime() AS updated_time,
                        s1.hostname,
                        s1.loginame,
                        s3.text,
                        Getdate()     AS collectiontime,
                        s2.*,
                        SQL_CURSORSTATS.plan_handle,
                        SQL_CURSORSTATS.query_hash,
                        SQL_CURSORSTATS.query_plan_hash,
                        s1.context_info
        FROM   sys.sysprocesses s1
               CROSS APPLY sys.dm_exec_cursors(s1.spid) AS s2
               CROSS APPLY sys.dm_exec_sql_text(s2.sql_handle) AS s3
               LEFT JOIN (SELECT DISTINCT plan_handle,
                                          sql_handle,
                                          statement_start_offset,
                                          statement_end_offset,
                                          plan_generation_num,
                                          query_hash,
                                          query_plan_hash
                          FROM   sys.dm_exec_query_stats) AS SQL_CURSORSTATS
                      ON SQL_CURSORSTATS.sql_handle = s2.sql_handle
                         AND s2.statement_start_offset = SQL_CURSORSTATS.statement_start_offset
                         AND s2.statement_end_offset = SQL_CURSORSTATS.statement_end_offset
        WHERE  SQL_CURSORSTATS.plan_generation_num = s2.plan_generation_num) AS A --This we'll join to the correct plan in cache if more then 1 plan

--OUTER APPLY sys.dm_exec_query_plan(A.plan_handle) AS SQL_CURSORPLAN 


GO


/****** Object:  View [dbo].[INDEX_HISTORICAL_VW]    Script Date: 02/19/2014 13:09:11 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[INDEX_HISTORICAL_VW]'))
DROP VIEW [dbo].[INDEX_HISTORICAL_VW]
GO



/****** Object:  View [dbo].[INDEX_HISTORICAL_VW]    Script Date: 02/19/2014 13:09:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[INDEX_HISTORICAL_VW] 
AS
SELECT DATEDIFF(DD, MIN(S.SQL_SERVER_STARTTIME), MAX(S.STATS_TIME)  ) AS HISTORICAL_DAYS,
       S.DATABASE_NAME,
       D.TABLE_NAME,
       D.INDEX_NAME,
       max(INDEX_DESCRIPTION)                              AS INDEX_DESCRIPTION,
       max(D.DATA_COMPRESSION)                             AS DATA_COMPRESSION,
       max(INDEX_KEYS)                                     AS INDEX_KEYS,
       max(INCLUDED_COLUMNS)                               AS INCLUDED_COLUMNS,
       sum(USER_SEEKS)                                     AS USER_SEEKS,
       sum(USER_SCANS)                                     AS USER_SCANS,
       sum(USER_LOOKUPS)                                   AS USER_LOOKUPS,
       sum(USER_UPDATES)                                   AS USER_UPDATES,
       sum(RANGE_SCAN_COUNT)                               AS RANGE_SCAN_COUNT,
       max(PAGE_COUNT)                                     AS PAGE_COUNT,
       max(ROW_COUNT)                                      AS ROW_COUNT,
       sum(SINGLETON_LOOKUP_COUNT)                         AS SINGLETON_LOOKUP_COUNT,
       sum(FORWARDED_FETCH_COUNT)                          AS FORWARDED_FETCH_COUNT,
       max(INDEX_DEPTH)                                    AS INDEX_DEPTH,
       avg(AVG_FRAGMENTATION_IN_PERCENT)                   AS AVG_FRAGMENTATION_IN_PERCENT,
       max(FRAGMENT_COUNT)                                 AS FRAGMENT_COUNT,
       sum(ROW_LOCK_WAIT_IN_MS)                            AS ROW_LOCK_WAIT_IN_MS,
       sum(PAGE_LOCK_WAIT_IN_MS)                           AS PAGE_LOCK_WAIT_IN_MS,
       sum(INDEX_LOCK_PROMOTION_ATTEMPT_COUNT)             AS INDEX_LOCK_PROMOTION_ATTEMPT_COUNT,
       sum(INDEX_LOCK_PROMOTION_COUNT)                     AS INDEX_LOCK_PROMOTION_COUNT,
       sum(PAGE_LATCH_WAIT_IN_MS)                          AS PAGE_LATCH_WAIT_IN_MS,
       sum(PAGE_IO_LATCH_WAIT_IN_MS)                       AS PAGE_IO_LATCH_WAIT_IN_MS,
       sum(LEAF_INSERT_COUNT)                              AS LEAF_INSERT_COUNT,
       sum(LEAF_DELETE_COUNT)                              AS LEAF_DELETE_COUNT,
       sum(LEAF_UPDATE_COUNT)                              AS LEAF_UPDATE_COUNT,
       sum(LEAF_GHOST_COUNT)                               AS LEAF_GHOST_COUNT,
       sum(NONLEAF_INSERT_COUNT)                           AS NONLEAF_INSERT_COUNT,
       sum(NONLEAF_DELETE_COUNT)                           AS NONLEAF_DELETE_COUNT,
       sum(NONLEAF_UPDATE_COUNT)                           AS NONLEAF_UPDATE_COUNT,
       sum(LEAF_ALLOCATION_COUNT)                          AS LEAF_ALLOCATION_COUNT,
       sum(NONLEAF_ALLOCATION_COUNT)                       AS NONLEAF_ALLOCATION_COUNT,
       sum(LEAF_PAGE_MERGE_COUNT)                          AS LEAF_PAGE_MERGE_COUNT,
       sum(NONLEAF_PAGE_MERGE_COUNT)                       AS NONLEAF_PAGE_MERGE_COUNT,
       sum(LOB_FETCH_IN_PAGES)                             AS LOB_FETCH_IN_PAGES,
       sum(LOB_FETCH_IN_BYTES)                             AS LOB_FETCH_IN_BYTES,
       sum(LOB_ORPHAN_CREATE_COUNT)                        AS LOB_ORPHAN_CREATE_COUNT,
       sum(LOB_ORPHAN_INSERT_COUNT)                        AS LOB_ORPHAN_INSERT_COUNT,
       sum(ROW_OVERFLOW_FETCH_IN_PAGES)                    AS ROW_OVERFLOW_FETCH_IN_PAGES,
       sum(ROW_OVERFLOW_FETCH_IN_BYTES)                    AS ROW_OVERFLOW_FETCH_IN_BYTES,
       sum(COLUMN_VALUE_PUSH_OFF_ROW_COUNT)                AS COLUMN_VALUE_PUSH_OFF_ROW_COUNT,
       sum(COLUMN_VALUE_PULL_IN_ROW_COUNT)                 AS COLUMN_VALUE_PULL_IN_ROW_COUNT,
       sum(ROW_LOCK_COUNT)                                 AS ROW_LOCK_COUNT,
       sum(ROW_LOCK_WAIT_COUNT)                            AS ROW_LOCK_WAIT_COUNT,
       sum(PAGE_LOCK_COUNT)                                AS PAGE_LOCK_COUNT,
       sum(PAGE_LOCK_WAIT_COUNT)                           AS PAGE_LOCK_WAIT_COUNT,
       sum(PAGE_LATCH_WAIT_COUNT)                          AS PAGE_LATCH_WAIT_COUNT,
       sum(PAGE_IO_LATCH_WAIT_COUNT)                       AS PAGE_IO_LATCH_WAIT_COUNT,
       max(S.STATS_TIME)                                   AS LAST_STATS_TIME,
       min(S.STATS_TIME)                                   AS MIN_STATS_TIME,
       DS.INSTALLED_DATE
FROM   (SELECT min(SQL_SERVER_STARTTIME) AS SQL_SERVER_STARTTIME ,
               DATABASE_NAME,
               max(STATS_TIME) AS STATS_TIME
        FROM   STATS_COLLECTION_SUMMARY SS
        GROUP  BY SQL_SERVER_STARTTIME,
                  DATABASE_NAME) AS S
       JOIN INDEX_DETAIL D WITH (NOLOCK)
         ON S.STATS_TIME = D.STATS_TIME
            AND S.DATABASE_NAME = D.DATABASE_NAME
       LEFT JOIN INDEX_USAGE_STATS U WITH (NOLOCK)
              ON U.STATS_TIME = D.STATS_TIME
                 AND U.DATABASE_NAME = D.DATABASE_NAME
                 AND U.OBJECT_ID = D.OBJECT_ID
                 AND U.INDEX_ID = D.INDEX_ID
       LEFT JOIN INDEX_PHYSICAL_STATS P WITH (NOLOCK)
              ON D.STATS_TIME = P.STATS_TIME
                 AND D.DATABASE_NAME = P.DATABASE_NAME
                 AND D.OBJECT_ID = P.OBJECT_ID
                 AND D.INDEX_ID = P.INDEX_ID
       LEFT JOIN INDEX_OPERATIONAL_STATS O WITH (NOLOCK)
              ON D.STATS_TIME = O.STATS_TIME
                 AND D.DATABASE_NAME = O.DATABASE_NAME
                 AND D.OBJECT_ID = O.OBJECT_ID
                 AND D.INDEX_ID = O.INDEX_ID
       CROSS APPLY DYNAMICSPERF_SETUP DS
GROUP  BY S.DATABASE_NAME,
          D.TABLE_NAME,
          D.INDEX_NAME,
          DS.INSTALLED_DATE 

GO



/****** Object:  View [dbo].[QUERY_STATS_HASH_VW]    Script Date: 02/20/2014 08:56:23 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[QUERY_STATS_HASH_VW]'))
DROP VIEW [dbo].[QUERY_STATS_HASH_VW]
GO



/****** Object:  View [dbo].[QUERY_STATS_HASH_VW]    Script Date: 02/20/2014 08:56:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[QUERY_STATS_HASH_VW]
AS
SELECT S.RUN_NAME,
       S.DATABASE_NAME,
       Q.EXECUTION_COUNT,
       Q.AVG_TIME_ms AS AVG_ELAPSED_TIME,
       QT.SQL_TEXT   AS SQL_TEXT,
       QP.SQL_PARMS  AS QUERY_PARAMETER_VALUES,
       QUERY_PLAN,
       Q.QUERY_HASH,
       S.STATS_TIME,
       Q.QUERY_PLAN_HASH,
       C.COMMENT
FROM   QUERY_STATS Q WITH (NOLOCK)
       INNER JOIN QUERY_PLANS QP WITH (NOLOCK)
               ON QP.QUERY_PLAN_HASH = Q.QUERY_PLAN_HASH
       INNER JOIN STATS_COLLECTION_SUMMARY S WITH (NOLOCK)
               ON Q.STATS_TIME = S.STATS_TIME
                  AND Q.DATABASE_NAME = S.DATABASE_NAME
       LEFT OUTER JOIN QUERY_TEXT QT
                    ON Q.QUERY_HASH = QT.QUERY_HASH
       LEFT OUTER JOIN COMMENTS C
                    ON Q.QUERY_HASH = C.QUERY_HASH 



GO






/****************************  END OF CREATE VIEWS **************************************/



/*************************** START OF FUNCTIONS *****************************************/


USE [DynamicsPerf]
GO

/****** Object:  UserDefinedFunction [dbo].[fn_dbstats]    Script Date: 08/25/2011 15:02:21 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fn_dbstats]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[fn_dbstats]
GO

USE [DynamicsPerf]
GO

/****** Object:  UserDefinedFunction [dbo].[fn_dbstats]    Script Date: 08/25/2011 15:02:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE FUNCTION [dbo].[fn_dbstats](@RUN1 AS VARCHAR(60),
                                   @RUN2 AS VARCHAR(60))
RETURNS @tablereturn TABLE (
	[DATABASE_NAME] [nvarchar](128) NULL,
	[TABLE_NAME] [nvarchar](128) NULL,
	[ORIGINAL_PAGECOUNT] [BIGINT] NULL,
	[NEW_PAGECOUNT] [BIGINT] NULL,
	[ORIGINAL_SIZEMB] [BIGINT] NULL,
	[NEW_SIZEMB] [BIGINT] NULL,
	[DELTA_SIZEMB] [BIGINT] NULL,
	[TABLE_UPDATES] [BIGINT] NULL,
	[DELTA_IN_ROWS] [BIGINT] NULL,
	[DAYS] [INT] NULL
  )
AS
  BEGIN
  
  
      INSERT INTO @tablereturn
      SELECT DISTINCT TOP 1000 COLLECTION1.DATABASE_NAME,									
							  COLLECTION1.TABLE_NAME,
                              COLLECTION1.PAGE_COUNT                                                    AS ORIGINAL_PAGECOUNT,
                              COLLECTION2.PAGE_COUNT                                                    AS NEW_PAGECOUNT,
                              COLLECTION1.PAGE_COUNT * 8 / 1024                                         AS ORIGINAL_SIZEMB,
                              COLLECTION2.PAGE_COUNT * 8 / 1024                                         AS NEW_SIZEMB,
                              ( COLLECTION2.PAGE_COUNT * 8 / 1024 - COLLECTION1.PAGE_COUNT * 8 / 1024 ) AS DELTA_SIZEMB,
                              COLLECTION2.USER_UPDATES - COLLECTION1.USER_UPDATES                       AS TABLE_UPDATES,
                              COLLECTION2.ROW_COUNT - COLLECTION1.ROW_COUNT                             AS DELTA_IN_ROWS,
                              Datediff(DD, COLLECTION1.STATS_TIME, COLLECTION2.STATS_TIME)              AS DAYS
      FROM   INDEX_STATS_VW COLLECTION1
             INNER JOIN INDEX_STATS_VW COLLECTION2
               ON COLLECTION1.TABLE_NAME = COLLECTION2.TABLE_NAME
               AND COLLECTION1.DATABASE_NAME = COLLECTION2.DATABASE_NAME
      WHERE  COLLECTION1.RUN_NAME = @RUN1
             AND COLLECTION2.RUN_NAME = @RUN2
             AND ( ( COLLECTION1.INDEX_DESCRIPTION LIKE 'CLUSTERED%'
                      OR COLLECTION1.INDEX_DESCRIPTION LIKE 'HEAP%' )
                   AND ( COLLECTION2.INDEX_DESCRIPTION LIKE 'CLUSTERED%'
                          OR COLLECTION2.INDEX_DESCRIPTION LIKE 'HEAP%' ) )
      ORDER  BY DELTA_IN_ROWS DESC


      RETURN;
  END




GO




USE [DynamicsPerf]
GO

/****** Object:  UserDefinedFunction [dbo].[fn_getnonclusteredcount]    Script Date: 02/28/2011 12:24:33 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fn_getnonclusteredcount]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[fn_getnonclusteredcount]
GO

USE [DynamicsPerf]
GO

/****** Object:  UserDefinedFunction [dbo].[fn_getnonclusteredcount]    Script Date: 02/28/2011 12:24:33 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fn_getnonclusteredcount](@dbname AS VARCHAR(128),@table_name AS VARCHAR(128))
RETURNS @TABLERETURN TABLE (
  INDEX_NAME VARCHAR(128),
  COUNT      BIGINT)
AS
  BEGIN
      DECLARE @T2_NAME VARCHAR(128);
      DECLARE @T2_COUNT BIGINT;

      SET @T2_NAME = (SELECT TOP 1 INDEX_NAME
                      FROM   INDEX_STATS_VW O
                      WHERE  ( INDEX_DESCRIPTION NOT LIKE 'HEAP%'
                               AND INDEX_DESCRIPTION NOT LIKE 'CLUSTERED%' )
                             AND TABLE_NAME = @table_name
                             AND DATABASE_NAME = @dbname
                             AND STATS_TIME > (SELECT MAX(SQL_SERVER_STARTTIME) FROM STATS_COLLECTION_SUMMARY)
                      ORDER  BY USER_SEEKS + RANGE_SCAN_COUNT DESC);
      SET @T2_COUNT = (SELECT TOP 1 USER_SEEKS + RANGE_SCAN_COUNT
                       FROM   INDEX_STATS_VW O
                       WHERE  ( INDEX_DESCRIPTION NOT LIKE 'HEAP%'
                                AND INDEX_DESCRIPTION NOT LIKE 'CLUSTERED%' )
                              AND TABLE_NAME = @table_name
                              AND DATABASE_NAME = @dbname
                              AND STATS_TIME > (SELECT MAX(SQL_SERVER_STARTTIME) FROM STATS_COLLECTION_SUMMARY)
                       ORDER  BY USER_SEEKS + RANGE_SCAN_COUNT DESC);

      INSERT INTO @TABLERETURN
      VALUES      (@T2_NAME,
                   @T2_COUNT)

      RETURN;
  END


GO



USE [DynamicsPerf]
GO

/****** Object:  UserDefinedFunction [dbo].[fn_getnonclusteredindexes]    Script Date: 02/28/2011 12:25:16 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fn_getnonclusteredindexes]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[fn_getnonclusteredindexes]
GO

USE [DynamicsPerf]
GO

/****** Object:  UserDefinedFunction [dbo].[fn_getnonclusteredindexes]    Script Date: 02/28/2011 12:25:16 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

CREATE FUNCTION [dbo].[fn_getnonclusteredindexes](@dbname AS VARCHAR(128),@table_name AS VARCHAR(128))
RETURNS VARCHAR(128)
AS
  BEGIN
      DECLARE @T2_NAME VARCHAR(128);

      SET @T2_NAME = (SELECT TOP 1 INDEX_NAME
                      FROM   INDEX_STATS_VW O
                      WHERE  ( INDEX_DESCRIPTION NOT LIKE 'HEAP%'
                               AND INDEX_DESCRIPTION NOT LIKE 'CLUSTERED%' )
                             AND TABLE_NAME = @table_name
                             AND DATABASE_NAME = @dbname
							 AND STATS_TIME > (SELECT MAX(SQL_SERVER_STARTTIME) FROM STATS_COLLECTION_SUMMARY)
                      ORDER  BY USER_SEEKS + RANGE_SCAN_COUNT DESC);

      RETURN ( @T2_NAME );
  END


GO
/*************************** END OF FUNCTIONS *******************************************/


/*************************** START OF SQL JOBS ******************************************/

USE [msdb]
GO
--REH  Delete old jobs that we renamed
/****** Object:  Job [DYNPERF_Log_Blocks_Option1_Tracing]    Script Date: 10/10/2010 14:34:59 ******/
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DYNPERF_Log_Blocks_Option1_Tracing_Start')
EXEC msdb.dbo.sp_delete_job @job_name=N'DYNPERF_Log_Blocks_Option1_Tracing_Start', @delete_unused_schedule=1
GO
/****** Object:  Job [DYNPERF_Log_Blocks_Option1_Tracing_Stop]    Script Date: 10/10/2010 15:24:21 ******/
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DYNPERF_Log_Blocks_Option1_Tracing_Stop')
EXEC msdb.dbo.sp_delete_job @job_name=N'DYNPERF_Log_Blocks_Option1_Tracing_Stop', @delete_unused_schedule=1
GO
/****** Object:  Job [DYNPERF_Log_Blocks_Option1_Load_Blocked_Data]    Script Date: 12/16/2010 11:22:48 ******/
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DYNPERF_Log_Blocks_Option1_Load_Blocked_Data')
EXEC msdb.dbo.sp_delete_job @job_name=N'DYNPERF_Log_Blocks_Option1_Load_Blocked_Data', @delete_unused_schedule=1
GO
/****** Object:  Job [DYNPERF_Log_Blocks_Option2_Polling]    Script Date: 10/10/2010 14:36:42 ******/
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DYNPERF_Log_Blocks_Option2_Polling')
EXEC msdb.dbo.sp_delete_job @job_name=N'DYNPERF_Log_Blocks_Option2_Polling', @delete_unused_schedule=1
GO
/****** Object:  Job [DYNPERF_Option1_Tracing_Start]    Script Date: 10/19/2011 15:23:06 ******/
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DYNPERF_Option1_Tracing_Start')
EXEC msdb.dbo.sp_delete_job @job_name=N'DYNPERF_Option1_Tracing_Start', @delete_unused_schedule=1
GO
/****** Object:  Job [DYNPERF_Log_Blocks_Option1_Tracing_Stop]    Script Date: 10/10/2010 15:24:21 ******/
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DYNPERF_Option1_Tracing_Stop')
EXEC msdb.dbo.sp_delete_job @job_name=N'DYNPERF_Option1_Tracing_Stop', @delete_unused_schedule=1
GO
/****** Object:  Job [DYNPERF_Log_Blocks_Option1_Load_Blocked_Data]    Script Date: 12/16/2010 11:22:48 ******/
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DYNPERF_Option1_Load_Blocked_Data')
EXEC msdb.dbo.sp_delete_job @job_name=N'DYNPERF_Option1_Load_Blocked_Data', @delete_unused_schedule=1
GO
/****** Object:  Job [DYNPERF_Log_Blocks_Option2_Polling]    Script Date: 10/10/2010 14:36:42 ******/
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DYNPERF_Option2_Polling_for_Blocking')
EXEC msdb.dbo.sp_delete_job @job_name=N'DYNPERF_Option2_Polling_for_Blocking', @delete_unused_schedule=1
GO
/****** Object:  Job [DYNPERF_Log_Blocks_Option2_Polling]    Script Date: 10/10/2010 14:36:42 ******/
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DYNPERF_Option2_Polling_for_Blocking')
EXEC msdb.dbo.sp_delete_job @job_name=N'DYNPERF_Option2_Polling_for_Blocking', @delete_unused_schedule=1
GO

/****** Object:  Job [DYNPERF_Purge_Stats]    Script Date: 10/10/2010 14:36:42 ******/
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DYNPERF_Purge_Stats')
EXEC msdb.dbo.sp_delete_job @job_name=N'DYNPERF_Purge_Stats', @delete_unused_schedule=1
GO

/****** Object:  Job [DYNPERF_Default_Trace_Start]    Script Date: 04/26/2012 19:26:53 ******/
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DYNPERF_Detailed_Trace')
EXEC msdb.dbo.sp_delete_job @job_name=N'DYNPERF_Detailed_Trace', @delete_unused_schedule=1
GO


/****** Object:  Job [log_blocks_purge]    Script Date: 02/16/2010 14:14:02 ******/
IF EXISTS (SELECT job_id
           FROM   msdb.dbo.sysjobs_view
           WHERE  name = N'DYNPERF_Purge_Blocks')
  EXEC msdb.dbo.sp_delete_job
    @job_name = N'DYNPERF_Purge_Blocks',
    @delete_unused_schedule=1

GO 
USE [msdb]
GO

/****** Object:  Job [DYNPERF_Purge_Blocks]    Script Date: 04/01/2011 07:27:13 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]]    Script Date: 04/01/2011 07:27:13 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DYNPERF_Purge_Blocks', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'purge data from the blocks table. Default is 7 days', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Purge Blocks]    Script Date: 04/01/2011 07:27:13 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Purge Blocks', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'
[SP_PURGEBLOCKS] @days= 7', 
		@database_name=N'DynamicsPerf', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Daily', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20110401, 
		@active_end_date=99991231, 
		@active_start_time=40000, 
		@active_end_time=235959
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO




USE [msdb]
GO
/****** Object:  Job [DYNPERF_Capture_Stats]    Script Date: 02/18/2010 11:38:20 ******/
IF EXISTS (SELECT job_id
           FROM   msdb.dbo.sysjobs_view
           WHERE  name = N'DYNPERF_Capture_Stats')
  EXEC msdb.dbo.sp_delete_job
    @job_name=N'DYNPERF_Capture_Stats',
    @delete_unused_schedule=1

GO 

USE [msdb]
GO

/****** Object:  Job [DYNPERF_Capture_Stats]    Script Date: 10/10/2010 14:25:48 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]]    Script Date: 10/10/2010 14:25:48 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DYNPERF_Capture_Stats', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Capture DMV Data for performance analysis, daily', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [sp_capturestats]    Script Date: 10/10/2010 14:25:48 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'sp_capturestats', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC SP_CAPTURESTATS	@DATABASE_NAME = ''dbname'', @SKIP_STATS = ''N''', 
		@database_name=N'DynamicsPerf', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Daily', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20101008, 
		@active_end_date=99991231, 
		@active_start_time=170000, 
		@active_end_time=235959

IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO

USE [msdb]
GO

/****** Object:  Job [DYNPERF_Default_Trace_Start]    Script Date: 10/19/2011 15:23:06 ******/
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DYNPERF_Default_Trace_Start')
EXEC msdb.dbo.sp_delete_job @job_name=N'DYNPERF_Default_Trace_Start', @delete_unused_schedule=1
GO

USE [msdb]
GO

/****** Object:  Job [DYNPERF_Default_Trace_Start]    Script Date: 10/19/2011 15:23:06 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]]    Script Date: 10/19/2011 15:23:06 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DYNPERF_Default_Trace_Start', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Records all blocking information into a trace file C:\SQLTRACE\DYNAMICS_DEFAULT.TRC. You must edit the steps to change the location of this file. Use Query Blocks - Investigate Blocks.sql in the Performance Analyzer 1.16 for Microsoft Dynamics to analyze this data. If the path is changed, you must edit the definition of BLOCKED_PROCESS_VW to the new path.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Start Tracing]    Script Date: 10/19/2011 15:23:06 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Start Tracing', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'SP_SQLTRACE
	@FILE_PATH 		= ''C:\SQLTRACE'', -- Location to write trace files.  Note: directory must exist before start of trace
	@TRACE_NAME  		= ''DYNAMICS_DEFAULT'', -- Trace name - becomes base of trace file name
	@DATABASE_NAME	= NULL,			-- Name of database to trace; default (NULL) will trace all databases
	@TRACE_FILE_SIZE	= 10,			-- maximum trace file size - will rollover when reached
	@TRACE_FILE_COUNT	= 100,			-- maximum numer of trace files  - will delete oldest when reached
	@TRACE_STOP  		= ''N'',			-- When set to ''Y'' will stop the trace and exit
	@TRACE_RUN_HOURS  	= 25 			-- Number of hours to run trace

	', 
		@database_name=N'DynamicsPerf', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Daily', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20110313, 
		@active_end_date=99991231, 
		@active_start_time=000000, 
		@active_end_time=235959, 
		@schedule_uid=N'3aa2d032-645a-4a48-b96e-a40fb57097aa'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Startup', 
		@enabled=1, 
		@freq_type=64, 
		@freq_interval=0, 
		@freq_subday_type=0, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20111019, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'bce0cd16-d38d-4b96-b90b-b352600980b1'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO




USE [msdb]
GO

/****** Object:  Job [DYNPERF_Default_Trace_Stop]    Script Date: 10/10/2010 15:24:21 ******/
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DYNPERF_Default_Trace_Stop')
EXEC msdb.dbo.sp_delete_job @job_name=N'DYNPERF_Default_Trace_Stop', @delete_unused_schedule=1
GO

USE [msdb]
GO

/****** Object:  Job [DYNPERF_Default_Trace_Stop]    Script Date: 10/10/2010 15:24:21 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]]    Script Date: 10/10/2010 15:24:21 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DYNPERF_Default_Trace_Stop', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'This job stops the tracing started by the DYNPERF_Option1_Tracing job.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Stop Tracing]    Script Date: 10/10/2010 15:24:21 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Stop Tracing', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'/****************  Stop the Trace ****************************/
EXEC SP_SQLTRACE @TRACE_NAME = ''DYNAMICS_DEFAULT'', -- Trace name - becomes base of trace file name
	@TRACE_STOP = ''Y'' -- When set to ''Y'' will stop the trace and exit', 
		@database_name=N'DynamicsPerf', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO

USE [msdb]
GO

/****** Object:  Job [DYNPERF_LONG_DURATION_TRACE]    Script Date: 04/26/2012 19:26:53 ******/
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DYNPERF_Long_Duration_Trace')
EXEC msdb.dbo.sp_delete_job @job_name=N'DYNPERF_Long_Duration_Trace', @delete_unused_schedule=1
GO

USE [msdb]
GO

/****** Object:  Job [DYNPERF_LONG_DURATION_TRACE]    Script Date: 04/26/2012 19:26:53 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]]    Script Date: 04/26/2012 19:26:53 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DYNPERF_Long_Duration_Trace', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=0,
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Records long duration SQL Statement events into a trace file C:\SQLTRACE\DYNAMICS_LONG_DURATION.TRC. You must edit the steps to change the location of this file. ', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Start Tracing]    Script Date: 04/26/2012 19:26:53 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Start Tracing', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'SP_SQLTRACE
	@FILE_PATH 		= ''C:\SQLTRACE'', -- Location to write trace files.  Note: directory must exist before start of trace
	@TRACE_NAME  		= ''DYNAMICS_LONG_DURATION'', -- Trace name - becomes base of trace file name
	@DATABASE_NAME	= NULL,			-- Name of database to trace; default (NULL) will trace all databases
	@TRACE_FILE_SIZE	= 10,			-- maximum trace file size - will rollover when reached
	@TRACE_FILE_COUNT	= 100,			-- maximum numer of trace files  - will delete oldest when reached
	@TRACE_STOP  		= ''N'',			-- When set to ''Y'' will stop the trace and exit
	@TRACE_RUN_HOURS  	= 25 ,			-- Number of hours to run trace
	@DURATION_SECS	        = 5  
-- DO NOT reduce this value without direction from Microsoft support. 
-- Could cause system performance issues.
	', 
		@database_name=N'DynamicsPerf', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Daily', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20110313, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'3aa2d032-645a-4a48-b96e-a40fb57097aa'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Startup', 
		@enabled=1, 
		@freq_type=64, 
		@freq_interval=0, 
		@freq_subday_type=0, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20111019, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'bce0cd16-d38d-4b96-b90b-b352600980b1'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO



USE [msdb]
GO

/****** Object:  Job [DYNPERF_Default_Trace_Start_Load_Blocking_Data]    Script Date: 12/16/2010 11:22:48 ******/
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DYNPERF_Default_Trace_Start_Load_Blocking_Data')
EXEC msdb.dbo.sp_delete_job @job_name=N'DYNPERF_Default_Trace_Start_Load_Blocking_Data', @delete_unused_schedule=1
GO

--USE [msdb]
--GO

--/****** Object:  Job [DYNPERF_Log_Blocks_Option1_Load_Blocked_Data]    Script Date: 12/16/2010 11:22:48 ******/
--BEGIN TRANSACTION
--DECLARE @ReturnCode INT
--SELECT @ReturnCode = 0
--/****** Object:  JobCategory [[Uncategorized (Local)]]]    Script Date: 12/16/2010 11:22:48 ******/
--IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
--BEGIN
--EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
--IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

--END

--DECLARE @jobId BINARY(16)
--EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DYNPERF_Default_Trace_Start_Load_Blocking_Data', 
--		@enabled=0, 
--		@notify_level_eventlog=0, 
--		@notify_level_email=0, 
--		@notify_level_netsend=0, 
--		@notify_level_page=0, 
--		@delete_level=0, 
--		@description=N'Load the blocking data from the Trace created with the DYNPERF_Option1_Tracing_Start job', 
--		@category_name=N'[Uncategorized (Local)]', 
--		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
--IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
--/****** Object:  Step [Load Blocking Data]    Script Date: 12/16/2010 11:22:49 ******/
--EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Load Blocking Data', 
--		@step_id=1, 
--		@cmdexec_success_code=0, 
--		@on_success_action=1, 
--		@on_success_step_id=0, 
--		@on_fail_action=2, 
--		@on_fail_step_id=0, 
--		@retry_attempts=0, 
--		@retry_interval=0, 
--		@os_run_priority=0, @subsystem=N'TSQL', 
--		@command=N'

----This Query loads the data from the Trace file into DynamicsPerf database
--EXEC SP_POPULATE_BLOCKED_PROCESS_INFO ', 
--		@database_name=N'DynamicsPerf', 
--		@flags=0
--IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
--EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
--IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
--EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every Ten Minutes', 
--		@enabled=1, 
--		@freq_type=4, 
--		@freq_interval=1, 
--		@freq_subday_type=4, 
--		@freq_subday_interval=10, 
--		@freq_relative_interval=0, 
--		@freq_recurrence_factor=0, 
--		@active_start_date=20101216, 
--		@active_end_date=99991231, 
--		@active_start_time=80000, 
--		@active_end_time=200000
--IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
--EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
--IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
--COMMIT TRANSACTION
--GOTO EndSave
--QuitWithRollback:
--    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
--EndSave:

GO



USE [msdb]
GO

/****** Object:  Job [DYNPERF_Log_Blocks_Option2_Polling]    Script Date: 10/10/2010 14:36:42 ******/
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DYNPERF_Optional_Polling_for_Blocking')
EXEC msdb.dbo.sp_delete_job @job_name=N'DYNPERF_Optional_Polling_for_Blocking', @delete_unused_schedule=1
GO

USE [msdb]
GO

/****** Object:  Job [DYNPERF_Log_Blocks_Option2_Polling]    Script Date: 10/10/2010 14:36:42 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]]    Script Date: 10/10/2010 14:36:42 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DYNPERF_Optional_Polling_for_Blocking', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Records all blocking into a table called Blocks in the DynamicsPerfdb via polling.  This method can put stress on SQL Server if there are many processes getting blocked, but works well for a fast check of blocking or when there is a limited amount of blocking. Use Query Blocks - Investigate Blocks.sql in the Performance Analyzer 1.0 for Microsoft Dynamics to analyze this data.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Record Database Blocking]    Script Date: 10/10/2010 14:36:42 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Record Database Blocking', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=1, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'SP_LOCKS_MS ''00:00:02''', 
		@database_name=N'DynamicsPerf', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


USE [msdb]
GO

/****** Object:  Job [DYNPERF_Capture_Stats_Purge]    Script Date: 02/18/2010 11:38:53 ******/
IF EXISTS (SELECT job_id
           FROM   msdb.dbo.sysjobs_view
           WHERE  name = N'DYNPERF_Capture_Stats_Purge')
  EXEC msdb.dbo.sp_delete_job
    @job_name=N'DYNPERF_Capture_Stats_Purge',
    @delete_unused_schedule=1

GO 
USE [msdb]
GO

/****** Object:  Job [DYNPERF_Capture_Stats_Purge]    Script Date: 03/13/2011 13:24:08 ******/
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DYNPERF_Capture_Stats_Purge')
EXEC msdb.dbo.sp_delete_job @job_name=N'DYNPERF_Capture_Stats_Purge', @delete_unused_schedule=1
GO

USE [msdb]
GO

/****** Object:  Job [DYNPERF_Capture_Stats_Purge]    Script Date: 03/13/2011 13:24:08 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]]    Script Date: 03/13/2011 13:24:08 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DYNPERF_Capture_Stats_Purge', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Purge data from the DynamicsPerf database', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [sp_purgestats]    Script Date: 03/13/2011 13:24:08 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'sp_purgestats', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC SP_PURGESTATS	@PURGE_DAYS = 14
GO
-- Clear Wait Stats 
DBCC SQLPERF(''sys.dm_os_wait_stats'', CLEAR);
GO
sp_updatestats
', 
		@database_name=N'DynamicsPerf', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Daily', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20101007, 
		@active_end_date=99991231, 
		@active_start_time=235959, 
		@active_end_time=235959
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO

USE [msdb]
GO

/****** Object:  Job [DYNPERF_PerfStats_Hourly]    Script Date: 03/13/2011 13:38:20 ******/
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DYNPERF_PerfStats_Hourly')
EXEC msdb.dbo.sp_delete_job @job_name=N'DYNPERF_PerfStats_Hourly', @delete_unused_schedule=1
GO

USE [msdb]
GO

/****** Object:  Job [DYNPERF_PerfStats_Hourly]    Script Date: 03/13/2011 13:38:20 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]]    Script Date: 03/13/2011 13:38:20 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DYNPERF_PerfStats_Hourly', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'This job captures a very small subset of the data collected by the DYNPERF_Capture_Stats job.  This data is used to determine hourly transaction volume information.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [CaptureStats]    Script Date: 03/13/2011 13:38:20 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'CaptureStats', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'SP_CAPTURESTATS_PERF  @DATABASE_NAME = ''dbname''', 
		@database_name=N'DynamicsPerf', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Hourly', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20110313, 
		@active_end_date=99991231, 
		@active_start_time=00000, 
		@active_end_time=235900
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO




USE [msdb]
GO

/****** Object:  Job [DYNPERF_SQL_Trace]    Script Date: 02/18/2010 12:58:00 ******/
IF EXISTS (SELECT job_id
           FROM   msdb.dbo.sysjobs_view
           WHERE  name = N'DYNPERF_SQL_Trace')
  EXEC msdb.dbo.sp_delete_job
    @job_name=N'DYNPERF_SQL_Trace',
    @delete_unused_schedule=1

GO 


USE [msdb]
GO

/****** Object:  Job [DYNPERF_Purge_SYSTRACETABLESQL_AX]    Script Date: 10/19/2011 16:21:00 ******/
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DYNPERF_Purge_SYSTRACETABLESQL_AX')
EXEC msdb.dbo.sp_delete_job @job_name=N'DYNPERF_Purge_SYSTRACETABLESQL_AX', @delete_unused_schedule=1
GO

USE [msdb]
GO

/****** Object:  Job [DYNPERF_Purge_SYSTRACETABLESQL_AX]    Script Date: 10/19/2011 16:21:00 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]]    Script Date: 10/19/2011 16:21:00 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DYNPERF_Purge_SYSTRACETABLESQL_AX', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'This job is designed to purge data from a Dynamics AX database.  It will purges data from SYSTRACETABLE and SYSTRACETABLESQL.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Purge_SYSTRACETABLE]    Script Date: 10/19/2011 16:21:01 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Purge_SYSTRACETABLE', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DELETE FROM SYSTRACETABLE WHERE CREATEDDATETIME<=
DATEADD(DD,-14, GETDATE())

GO

DELETE FROM SYSTRACETABLESQL WHERE CREATEDDATETIME<=
DATEADD(DD,-14, GETDATE())

GO


DELETE SP FROM SYSTRACETABLESQLEXECPLAN SP 
WHERE NOT EXISTS (SELECT RECID FROM SYSTRACETABLE ST WHERE ST.RECID=SP.TRACERECID)
GO


DELETE SF FROM SYSTRACETABLESQLTABREF SF
 WHERE NOT EXISTS (SELECT RECID FROM SYSTRACETABLE ST WHERE ST.RECID=SF.TRACERECID)

', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Daily', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20111019, 
		@active_end_date=99991231, 
		@active_start_time=10000, 
		@active_end_time=235959
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO

USE [msdb]
GO

/****** Object:  Job [DYNPERF_Capture_Stats_Baseline]    Script Date: 03/18/2014 21:27:20 ******/
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DYNPERF_Capture_Stats_Baseline')
EXEC msdb.dbo.sp_delete_job @job_name=N'DYNPERF_Capture_Stats_Baseline', @delete_unused_schedule=1
GO

USE [msdb]
GO

/****** Object:  Job [DYNPERF_Capture_Stats_Baseline]    Script Date: 03/18/2014 21:27:20 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]]    Script Date: 03/18/2014 21:27:20 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DYNPERF_Capture_Stats_Baseline', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Capture DMV Data for performance analysis, daily', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [sp_capturestats_baseline]    Script Date: 03/18/2014 21:27:20 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'sp_capturestats_baseline', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'
DECLARE @R AS VARCHAR(128)
SET @R = ''BASE '' + CONVERT(VARCHAR, GETDATE() )
EXEC SP_CAPTURESTATS @DATABASE_NAME = ''dbname'' 
,@SKIP_STATS=''N''
,@RUN_NAME = @R
', 
		@database_name=N'DynamicsPerf', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO




USE [msdb]
GO

/****** Object:  Job [DYNPERF_Compression_Analyzer]    Script Date: 09/08/2011 12:40:32 ******/
--REH put this in to remove this from anybody that ran a beta version of Performance Analyzer
IF EXISTS (SELECT job_id
           FROM   msdb.dbo.sysjobs_view
           WHERE  name = N'DYNPERF_Compression_Analyzer')
  EXEC msdb.dbo.sp_delete_job
    @job_name=N'DYNPERF_Compression_Analyzer',
    @delete_unused_schedule=1
    
    

GO 

USE [msdb]
GO

/****** Object:  Job [DYNPERF_Set_AX_User_Trace_on]    Script Date: 04/01/2014 08:20:00 ******/
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DYNPERF_Set_AX_User_Trace_on')
EXEC msdb.dbo.sp_delete_job @job_name=N'DYNPERF_Set_AX_User_Trace_on', @delete_unused_schedule=1
GO

USE [msdb]
GO

/****** Object:  Job [DYNPERF_Set_AX_User_Trace_on]    Script Date: 04/01/2014 08:20:00 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]]    Script Date: 04/01/2014 08:20:00 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DYNPERF_Set_AX_User_Trace_on', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Turn on the long running user trace functionality inside Dynamics AX', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Set Trace On]    Script Date: 04/01/2014 08:20:00 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Set Trace On', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE DynamicsPerf

EXEC SET_AX_SQLTRACE
  @DATABASE_NAME = ''dbname'',
  @QUERY_TIME_LIMIT = 5000', 
		@database_name=N'DynamicsPerf', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Weekly', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20140401, 
		@active_end_date=99991231, 
		@active_start_time=40000, 
		@active_end_time=235959
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO

USE [msdb]
GO

/****** Object:  Job [DYNPERF_Set_AX_User_Trace_off]    Script Date: 04/01/2014 08:21:23 ******/
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DYNPERF_Set_AX_User_Trace_off')
EXEC msdb.dbo.sp_delete_job @job_name=N'DYNPERF_Set_AX_User_Trace_off', @delete_unused_schedule=1
GO

USE [msdb]
GO

/****** Object:  Job [DYNPERF_Set_AX_User_Trace_off]    Script Date: 04/01/2014 08:21:23 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]]    Script Date: 04/01/2014 08:21:23 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DYNPERF_Set_AX_User_Trace_off', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Turn off the long running SQL Trace functionality in Dynamics AX', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Turn Off]    Script Date: 04/01/2014 08:21:23 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Turn Off', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE DynamicsPerf

EXEC SET_AX_SQLTRACE
  @DATABASE_NAME = ''dbname'',
  @TRACE_STATUS = ''OFF'' 
', 
		@database_name=N'DynamicsPerf', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO



/********************** END OF SQL JOBS ***********************************/



sp_configure 'Show Advanced Options', 1

GO

RECONFIGURE WITH OVERRIDE

GO

sp_configure 'blocked process threshold', 5

GO

RECONFIGURE WITH OVERRIDE

GO 

DECLARE @SQL VARCHAR(MAX)

IF EXISTS (SELECT name FROM tempdb..sysobjects WHERE name = '##Results')  
   BEGIN  
       DROP TABLE ##Results  
   END 
    
CREATE TABLE ##Results
  (
     [Database Name]         SYSNAME,
     [File Name]             SYSNAME,
     [Physical Name]         NVARCHAR(260),
     [File Type]             VARCHAR(4),
     [Total Size in Mb]      INT,
     [Available Space in Mb] INT,
     [Growth Units]          VARCHAR(15),
     [max File Size in Mb]   INT,
     [file_id]				 INT
  ) 

SELECT @SQL =  
'USE [?] INSERT INTO ##Results([Database Name], [File Name], [Physical Name],  
[File Type], [Total Size in Mb], [Available Space in Mb],  
[Growth Units], [max File Size in Mb])  
SELECT DB_NAME(), 
[name] AS [File Name],  
physical_name AS [Physical Name],  
[File Type] =  
CASE type 
WHEN 0 THEN ''Data'''  
+ 
           'WHEN 1 THEN ''Log''' 
+ 
       'END, 
[Total Size in Mb] = 
CASE ceiling([size]/128)  
WHEN 0 THEN 1 
ELSE ceiling([size]/128) 
END, 
[Available Space in Mb] =  
CASE ceiling([size]/128) 
WHEN 0 THEN (1 - CAST(FILEPROPERTY([name], ''SpaceUsed''' + ') as int) /128) 
ELSE (([size]/128) - CAST(FILEPROPERTY([name], ''SpaceUsed''' + ') as int) /128) 
END, 
[Growth Units]  =  
CASE [is_percent_growth]  
WHEN 1 THEN CAST(growth AS varchar(20)) + ''%''' 
+ 
           'ELSE CAST(growth/128 AS varchar(20)) + ''Mb''' 
+ 
       'END, 
[max File Size in Mb] =  
CASE [max_size] 
WHEN -1 THEN NULL 
WHEN 268435456 THEN NULL 
ELSE [max_size] 
END 
FROM sys.database_files
WHERE type =0 and EXISTS (SELECT name FROM sys.objects where name
 in (''SYSTRACETABLESQL'',''RPTRUNTIME'', ''GL00100'', ''SY01500'',''AccountExtensionBase'',''CrmKeySetting '',''$ndo$dbproperty ''))
' 

--Print the command to be issued against all databases 
--PRINT @SQL 


--Run the command against each database 
EXEC sp_MSforeachdb @SQL 

DECLARE @DYNAMICSDB SYSNAME


SET @DYNAMICSDB = (SELECT TOP 1 [Database Name] FROM ##Results ORDER BY [Total Size in Mb] DESC)
INSERT DynamicsPerf..DATABASES_2_COLLECT SELECT DISTINCT [Database Name] FROM ##Results ORDER BY [Database Name]
IF @DYNAMICSDB IS NULL SET @DYNAMICSDB = 'dbname'


PRINT '-----------------------------------------------------------------------------------------'
PRINT '-- Auto-Configured the DYNPERF SQL jobs to your largest Dynamics database				'
PRINT '--						' +UPPER(@DYNAMICSDB) +'										'
PRINT '-----------------------------------------------------------------------------------------'
PRINT ''


SET @SQL ='EXEC  SP_CAPTURESTATS @DATABASE_NAME = ' + QUOTENAME(@DYNAMICSDB,'''')  + ' , @SKIP_STATS = ' + QUOTENAME('N', '''') 

EXEC msdb.dbo.sp_update_jobstep
    @job_name = N'DYNPERF_Capture_Stats',
    @step_id = 1,
	@command = @SQL



SET @SQL = 'DECLARE @R AS VARCHAR(128)
SET @R = ''BASE '' + CONVERT(VARCHAR, GETDATE() )
EXEC  SP_CAPTURESTATS @DATABASE_NAME = ' + QUOTENAME(@DYNAMICSDB,'''')  + ' , @SKIP_STATS = ' + QUOTENAME('N', '''') 
+ ' ,@RUN_NAME = @R'

exec msdb.dbo.sp_update_jobstep
    @job_name = N'DYNPERF_Capture_Stats_Baseline',
    @step_id = 1,
    @command = @SQL
    
SET @SQL = 'USE DynamicsPerf

EXEC SET_AX_SQLTRACE
  @DATABASE_NAME = ' + QUOTENAME(@DYNAMICSDB,'''')  +',
  @QUERY_TIME_LIMIT = 5000'

exec msdb.dbo.sp_update_jobstep
    @job_name = N'DYNPERF_Set_AX_User_Trace_on',
    @step_id = 1,
    @command = @SQL
    
  
SET @SQL = 'USE DynamicsPerf

EXEC SET_AX_SQLTRACE
  @DATABASE_NAME = ' + QUOTENAME(@DYNAMICSDB,'''')  +',
  @QUERY_TIME_LIMIT = 5000,
  @TRACE_STATUS = ''OFF'''

exec msdb.dbo.sp_update_jobstep
    @job_name = N'DYNPERF_Set_AX_User_Trace_off',
    @step_id = 1,
    @command = @SQL
    

SET @SQL = 'EXEC SP_CAPTURESTATS_PERF @DATABASE_NAME = ' +QUOTENAME(@DYNAMICSDB,'''') 


EXEC msdb.dbo.sp_update_jobstep
    @job_name = N'DYNPERF_PerfStats_Hourly',
    @step_id = 1,
    @command = @SQL


--Insert  blank record for Dynamics AX cursors, so we only have 1 plan for fetch api_cursor calls  otherwise we'll insert a plan for every fetch api_cursor sitting in procedure cache
--     this record will be deleted after a week by the purge_stats job if it's not needed.
INSERT INTO [DynamicsPerf]..QUERY_PLANS VALUES(0x0000000000000000,'<ShowPlanXML xmlns="http://schemas.microsoft.com/sqlserver/2004/07/showplan" Version="1.1" Build="10.50.1765.0"><BatchSequence><Batch><Statements><StmtCursor StatementText="FETCH API_CURSOR Look for another QUERY_STATS record with a creation time close to this record" StatementId="1" StatementCompId="9" StatementType="FETCH CURSOR"><CursorPlan CursorName="API_CURSOR00000000000000B3" /></StmtCursor></Statements></Batch></BatchSequence></ShowPlanXML>','',0)



PRINT '-----------------------------------------------------------------------------------------'
PRINT '-- If deploying on Dynamics database be sure to run the									'
PRINT '--		2-Create_XX_Objects.sql  for the appropriate Dynamics product					'
PRINT '-----------------------------------------------------------------------------------------'
PRINT ''
PRINT '-----------------------------------------------------------------------------------------'
PRINT '-- 												'
PRINT '-- PLEASE VISIT HTTP://BLOOGS.MSDN.COM/AXINTHEFIELD  for details on this tool			'
PRINT '-- 												'
PRINT '-----------------------------------------------------------------------------------------'

