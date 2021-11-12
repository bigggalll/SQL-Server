CREATE DATABASE [ServerAnalysis]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'ServerAnalysis', FILENAME = N'E:\MSSQL\Data\ServerAnalysis.mdf' , SIZE = 10MB , FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'ServerAnalysis_log', FILENAME = N'F:\MSSQL\Data\ServerAnalysis_log.ldf' , SIZE = 5MB , FILEGROWTH = 1024KB)
GO
USE [ServerAnalysis]
GO
CREATE SCHEMA [Analysis]
GO

CREATE TABLE [Analysis].[Server] (
    ServerID    int IDENTITY(1,1) NOT NULL,
    ServerNm    varchar(50) NOT NULL,
    CONSTRAINT [PK_Server] PRIMARY KEY CLUSTERED 
    (
        [ServerID] ASC
    )
)
GO

CREATE TABLE [Analysis].[ServerStats] (
    ServerID    int IDENTITY(1,1) NOT NULL,
    ServerNm    varchar(30) NOT NULL,
    PerfDate    datetime NOT NULL,
    PctProc     decimal(10,4) NOT NULL,
    Memory      bigint NOT NULL,
    PgFilUse    decimal(10,4) NOT NULL,
    DskSecRd    decimal(10,4) NOT NULL,
    DskSecWrt   decimal(10,4) NOT NULL,
    ProcQueLn   int NOT NULL
    CONSTRAINT [PK_ServerStats] PRIMARY KEY CLUSTERED 
    (
        [ServerID] ASC
    )
)
GO

CREATE TABLE [Analysis].[InstanceStats] (
    InstanceID  int IDENTITY(1,1) NOT NULL,
    ServerID    int NOT NULL,
    ServerNm    varchar(30) NOT NULL,
    InstanceNm  varchar(30) NOT NULL,
    PerfDate    datetime NOT NULL,
    FwdRecSec   decimal(10,4) NOT NULL,
    PgSpltSec   decimal(10,4) NOT NULL,
    BufCchHit   decimal(10,4) NOT NULL,
    PgLifeExp   int NOT NULL,
    LogGrwths   int NOT NULL,
    BlkProcs    int NOT NULL,
    BatReqSec   decimal(10,4) NOT NULL,
    SQLCompSec  decimal(10,4) NOT NULL,
    SQLRcmpSec  decimal(10,4) NOT NULL
    CONSTRAINT [PK_InstanceStats] PRIMARY KEY CLUSTERED 
    (
        [InstanceID] ASC
    )
)
GO
ALTER TABLE [Analysis].[InstanceStats] WITH CHECK ADD  CONSTRAINT [FX_InstanceStats] FOREIGN KEY([ServerID])
REFERENCES [Analysis].[ServerStats] ([ServerID])
GO

ALTER TABLE [Analysis].[InstanceStats] CHECK CONSTRAINT [FX_InstanceStats] 
GO
CREATE NONCLUSTERED INDEX [AK_ServerStats] ON [Analysis].[InstanceStats] 
(
    [ServerID] ASC
)
GO
CREATE NONCLUSTERED INDEX [IX_ServerStats_PerfDate] ON [Analysis].[ServerStats] 
(
    [PerfDate] ASC
)
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Analysis].[insServerStats]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [Analysis].[insServerStats]
GO
CREATE PROCEDURE [Analysis].[insServerStats]
           (@ServerID       int OUTPUT
           ,@ServerNm       varchar(30) = NULL
           ,@PerfDate       datetime = NULL
           ,@PctProc        decimal(10,4) = NULL
           ,@Memory     bigint = NULL
           ,@PgFilUse       decimal(10,4) = NULL
           ,@DskSecRd       decimal(10,4) = NULL
           ,@DskSecWrt      decimal(10,4) = NULL
           ,@ProcQueLn      int = NULL)
AS
    SET NOCOUNT ON
    
    DECLARE @ServerOut table( ServerID int);

    INSERT INTO [Analysis].[ServerStats]
           ([ServerNm]
           ,[PerfDate]
           ,[PctProc]
           ,[Memory]
           ,[PgFilUse]
           ,[DskSecRd]
           ,[DskSecWrt]
           ,[ProcQueLn])
    OUTPUT INSERTED.ServerID INTO @ServerOut
        VALUES
           (@ServerNm
           ,@PerfDate
           ,@PctProc
           ,@Memory
           ,@PgFilUse
           ,@DskSecRd
           ,@DskSecWrt
           ,@ProcQueLn)

    SELECT @ServerID = ServerID FROM @ServerOut
    
    RETURN

GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Analysis].[insInstanceStats]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [Analysis].[insInstanceStats]
GO
CREATE PROCEDURE [Analysis].[insInstanceStats]
           (@InstanceID     int OUTPUT
           ,@ServerID       int = NULL
           ,@ServerNm       varchar(30) = NULL
           ,@InstanceNm     varchar(30) = NULL
           ,@PerfDate       datetime = NULL
           ,@FwdRecSec      decimal(10,4) = NULL
           ,@PgSpltSec      decimal(10,4) = NULL
           ,@BufCchHit      decimal(10,4) = NULL
           ,@PgLifeExp      int = NULL
           ,@LogGrwths      int = NULL
           ,@BlkProcs       int = NULL
           ,@BatReqSec      decimal(10,4) = NULL
           ,@SQLCompSec     decimal(10,4) = NULL
           ,@SQLRcmpSec     decimal(10,4) = NULL)
AS
    SET NOCOUNT ON
    
    DECLARE @InstanceOut table( InstanceID int);

    INSERT INTO [Analysis].[InstanceStats]
           ([ServerID]
           ,[ServerNm]
           ,[InstanceNm]
           ,[PerfDate]
           ,[FwdRecSec]
           ,[PgSpltSec]
           ,[BufCchHit]
           ,[PgLifeExp]
           ,[LogGrwths]
           ,[BlkProcs]
           ,[BatReqSec]
           ,[SQLCompSec]
           ,[SQLRcmpSec])
    OUTPUT INSERTED.InstanceID INTO @InstanceOut
    VALUES
           (@ServerID
           ,@ServerNm
           ,@InstanceNm
           ,@PerfDate
           ,@FwdRecSec
           ,@PgSpltSec
           ,@BufCchHit
           ,@PgLifeExp
           ,@LogGrwths
           ,@BlkProcs
           ,@BatReqSec
           ,@SQLCompSec
           ,@SQLRcmpSec)

    SELECT @InstanceID = InstanceID FROM @InstanceOut
    
    RETURN

GO


CREATE PROCEDURE [Analysis].[selServer]
AS
SET NOCOUNT ON

SELECT [ServerNm]
FROM [Analysis].[Server]
ORDER BY [ServerNm]
GO

INSERT INTO Analysis.Server (ServerNm)
SELECT @@SERVERNAME
GO

USE [ServerAnalysis]
GO

CREATE TABLE [Analysis].[DiskUsage](
	[disk_id] [int] IDENTITY(1,1) NOT NULL,
	[PerfDate] [datetime] NOT NULL,
	[ServerName] [varchar](30) NULL,
	[VolumeName] [varchar](30) NULL,
	[DriveName] [varchar](5) NULL,
	[Size] [float] NULL,
	[FreeSpace] [float] NULL,
	[PercentFree] [float] NULL,
 CONSTRAINT [PK_DiskUsage] PRIMARY KEY CLUSTERED 
(
	[disk_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [Analysis].[DatabaseUsage](
	[database_id] [int] IDENTITY(1,1) NOT NULL,
	[PerfDate] [datetime] NOT NULL,
	[ServerName] [varchar](30) NULL,
	[DatabaseName] [varchar](30) NULL,
	[Collation] [varchar](30) NULL,
	[CompatibilityLevel] [varchar](30) NULL,
	[AutoShrink] [varchar](5) NULL,
	[RecoveryModel] [varchar](30) NULL,
	[Size] [float] NULL,
	[SpaceAvailable] [float] NULL,
 CONSTRAINT [PK_DatabaseUsage] PRIMARY KEY CLUSTERED 
(
	[database_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE PROCEDURE [Analysis].[insDiskUsage]
		   (@ServerNm	varchar(30)=NULL
		   ,@PerfDate	DATETIME = NULL
		   ,@VolName	varchar(30)=NULL
		   ,@Drive	varchar(5)=NULL
		   ,@Size	float=NULL
		   ,@Free	float=NULL
		   ,@Percent	float=NULL)
AS
	SET NOCOUNT ON
	
	INSERT INTO [Analysis].[DiskUsage]
           ([PerfDate]
           ,[ServerName]
           ,[VolumeName]
           ,[DriveName]
           ,[Size]
           ,[FreeSpace]
           ,[PercentFree])
     VALUES
           (@PerfDate
           ,@ServerNm
           ,@VolName
           ,@Drive
           ,@Size
           ,@Free
           ,@Percent)


GO

CREATE PROCEDURE [Analysis].[insDatabaseUsage]
		   (@ServerNm	varchar(30)=NULL
		   ,@PerfDate	DATETIME = NULL
		   ,@DBName	varchar(30)=NULL
		   ,@Collation	varchar(30)=NULL
		   ,@Compat	varchar(30)=NULL
		   ,@Shrink	varchar(5)=NULL
		   ,@Recovery	varchar(30)=NULL
		   ,@Size	float=NULL
		   ,@Available	float=NULL)
AS
	SET NOCOUNT ON
	
	INSERT INTO [Analysis].[DatabaseUsage]
           ([PerfDate]
           ,[ServerName]
           ,[DatabaseName]
           ,[Collation]
           ,[CompatibilityLevel]
           ,[AutoShrink]
           ,[RecoveryModel]
           ,[Size]
           ,[SpaceAvailable])
     VALUES
           (@PerfDate
           ,@ServerNm
           ,@DBName
           ,@Collation
           ,@Compat
           ,@Shrink
           ,@Recovery
           ,@Size
           ,@Available)


GO

CREATE PROCEDURE [Analysis].[selComparativeAnalysisReport] (@InstanceName varchar(50))
AS
SET NOCOUNT ON

DECLARE @Sep INT, @BoxNm VARCHAR(50), @InstNm VARCHAR(50)

SELECT @Sep = CHARINDEX('\', @InstanceName)

IF @Sep > 0
  BEGIN
  SELECT @BoxNm = SUBSTRING(@InstanceName, 1, @Sep - 1), @InstNm = SUBSTRING(@InstanceName, @Sep + 1, (LEN(@InstanceName) - @Sep))
  END
ELSE
  BEGIN
  SELECT @BoxNm = @InstanceName, @InstNm = 'MSSQLSERVER'
  END

SELECT CONVERT(char(10), s.[PerfDate], 101) as PerfDate
      ,CONVERT(char(8), s.[PerfDate], 108) as PerfTime
      ,s.[PctProc]
      ,i.[BatReqSec]
      ,i.[BufCchHit]
      ,i.[PgLifeExp]
FROM [Analysis].[ServerStats] s
INNER JOIN [Analysis].[InstanceStats] i
ON s.[ServerID] = i.[ServerID]
WHERE s.ServerNm = @BoxNm
AND i.ServerNm = @BoxNm
AND i.InstanceNm = @InstNm
AND s.[PerfDate] > DATEADD(dd, -35, GETDATE())
ORDER BY CONVERT(Date,s.[PerfDate]) DESC, PerfTime ASC
GO

CREATE PROCEDURE [Analysis].[selPerformanceAnalysisReport] (@InstanceName varchar(50), @PerfDate DATETIME)
AS
SET NOCOUNT ON

DECLARE @Sep INT, @BoxNm VARCHAR(50), @InstNm VARCHAR(50)

SELECT @Sep = CHARINDEX('\', @InstanceName)

IF @Sep > 0
  BEGIN
  SELECT @BoxNm = SUBSTRING(@InstanceName, 1, @Sep - 1), @InstNm = SUBSTRING(@InstanceName, @Sep + 1, (LEN(@InstanceName) - @Sep))
  END
ELSE
  BEGIN
  SELECT @BoxNm = @InstanceName, @InstNm = 'MSSQLSERVER'
  END

SELECT CONVERT(char(8), s.[PerfDate], 108) as PerfTime
      ,s.[ServerNm]
      ,i.[InstanceNm]
      ,s.[PctProc]
      ,s.[Memory]
      ,s.[PgFilUse]
      ,s.[DskSecRd]
      ,s.[DskSecWrt]
      ,s.[ProcQueLn]
      ,i.[FwdRecSec]
      ,i.[PgSpltSec]
      ,i.[BufCchHit]
      ,i.[PgLifeExp]
      ,i.[LogGrwths]
      ,i.[BlkProcs]
      ,i.[BatReqSec]
      ,i.[SQLCompSec]
      ,i.[SQLRcmpSec]
FROM [Analysis].[ServerStats] s
INNER JOIN [Analysis].[InstanceStats] i
ON s.[ServerID] = i.[ServerID]
WHERE s.ServerNm = @BoxNm
AND i.ServerNm = @BoxNm
AND i.InstanceNm = @InstNm
AND s.[PerfDate] BETWEEN @PerfDate AND DATEADD(DAY,1,@PerfDate)
GO
