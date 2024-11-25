-- Raw examination of schedulers
-- Remember to show 'quantum length' column
SELECT * FROM sys.dm_os_schedulers;
GO

-- What's happening right now?
SELECT
	[ot].[scheduler_id],
	[task_state],
	COUNT (*) AS [task_count]
FROM
	sys.dm_os_tasks AS [ot]
INNER JOIN
	sys.dm_exec_requests AS [er]
    ON [ot].[session_id] = [er].[session_id]
INNER JOIN
	sys.dm_exec_sessions AS [es]
    ON [er].[session_id] = [es].[session_id]
WHERE
	[es].[is_user_process] = 1
GROUP BY
	[ot].[scheduler_id],
	[task_state]
ORDER BY
	[ot].[scheduler_id],
	[task_state];
GO

-- Now set up the demo by running the code in the
-- SetupWorkload.sql file

-- Now start the workload by double-clicking the
-- Add50Clients.cmd

SELECT
	[ot].[scheduler_id],
	[task_state],
	COUNT (*) AS [task_count]
FROM
	sys.dm_os_tasks AS [ot]
INNER JOIN
	sys.dm_exec_requests AS [er]
    ON [ot].[session_id] = [er].[session_id]
INNER JOIN
	sys.dm_exec_sessions AS [es]
    ON [er].[session_id] = [es].[session_id]
WHERE
	[es].[is_user_process] = 1
GROUP BY
	[ot].[scheduler_id],
	[task_state]
ORDER BY
	[ot].[scheduler_id],
	[task_state];
GO

-- Now stop the workload by double-clicking the
-- StopWorkload.cmd

USE [master];
GO

IF DATABASEPROPERTYEX (N'HotSpot', N'Version') > 0
BEGIN
	ALTER DATABASE [HotSpot] SET SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [HotSpot];
END
GO