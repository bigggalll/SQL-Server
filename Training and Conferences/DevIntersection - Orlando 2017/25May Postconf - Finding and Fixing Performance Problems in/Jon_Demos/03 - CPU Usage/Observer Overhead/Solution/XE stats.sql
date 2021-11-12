SELECT  [address],
        [name],
        [pending_buffers],
        [total_regular_buffers],
        [regular_buffer_size],
        [total_large_buffers],
        [large_buffer_size],
        [total_buffer_size],
        [buffer_policy_flags],
        [buffer_policy_desc],
        [flags],
        [flag_desc],
        [dropped_event_count],
        [dropped_buffer_count],
        [blocked_event_fire_time],
        [create_time],
        [largest_event_dropped_size]
FROM sys.[dm_xe_sessions] AS dxs;

-- Get events in a session
SELECT 
   ses.name AS session_name,
   sese.package AS event_package,
   sese.name AS event_name,
   sese.predicate AS event_predicate
FROM sys.server_event_sessions AS ses
INNER JOIN sys.server_event_session_events AS sese
    ON ses.event_session_id = sese.event_session_id;

-- Get actions 
SELECT 
   ses.name AS session_name,
   sese.package AS event_package,
   sese.name AS event_name,
   sese.predicate AS event_predicate,
   sesa.package AS action_package,
   sesa.name AS action_name
FROM sys.server_event_sessions AS ses
INNER JOIN sys.server_event_session_events AS sese
    ON ses.event_session_id = sese.event_session_id
INNER JOIN sys.server_event_session_actions AS sesa
     ON ses.event_session_id = sesa.event_session_id
    AND sese.event_id = sesa.event_id;

