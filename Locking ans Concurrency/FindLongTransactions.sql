SELECT s.session_id,
       DB_NAME(d.database_id) DBNAME,
       st.text,
	  d.database_transaction_begin_time
FROM master.sys.dm_tran_database_transactions d
     INNER JOIN master.sys.dm_tran_session_transactions s ON d.transaction_id = s.transaction_id
	INNER JOIN sys.dm_exec_requests AS r  with(nolock) ON r.session_id = s.session_id
	OUTER APPLY sys.dm_exec_sql_text(r.sql_handle) AS st
WHERE DATEDIFF(minute, d.database_transaction_begin_time, GETDATE()) > 1;