/*============================================================================
  File:     02a_CrossDB.sql

  SQL Server Versions: 2016+, Azure SQLDB
------------------------------------------------------------------------------
  Written by Erin Stellato, SQLskills.com
  
  (c) 2021, SQLskills.com. All rights reserved.

  For more scripts and sample code, check out 
    http://www.SQLskills.com

  You may alter this code for your own *non-commercial* purposes. You may
  republish altered code as long as you include this copyright and give due
  credit, but you must obtain prior permission before blogging this code.
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

/*
	Create the "MAIN" database 
*/
DROP DATABASE IF EXISTS [MAINMovies];
GO

CREATE DATABASE [MAINMovies]
	ON  PRIMARY 
	(NAME = N'Movies', FILENAME = N'C:\Databases\Movies\MainMovies.mdf' , 
	SIZE = 262144KB , FILEGROWTH = 65536KB )
	LOG ON 
	(NAME = N'Movies_log', FILENAME = N'C:\Databases\Movies\MainMovies_log.ldf' , 
	SIZE = 131072KB , FILEGROWTH = 65536KB );
GO

ALTER DATABASE [MAINMovies] SET RECOVERY SIMPLE;
GO

/*
	Enable Query Store 
*/
USE [master];
GO
ALTER DATABASE [MAINMovies] SET QUERY_STORE (
	OPERATION_MODE = READ_WRITE,
	CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30),  
	DATA_FLUSH_INTERVAL_SECONDS = 60,
	INTERVAL_LENGTH_MINUTES = 10,
	MAX_STORAGE_SIZE_MB = 512,
	QUERY_CAPTURE_MODE = ALL,
	SIZE_BASED_CLEANUP_MODE = AUTO,
	MAX_PLANS_PER_QUERY = 200);
GO


/*
	Create DB1 database 
*/
DROP DATABASE IF EXISTS [DB1_Movies];
GO

CREATE DATABASE [DB1_Movies]
	ON  PRIMARY 
	(NAME = N'Movies', FILENAME = N'C:\Databases\Movies\DB1_Movies.mdf' , 
	SIZE = 262144KB , FILEGROWTH = 65536KB )
	LOG ON 
	(NAME = N'Movies_log', FILENAME = N'C:\Databases\Movies\DB1_Movies_log.ldf' , 
	SIZE = 131072KB , FILEGROWTH = 65536KB );
GO

ALTER DATABASE [DB1_Movies] SET RECOVERY SIMPLE;
GO

/*
	Create tables and add data
*/
USE [DB1_Movies];
GO

CREATE TABLE [dbo].[MovieInfo] (
	[MovieID] INT IDENTITY(1,1) PRIMARY KEY, 
	[MovieName] VARCHAR(800), 
	[ReleaseDate] SMALLDATETIME,
	[Rating] VARCHAR(5)
	);
GO

INSERT INTO [dbo].[MovieInfo] ( 
	[MovieName], [ReleaseDate], [Rating]
	)
VALUES
	('IronMan', '2008-05-02 00:00:00', 'PG-13'),
	('Joy', '2016-12-25', 'PG-13'),
	('Caddyshack', '1980-07-25', 'R'),
	('The Martian', '2015-10-02', 'PG-13'),
	('Apollo 13', '1995-05-30 00:00:00', 'PG'),
	('The Hunt for Red October', '1990-03-02 00:00:00', 'PG'),
	('A Few Good Men', '1994-12-11 00:00:00', 'R'),
	('Memento', '2000-10-11', 'R'),
	('The Truman Show', '1998-06-05 00:00:00', 'PG-13'),
	('All The President''s Men', '1976-04-09 00:00:00', 'R'),
	('The Right Stuff', '1983-10-21 00:00:00', 'PG-13'),
	('The Blind Side', '2009-11-20', 'PG-13'),
	('The Natural', '1984-05-11 00:00:00', 'PG'),
	('The Hangover', '2009-06-05 00:00:00', 'R'),
	('The Incredibles', '2004-11-05 00:00:00', 'PG');
GO


CREATE TABLE [dbo].[Actors](
	[ActorID] INT IDENTITY(1,1) PRIMARY KEY, 
	[FirstName] VARCHAR(100), 
	[LastName] VARCHAR(200),
	[DOB] SMALLDATETIME
	);
GO

INSERT INTO [dbo].[Actors](
	[FirstName], [LastName], [DOB]
	)
VALUES
	('Jennifer', 'Lawrence', '1990-08-15'),
	('Robert', 'Redford', '1936-08-18'),
	('Demi', 'Moore', '1962-11-11'),
	('Alec', 'Baldwin', '1958-01-03'),
	('Sandra', 'Bullock', '1964-07-26'),
	('Tom', 'Hanks', '1956-07-09');
GO

CREATE TABLE [dbo].[Cast](
	[MovieID] INT,
	[ActorID] INT
	);
GO

INSERT INTO [dbo].[Cast](
	[MovieID], [ActorID])
VALUES
	(2, 1),
	(10, 2),
	(13, 2),
	(7, 3),
	(6, 4),
	(12, 5),
	(5, 6);
GO


/*
	Create DB2 database 
*/
DROP DATABASE IF EXISTS [DB2_Movies];
GO

CREATE DATABASE [DB2_Movies]
	ON  PRIMARY 
	(NAME = N'Movies', FILENAME = N'C:\Databases\Movies\DB2_Movies.mdf' , 
	SIZE = 262144KB , FILEGROWTH = 65536KB )
	LOG ON 
	(NAME = N'Movies_log', FILENAME = N'C:\Databases\Movies\DB2_Movies_log.ldf' , 
	SIZE = 131072KB , FILEGROWTH = 65536KB );
GO

ALTER DATABASE [DB2_Movies] SET RECOVERY SIMPLE;
GO

/*
	Create tables and add data
*/
USE [DB2_Movies];
GO

CREATE TABLE [dbo].[OTHERMovieInfo] (
	[MovieID] INT IDENTITY(1,1) PRIMARY KEY, 
	[MovieName] VARCHAR(800), 
	[ReleaseDate] SMALLDATETIME,
	[Rating] VARCHAR(5)
	);
GO

INSERT INTO [dbo].[OTHERMovieInfo] ( 
	[MovieName], [ReleaseDate], [Rating]
	)
VALUES
	('IronMan', '2008-05-02 00:00:00', 'PG-13'),
	('Joy', '2016-12-25', 'PG-13'),
	('Caddyshack', '1980-07-25', 'R'),
	('The Martian', '2015-10-02', 'PG-13'),
	('Apollo 13', '1995-05-30 00:00:00', 'PG'),
	('The Hunt for Red October', '1990-03-02 00:00:00', 'PG'),
	('A Few Good Men', '1994-12-11 00:00:00', 'R'),
	('Memento', '2000-10-11', 'R'),
	('The Truman Show', '1998-06-05 00:00:00', 'PG-13'),
	('All The President''s Men', '1976-04-09 00:00:00', 'R'),
	('The Right Stuff', '1983-10-21 00:00:00', 'PG-13'),
	('The Blind Side', '2009-11-20', 'PG-13'),
	('The Natural', '1984-05-11 00:00:00', 'PG'),
	('The Hangover', '2009-06-05 00:00:00', 'R'),
	('The Incredibles', '2004-11-05 00:00:00', 'PG');
GO


CREATE TABLE [dbo].[OTHERActors](
	[ActorID] INT IDENTITY(1,1) PRIMARY KEY, 
	[FirstName] VARCHAR(100), 
	[LastName] VARCHAR(200),
	[DOB] SMALLDATETIME
	);
GO

INSERT INTO [dbo].[OTHERActors](
	[FirstName], [LastName], [DOB]
	)
VALUES
	('Jennifer', 'Lawrence', '1990-08-15'),
	('Robert', 'Redford', '1936-08-18'),
	('Demi', 'Moore', '1962-11-11'),
	('Alec', 'Baldwin', '1958-01-03'),
	('Sandra', 'Bullock', '1964-07-26'),
	('Tom', 'Hanks', '1956-07-09');
GO

CREATE TABLE [dbo].[OTHERCast](
	[MovieID] INT,
	[ActorID] INT
	);
GO

INSERT INTO [dbo].[OTHERCast](
	[MovieID], [ActorID])
VALUES
	(2, 1),
	(10, 2),
	(13, 2),
	(7, 3),
	(6, 4),
	(12, 5),
	(5, 6);
GO



/*
	Create SP inthe MAINMovies DB against DB1 and DB2
*/
USE [MAINMovies];
GO

CREATE PROCEDURE dbo.MovieData @Date DATETIME
AS
BEGIN
	SELECT m.*, c.*
	FROM [DB1_Movies].[dbo].[MovieInfo] m
	JOIN [DB2_Movies].[dbo].[OTHERCast] c
		ON m.MovieID = c.MovieID
	WHERE m.[ReleaseDate] >= @Date;
END

USE DB1_Movies;
GO
EXECUTE MAINMovies.dbo.MovieData '2001-01-01'
GO 10


/*
	What do we get from the system views?
	Notice any interesting queries in the query text?
*/
USE [MAINMovies];
GO

SELECT *
FROM [sys].[query_store_query_text]
ORDER BY [query_text_id] DESC;
GO

SELECT *
FROM [sys].[query_store_query]
ORDER BY [query_text_id] DESC;
GO


/*
	Change context
*/
USE [MAINMovies];
GO
EXECUTE MAINMovies.dbo.MovieData '2001-01-01'
GO 10


USE [DB2_Movies];
GO

CREATE PROCEDURE dbo.DB2_MovieData @Date DATETIME
AS
BEGIN
	SELECT m.*, c.*
	FROM [DB1_Movies].[dbo].[MovieInfo] m
	JOIN [DB2_Movies].[dbo].[OTHERCast] c
		ON m.MovieID = c.MovieID
	WHERE m.[ReleaseDate] >= @Date;
END

USE [MAINMovies];
GO
EXECUTE DB2_Movies.dbo.DB2_MovieData '2001-01-01'
GO 10

/*
	Clean up
*/
USE [master];
GO
DROP DATABASE [MAINMovies];
GO
DROP DATABASE [DB1_Movies];
GO
DROP DATABASE [DB2_Movies];
GO