
SELECT *
FROM DBA_log..WhoIsActive
WHERE collection_time > '2017-11-13 23:50:00'
      AND CAST(sql_text AS VARCHAR(MAX)) LIKE '%I_855USERIDX%';