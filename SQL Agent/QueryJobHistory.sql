SELECT
       j.name AS 'JobName'
     , s.step_id AS 'Step'
     , s.step_name AS 'StepName'
     , msdb.dbo.agent_datetime(run_date, run_time) AS 'RunDateTime'
     , ((run_duration / 10000 * 3600 + (run_duration / 100) % 100 * 60 + run_duration % 100 + 31) / 60) AS 'RunDurationMinutes'
	, *
FROM msdb.dbo.sysjobs j
     INNER JOIN msdb.dbo.sysjobsteps s
        ON j.job_id = s.job_id
     INNER JOIN msdb.dbo.sysjobhistory h
        ON s.job_id = h.job_id
           AND s.step_id = h.step_id
           AND h.step_id <> 0
WHERE j.enabled = 1   --Only Enabled Jobs
      AND j.name = 'Qj##sqlMaintenanceBD_Debut' --Uncomment to search for a single job
      --AND msdb.dbo.agent_datetime(run_date, run_time) BETWEEN '2017-12-18' AND '2017-12-19'  --Uncomment for date range queries
ORDER BY
         RunDateTime; 