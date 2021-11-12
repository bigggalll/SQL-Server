/***************************************************************************** 
* 
*   Summary: Demonstrates how to parse the contents of sys.dm_os_ring_buffers for 
*                    Low memory notifications by the OS. 
*         
*   Date: May 4, 2015
* 
*   SQL Server Versions: 
*         2012, 2014
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
*    due credit. 
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
    record.value('(/Record/@id)[1]', 'bigint') as [ID], 
    tab.timestamp,
    EventTime, 
    record.value('(/Record/ResourceMonitor/Notification)[1]', 'varchar(max)') as [Type], 
    record.value('(/Record/ResourceMonitor/IndicatorsProcess)[1]', 'bigint') as [IndicatorsProcess], 
    record.value('(/Record/ResourceMonitor/IndicatorsSystem)[1]', 'bigint') as [IndicatorsSystem],
    record.value('(/Record/ResourceMonitor/NodeId)[1]', 'bigint') as [NodeId],
    record.value('(/Record/MemoryNode/TargetMemory)[1]', 'bigint') as [SQL_TargetMemoryKB],
    record.value('(/Record/MemoryNode/ReservedMemory)[1]', 'bigint') as [SQL_ReservedMemoryKB],
    record.value('(/Record/MemoryNode/AWEMemory)[1]', 'bigint') as [SQL_AWEMemoryKB],
    record.value('(/Record/MemoryNode/PagesMemory)[1]', 'bigint') as [SQL_PagesMemoryKB],
    record.value('(/Record/MemoryRecord/MemoryUtilization)[1]', 'bigint') AS [MemoryUtilization%], 
    record.value('(/Record/MemoryRecord/AvailablePhysicalMemory)[1]', 'bigint') AS [AvailablePhysicalMemoryKB], 
    record.value('(/Record/ResourceMonitor/Effect[@type="APPLY_LOWPM"]/@state)[1]', 'nvarchar(50)') as [APPLY_LOWPM_State],
    record.value('(/Record/ResourceMonitor/Effect[@type="APPLY_LOWPM"]/@reversed)[1]', 'bit') as [APPLY_LOWPM_Reversed],
    record.value('(/Record/ResourceMonitor/Effect[@type="APPLY_LOWPM"])[1]', 'bigint') as [APPLY_LOWPM_Time],
    record.value('(/Record/ResourceMonitor/Effect[@type="APPLY_HIGHPM"]/@state)[1]', 'nvarchar(50)') as [APPLY_HIGHPM_State],
    record.value('(/Record/ResourceMonitor/Effect[@type="APPLY_HIGHPM"]/@reversed)[1]', 'bit') as [APPLY_HIGHPM_Reversed],
    record.value('(/Record/ResourceMonitor/Effect[@type="APPLY_HIGHPM"])[1]', 'bigint') as [APPLY_HIGHPM_Time],
    record.value('(/Record/ResourceMonitor/Effect[@type="REVERT_HIGHPM"]/@state)[1]', 'nvarchar(50)') as [REVERT_HIGHPM_State],
    record.value('(/Record/ResourceMonitor/Effect[@type="REVERT_HIGHPM"]/@reversed)[1]', 'bit') as [REVERT_HIGHPM_Reversed],
    record.value('(/Record/ResourceMonitor/Effect[@type="REVERT_HIGHPM"])[1]', 'bigint') as [REVERT_HIGHPM_Time],
    record.value('(/Record/MemoryRecord/TotalPhysicalMemory)[1]', 'bigint') AS [TotalPhysicalMemoryKB],
    record.value('(/Record/MemoryRecord/TotalPageFile)[1]', 'bigint') AS [TotalPageFileKB], 
    record.value('(/Record/MemoryRecord/AvailablePageFile)[1]', 'bigint') AS [AvailablePageFileKB],
    record.value('(/Record/MemoryRecord/TotalVirtualAddressSpace)[1]', 'bigint') AS [TotalVirtualAddressSpaceKB], 
    record.value('(/Record/MemoryRecord/AvailableVirtualAddressSpace)[1]', 'bigint') AS [AvailableVirtualAddressSpaceKB],
    record.value('(/Record/MemoryRecord/AvailableExtendedVirtualAddressSpace)[1]', 'bigint') AS [AvailableExtendedVirtualAddressSpaceKB]
FROM ( 
    SELECT 
		[timestamp],
        DATEADD (ss, (-1 * ((cpu_ticks / CONVERT (float, ( cpu_ticks / ms_ticks ))) - [timestamp])/1000), GETDATE()) AS EventTime, 
        CONVERT (xml, record) AS record 
    FROM sys.dm_os_ring_buffers 
    CROSS JOIN sys.dm_os_sys_info 
    WHERE ring_buffer_type = 'RING_BUFFER_RESOURCE_MONITOR') AS tab 
ORDER BY ID DESC;

--Per Node Memory Usage 
SELECT	
		record.value('(/Record/@id)[1]', 'bigint') as [ID], 
		tab.timestamp,
		EventTime, 
		x.value('(@id)[1]', 'int') AS NodeID,
		x.value('(TargetMemory)[1]', 'bigint') AS TargetMemory,
		x.value('(ReservedMemory)[1]', 'bigint') AS ReservedMemory,
		x.value('(CommittedMemory)[1]', 'bigint') AS CommittedMemory,
		x.value('(SharedMemory)[1]', 'bigint') AS SharedMemory,
		x.value('(PagesMemory)[1]', 'bigint') AS PagesMemory
FROM ( 
    SELECT 
		[timestamp],
        DATEADD (ss, (-1 * ((cpu_ticks / CONVERT (float, ( cpu_ticks / ms_ticks ))) - [timestamp])/1000), GETDATE()) AS EventTime, 
        CONVERT (xml, record) AS record 
    FROM sys.dm_os_ring_buffers 
    CROSS JOIN sys.dm_os_sys_info 
    WHERE ring_buffer_type = 'RING_BUFFER_RESOURCE_MONITOR') AS tab
CROSS APPLY record.nodes('/Record/MemoryNode') AS node(x)
ORDER BY ID DESC;



-- Get Memory Broker notifications
SELECT 
    EventTime,
    n.value('(Pool)[1]', 'bigint') AS [Pool],
    n.value('(Broker)[1]', 'varchar(40)') AS [Broker],
    n.value('(Notification)[1]', 'varchar(40)') AS [Notification],
    n.value('(MemoryRatio)[1]', 'bigint') AS [MemoryRatio], 
    n.value('(NewTarget)[1]', 'bigint') AS [NewTarget],
    n.value('(Overall)[1]', 'bigint') AS [Overall],
    n.value('(Rate)[1]', 'bigint') AS [Rate],
    n.value('(CurrentlyPredicted)[1]', 'bigint') AS [CurrentlyPredicted],
    n.value('(CurrentlyAllocated)[1]', 'bigint') AS [CurrentlyAllocated]
FROM (
	SELECT 
		DATEADD (ss, (-1 * ((cpu_ticks / CONVERT (float, ( cpu_ticks / ms_ticks ))) - [timestamp])/1000), GETDATE()) AS EventTime, 
		CONVERT (xml, record) AS record
	FROM sys.dm_os_ring_buffers 
	CROSS JOIN sys.dm_os_sys_info
	WHERE ring_buffer_type = 'RING_BUFFER_MEMORY_BROKER') AS t
CROSS APPLY record.nodes('/Record/MemoryBroker') AS x(n)
ORDER BY EventTime DESC;


-- Memory Broker Clerks
SELECT 
	EventTime,
	n.value('(Name)[1]', 'varchar(50)') as Name,
	n.value('(TotalPages)[1]', 'bigint') as TotalPages,
	n.value('(SimulatedPages)[1]', 'bigint') as SimulatedPages,
	n.value('(SimulationBenefit)[1]', 'decimal(12,10)') as SimulationBenefit,
	n.value('(InternalBenefit)[1]', 'decimal(12,10)') as InternalBenefit,
	n.value('(ExternalBenefit)[1]', 'decimal(12,10)') as ExternalBenefit,
	n.value('(ValueOfMemory)[1]', 'decimal(12,10)') as ValueOfMemory,
	n.value('(PeriodicFreedPages)[1]', 'bigint') as PeriodicFreedPages,
	n.value('(InternalFreedPages)[1]', 'bigint') as InternalFreedPages
FROM(SELECT 
		DATEADD (ss, (-1 * ((cpu_ticks / CONVERT (float, ( cpu_ticks / ms_ticks ))) - [timestamp])/1000), GETDATE()) AS EventTime, 
		CONVERT (xml, record) AS record
	FROM sys.dm_os_ring_buffers 
	CROSS JOIN sys.dm_os_sys_info
	WHERE ring_buffer_type = 'RING_BUFFER_MEMORY_BROKER_CLERKS') as tab
CROSS APPLY record.nodes('/Record/MemoryBrokerClerk') AS x(n);
