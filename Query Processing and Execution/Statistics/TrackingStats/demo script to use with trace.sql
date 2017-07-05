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
	start a SQL Trace
	note the TraceID that is output
	*note: you may want to change the trace file 
	output location: C:\temp\autoupdates
*/
-- Create a Queue
declare @rc int
declare @TraceID int
declare @maxfilesize bigint
set @maxfilesize = 100 

-- Replace C:\temp\autoupdates with an appropriate path

exec @rc = sp_trace_create @TraceID output, 0, N'C:\temp\autoupdates', @maxfilesize, NULL 
if (@rc != 0) goto error

-- Set the events
declare @on bit
set @on = 1
exec sp_trace_setevent @TraceID, 58, 1, @on
exec sp_trace_setevent @TraceID, 58, 3, @on
exec sp_trace_setevent @TraceID, 58, 11, @on
exec sp_trace_setevent @TraceID, 58, 10, @on
exec sp_trace_setevent @TraceID, 58, 12, @on
exec sp_trace_setevent @TraceID, 58, 13, @on
exec sp_trace_setevent @TraceID, 58, 14, @on
exec sp_trace_setevent @TraceID, 58, 15, @on
exec sp_trace_setevent @TraceID, 58, 22, @on
exec sp_trace_setevent @TraceID, 58, 24, @on
exec sp_trace_setevent @TraceID, 58, 60, @on


-- Set the Filters
declare @intfilter int
declare @bigintfilter bigint

-- Set the trace status to start
exec sp_trace_setstatus @TraceID, 1

-- display trace id for future references
select TraceID=@TraceID
goto finish

error: 
select ErrorCode=@rc

finish: 
go



/*
	trace is now running
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
	stop the trace and remove the trace definition
	note that the statements below assume a TraceID of 2
	change the first integer to your TraceID if it is not 2
*/
exec sp_trace_setstatus 2, 0
exec sp_trace_setstatus 2, 2



/*
	load the trace data into a table
	change the location of the trace file if necessary
*/
SELECT IDENTITY(int, 1, 1) AS RowNumber, * 
INTO [dbo].[trace]
FROM fn_trace_gettable('C:\temp\autoupdates.trc', 1)

/*
	check to see what creates/updates occurred
*/
SELECT [d].[name] [Database], [tb].[name] [Table], [i].[name] [Index], [tr].[TextData], [tr].[StartTime], [tr].[EndTime], [tr].[Duration], [tr].[ApplicationName], [tr].[LoginName]
FROM [dbo].[trace] tr
JOIN [sys].[databases] d ON [tr].[DatabaseID] = [d].[database_id]
JOIN [sys].[tables] tb ON [tr].[ObjectID] = [tb].[object_id]
LEFT OUTER JOIN [sys].[indexes] i ON [tr].[IndexID] = [i].[index_id] AND [tb].[object_id] = [i].[object_id]
WHERE [EventClass] = 58


/*
	clean up
*/
DROP TABLE [dbo].[PlayerInfo];
DROP TABLE [dbo].[trace];