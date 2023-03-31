SELECT
t1.resource_type,
t1.resource_database_id,
t1.resource_associated_entity_id,
t1.request_mode,
t1.request_session_id,
t2.blocking_session_id,
o1.name 'object name',
o1.type_desc 'object descr',
p1.partition_id 'partition id',
p1.rows 'partition/page rows',
a1.type_desc 'index descr',
a1.container_id 'index/page container_id'
FROM sys.dm_tran_locks as t1
INNER JOIN sys.dm_os_waiting_tasks as t2
	ON t1.lock_owner_address = t2.resource_address
LEFT OUTER JOIN sys.objects o1 on o1.object_id = t1.resource_associated_entity_id
LEFT OUTER JOIN sys.partitions p1 on p1.hobt_id = t1.resource_associated_entity_id
LEFT OUTER JOIN sys.allocation_units a1 on a1.allocation_unit_id = t1.resource_associated_entity_id

select cmd,* from sys.sysprocesses
where blocked > 0

select  
    object_name(P.object_id) as TableName, 
    resource_type, resource_description
from
    sys.dm_tran_locks L
    join sys.partitions P on L.resource_associated_entity_id = p.hobt_id

SELECT 
         SessionID = s.Session_id,
         resource_type,   
         DatabaseName = DB_NAME(resource_database_id),
         request_mode,
         request_type,
         login_time,
         host_name,
         program_name,
         client_interface_name,
         login_name,
         nt_domain,
         nt_user_name,
         s.status,
         last_request_start_time,
         last_request_end_time,
         s.logical_reads,
         s.reads,
         request_status,
         request_owner_type,
         objectid,
         dbid,
         a.number,
         a.encrypted ,
         a.blocking_session_id,
         a.text       
     FROM   
         sys.dm_tran_locks l
         JOIN sys.dm_exec_sessions s ON l.request_session_id = s.session_id
         LEFT JOIN   
         (
             SELECT  *
             FROM    sys.dm_exec_requests r
             CROSS APPLY sys.dm_exec_sql_text(sql_handle)
         ) a ON s.session_id = a.session_id
     WHERE  
         s.session_id > 50