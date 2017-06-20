-- Drop the session if it exists. 
IF EXISTS (SELECT * FROM sys.server_event_sessions WHERE name = 'MonitorWaits')
    DROP EVENT SESSION MonitorWaits ON SERVER
GO

CREATE EVENT SESSION MonitorWaits ON SERVER
ADD EVENT sqlos.wait_info
    (WHERE sqlserver.session_id = 329 /* session_id of connection to monitor */)
ADD TARGET package0.asynchronous_file_target
    (SET FILENAME = N'C:\temp\EE_WaitStats.xel', 
    METADATAFILE = N'C:\temp\EE_WaitStats.xem')
WITH (max_dispatch_latency = 1 seconds);
GO

-- Start the session
ALTER EVENT SESSION MonitorWaits ON SERVER STATE = START;
GO

-- Go do the query

-- Stop the event session
ALTER EVENT SESSION MonitorWaits ON SERVER STATE = STOP;
GO

SELECT COUNT (*)
FROM sys.fn_xe_file_target_read_file
    ('C:\temp\EE_WaitStats*.xel',
    'C:\temp\EE_WaitStats*.xem', null, null);
GO

-- Create intermediate temp table for raw event data
CREATE TABLE #RawEventData (
    Rowid  INT IDENTITY PRIMARY KEY,
    event_data XML);
 
GO

-- Read the file data into intermediate temp table
INSERT INTO #RawEventData (event_data)
SELECT
    CAST (event_data AS XML) AS event_data
FROM sys.fn_xe_file_target_read_file (
    'C:\temp\EE_WaitStats*.xel',
    'C:\temp\EE_WaitStats*.xem', null, null);
GO

SELECT
    waits.[Wait Type],
    COUNT (*) AS [Wait Count],
    SUM (waits.[Duration]) AS [Total Wait Time (ms)],
    SUM (waits.[Duration]) - SUM (waits.[Signal Duration]) AS [Total Resource Wait Time (ms)],
    SUM (waits.[Signal Duration]) AS [Total Signal Wait Time (ms)]
FROM 
    (SELECT
        event_data.value ('(/event/@timestamp)[1]', 'DATETIME') AS [Time],
        event_data.value ('(/event/data[@name=''wait_type'']/text)[1]', 'VARCHAR(100)') AS [Wait Type],
        event_data.value ('(/event/data[@name=''opcode'']/text)[1]', 'VARCHAR(100)') AS [Op],
        event_data.value ('(/event/data[@name=''duration'']/value)[1]', 'BIGINT') AS [Duration],
        event_data.value ('(/event/data[@name=''signal_duration'']/value)[1]', 'BIGINT') AS [Signal Duration]
     FROM #RawEventData
    ) AS waits
WHERE waits.[Op] = 'End'
GROUP BY waits.[Wait Type]
ORDER BY [Total Wait Time (ms)] DESC;
GO

-- Cleanup
DROP TABLE #RawEventData;
GO

