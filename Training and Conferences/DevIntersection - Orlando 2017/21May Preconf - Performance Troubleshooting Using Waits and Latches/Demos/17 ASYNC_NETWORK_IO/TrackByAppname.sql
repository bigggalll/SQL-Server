-- Lookup the MapKey for the NETWORK_IO Wait Type
SELECT map_key, map_value
FROM sys.dm_xe_map_values
WHERE map_value = N'NETWORK_IO'
  AND name = N'wait_types';
GO  

-- If the event session exists drop it
IF EXISTS (SELECT 1 
			FROM sys.server_event_sessions 
			WHERE name = N'TrackNetworkWaits_AppName')
	DROP EVENT SESSION [TrackNetworkWaits_AppName] 
	ON SERVER;
GO

-- Create event session to track network waits by application
CREATE EVENT SESSION [TrackNetworkWaits_AppName]
ON SERVER 
ADD EVENT sqlos.wait_info
(
    ACTION (sqlserver.client_app_name)
    WHERE
        (opcode = 1 -- End Events Only
            AND duration > 0 AND (wait_type = 99) -- Network waits
		)            
)
ADD TARGET package0.histogram (
	SET filtering_event_name = N'sqlos.wait_info',
		source_type = 1, -- Action
		source = N'sqlserver.client_app_name');
GO

-- Start the Event Session
ALTER EVENT SESSION [TrackNetworkWaits_AppName] 
ON SERVER 
STATE=START;
GO

-- What is the worst Application out there for this? How about SSMS!
SELECT * 
FROM SalesDB.dbo.Sales
WHERE [SalesID] < 100000;
GO 10

-- Query target data
SELECT 
    n.value ('(value)[1]', 'nvarchar(4000)') AS AppName,
    n.value ('(@count)[1]', 'int') AS NetworkWaitCount
FROM
(
	SELECT CAST(target_data as XML) target_data
	FROM sys.dm_xe_sessions AS s 
	JOIN sys.dm_xe_session_targets t
		ON s.address = t.event_session_address
	WHERE s.name = N'TrackNetworkWaits_AppName'
		AND t.target_name = N'histogram'
) AS tab
CROSS APPLY target_data.nodes('HistogramTarget/Slot') as q(n)
ORDER BY AppName;
GO

-- Drop the Event Session
DROP EVENT SESSION [TrackNetworkWaits_AppName]
ON SERVER;
GO