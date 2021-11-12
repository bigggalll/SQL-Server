WITH JobStepHist (JobName, StepId, StepName, RunStartDateTime, RunDurationSecs, Status, Message
)
AS
(
	SELECT
       j.name AS 'JobName'
     , s.step_id AS 'StepId'
     , s.step_name AS 'StepName'
     , msdb.dbo.agent_datetime(run_date, run_time) AS 'RunDateTime'
	 , ((h.run_duration/1000000)*86400) + (((h.run_duration-((h.run_duration/1000000)*1000000))/10000)*3600) + (((h.run_duration-((h.run_duration/10000)*10000))/100)*60) + (h.run_duration-(h.run_duration/100)*100) as 'RunDurationSecs'
	 , h.run_status
	 , h.[message]
   FROM msdb.dbo.sysjobs j
     INNER JOIN msdb.dbo.sysjobsteps s
        ON j.job_id = s.job_id
     INNER JOIN msdb.dbo.sysjobhistory h
        ON s.job_id = h.job_id
           AND s.step_id = h.step_id
)
SELECT 
	JobName
	, StepId
	, StepName
	, RunStartDateTime
	, DATEADD(s,RunDurationSecs,RunStartDateTime) as RunEndDateTime
	, RunDurationSecs
	, Status
	, Message
FROM 
	JobStepHist j
WHERE RunStartDateTime > GETDATE()-1
--j.enabled = 1   --Only Enabled Jobs
      AND 
	 j.JobName like '%Qj##sqlTrack_Resource%' --Uncomment to search for a single job
      --AND 
--	  msdb.dbo.agent_datetime(run_date, run_time) BETWEEN '2019-02-02' AND '2019-02-04'  --Uncomment for date range queries
--ORDER BY
--         JobName,Step,RunDateTime desc; 