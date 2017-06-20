if not exists (SELECT * FROM RockSolidHistory.Information_Schema.Columns where Table_NAme='InstanceJobExecutionStepHistory' AND Column_Name='EndTime')
BEGIN
 ALTER TABLE RockSolidHistory.[dbo].[InstanceJobExecutionStepHistory]
 add EndTime datetime
END

USE [RockSolid]
GO

/****** Object:  StoredProcedure [dbo].[rrsp_SERVERAGENT_Log_InstanceJobExecutionHistory]    Script Date: 30/01/2017 1:17:27 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER proc [dbo].[rrsp_SERVERAGENT_Log_InstanceJobExecutionHistory]
	@InstanceKey			uniqueidentifier,
	@Job_Id					uniqueidentifier,
	@StartTime				datetime,
	@Duration				int,
	@Step_Id				int,
	@RunOutcome				smallint = NULL,
	@OutcomeMessage			varchar(max)=NULL
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

IF 1=1
BEGIN
	IF @Duration IS NOT NULL AND @Duration>0
	BEGIN
		select	@Duration = ((@Duration/10000)*60*60)+
							((@Duration/100%100) * 60) +
							(@Duration%100)
	END


	DECLARE				@InstanceJobKey						uniqueidentifier,
						@HoursAdd							int,
						@InstanceJobExecutionHistoryKey		bigint

	-- As the hours was passed in as a string we need to time zone convert it
	SELECT				@HoursAdd	= IsNull(HoursAdd,0) * -1
	FROM				dbo.Instance i (nolock)
	LEFT OUTER JOIN		dbo.Location l on i.LocationKey = l.LocationKey
	WHERE				i.InstanceKey = @InstanceKey

	SELECT		@StartTime = DATEADD(hh,@HoursAdd,@StartTime)

	-- Find the job
	SELECT		@InstanceJobKey		= InstanceJobKey
	FROM		dbo.InstanceJob	(nolock)
	WHERE		InstanceKey			= @InstanceKey
	AND			Job_ID				= @Job_Id


	IF	@InstanceJobKey IS NOT NULL
	BEGIN

		-- There shouldn't be a situation where there is multiple rows
		-- where the end date is NULL.  If there is then close them off
		-- using 1/1/1900 to indicate the issue.
		IF (	SELECT COUNT(*)
				FROM	dbo.view_rsperformance_InstanceJobExecutionHistory  (nolock)
				WHERE	InstanceJobKey = @InstanceJobKey
				AND		EndTime IS NULL
			) > 1
		BEGIN
			
				UPDATE	dbo.view_rsperformance_InstanceJobExecutionHistory 
				SET		EndTime = '19000101'
				WHERE	InstanceJobKey = @InstanceJobKey
				AND		EndTime IS NULL
				AND		StartTime < (SELECT MAX(StartTime) FROM dbo.view_rsperformance_InstanceJobExecutionHistory (nolock) WHERE InstanceJobKey = @InstanceJobKey AND EndTime IS NULL)
		END


		SELECT	@InstanceJobExecutionHistoryKey = InstanceJobExecutionHistoryKey
		FROM	dbo.view_rsperformance_InstanceJobExecutionHistory  (nolock)
		WHERE	InstanceJobKey = @InstanceJobKey
		AND		EndTime IS NULL

		-- If the Step ID isn't zero then it is a run time step. 
		IF @Step_ID <> 0
		BEGIN	

			-- So if it is a run time step, check to see if any in progress job history record for this job
			IF @InstanceJobExecutionHistoryKey IS NOT NULL
			BEGIN

				-- If it does only update the start time if the passed in StartTime is less than the current
				-- records start time.
				UPDATE		dbo.view_rsperformance_InstanceJobExecutionHistory 
					SET		StartTime = @StartTime
				WHERE		InstanceJobExecutionHistoryKey = @InstanceJobExecutionHistoryKey
				AND			@StartTime < StartTime

			END
			ELSE
			BEGIN
			
				-- 20130917 Ensure no duplicate job histories are logged
				IF NOT EXISTS(	SELECT	*
								FROM	dbo.view_rsperformance_InstanceJobExecutionHistory (nolock)
								WHERE	InstanceJobKey = @InstanceJobKey
								AND		StartTime = @StartTime
							)
				BEGIN
								
					INSERT dbo.view_rsperformance_InstanceJobExecutionHistory 
					(InstanceJobKey, StartTime)
					VALUES
					(@InstanceJobKey, @StartTime)
					
					SELECT @InstanceJobExecutionHistoryKey = SCOPE_IDENTITY()
				END
				ELSE
				BEGIN
				
					SELECT	@InstanceJobExecutionHistoryKey = InstanceJobExecutionHistoryKey
					FROM	dbo.view_rsperformance_InstanceJobExecutionHistory (nolock)
					WHERE	InstanceJobKey	= @InstanceJobKey
					AND		StartTime		= @StartTime				
				
				END
			END


			EXEC  [rrsp_SERVERAGENT_Log_InstanceJobExecutionStepHistory] @InstanceJobExecutionHistoryKey=@InstanceJobExecutionHistoryKey,@StartTime=@StartTime,@Duration=@Duration, @Step_Id=@Step_Id, @RunOutcome=@RunOutcome, @OutcomeMessage=@OutcomeMessage
		END
		-- Step ID 0 is the Job Completeion step.  Use this step to log the completion data
		ELSE IF @Step_ID = 0
		BEGIN

				UPDATE		dbo.view_rsperformance_InstanceJobExecutionHistory 
					SET		EndTime				= DATEADD(ss,@Duration, @StartTime),
							StartTime			= @StartTime, -- Nessecary to ensure job execute details are not lost 
							RunOutcome			= @RunOutcome,
							OutcomeMessage		= @OutcomeMessage
				WHERE		InstanceJobExecutionHistoryKey = @InstanceJobExecutionHistoryKey
			
		END


	END

	IF EXISTS(SELECT * FROM dbo.InstanceJobNotificationRequest (nolock) WHERE InstanceJobKey=@InstanceJobKey)
	BEGIN

			INSERT	dbo.NOTIFICATION_Email_Out
			(
				EmailFrom, 
				EmailTo, 
				EmailSubject, 
				EmailBody, 
				EmailStatusKey
			)

			SELECT
				(select RockSolidConfigValue from RockSolidConfig WHERE RockSolidConfigCode='REPORTSENDEMAIL'),
				'baint@rocksolidsql.com',
				'SQL Agent Job '+
				case @RunOutcome
				when 0 then 'Failed'
				when 1 then 'Succeded' 
				when 2 then 'Retry' 
				when 3 then 'Cancelled' 
				END + ' [' + i.InstanceName + '].[' + ij.Job_Name +']',
				'The SQL Agent job [' + i.InstanceName + '].[' + ij.Job_Name +'] has executed with an outcome of "'+ case @RunOutcome
				when 0 then 'Failed'
				when 1 then 'Succeded' 
				when 2 then 'Retry' 
				when 3 then 'Cancelled' 
				END +'"<br/>'+
				'The outcome message was:<br/>'+
				'<i>'+@OutcomeMessage +'</i>',
				1
			FROM			dbo.InstanceJobNotificationRequest jnr
			INNER JOIN		dbo.InstanceJob ij on ij.InstanceJobKey = jnr.InstanceJobKey
			INNER JOIN		dbo.Instance i on i.InstanceKey = ij.InstanceKey
			INNER JOIN		dbo.CustomerUser cu on cu.CustomerUserKey = jnr.CustomerUserKey
			inner join		dbo.Customer c on c.CustomerKey = cu.CustomerKey
			WHERE			jnr.InstanceJobKey = @InstanceJobKey
			AND				jnr.JobExecutionType = @RunOutcome
	END

END


GO


USE [RockSolid]
GO

/****** Object:  StoredProcedure [dbo].[rrsp_SERVERAGENT_Log_InstanceJobExecutionStepHistory]    Script Date: 30/01/2017 1:17:36 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





ALTER proc [dbo].[rrsp_SERVERAGENT_Log_InstanceJobExecutionStepHistory]
	@InstanceJobExecutionHistoryKey		bigint,
	@StartTime				datetime,
	@Duration				int,
	@Step_Id				int,
	@RunOutcome				smallint = NULL,
	@OutcomeMessage			varchar(max)=NULL
AS
SET NOCOUNT ON
IF 1=1
BEGIN

	DECLARE				@InstanceJobExecutionHistoryStepKey			bigint

	SELECT	@InstanceJobExecutionHistoryStepKey = InstanceJobExecutionHistoryStepKey
	FROM	dbo.view_rsperformance_InstanceJobExecutionStepHistory (nolock)
	WHERE	InstanceJobExecutionHistoryKey		= @InstanceJobExecutionHistoryKey
	AND		Step_Id								= @Step_Id


	-- So if it is a run time step, check to see if any in progress job history record for this job
	IF @InstanceJobExecutionHistoryStepKey IS NOT NULL
	BEGIN

		-- If it does only update the start time if the passed in StartTime is less than the current
		-- records start time.
		UPDATE		dbo.view_rsperformance_InstanceJobExecutionStepHistory 
			SET		RunOutcome			= @RunOutcome,
					OutcomeMessage		= @OutcomeMessage,
					EndTime				= DATEADD(ss,@Duration, @StartTime)
		WHERE		InstanceJobExecutionHistoryStepKey = @InstanceJobExecutionHistoryStepKey

	END
	ELSE
	BEGIN

		INSERT dbo.view_rsperformance_InstanceJobExecutionStepHistory 
		(InstanceJobExecutionHistoryKey, StartTime, Step_Id,RunOutcome,OutcomeMessage, EndTime )
		VALUES
		(@InstanceJobExecutionHistoryKey, @StartTime, @Step_Id, @RunOutcome, @OutcomeMessage, DATEADD(ss,@Duration, @StartTime))
		
	END



END

GO

