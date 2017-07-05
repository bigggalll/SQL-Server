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
	create event session
*/
CREATE EVENT SESSION [Capture Auto Stats Updates] 
	ON SERVER 
	ADD EVENT sqlserver.auto_stats(
		ACTION(
			sqlserver.client_app_name,
			sqlserver.server_principal_name
			)
		) 
ADD TARGET package0.event_file(SET filename=N'C:\temp\CaptureAutoStatsUpdates.xel')
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,
MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF)

/*
	start event session
*/
ALTER EVENT SESSION [Capture Auto Stats Updates] 
	ON SERVER
	STATE = START


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
	run a query that creates a column statistic
*/
SELECT [nameFirst], [nameLast], [debut]
FROM [dbo].[PlayerInfo] WHERE [finalGame] IS NULL;


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
	stop event session
*/
ALTER EVENT SESSION [Capture Auto Stats Updates] 
	ON SERVER
	STATE = STOP;

/*
	load the XE data into a table
	open the .xel file in SSMS
	select Extended Events | Export To | Table
	select the BaseballData database and name the table xe
*/


/*
	check to see what creates/updates occurred
*/
SELECT [d].[name] [Database], [tb].[name] [Table], [i].[name] [Index], [x].[statistics_list], [x].[timestamp], [x].[duration], [x].[client_app_name], [x].[server_principal_name]
FROM [dbo].[xe] x
JOIN [sys].[databases] d ON [x].[database_id] = [d].[database_id]
JOIN [sys].[tables] tb ON [x].[object_id] = [tb].[object_id]
LEFT OUTER JOIN [sys].[indexes] i ON [x].[index_id] = [i].[index_id] AND [tb].[object_id] = [i].[object_id]


/*
	clean up
*/
DROP TABLE [dbo].[PlayerInfo];
DROP TABLE [dbo].[xe];
DROP EVENT SESSION [Capture Auto Stats Updates] 
	ON SERVER;