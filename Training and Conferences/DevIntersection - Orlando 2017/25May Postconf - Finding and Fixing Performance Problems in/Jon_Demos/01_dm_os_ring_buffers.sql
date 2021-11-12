/*****************************************************************************
*   Presentation: Module 11 - DMV's
*   FileName:  dm_os_ring_buffers.sql
*
*   Summary: Demonstrates how to parse the contents of sys.dm_os_ring_buffers.
*
*   Date: March 14, 2011 
*
*   SQL Server Versions:
*         2008, 2008 R2
*         
******************************************************************************
*   Copyright (C) 2011 Jonathan M. Kehayias, SQLskills.com
*   All rights reserved. 
*
*   For more scripts and sample code, check out 
*      http://sqlskills.com/blogs/jonathan
*
*   You may alter this code for your own *non-commercial* purposes. You may
*   republish altered code as long as you include this copyright and give 
*	due credit. 
*
*
*   THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
*   ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
*   TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
*   PARTICULAR PURPOSE. 
*
******************************************************************************/


--System Memory Usage
SELECT  
	EventTime,
	--record,
    record.value('(/Record/ResourceMonitor/Notification)[1]', 'varchar(max)') as [Type], 
    record.value('(/Record/MemoryRecord/AvailablePhysicalMemory)[1]', 'bigint') AS [Avail Phys Mem, Kb], 
    record.value('(/Record/MemoryRecord/AvailableVirtualAddressSpace)[1]', 'bigint') AS [Avail VAS, Kb] 
FROM (
	SELECT 
		DATEADD (ss, (-1 * ((cpu_ticks / CONVERT (float, ( cpu_ticks / ms_ticks ))) - [timestamp])/1000), GETDATE()) AS EventTime, 
		CONVERT (xml, record) AS record
	FROM sys.dm_os_ring_buffers 
	CROSS JOIN sys.dm_os_sys_info
	WHERE ring_buffer_type = 'RING_BUFFER_RESOURCE_MONITOR') AS tab 
ORDER BY EventTime DESC

-- Get CPU Utilization
SELECT 
    EventTime,
    n.value('(SystemIdle)[1]', 'int') AS idle_cpu,
    100-(n.value('(SystemIdle)[1]', 'int') +
			n.value('(ProcessUtilization)[1]', 'int')) AS nonsql_cpu,
    n.value('(ProcessUtilization)[1]', 'int') AS sql_cpu
FROM (
	SELECT
		DATEADD (ss, (-1 * ((cpu_ticks / CONVERT (float, ( cpu_ticks / ms_ticks ))) - [timestamp])/1000), GETDATE()) AS EventTime, 
		CONVERT (xml, record) AS record
	FROM sys.dm_os_ring_buffers 
	CROSS JOIN sys.dm_os_sys_info
	WHERE ring_buffer_type = 'RING_BUFFER_SCHEDULER_MONITOR') AS t
CROSS APPLY record.nodes('/Record/SchedulerMonitorEvent/SystemHealth') AS x(n)
ORDER BY EventTime DESC

-- Error Exceptions
SELECT 
	COUNT(*) AS [count],
	'RING_BUFFER_EXCEPTION' AS [Type],
	tab1.[error],
	m.text AS [Error_Message]
FROM (	SELECT RingBuffer.Record.value('Error[1]', 'int') as error
		FROM (SELECT CAST(Record AS XML) AS TargetData 
			  FROM sys.dm_os_ring_buffers
			  WHERE ring_buffer_type = 'RING_BUFFER_EXCEPTION') AS Data
		CROSS APPLY TargetData.nodes('/Record/Exception') AS RingBuffer(Record)) tab1
LEFT JOIN sys.messages m
	ON tab1.[error] = m.message_id 
		AND m.[language_id] = SERVERPROPERTY('LCID')
GROUP BY m.text, tab1.[error]

-- Connectivity issues and timers
SELECT 
	record.value('(Record/@id)[1]', 'int') as id,
	record.value('(Record/@type)[1]', 'varchar(50)') as type,
	n.value('(RecordType)[1]', 'varchar(50)') as RecordType,
	n.value('(RecordSource)[1]', 'varchar(50)') as RecordSource,
	n.value('(Spid)[1]', 'int') as Spid,
	n.value('(SniConnectionid)[1]', 'uniqueidentifier') as SniConnectionid,
	n.value('(SniProvider)[1]', 'int') as SniProvider,
	n.value('(OSError)[1]', 'int') as OSError,
	n.value('(SniConsumerError)[1]', 'int') as SniConsumerError,
	n.value('(State)[1]', 'int') as State,
	n.value('(RemoteHost)[1]', 'varchar(50)') as RemoteHost,
	n.value('(RemotePort)[1]', 'varchar(50)') as RemotePort,
	n.value('(LocalHost)[1]', 'varchar(50)') as LocalHost,
	n.value('(LocalPort)[1]', 'varchar(50)') as LocalPort,
	n.value('(RecordTime)[1]', 'datetime') as RecordTime,
	n.value('(LoginTimers/TotalLoginTimeinMilliseconds)[1]', 'bigint') as TotalLoginTimeinMilliseconds,
	n.value('(LoginTimers/LoginTaskEnqueuedinMilliseconds)[1]', 'bigint') as LoginTaskEnqueuedinMilliseconds,
	n.value('(LoginTimers/NetworkWritesinMilliseconds)[1]', 'bigint') as NetworkWritesinMilliseconds,
	n.value('(LoginTimers/NetworkReadsinMilliseconds)[1]', 'bigint') as NetworkReadsinMilliseconds,
	n.value('(LoginTimers/SslProcessinginMilliseconds)[1]', 'bigint') as SslProcessinginMilliseconds,
	n.value('(LoginTimers/SspiProcessinginMilliseconds)[1]', 'bigint') as SspiProcessinginMilliseconds,
	n.value('(LoginTimers/LoginTriggerAndResourceGovernorProcessinginMilliseconds)[1]', 'bigint') as LoginTriggerAndResourceGovernorProcessinginMilliseconds,
	n.value('(TdsBuffersinformation/TdsinputBufferError)[1]', 'int') as TdsinputBufferError,
	n.value('(TdsBuffersinformation/TdsOutputBufferError)[1]', 'int') as TdsOutputBufferError,
	n.value('(TdsBuffersinformation/TdsinputBufferBytes)[1]', 'int') as TdsinputBufferBytes,
	n.value('(TdsDisconnectFlags/PhysicalConnectionisKilled)[1]', 'int') as PhysicalConnectionisKilled,
	n.value('(TdsDisconnectFlags/DisconnectDueToReadError)[1]', 'int') as DisconnectDueToReadError,
	n.value('(TdsDisconnectFlags/NetworkErrorFoundininputStream)[1]', 'int') as NetworkErrorFoundininputStream,
	n.value('(TdsDisconnectFlags/ErrorFoundBeforeLogin)[1]', 'int') as ErrorFoundBeforeLogin,
	n.value('(TdsDisconnectFlags/SessionisKilled)[1]', 'int') as SessionisKilled,
	n.value('(TdsDisconnectFlags/NormalDisconnect)[1]', 'int') as NormalDisconnect,
	n.value('(TdsDisconnectFlags/NormalLogout)[1]', 'int') as NormalLogout
FROM(SELECT 
		DATEADD (ss, (-1 * ((cpu_ticks / CONVERT (float, ( cpu_ticks / ms_ticks ))) - [timestamp])/1000), GETDATE()) AS EventTime, 
		CONVERT (xml, record) AS record
	FROM sys.dm_os_ring_buffers 
	CROSS JOIN sys.dm_os_sys_info
	WHERE ring_buffer_type = 'RING_BUFFER_CONNECTIVITY') as tab
CROSS APPLY record.nodes('/Record/ConnectivityTraceRecord') AS x(n)

-- Get Startup Memory Utilization
SELECT 
    EventTime,
    n.value('(Pool)[1]', 'int') AS [Pool],
    n.value('(Broker)[1]', 'varchar(40)') AS [Broker],
    n.value('(Notification)[1]', 'varchar(40)') AS [Notification],
    n.value('(MemoryRatio)[1]', 'int') AS [MemoryRatio], 
    n.value('(NewTarget)[1]', 'int') AS [NewTarget],
    n.value('(Overall)[1]', 'int') AS [Overall],
    n.value('(Rate)[1]', 'int') AS [Rate],
    n.value('(CurrentlyPredicted)[1]', 'int') AS [CurrentlyPredicted],
    n.value('(CurrentlyAllocated)[1]', 'int') AS [CurrentlyAllocated]
FROM (
	SELECT 
		DATEADD (ss, (-1 * ((cpu_ticks / CONVERT (float, ( cpu_ticks / ms_ticks ))) - [timestamp])/1000), GETDATE()) AS EventTime, 
		CONVERT (xml, record) AS record
	FROM sys.dm_os_ring_buffers 
	CROSS JOIN sys.dm_os_sys_info
	WHERE ring_buffer_type = 'RING_BUFFER_MEMORY_BROKER') AS t
CROSS APPLY record.nodes('/Record/MemoryBroker') AS x(n)
ORDER BY EventTime DESC

-- Out of Memory Notifications
SELECT 
	EventTime,
	n.value('(OOM/Action)[1]', 'varchar(50)') as Action,
	n.value('(OOM/Resources)[1]', 'int') as Resources,
	n.value('(OOM/Task)[1]', 'varchar(20)') as Task,
	n.value('(OOM/Pool)[1]', 'int') as PoolID,
	n.value('(MemoryRecord/MemoryUtilization)[1]', 'int') as MemoryUtilization,
	n.value('(MemoryRecord/AvailablePhysicalMemory)[1]', 'int') as AvailablePhysicalMemory,
	n.value('(MemoryRecord/AvailableVirtualAddressSpace)[1]', 'int') as AvailableVirtualAddressSpace
FROM(SELECT 
		DATEADD (ss, (-1 * ((cpu_ticks / CONVERT (float, ( cpu_ticks / ms_ticks ))) - [timestamp])/1000), GETDATE()) AS EventTime, 
		CONVERT (xml, record) AS record
	FROM sys.dm_os_ring_buffers 
	CROSS JOIN sys.dm_os_sys_info
	WHERE ring_buffer_type = 'RING_BUFFER_OOM') as tab
CROSS APPLY record.nodes('/Record') AS x(n)