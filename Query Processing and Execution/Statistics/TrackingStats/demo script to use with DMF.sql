USE [BaseballData];
GO

/*
	ensure Auto Create and Auto Update are enabled
*/
ALTER DATABASE [BaseballData] SET AUTO_CREATE_STATISTICS ON;
GO

ALTER DATABASE [BaseballData] SET AUTO_UPDATE_STATISTICS ON;
GO

/*
	create table to hold stats data
*/
CREATE TABLE [dbo].[CaptureStats](
	[CaptureDate] [datetime2] NOT NULL,
	[TableName] [nvarchar](257) NOT NULL,
	[Index ID] [int] NULL,
	[Statistic] [nvarchar](128) NULL,
	[StatsLastUpdated] [datetime2](7) NULL,
	[RowsInTable] [bigint] NULL,
	[RowsSampled] [bigint] NULL,
	[UnfilteredRows] [bigint] NULL,
	[RowModifications] [bigint] NULL
) ON [PRIMARY];


ALTER TABLE [dbo].[CaptureStats] ADD CONSTRAINT [default_CaptureDate] DEFAULT SYSDATETIME() FOR [CaptureDate];


/* 
	create dbo.PlayerInfo as a COPY of dbo.players 
*/
SELECT TOP 0 * 
	INTO [dbo].[PlayerInfo] 
	FROM [dbo].[players];


/*
	create a clustered index for the table
*/
CREATE UNIQUE CLUSTERED INDEX [CI_PlayerInfo_ID] 
	ON [dbo].[PlayerInfo]([lahmanID]);


/*
	create a non-clustered index for the table
*/
CREATE NONCLUSTERED INDEX [IX_PlayerInfo_nameLast_nameFirst] 
	ON [dbo].[PlayerInfo]([nameLast],[nameFirst]);


/*
	capture stats
*/
INSERT INTO [dbo].[CaptureStats] (
	[TableName],
	[Index ID],
	[Statistic],
	[StatsLastUpdated],
	[RowsInTable],
	[RowsSampled],
	[UnfilteredRows],
	[RowModifications])
SELECT  
	[sch].[name] + '.' + [so].[name] [TableName],
	[si].[index_id] [Index ID],
	[ss].[name] [Statistic],
	[sp].[last_updated] AS [StatsLastUpdated],
	[sp].[rows] AS [RowsInTable] ,
	[sp].[rows_sampled] AS [RowsSampled],
	[sp].[unfiltered_rows] AS [UnfilteredRows],
	[sp].[modification_counter] AS [RowModifications]
FROM [sys].[stats] [ss]
JOIN [sys].[objects] [so] 
	ON [ss].[object_id] = [so].[object_id]
JOIN [sys].[schemas] [sch] 
	ON [so].[schema_id] = [sch].[schema_id]
LEFT OUTER JOIN [sys].[indexes] [si] 
	ON [so].[object_id] = [si].[object_id]
	AND [ss].[name] = [si].[name]
OUTER APPLY [sys].[dm_db_stats_properties]([so].[object_id],[ss].[stats_id]) sp
WHERE [so].[object_id] = OBJECT_ID(N'dbo.PlayerInfo')
ORDER BY [ss].[user_created], [ss].[auto_created], [ss].[has_filter];

/*
	load a few rows of data
*/
INSERT INTO [dbo].[PlayerInfo]
	(lahmanID, playerID, managerID, hofID, birthYear, birthMonth, birthDay, birthCountry, 
	birthState, birthCity, deathYear, deathMonth, deathDay, deathCountry, deathState, deathCity, 
	nameFirst, nameLast, nameNote, nameGiven, nameNick, [weight], height, bats, throws, debut, 
	finalGame, college, lahman40ID, lahman45ID, retroID, holtzID, bbrefID)
	SELECT
		lahmanID, playerID, managerID, hofID, birthYear, birthMonth, birthDay, birthCountry, 
		birthState, birthCity, deathYear, deathMonth, deathDay, deathCountry, deathState, deathCity, 
		nameFirst, nameLast, nameNote, nameGiven, nameNick, [weight], height, bats, throws, debut, 
		finalGame, college, lahman40ID, lahman45ID, retroID, holtzID, bbrefID
	FROM [dbo].[players]
	where nameFirst = 'Ted';
GO


/*
	run a query that uses the NCI
*/
SELECT [nameFirst], [nameLast]
FROM [dbo].[PlayerInfo] WHERE [nameLast] = 'Williams';


/*
	capture stats
*/
INSERT INTO [dbo].[CaptureStats] (
	[TableName],
	[Index ID],
	[Statistic],
	[StatsLastUpdated],
	[RowsInTable],
	[RowsSampled],
	[UnfilteredRows],
	[RowModifications])
SELECT  
	[sch].[name] + '.' + [so].[name] [TableName],
	[si].[index_id] [Index ID],
	[ss].[name] [Statistic],
	[sp].[last_updated] AS [StatsLastUpdated],
	[sp].[rows] AS [RowsInTable] ,
	[sp].[rows_sampled] AS [RowsSampled],
	[sp].[unfiltered_rows] AS [UnfilteredRows],
	[sp].[modification_counter] AS [RowModifications]
FROM [sys].[stats] [ss]
JOIN [sys].[objects] [so] 
	ON [ss].[object_id] = [so].[object_id]
JOIN [sys].[schemas] [sch] 
	ON [so].[schema_id] = [sch].[schema_id]
LEFT OUTER JOIN [sys].[indexes] [si] 
	ON [so].[object_id] = [si].[object_id]
	AND [ss].[name] = [si].[name]
OUTER APPLY [sys].[dm_db_stats_properties]([so].[object_id],[ss].[stats_id]) sp
WHERE [so].[object_id] = OBJECT_ID(N'dbo.PlayerInfo')
ORDER BY [ss].[user_created], [ss].[auto_created], [ss].[has_filter];

/*
	run a query that creates a column statistic
*/
SELECT [nameFirst], [nameLast], [debut]
FROM [dbo].[PlayerInfo] WHERE [finalGame] IS NULL;


/*
	capture stats
*/
INSERT INTO [dbo].[CaptureStats] (
	[TableName],
	[Index ID],
	[Statistic],
	[StatsLastUpdated],
	[RowsInTable],
	[RowsSampled],
	[UnfilteredRows],
	[RowModifications])
SELECT  
	[sch].[name] + '.' + [so].[name] [TableName],
	[si].[index_id] [Index ID],
	[ss].[name] [Statistic],
	[sp].[last_updated] AS [StatsLastUpdated],
	[sp].[rows] AS [RowsInTable] ,
	[sp].[rows_sampled] AS [RowsSampled],
	[sp].[unfiltered_rows] AS [UnfilteredRows],
	[sp].[modification_counter] AS [RowModifications]
FROM [sys].[stats] [ss]
JOIN [sys].[objects] [so] 
	ON [ss].[object_id] = [so].[object_id]
JOIN [sys].[schemas] [sch] 
	ON [so].[schema_id] = [sch].[schema_id]
LEFT OUTER JOIN [sys].[indexes] [si] 
	ON [so].[object_id] = [si].[object_id]
	AND [ss].[name] = [si].[name]
OUTER APPLY [sys].[dm_db_stats_properties]([so].[object_id],[ss].[stats_id]) sp
WHERE [so].[object_id] = OBJECT_ID(N'dbo.PlayerInfo')
ORDER BY [ss].[user_created], [ss].[auto_created], [ss].[has_filter];


/*
	load the rest of the data
*/
INSERT INTO [dbo].[PlayerInfo]
	(lahmanID, playerID, managerID, hofID, birthYear, birthMonth, birthDay, birthCountry, 
	birthState, birthCity, deathYear, deathMonth, deathDay, deathCountry, deathState, deathCity, 
	nameFirst, nameLast, nameNote, nameGiven, nameNick, [weight], height, bats, throws, debut, 
	finalGame, college, lahman40ID, lahman45ID, retroID, holtzID, bbrefID)
	SELECT
		lahmanID, playerID, managerID, hofID, birthYear, birthMonth, birthDay, birthCountry, 
		birthState, birthCity, deathYear, deathMonth, deathDay, deathCountry, deathState, deathCity, 
		nameFirst, nameLast, nameNote, nameGiven, nameNick, [weight], height, bats, throws, debut, 
		finalGame, college, lahman40ID, lahman45ID, retroID, holtzID, bbrefID
	FROM [dbo].[players]
	where nameFirst <> 'Ted';

/*
	re-run the query
*/
SELECT [nameFirst], [nameLast], [debut]
FROM [dbo].[PlayerInfo] WHERE [finalGame] IS NULL;


/*
	capture stats
*/
INSERT INTO [dbo].[CaptureStats] (
	[TableName],
	[Index ID],
	[Statistic],
	[StatsLastUpdated],
	[RowsInTable],
	[RowsSampled],
	[UnfilteredRows],
	[RowModifications])
SELECT  
	[sch].[name] + '.' + [so].[name] [TableName],
	[si].[index_id] [Index ID],
	[ss].[name] [Statistic],
	[sp].[last_updated] AS [StatsLastUpdated],
	[sp].[rows] AS [RowsInTable] ,
	[sp].[rows_sampled] AS [RowsSampled],
	[sp].[unfiltered_rows] AS [UnfilteredRows],
	[sp].[modification_counter] AS [RowModifications]
FROM [sys].[stats] [ss]
JOIN [sys].[objects] [so] 
	ON [ss].[object_id] = [so].[object_id]
JOIN [sys].[schemas] [sch] 
	ON [so].[schema_id] = [sch].[schema_id]
LEFT OUTER JOIN [sys].[indexes] [si] 
	ON [so].[object_id] = [si].[object_id]
	AND [ss].[name] = [si].[name]
OUTER APPLY [sys].[dm_db_stats_properties]([so].[object_id],[ss].[stats_id]) sp
WHERE [so].[object_id] = OBJECT_ID(N'dbo.PlayerInfo')
ORDER BY [ss].[user_created], [ss].[auto_created], [ss].[has_filter];



/*
	check to see what creates/updates occurred
*/
SELECT *
FROM [dbo].[CaptureStats]
ORDER BY [TableName], [Index ID], [Statistic], [CaptureDate]


 
/*
	clean up
*/
DROP TABLE [dbo].[PlayerInfo];
DROP TABLE [dbo].[CaptureStats];