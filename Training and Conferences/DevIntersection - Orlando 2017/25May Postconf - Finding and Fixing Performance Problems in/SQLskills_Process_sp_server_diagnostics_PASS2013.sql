/*============================================================================
  File:     SQLskills_Process_sp_server_diagnostics.sql

  Summary:  This script queries the system_health event session files and
            parses the sp_server_diagnostics event output entries and other
            critical events into tables based on the parameters that are set
            at the start of the script.

  Date:     February 2013

  SQL Server Versions:
	2012 SP1
------------------------------------------------------------------------------
  Created by: Jonathan Kehayias, SQLskills.com

  For more scripts and sample code, check out 
    http://www.SQLskills.com

  You may alter this code for your own *non-commercial* purposes. You may
  republish altered code as long as you give due credit.
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/


-- A quick lesson on XML parsing performance
DECLARE @Filename VARCHAR(255) = N'C:\Shares\SQL01\system_health*.xel';

SELECT 
	eventname,
	COUNT(*)
FROM (	SELECT
			event_data.value('(event/@name)[1]', 'VARCHAR(50)') AS eventname
		FROM (
			-- Cast the target_data to XML
			SELECT CAST(event_data AS XML) AS event_data
			FROM sys.fn_xe_file_target_read_file(@Filename, null, null, null)
			-- Trust me on this! I'll explain
			--WHERE event_data NOT LIKE '%security_error_ring_buffer_recorded%'
			) AS sub
) AS tab
GROUP BY eventname;
GO


-- Read all of the available files INTo a temporary table for processing
IF OBJECT_ID(N'tempdb..#results') IS NOT NULL
	DROP TABLE #results;

CREATE TABLE #results
(RowID INT IDENTITY PRIMARY KEY,
 event_data XML);

DECLARE @Filename VARCHAR(255) = N'C:\Shares\SQL01\system_health*.xel';

INSERT INTO #results (event_data)
-- Cast the target_data to XML
SELECT CAST(event_data AS XML) AS event_data
FROM sys.fn_xe_file_target_read_file(@Filename, null, null, null)
-- Filter out security issues for now....
--WHERE event_data NOT LIKE '%security_error_ring_buffer_recorded%';


/* Count each event captured */
SELECT 
	eventname,
	COUNT(*)
FROM (	SELECT
			event_data.value('(event/@name)[1]', 'VARCHAR(50)') AS eventname
		FROM #results
) AS tab
GROUP BY eventname;



/* Lets look at the security_error_ring_buffer_recorded events quickly */
SELECT 
    event_data.value('(event/@timestamp)[1]', 'DATETIME2') AS eventtimestamp,
    event_data.value('(event/data[@name="id"]/value)[1]', 'INT') AS id,
    event_data.value('(event/data[@name="timestamp"]/value)[1]', 'BIGINT') AS timestamp,
    event_data.value('(event/data[@name="session_id"]/value)[1]', 'INT') AS session_id,
    event_data.value('(event/data[@name="error_code"]/value)[1]', 'INT') AS error_code,
    event_data.value('(event/data[@name="api_name"]/value)[1]', 'NVARCHAR(128)') AS api_name,
    event_data.value('(event/data[@name="calling_api_name"]/value)[1]', 'NVARCHAR(128)') AS calling_api_name,
    event_data.value('(event/data[@name="call_stack"]/value)[1]', 'NVARCHAR(max)') AS call_stack
FROM #results
WHERE CAST(event_data AS NVARCHAR(MAX)) LIKE '%security_error_ring_buffer_recorded%'
ORDER BY eventtimestamp ASC
OPTION(MAXDOP 1);



/* Lets look at the security_error_ring_buffer_recorded events quickly */
SELECT 
    event_data.value('(event/@timestamp)[1]', 'DATETIME2') AS eventtimestamp,
    event_data.value('(event/data[@name="id"]/value)[1]', 'INT') AS id,
    event_data.value('(event/data[@name="timestamp"]/value)[1]', 'BIGINT') AS timestamp,
    event_data.value('(event/data[@name="session_id"]/value)[1]', 'INT') AS session_id,
    event_data.value('(event/data[@name="error_code"]/value)[1]', 'INT') AS error_code,
    event_data.value('(event/data[@name="api_name"]/value)[1]', 'NVARCHAR(128)') AS api_name,
    event_data.value('(event/data[@name="calling_api_name"]/value)[1]', 'NVARCHAR(128)') AS calling_api_name,
    event_data.value('(event/data[@name="call_stack"]/value)[1]', 'NVARCHAR(max)') AS call_stack
FROM #results
WHERE event_data.value('(event/@name)[1]', 'VARCHAR(50)') = 'security_error_ring_buffer_recorded'
ORDER BY eventtimestamp ASC
OPTION(MAXDOP 1);


/* Debugging events captured */
SELECT 
	eventname,
	COUNT(*)
FROM (	SELECT
			event_data.value('(event/@name)[1]', 'VARCHAR(50)') AS eventname,
			event_data.value('(event/@timestamp)[1]', 'DATETIME2') AS eventtimestamp,
			event_data.value('(event/data[@name="component"]/text)[1]', 'VARCHAR(20)') AS component,
			event_data.value('(event/data[@name="state"]/text)[1]', 'VARCHAR(20)') AS state,
			event_data.query('(event/data[@name="data"]/value/*)[1]') AS data,
			event_data.query('.')  AS event_data
		FROM #results
) AS tab
GROUP BY eventname;

/* System information */
SELECT 
    event_data.value('(event/@timestamp)[1]', 'DATETIME2') AS eventtimestamp,
    event_data.value('(event/data[@name="component"]/text)[1]', 'VARCHAR(20)') AS component,
	event_data.value('(event/data[@name="state"]/text)[1]', 'VARCHAR(20)') AS state,
	event_data.value('(event/data[@name="data"]/value/system/@spinlockBackoffs)[1]', 'INT') AS spinlockBackoffs,
	event_data.value('(event/data[@name="data"]/value/system/@sickSpinlockType)[1]', 'VARCHAR(20)') AS sickSpinlockType,
	event_data.value('(event/data[@name="data"]/value/system/@sickSpinlockTypeAfterAv)[1]', 'VARCHAR(20)') AS sickSpinlockTypeAfterAv,
	event_data.value('(event/data[@name="data"]/value/system/@latchWarnings)[1]', 'INT') AS latchWarnings,
	event_data.value('(event/data[@name="data"]/value/system/@isAccessViolationOccurred)[1]', 'INT') AS isAccessViolationOccurred,
	event_data.value('(event/data[@name="data"]/value/system/@writeAccessViolationCount)[1]', 'INT') AS writeAccessViolationCount,
	event_data.value('(event/data[@name="data"]/value/system/@totalDumpRequests)[1]', 'INT') AS totalDumpRequests,
	event_data.value('(event/data[@name="data"]/value/system/@INTervalDumpRequests)[1]', 'INT') AS INTervalDumpRequests,
	event_data.value('(event/data[@name="data"]/value/system/@nonYieldingTasksReported)[1]', 'INT') AS nonYieldingTasksReported,
	event_data.value('(event/data[@name="data"]/value/system/@pageFaults)[1]', 'INT') AS pageFaults,
	event_data.value('(event/data[@name="data"]/value/system/@systemCpuUtilization)[1]', 'INT') AS systemCpuUtilization,
	event_data.value('(event/data[@name="data"]/value/system/@sqlCpuUtilization)[1]', 'INT') AS sqlCpuUtilization,
	event_data.value('(event/data[@name="data"]/value/system/@BadPagesDetected)[1]', 'INT') AS BadPagesDetected,
	event_data.value('(event/data[@name="data"]/value/system/@BadPagesFixed)[1]', 'INT') AS BadPagesFixed,
	event_data.value('(event/data[@name="data"]/value/system/@LastBadPageAddress)[1]', 'VARCHAR(20)') AS LastBadPageAddress
FROM #results
WHERE event_data.value('(event/data[@name="component"]/text)[1]', 'VARCHAR(20)') = 'SYSTEM'
ORDER BY eventtimestamp ASC
OPTION(MAXDOP 1);


/* Resource memory information */
SELECT 
    event_data.value('(event/@timestamp)[1]', 'DATETIME2') AS eventtimestamp,
    event_data.value('(event/data[@name="component"]/text)[1]', 'VARCHAR(20)') AS component,
	event_data.value('(event/data[@name="state"]/text)[1]', 'VARCHAR(20)') AS state,
	event_data.value('(event/data[@name="data"]/value/resource/@lastNotification)[1]', 'VARCHAR(30)') AS lastNotification,
	event_data.value('(event/data[@name="data"]/value/resource/@outOfMemoryExceptions)[1]', 'INT') AS outOfMemoryExceptions,
	event_data.value('(event/data[@name="data"]/value/resource/@isAnyPoolOutOfMemory)[1]', 'bit') AS isAnyPoolOutOfMemory,
	event_data.value('(event/data[@name="data"]/value/resource/@processOutOfMemoryPeriod)[1]', 'INT') AS processOutOfMemoryPeriod,
	event_data.query('(event/data[@name="data"]/value/resource/memoryReport[@name="Process/System Counts"])[1]') AS [Process/System Counts],
	event_data.query('(event/data[@name="data"]/value/resource/memoryReport[@name="Memory Manager"])[1]') AS [Memory Manager]
FROM #results
WHERE event_data.value('(event/data[@name="component"]/text)[1]', 'VARCHAR(20)') = 'RESOURCE'
ORDER BY eventtimestamp ASC
OPTION(MAXDOP 1);

/* Query processing information */
SELECT 
    event_data.value('(event/@timestamp)[1]', 'DATETIME2') AS eventtimestamp,
    event_data.value('(event/data[@name="component"]/text)[1]', 'VARCHAR(20)') AS component,
	event_data.value('(event/data[@name="state"]/text)[1]', 'VARCHAR(20)') AS state,
	event_data.value('(event/data[@name="data"]/value/queryProcessing/@maxWorkers)[1]', 'INT') AS maxWorkers,
	event_data.value('(event/data[@name="data"]/value/queryProcessing/@workersCreated)[1]', 'INT') AS workersCreated,
	event_data.value('(event/data[@name="data"]/value/queryProcessing/@workersIdle)[1]', 'bit') AS workersIdle,
	event_data.exist('(event/data[@name="data"]/value/queryProcessing/blockingTasks/blocked-process-report)') AS has_blocked_processes,
	event_data.value('(event/data[@name="data"]/value/queryProcessing/@tasksCompletedWithinINTerval)[1]', 'INT') AS tasksCompletedWithinINTerval,
	event_data.value('(event/data[@name="data"]/value/queryProcessing/@pendingTasks)[1]', 'INT') AS pendingTasks,
	event_data.value('(event/data[@name="data"]/value/queryProcessing/@oldestPendingTaskWaitingTime)[1]', 'BIGINT') AS oldestPendingTaskWaitingTime,
	event_data.value('(event/data[@name="data"]/value/queryProcessing/@hasUnresolvableDeadlockOccurred)[1]', 'bit') AS hasUnresolvableDeadlockOccurred,
	event_data.value('(event/data[@name="data"]/value/queryProcessing/@hasDeadlockedSchedulersOccurred)[1]', 'bit') AS hasDeadlockedSchedulersOccurred,
	event_data.value('(event/data[@name="data"]/value/queryProcessing/@trackingNonYieldingScheduler)[1]', 'VARCHAR(20)') AS trackingNonYieldingScheduler,
	event_data.query('(event/data[@name="data"]/value/queryProcessing/topWaits/nonPreemptive)[1]') AS [nonPreemptive Waits],
	event_data.query('(event/data[@name="data"]/value/queryProcessing/topWaits/preemptive)[1]') AS [Preemtive Waits],
	event_data.query('(event/data[@name="data"]/value/queryProcessing/cpuINTensiveRequests)[1]') AS [cpuINTensiveRequests],
	event_data.query('(event/data[@name="data"]/value/queryProcessing/blockingTasks)[1]') AS [blockingTasks]
FROM #results
WHERE event_data.value('(event/data[@name="component"]/text)[1]', 'VARCHAR(20)') = 'QUERY_PROCESSING'
ORDER BY eventtimestamp ASC
OPTION(MAXDOP 1);

/* I/O subsystem information */
SELECT 
    event_data.value('(event/@timestamp)[1]', 'DATETIME2') AS eventtimestamp,
    event_data.value('(event/data[@name="component"]/text)[1]', 'VARCHAR(20)') AS component,
	event_data.value('(event/data[@name="state"]/text)[1]', 'VARCHAR(20)') AS state,
	event_data.value('(event/data[@name="data"]/value/ioSubsystem/@ioLatchTimeouts)[1]', 'INT') AS ioLatchTimeouts,
	event_data.value('(event/data[@name="data"]/value/ioSubsystem/@INTervalLongIos)[1]', 'INT') AS INTervalLongIos,
	event_data.value('(event/data[@name="data"]/value/ioSubsystem/@totalLongIos)[1]', 'bit') AS totalLongIos,
	event_data.exist('(event/data[@name="data"]/value/ioSubsystem/longestPendingRequests/pendingRequest)') AS has_pending_ios,
	event_data.query('(event/data[@name="data"]/value/ioSubsystem/longestPendingRequests)[1]') AS [blockingTasks]
FROM #results
WHERE event_data.value('(event/data[@name="component"]/text)[1]', 'VARCHAR(20)') = 'IO_SUBSYSTEM'
ORDER BY eventtimestamp ASC
OPTION(MAXDOP 1);


/* Process/System memory counters */
SELECT  
	eventtimestamp, 
	'Process/System Memory' AS counter_type,
	[Available Physical Memory],
	[Available Virtual Memory],
	[Available Paging File],
	[Working Set],
	[Percent of Committed Memory in WS],
	[Page Faults],
	[System physical memory high],
	[System physical memory low],
	[Process physical memory low],
	[Process virtual memory low]
FROM
(	SELECT 
		event_data.value('(event/@timestamp)[1]', 'DATETIME2') AS eventtimestamp,
		n.value('(@description)[1]', 'VARCHAR(50)') AS counter_name,
		n.value('(@value)[1]', 'VARCHAR(50)') AS counter_value
	FROM #results
	CROSS APPLY event_data.nodes('event/data[@name="data"]/value/resource/memoryReport[@name="Process/System Counts"]/entry') AS q(n)
	WHERE event_data.value('(event/data[@name="component"]/text)[1]', 'VARCHAR(20)') = 'RESOURCE'
) AS tab
PIVOT 
(
	MAX(counter_value)
	FOR counter_name IN 
	(	
		[Available Physical Memory],
		[Available Virtual Memory],
		[Available Paging File],
		[Working Set],
		[Percent of Committed Memory in WS],
		[Page Faults],
		[System physical memory high],
		[System physical memory low],
		[Process physical memory low],
		[Process virtual memory low]
	)
) AS pvt
ORDER BY eventtimestamp ASC
OPTION(MAXDOP 1);


/* Memory Manager counters */
SELECT  
	eventtimestamp, 
	'Memory Manager Memory' AS counter_type,
	[VM Reserved],
	[VM Committed],
	[Locked Pages Allocated],
	[Large Pages Allocated],
	[Emergency Memory],
	[Emergency Memory In Use],
	[Target Committed],
	[Current Committed],
	[Pages Allocated],
	[Pages Reserved],
	[Pages Free],
	[Pages In Use],
	[Page Alloc Potential],
	[NUMA Growth Phase],
	[Last OOM Factor],
	[Last OS Error]
FROM
(	SELECT 
		event_data.value('(event/@timestamp)[1]', 'DATETIME2') AS eventtimestamp,
		n.value('(@description)[1]', 'VARCHAR(50)') AS counter_name,
		n.value('(@value)[1]', 'VARCHAR(50)') AS counter_value
	FROM #results
	CROSS APPLY event_data.nodes('event/data[@name="data"]/value/resource/memoryReport[@name="Memory Manager"]/entry') AS q(n)
	WHERE event_data.value('(event/data[@name="component"]/text)[1]', 'VARCHAR(20)') = 'RESOURCE'
) AS tab
PIVOT 
(
	MAX(counter_value)
	FOR counter_name IN 
	(	[VM Reserved],
		[VM Committed],
		[Locked Pages Allocated],
		[Large Pages Allocated],
		[Emergency Memory],
		[Emergency Memory In Use],
		[Target Committed],
		[Current Committed],
		[Pages Allocated],
		[Pages Reserved],
		[Pages Free],
		[Pages In Use],
		[Page Alloc Potential],
		[NUMA Growth Phase],
		[Last OOM Factor],
		[Last OS Error]
	)
) AS pvt
ORDER BY eventtimestamp ASC
OPTION(MAXDOP 1);


/* Output Deadlock Graphs */
SELECT 
    event_data.value('(event/@timestamp)[1]', 'DATETIME2') AS eventtimestamp,
    event_data.query('(event/data/value/deadlock)[1]') AS DeadlockGraph 
FROM #results
WHERE event_data.exist('event[@name="xml_deadlock_report"]') = 1
ORDER BY eventtimestamp ASC
OPTION(MAXDOP 1);


/* Blocked Process information */
SELECT 
    event_data.value('(event/@timestamp)[1]', 'DATETIME2') AS eventtimestamp,
	n.query('.') AS [blocked-process-report]
FROM #results
CROSS APPLY event_data.nodes('(event/data[@name="data"]/value/queryProcessing/blockingTasks/blocked-process-report)') q(n)
WHERE event_data.value('(event/data[@name="component"]/text)[1]', 'VARCHAR(20)') = 'QUERY_PROCESSING'
ORDER BY eventtimestamp ASC
OPTION(MAXDOP 1);


/* CPU Usage information */
SELECT 
	eventtimestamp,
	process_utilization AS sql_utilization,
	system_idle,
	(100 - system_idle - process_utilization) AS nonsql_utilization
FROM (	SELECT 
			event_data.value('(event/@timestamp)[1]', 'DATETIME2') AS eventtimestamp,
			event_data.value('(event/data[@name="process_utilization"]/value)[1]', 'INT') AS process_utilization,
			event_data.value('(event/data[@name="system_idle"]/value)[1]', 'INT') AS system_idle
		FROM #results
		WHERE event_data.exist('event[@name="scheduler_monitor_system_health_ring_buffer_recorded"]') = 1
) AS tab
ORDER BY eventtimestamp ASC
OPTION(MAXDOP 1);


/* Login Timers */
SELECT
    event_data.value('(event/@name)[1]', 'VARCHAR(50)') AS eventname,
    event_data.value('(event/@timestamp)[1]', 'DATETIME2') AS eventtimestamp,
    event_data.value('(event/data[@name="type"]/text)[1]', 'VARCHAR(20)') AS type,
    event_data.value('(event/data[@name="source"]/text)[1]', 'VARCHAR(20)') AS source,
    event_data.value('(event/data[@name="os_error"]/value)[1]', 'INT') AS os_error,
    event_data.value('(event/data[@name="sni_error"]/value)[1]', 'INT') AS sni_error,
    event_data.value('(event/data[@name="sni_consumer_error"]/value)[1]', 'INT') AS sni_consumer_error,
    event_data.value('(event/data[@name="sni_provider"]/value)[1]', 'INT') AS sni_provider,
    event_data.value('(event/data[@name="state"]/value)[1]', 'INT') AS state,
    event_data.value('(event/data[@name="local_port"]/value)[1]', 'INT') AS local_port,
    event_data.value('(event/data[@name="remote_port"]/value)[1]', 'INT') AS remote_port,
    event_data.value('(event/data[@name="tds_input_buffer_error"]/value)[1]', 'INT') AS tds_input_buffer_error,
    event_data.value('(event/data[@name="tds_output_buffer_error"]/value)[1]', 'INT') AS tds_output_buffer_error,
    event_data.value('(event/data[@name="tds_input_buffer_bytes"]/value)[1]', 'INT') AS tds_input_buffer_bytes,
    event_data.value('(event/data[@name="tds_flags"]/text)[1]', 'VARCHAR(500)') AS tds_flags,
    event_data.value('(event/data[@name="total_login_time_ms"]/value)[1]', 'BIGINT') AS total_login_time_ms,
    event_data.value('(event/data[@name="login_task_enqueued_ms"]/value)[1]', 'BIGINT') AS login_task_enqueued_ms,
    event_data.value('(event/data[@name="network_writes_ms"]/value)[1]', 'BIGINT') AS network_writes_ms,
    event_data.value('(event/data[@name="network_reads_ms"]/value)[1]', 'BIGINT') AS network_reads_ms,
    event_data.value('(event/data[@name="ssl_processing_ms"]/value)[1]', 'BIGINT') AS ssl_processing_ms,
    event_data.value('(event/data[@name="sspi_processing_ms"]/value)[1]', 'BIGINT') AS sspi_processing_ms,
    event_data.value('(event/data[@name="login_trigger_and_resource_governor_processing_ms"]/value)[1]', 'BIGINT') AS login_trigger_and_resource_governor_processing_ms,
    event_data.value('(event/data[@name="connection_id"]/value)[1]', 'uniqueidentifier') AS connection_id,
    event_data.value('(event/data[@name="connection_peer_id"]/value)[1]', 'uniqueidentifier') AS connection_peer_id,
    event_data.value('(event/data[@name="local_host"]/value)[1]', 'VARCHAR(16)') AS local_host,
    event_data.value('(event/data[@name="remote_host"]/value)[1]', 'VARCHAR(16)') AS remote_host
FROM #results
WHERE event_data.exist('(event[@name="connectivity_ring_buffer_recorded"])') = 1
ORDER BY eventtimestamp ASC
OPTION(MAXDOP 1);


/* Errors Reported */
SELECT
    event_data.value('(event/@name)[1]', 'VARCHAR(50)') AS eventname,
    event_data.value('(event/@timestamp)[1]', 'DATETIME2') AS eventtimestamp,
    event_data.value('(event/data[@name="error_number"]/value)[1]', 'INT') AS error_number,
	event_data.value('(event/data[@name="severity"]/value)[1]', 'INT') AS severity,
	event_data.value('(event/data[@name="state"]/value)[1]', 'INT') AS state,
	event_data.value('(event/data[@name="user_defined"]/value)[1]', 'VARCHAR(5)') AS user_defined,
	event_data.value('(event/data[@name="category"]/text)[1]', 'VARCHAR(50)') AS category,
	event_data.value('(event/data[@name="destination"]/text)[1]', 'VARCHAR(50)') AS destination,
	event_data.value('(event/data[@name="is_INTercepted"]/value)[1]', 'VARCHAR(5)') AS is_INTercepted,
	event_data.value('(event/data[@name="message"]/value)[1]', 'VARCHAR(4000)') AS message
FROM #results
WHERE event_data.exist('(event[@name="error_reported"])') = 1
ORDER BY eventtimestamp ASC
OPTION(MAXDOP 1);


/* WaitInfo Details */
SELECT
    event_data.value('(event/@name)[1]', 'VARCHAR(50)') AS eventname,
    event_data.value('(event/@timestamp)[1]', 'DATETIME2') AS eventtimestamp,
    event_data.value('(event/data[@name="wait_type"]/text)[1]', 'VARCHAR(50)') AS wait_type,
	event_data.value('(event/data[@name="opcode"]/text)[1]', 'VARCHAR(50)') AS opcode,
	event_data.value('(event/data[@name="duration"]/value)[1]', 'BIGINT') AS duration,
	event_data.value('(event/data[@name="signal_duration"]/value)[1]', 'BIGINT') AS signal_duration
FROM #results
WHERE event_data.exist('(event[@name="wait_info"])') = 1
ORDER BY eventtimestamp ASC
OPTION(MAXDOP 1);


/* Top Waits by Count */
SELECT 
	event_data.value('(event/@timestamp)[1]', 'DATETIME2') AS eventtimestamp,
	'Non-Preemptive' AS type,
	n.value('(@waitType)[1]', 'VARCHAR(50)') AS waitType,
	n.value('(@waits)[1]', 'BIGINT') AS waits,
	n.value('(@averageWaitTime)[1]', 'BIGINT') AS averageWaitTime,
	n.value('(@maxWaitTime)[1]', 'BIGINT') AS maxWaitTime
FROM #results
CROSS APPLY event_data.nodes('(event/data[@name="data"]/value/queryProcessing/topWaits/nonPreemptive/byCount/wait)') AS q(n)
WHERE event_data.value('(event/data[@name="component"]/text)[1]', 'VARCHAR(20)') = 'QUERY_PROCESSING'
UNION ALL
SELECT 
	event_data.value('(event/@timestamp)[1]', 'DATETIME2') AS eventtimestamp,
	'Preemptive' AS type,
	n.value('(@waitType)[1]', 'VARCHAR(50)') AS waitType,
	n.value('(@waits)[1]', 'BIGINT') AS waits,
	n.value('(@averageWaitTime)[1]', 'BIGINT') AS averageWaitTime,
	n.value('(@maxWaitTime)[1]', 'BIGINT') AS maxWaitTime
FROM #results
CROSS APPLY event_data.nodes('(event/data[@name="data"]/value/queryProcessing/topWaits/preemptive/byCount/wait)') AS q(n)
WHERE event_data.value('(event/data[@name="component"]/text)[1]', 'VARCHAR(20)') = 'QUERY_PROCESSING'
ORDER BY eventtimestamp, type, maxWaitTime DESC
OPTION(MAXDOP 1);


/* Top Waits by Duration */
SELECT 
	event_data.value('(event/@timestamp)[1]', 'DATETIME2') AS eventtimestamp,
	'Non-Preemptive' AS type,
	n.value('(@waitType)[1]', 'VARCHAR(50)') AS waitType,
	n.value('(@waits)[1]', 'BIGINT') AS waits,
	n.value('(@averageWaitTime)[1]', 'BIGINT') AS averageWaitTime,
	n.value('(@maxWaitTime)[1]', 'BIGINT') AS maxWaitTime
FROM #results
CROSS APPLY event_data.nodes('(event/data[@name="data"]/value/queryProcessing/topWaits/nonPreemptive/byDuration/wait)') AS q(n)
WHERE event_data.value('(event/data[@name="component"]/text)[1]', 'VARCHAR(20)') = 'QUERY_PROCESSING'
UNION ALL
SELECT 
	event_data.value('(event/@timestamp)[1]', 'DATETIME2') AS eventtimestamp,
	'Preemptive' AS type,
	n.value('(@waitType)[1]', 'VARCHAR(50)') AS waitType,
	n.value('(@waits)[1]', 'BIGINT') AS waits,
	n.value('(@averageWaitTime)[1]', 'BIGINT') AS averageWaitTime,
	n.value('(@maxWaitTime)[1]', 'BIGINT') AS maxWaitTime
FROM #results
CROSS APPLY event_data.nodes('(event/data[@name="data"]/value/queryProcessing/topWaits/preemptive/byDuration/wait)') AS q(n)
WHERE event_data.value('(event/data[@name="component"]/text)[1]', 'VARCHAR(20)') = 'QUERY_PROCESSING'
ORDER BY eventtimestamp, type, maxWaitTime DESC
OPTION(MAXDOP 1);


/* CPU INTensive Requests */
SELECT 
    event_data.value('(event/@timestamp)[1]', 'DATETIME2') AS eventtimestamp,
	n.value('(@sessionId)[1]', 'INT') AS session_id,
	n.value('(@requestId)[1]', 'INT') AS request_id,
	n.value('(@command)[1]', 'VARCHAR(20)') AS command,
	n.value('(@taskAddress)[1]', 'VARCHAR(20)') AS task_address,
	n.value('(@cpuUtilization)[1]', 'INT') AS cpu_utilization_percent,
	n.value('(@cpuTimeMs)[1]', 'BIGINT') AS cpu_time_ms
FROM #results
CROSS APPLY event_data.nodes('(event/data[@name="data"]/value/queryProcessing/cpuINTensiveRequests/request)') q(n)
WHERE event_data.value('(event/data[@name="component"]/text)[1]', 'VARCHAR(20)') = 'QUERY_PROCESSING'
ORDER BY eventtimestamp ASC
OPTION(MAXDOP 1);
