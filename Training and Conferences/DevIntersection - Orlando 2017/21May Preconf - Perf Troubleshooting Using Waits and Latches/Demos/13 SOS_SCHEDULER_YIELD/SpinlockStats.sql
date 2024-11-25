/*============================================================================
  File:     SpinlockStats.sql

  Summary:  Examine spinlock stats

  SQL Server Versions: 2005 onwards
------------------------------------------------------------------------------
  Written by Paul S. Randal, SQLskills.com

  (c) 2016, SQLskills.com. All rights reserved.

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

-- SELECT * FROM sys.dm_os_spinlock_stats ORDER BY [spins] DESC;

IF EXISTS (SELECT * FROM [tempdb].[sys].[objects]
	WHERE [name] = N'##TempSpinlockStats1')
	DROP TABLE [##TempSpinlockStats1];

IF EXISTS (SELECT * FROM [tempdb].[sys].[objects]
	WHERE [name] = N'##TempSpinlockStats2')
	DROP TABLE [##TempSpinlockStats2];
GO

-- Baseline
SELECT * INTO [##TempSpinlockStats1]
FROM sys.dm_os_spinlock_stats
WHERE [collisions] > 0
ORDER BY [name];
GO

-- Now wait...
WAITFOR DELAY '00:00:05';
GO

-- Capture updated stats
SELECT * INTO [##TempSpinlockStats2]
FROM sys.dm_os_spinlock_stats
WHERE [collisions] > 0
ORDER BY [name];
GO

-- Diff them
SELECT
		'***' AS [New],
		[ts2].[name] AS [Spinlock],
		[ts2].[collisions] AS [DiffCollisions],
		[ts2].[spins] AS [DiffSpins],
		[ts2].[spins_per_collision] AS [SpinsPerCollision],
		[ts2].[sleep_time] AS [DiffSleepTime],
		[ts2].[backoffs] AS [DiffBackoffs]
	FROM [##TempSpinlockStats2] [ts2]
	LEFT OUTER JOIN [##TempSpinlockStats1] [ts1]
		ON [ts2].[name] = [ts1].[name]
	WHERE [ts1].[name] IS NULL
UNION
SELECT
		'' AS [New],
		[ts2].[name] AS [Spinlock],
		[ts2].[collisions] - [ts1].[collisions] AS [DiffCollisions],
		[ts2].[spins] - [ts1].[spins] AS [DiffSpins],
		CASE ([ts2].[spins] - [ts1].[spins]) WHEN 0 THEN 0
			ELSE ([ts2].[spins] - [ts1].[spins]) /
				([ts2].[collisions] - [ts1].[collisions]) END
				AS [SpinsPerCollision],
		[ts2].[sleep_time] - [ts1].[sleep_time] AS [DiffSleepTime],
		[ts2].[backoffs] - [ts1].[backoffs] AS [DiffBackoffs]
	FROM [##TempSpinlockStats2] [ts2]
	LEFT OUTER JOIN [##TempSpinlockStats1] [ts1]
		ON [ts2].[name] = [ts1].[name]
	WHERE [ts1].[name] IS NOT NULL
	AND [ts2].[collisions] - [ts1].[collisions] > 0
ORDER BY [New] DESC, [Spinlock] ASC;
GO
