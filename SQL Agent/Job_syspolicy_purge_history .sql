EXEC msdb.dbo.sp_syspolicy_configure
     @name = Enabled,
     @value = 1;
GO
EXEC msdb.dbo.sp_syspolicy_configure
     @name = N'HistoryRetentionInDays',
     @value = 30;
GO
EXEC msdb.dbo.sp_syspolicy_configure
     @name = N'LogOnSuccess',
     @value = 0;
GO
DECLARE @jobId UNIQUEIDENTIFIER;

-- Obtain the current job identifier that is associated with the PurgeHistory
SELECT @jobId = CAST(current_value AS UNIQUEIDENTIFIER)
FROM msdb.dbo.syspolicy_configuration_internal
WHERE name = N'PurgeHistoryJobGuid';

-- Delete the job identifier association in the syspolicy configuration
IF @jobId IS NOT NULL
    BEGIN
        DELETE FROM msdb.dbo.syspolicy_configuration_internal
        WHERE name = N'PurgeHistoryJobGuid';
        -- Delete the offending job
        IF EXISTS
        (
            SELECT job_id
            FROM msdb.dbo.sysjobs
            WHERE job_id = @jobId
        )
            BEGIN
                EXEC msdb.dbo.sp_delete_job
                     @job_id = @jobId;
            END;
    END;

-- Re-create the job and its association in the syspolicy configuration table
EXEC msdb.dbo.sp_syspolicy_create_purge_job;
GO

USE [msdb]
GO
EXEC msdb.dbo.sp_set_sqlagent_properties  
		@jobhistory_max_rows_per_job=1000
GO