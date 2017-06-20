SELECT        *   into t_stored_item_audit_20160304
FROM          sys.fn_get_audit_file('t:\audit\Audit_CPSB11P_AAD_t_stored_item%5_B3C7D985-F8DA-4660-A004-EF25A166BACD_0_131014287164120000.sqlaudit',null,null)
where	    event_time between '2016-03-04 4:10' and '2016-03-04 10:30'
ORDER BY      event_time desc