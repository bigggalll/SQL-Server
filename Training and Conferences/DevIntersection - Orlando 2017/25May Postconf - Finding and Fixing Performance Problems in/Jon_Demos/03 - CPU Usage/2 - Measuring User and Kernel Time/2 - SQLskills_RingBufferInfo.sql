/*============================================================================
	File: SQLskills_RingBufferInfo.sql 

	Summary: Parses the output of the sys.dm_os_ring_buffers DMV. 

	Date: March 2011 

	SQL Server Versions:
		2008, 2008 R2
------------------------------------------------------------------------------
	Copyright (C) 2011 Jonathan M. Kehayias, SQLskills.com
	All rights reserved. 

	For more scripts and sample code, check out
		http://www.sqlskills.com/ 

	You may alter this code for your own *non-commercial* purposes. You may
	republish altered code as long as you give due credit. 

	THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF
	ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED
	TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
	PARTICULAR PURPOSE.
============================================================================*/ 

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

