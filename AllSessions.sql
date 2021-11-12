set nocount on
set transaction isolation level read committed
select  [sessionid] = s.session_id ,
        [userprocess] = case when s.is_user_process = 0 then 'system'
                             when s.is_user_process = 1 then 'user'
                        end ,
        [login] = s.login_name ,
        [database] = isnull(db_name(r.database_id), N'') ,
        [taskstate] = isnull(t.task_state, N'') ,
        [command] = isnull(r.command, N'') ,
        /*[program] = isnull(s.program_name, n'') ,*/
        [program]= isnull( tempdb.dbo.shb_fn_sqlagentjobname(s.session_id),(isnull(s.program_name, N'') )) , 
        tempdb.dbo.shb_fn_msectohhmmss(isnull(w.wait_duration_ms, 0)) as [waittimems] ,
        [waittype] = isnull(w.wait_type, N'') ,
        [waitresource] = isnull(w.resource_description, N'') ,
        [blockedby] = isnull(convert (varchar, w.blocking_session_id), '') ,
        [headblocker] = case 
            /* session has an active request, is blocked, but is blocking others*/
                             when r2.session_id is not null
                                  and r.blocking_session_id = 0 then '1' 
            /* session is idle but has an open tran and is blocking others*/
                             when r.session_id is null then '1'
                             else ''
                        end ,
        [totalcpums] = tempdb.dbo.shb_fn_msectohhmmss(s.cpu_time) ,
        [totalphysicaliomb] = ( s.reads + s.writes ) * 8 / 1024 ,
        [memoryusekb] = s.memory_usage * 8 ,
        [opentransactions] = isnull(r.open_transaction_count, 0) ,
        [openresultsets] = isnull(r.open_resultset_count, 0) ,
        [logintime] = s.login_time ,
        [lastrequeststarttime] = s.last_request_start_time ,
        [hostname] = isnull(s.host_name, N'') ,
        [netaddress] = CONVERT(VARCHAR(100), isnull(c.client_net_address, N'')),
        sq.[text]
from    sys.dm_exec_sessions s with ( readpast )
        left outer join sys.dm_exec_connections c with ( readpast ) on ( s.session_id = c.session_id )
        left outer join sys.dm_exec_requests r with ( readpast ) on ( s.session_id = r.session_id )
        left outer join sys.dm_os_tasks t with ( readpast ) on ( r.session_id = t.session_id
                                                                 and r.request_id = t.request_id
                                                               )
        left outer join (
    /* in some cases (e.g. parallel queries, also waiting for a worker), one thread can be flagged as */
    /* waiting for several different threads.  this will cause that thread to show up in multiple rows */
    /* in our grid, which we don't want.  use row_number to select the longest wait for each thread, */
    /* and use it as representative of the other wait relationships this thread is involved in. */
                          select    * ,
                                    row_number() over ( partition by waiting_task_address order by wait_duration_ms desc ) as row_num
                          from      sys.dm_os_waiting_tasks with ( readpast )
                        ) w on ( t.task_address = w.waiting_task_address )
                               and w.row_num = 1
        left outer join sys.dm_exec_requests r2 with ( readpast ) on ( r.session_id = r2.blocking_session_id )
    /*  left outer join sys.dm_resource_governor_workload_groups g with ( readpast ) on ( g.group_id = s.group_id )*/
    outer apply sys.dm_exec_sql_text (c.most_recent_sql_handle) sq
order by s.session_id;