
/*********************************************************************
Copy one of the following links and press Ctrl-F and click FIND NEXT
in order to go to that section of the scripts


BLOCKING_EVENTS
DEADLOCKGRAPH_EVENTS
LOCKESCALATION_EVENTS
LONG_DURATION_QUERY_EVENTS
MISC_PERF_EVENTS
AX_CONTEXT_INFO


********************************************************************/



--NOTE:  you must have deployed the EXTENDED EVENTS in Step 7 of the 
--			installation steps



-- Set the location of your extended events files

-- HIGHLIGHT THE FOLLOWING and Press Control-H

--   C:\SQLTRACE


-- Replace the text with the file location used when setting up the extended
-- events. 

-- If you did a remote installation use the UNC path to the files on the production 
-- server such as:

--   \\myserver\C$\SQLTRACE








-- --------------------------------------------------------------
--
--			BLOCKING_EVENTS
-- Blocking events sorted by TIME desc
----------------------------------------------------------------

SELECT TOP 100 *
FROM   (SELECT event_data.value('(event/@name)[1]', 'varchar(50)')                                                                 AS EVENT_NAME,
               DATEADD(hh, DATEDIFF(hh, GETUTCDATE(), CURRENT_TIMESTAMP), event_data.value('(/event/@timestamp)[1]', 'datetime2')) AS END_TIME,
               event_data.value('(event/data[@name="duration"]/value)[1]', 'decimal(38,3)') / 1000                                 AS DURATION,
               event_data.value('(event/data[@name="object_id"]/value)[1]', 'int')                                                 AS OBJECT_ID,
               event_data.value('(event/data[@name="resource_owner_type"]/value)[1]', 'varchar(max)')                              AS RESOURCE_OWNER_TYPE,
               event_data.value('(event/data[@name="index_id"]/value)[1]', 'int')                                                  AS INDEX_ID,
               event_data.value('(event/data[@name="lock_mode"]/value)[1]', 'varchar(max)')                                        AS LOCK_MODE,
               event_data.value('(event/data[@name="transaction_id"]/value)[1]', 'bigint')                                            AS TRANSACTION_ID,
               event_data.value('(event/data[@name="database_name"]/value)[1]', 'varchar(max)')                                    AS DATABASE_NAME,
               event_data                                                                                                          AS EVENT_DATA
        FROM   (SELECT CONVERT(XML, event_data)
                FROM   sys.fn_xe_file_target_read_file('C:\SQLTRACE\DYNAMICS_BLOCKING*.XEL', NULL, NULL, NULL)) AS evts ( event_data )) AS DYNPERF_BLOCKING
WHERE  EVENT_NAME = 'blocked_process_report'
--AND END_TIME BETWEEN  '2016-02-13 10:19:37.5520000' AND '2016-02-13 10:21:17.9560000' 
ORDER  BY END_TIME DESC; 





-- --------------------------------------------------------------
--
--			DEADLOCKGRAPH_EVENTS
-- DEADLOCK events sorted by TIME desc
----------------------------------------------------------------

SELECT TOP 100 *
FROM   (SELECT event_data.value('(event/@name)[1]', 'varchar(50)')                                                                 AS EVENT_NAME,
               DATEADD(hh, DATEDIFF(hh, GETUTCDATE(), CURRENT_TIMESTAMP), event_data.value('(/event/@timestamp)[1]', 'datetime2')) AS END_TIME,
               event_data                                                                                                          AS DEADLOCK_GRAPH
        FROM   (SELECT CONVERT(XML, event_data)
                FROM   sys.Fn_xe_file_target_read_file('C:\SQLTRACE\DYNAMICS_BLOCKING*.XEL', NULL, NULL, NULL)) AS evts ( event_data )) AS DYNPERF_BLOCKING
WHERE  EVENT_NAME = 'xml_deadlock_report'
--AND END_TIME BETWEEN  '2016-02-13 10:19:37.5520000' AND '2016-02-13 10:21:17.9560000' 
ORDER  BY END_TIME DESC; 



-- --------------------------------------------------------------
--
--			LOCKESCALATION_EVENTS
-- LOCK ESCALATION events sorted by TIME desc
----------------------------------------------------------------

SELECT TOP 100 *
FROM   (SELECT event_data.value('(event/@name)[1]', 'varchar(50)')                                                                 AS EVENT_NAME,
               DATEADD(hh, DATEDIFF(hh, GETUTCDATE(), CURRENT_TIMESTAMP), event_data.value('(/event/@timestamp)[1]', 'datetime2')) AS END_TIME,
               event_data.value('(event/data[@name="collect_statement"]/value)[1]', 'bit')                                         AS COLLECT_STATEMENT,
               event_data.value('(event/data[@name="collect_database_name"]/value)[1]', 'bit')                                     AS COLLECT_DATABASE_NAME,
               event_data.value('(event/data[@name="resource_type"]/value)[1]', 'varchar(max)')                                    AS RESOURCE_TYPE,
               event_data.value('(event/data[@name="mode"]/value)[1]', 'varchar(max)')                                             AS MODE,
               event_data.value('(event/data[@name="owner_type"]/value)[1]', 'varchar(max)')                                       AS OWNER_TYPE,
               event_data.value('(event/data[@name="transaction_id"]/value)[1]', 'bigint')                                            AS TRANSACTION_ID,
               event_data.value('(event/data[@name="database_id"]/value)[1]', 'int')                                               AS DATABASE_ID,
               event_data.value('(event/data[@name="lockspace_workspace_id"]/value)[1]', 'varchar(max)')                           AS LOCKSPACE_WORKSPACE_ID,
               event_data.value('(event/data[@name="lockspace_sub_id"]/value)[1]', 'int')                                          AS LOCKSPACE_SUB_ID,
               event_data.value('(event/data[@name="lockspace_nest_id"]/value)[1]', 'int')                                         AS LOCKSPACE_NEST_ID,
               event_data.value('(event/data[@name="resource_0"]/value)[1]', 'int')                                                AS RESOURCE_0,
               event_data.value('(event/data[@name="resource_1"]/value)[1]', 'int')                                                AS RESOURCE_1,
               event_data.value('(event/data[@name="resource_2"]/value)[1]', 'int')                                                AS RESOURCE_2,
               event_data.value('(event/data[@name="escalation_cause"]/value)[1]', 'varchar(max)')                                 AS ESCALATION_CAUSE,
               event_data.value('(event/data[@name="object_id"]/value)[1]', 'int')                                                 AS OBJECT_ID,
               event_data.value('(event/data[@name="hobt_id"]/value)[1]', 'int')                                                   AS HOBT_ID,
               event_data.value('(event/data[@name="escalated_lock_count"]/value)[1]', 'int')                                      AS ESCALATED_LOCK_COUNT,
               event_data.value('(event/data[@name="hobt_lock_count"]/value)[1]', 'int')                                           AS HOBT_LOCK_COUNT,
               event_data.value('(event/data[@name="statement"]/value)[1]', 'varchar(max)')                                        AS STATEMENT,
               event_data.value('(event/data[@name="database_name"]/value)[1]', 'varchar(max)')                                    AS DATABASE_NAME,
               event_data                                                                                                          AS EVENT_DATA
        FROM   (SELECT CONVERT(XML, event_data)
                FROM   sys.fn_xe_file_target_read_file('C:\SQLTRACE\DYNAMICS_BLOCKING*.XEL', NULL, NULL, NULL)) AS evts ( event_data )) AS DYNPERF_BLOCKING
WHERE  EVENT_NAME = 'lock_escalation'
--AND END_TIME BETWEEN  '2016-02-13 10:19:37.5520000' AND '2016-02-13 10:21:17.9560000' 
ORDER  BY END_TIME DESC; 


-- --------------------------------------------------------------
--
--			LONG_DURATION_QUERY_EVENTS
-- Long Duration Queries sorted by TIME desc
----------------------------------------------------------------


-- Version for all products

SELECT TOP 100
	DATEADD(hh,DATEDIFF(hh, GETUTCDATE(), CURRENT_TIMESTAMP),
	event_data.value('(/event/@timestamp)[1]', 'datetime2'))								AS END_TIME,
	object_name																				AS STATEMENT_TYPE,
	event_data.value('(/event/action[@name = "client_app_name"]/value)[1]','nvarchar(max)')	AS APPLICATION_NAME,	
	event_data.value('(/event/action[@name = "client_hostname"]/value)[1]','nvarchar(max)')	AS HOST_NAME,
	event_data.value('(/event/action[@name = "session_id"]/value)[1]','int')				AS SQL_SESSION_ID,
	event_data.value('(/event/action[@name = "database_name"]/value)[1]','nvarchar(max)')	AS DATABASE_NAME,
	event_data.value('(/event/data[@name = "duration"]/value)[1]','decimal(38,3)')/1000		AS DURATION,
	event_data.value('(/event/data[@name = "cpu_time"]/value)[1]','decimal(38,3)')/1000		AS CPU_TIME,
	event_data.value('(/event/action[@name = "sql_text"]/value)[1]','nvarchar(max)')		AS SQL_STATEMENT,
	event_data.value('(/event/data[@name = "statement"]/value)[1]','nvarchar(max)')			AS RPC_STATEMENT,
	P.QUERY_PLAN 																			AS QUERY_PLAN,
	event_data.value('(/event/data[@name = "physical_reads"]/value)[1]','bigint')			AS PHYSICAL_READS,	
	event_data.value('(/event/data[@name = "logical_reads"]/value)[1]','bigint')			AS LOGICAL_READS,	
	event_data.value('(/event/data[@name = "writes"]/value)[1]','bigint')					AS WRITES,		
	event_data.value('(/event/data[@name = "last_row_count"]/value)[1]','bigint')			AS LAST_ROW_COUNT,	
	event_data.value('(/event/data[@name = "row_count"]/value)[1]','bigint')				AS ROW_COUNT,	
	dbo.FN_HASH_FROM_UINT64_TO_BINARY(event_data.value('(/event/action[@name = "query_plan_hash"]/value)[1]','decimal(38,0)'))	AS QUERY_PLAN_HASH,
	dbo.FN_HASH_FROM_UINT64_TO_BINARY(event_data.value('(/event/action[@name = "query_hash"]/value)[1]','decimal(38,0)'))		AS QUERY_HASH,
	file_name,
	file_offset
FROM
(
	SELECT	module_guid,
			package_guid,
			object_name,
			convert(xml, event_data) as event_data,
			file_name,
			file_offset
	FROM sys.fn_xe_file_target_read_file	('C:\SQLTRACE\DYNAMICS_LONG_DURATION*.XEL', NULL, NULL, NULL)
) AS A

LEFT JOIN	DynamicsPerf..QUERY_PLANS p
	ON		dbo.FN_HASH_FROM_UINT64_TO_BINARY(event_data.value('(/event/action[@name = "query_plan_hash"]/value)[1]','decimal(38,0)'))= P.QUERY_PLAN_HASH
	AND		dbo.FN_HASH_FROM_UINT64_TO_BINARY(event_data.value('(/event/action[@name = "query_plan_hash"]/value)[1]','decimal(38,0)'))<>0x0000000000000000





--Dynamics AX specific version 
SELECT TOP 100 
		DATEADD(hh, DATEDIFF(hh, GETUTCDATE(), CURRENT_TIMESTAMP), event_data.value('(/event/@timestamp)[1]', 'datetime2'))                                      AS END_TIME,
       object_name                                                                                                                                              AS STATEMENT_TYPE,
       event_data.value('(/event/action[@name = "client_app_name"]/value)[1]', 'nvarchar(max)')                                                                 AS APPLICATION_NAME,
       event_data.value('(/event/action[@name = "client_hostname"]/value)[1]', 'nvarchar(max)')                                                                 AS HOST_NAME,
       dbo.FN_RETURN_AXID_FROM_CONTEXT (CONVERT (VARBINARY(128), event_data.value('(/event/action[@name = "context_info"]/value)[1]', 'varchar(128)'), 2))      AS AX_USER_ID,
       --U.NAME																					AS AX_USER_NAME,
       dbo.FN_RETURN_AXSESSION_FROM_CONTEXT (CONVERT (VARBINARY(128), event_data.value('(/event/action[@name = "context_info"]/value)[1]', 'varchar(128)'), 2)) AS AX_SESSION_ID,
       event_data.value('(/event/action[@name = "session_id"]/value)[1]', 'int')                                                                                AS SQL_SESSION_ID,
       event_data.value('(/event/action[@name = "database_name"]/value)[1]', 'nvarchar(max)')                                                                   AS DATABASE_NAME,
       event_data.value('(/event/data[@name = "duration"]/value)[1]', 'decimal(38,3)') / 1000                                                                   AS DURATION,
       event_data.value('(/event/data[@name = "cpu_time"]/value)[1]', 'decimal(38,3)') / 1000                                                                   AS CPU_TIME,
       event_data.value('(/event/action[@name = "sql_text"]/value)[1]', 'nvarchar(max)')                                                                        AS SQL_STATEMENT,
       event_data.value('(/event/data[@name = "statement"]/value)[1]', 'nvarchar(max)')                                                                         AS RPC_STATEMENT,
       P.QUERY_PLAN                                                                                                                                             AS QUERY_PLAN,
       event_data.value('(/event/data[@name = "physical_reads"]/value)[1]', 'bigint')                                                                           AS PHYSICAL_READS,
       event_data.value('(/event/data[@name = "logical_reads"]/value)[1]', 'bigint')                                                                            AS LOGICAL_READS,
       event_data.value('(/event/data[@name = "writes"]/value)[1]', 'bigint')                                                                                   AS WRITES,
       event_data.value('(/event/data[@name = "last_row_count"]/value)[1]', 'bigint')                                                                           AS LAST_ROW_COUNT,
       event_data.value('(/event/data[@name = "row_count"]/value)[1]', 'bigint')                                                                                AS ROW_COUNT,
       dbo.FN_HASH_FROM_UINT64_TO_BINARY(event_data.value('(/event/action[@name = "query_plan_hash"]/value)[1]', 'decimal(38,0)'))                              AS QUERY_PLAN_HASH,
       dbo.FN_HASH_FROM_UINT64_TO_BINARY(event_data.value('(/event/action[@name = "query_hash"]/value)[1]', 'decimal(38,0)'))                                   AS QUERY_HASH,
       file_name,
       file_offset
FROM   (SELECT module_guid,
               package_guid,
               object_name,
               CONVERT(XML, event_data) AS event_data,
               file_name,
               file_offset
        FROM   sys.Fn_xe_file_target_read_file ('C:\SQLTRACE\DYNAMICS_LONG_DURATION*.XEL', NULL, NULL, NULL)) AS A
       LEFT JOIN DynamicsPerf..QUERY_PLANS p
              ON dbo.FN_HASH_FROM_UINT64_TO_BINARY(event_data.value('(/event/action[@name = "query_plan_hash"]/value)[1]', 'decimal(38,0)')) = P.QUERY_PLAN_HASH
                 AND dbo.FN_HASH_FROM_UINT64_TO_BINARY(event_data.value('(/event/action[@name = "query_plan_hash"]/value)[1]', 'decimal(38,0)')) <> 0x0000000000000000
LEFT JOIN DYNAMICSPERF..AX_USERINFO U 
	ON	ID=
		dbo.FN_RETURN_AXID_FROM_CONTEXT
				( 
					convert	
					(
						varbinary(128),
						event_data.value('(/event/action[@name = "context_info"]/value)[1]','varchar(128)'),
						2
					) 
				) 

ORDER  BY END_TIME DESC; 



-- --------------------------------------------------------------
--
--			MISC_PERF_EVENTS
-- Long Duration Queries sorted by TIME desc
----------------------------------------------------------------


SELECT TOP 100 *
FROM   (SELECT EVENT_DATA.value('(EVENT/@NAME)[1]', 'VARCHAR(50)')                                                                 AS EVENT_NAME,
               DATEADD(HH, DATEDIFF(HH, GETUTCDATE(), CURRENT_TIMESTAMP), EVENT_DATA.value('(/EVENT/@TIMESTAMP)[1]', 'DATETIME2')) AS END_TIME,
               EVENT_DATA                                                                                                          AS EVENT_DATA
        FROM   (SELECT CONVERT(XML, EVENT_DATA)
                FROM   sys.fn_xe_file_target_read_file('C:\SQLTRACE\DYNPERF_MISC*.XEL', NULL, NULL, NULL)) AS EVTS ( EVENT_DATA )) AS DYNPERF_BLOCKING
--WHERE END_TIME BETWEEN  '2016-02-13 10:19:37.5520000' AND '2016-02-13 10:21:17.9560000' 
ORDER  BY END_TIME DESC; 





-- --------------------------------------------------------------
--
--			AX_CONTEXT_INFO
-- Context_info for Dynamics AX customers
----------------------------------------------------------------

--Read optional CONTEXT_INFO extended event if it was deployed

SELECT TOP 100 *
FROM   (SELECT event_data.value('(event/@name)[1]', 'varchar(50)')                                                                 AS EVENT_NAME,
               DATEADD(HH, DATEDIFF(HH, GETUTCDATE(), CURRENT_TIMESTAMP), EVENT_DATA.value('(/EVENT/@TIMESTAMP)[1]', 'DATETIME2')) AS END_TIME,
               event_data.value('(event/action[@name="session_id"]/value)[1]', 'int')                                              AS SPID,
               event_data.value('(event/data[@name="statement"]/value)[1]', 'varchar(max)')                                        AS STATEMENT
        FROM   (SELECT CONVERT(XML, event_data)
                FROM   sys.fn_xe_file_target_read_file('C:\SQLTRACE\DYNPERF_AX_CONTEXTINFO*.XEL', NULL, NULL, NULL)) AS evts ( event_data )) AS DYNPERF_CONTEXTINFO
--WHERE  END_TIME BETWEEN  '2016-02-13 10:19:37.5520000' AND '2016-02-13 10:21:17.9560000' 
ORDER  BY END_TIME DESC; 




