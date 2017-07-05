--DROP TABLE DBA_SQL01p..t_StatsHeader;
--CREATE TABLE DBA_SQL01p..t_StatsHeader (
--	Id [int] IDENTITY(1, 1) NOT NULL
--	,Collection_Datetime DATETIME DEFAULT CURRENT_TIMESTAMP
--	,TableName NVARCHAR(128)
--	,ErrorMessage NVARCHAR(max)
--	,[Name] NVARCHAR(128)
--	,[Updated] DATETIME
--	,[Rows] BIGINT
--	,[Rows Sampled] BIGINT
--	,[Steps] SMALLINT
--	,[Density] REAL
--	,[Average key length] REAL
--	,[String Index] NCHAR(3)
--	,[Filter Expression] NVARCHAR(MAX)
--	,[Unfiltered Rows] BIGINT
--	);
--CREATE NONCLUSTERED INDEX IDX_StatHeader_TableName_StatName ON DBA_SQL01p..t_StatsHeader (
--	TableName ASC
--	,[Name] ASC
--	);
--CREATE NONCLUSTERED INDEX IDX_StatHeader_StatName ON DBA_SQL01p..t_StatsHeader ([Name] ASC);
--CREATE TABLE DBA_SQL01p..t_StatsDensity (
--	Id [int] IDENTITY(1, 1) NOT NULL
--	,Collection_Datetime DATETIME DEFAULT CURRENT_TIMESTAMP
--	,StatName NVARCHAR(128)
--	,TableName NVARCHAR(128)
--	,ErrorMessage NVARCHAR(max)
--	,[All density] REAL
--	,[Average Length] REAL
--	,[Columns] NVARCHAR(4000)
--	,last_updated DATETIME
--	);
--CREATE NONCLUSTERED INDEX IDX_StatDensity_StatName ON DBA_SQL01p..t_StatsDensity (StatName ASC);

--DROP TABLE DBA_SQL01p..t_StatsHistogram;

--CREATE TABLE DBA_SQL01p..t_StatsHistogram (
--	Id [int] IDENTITY(1, 1) NOT NULL
--	,Collection_Datetime DATETIME DEFAULT CURRENT_TIMESTAMP
--	,StatName NVARCHAR(128)
--	,TableName NVARCHAR(128)
--	,ErrorMessage NVARCHAR(max)
--	,Range_hi_key SQL_VARIANT
--	,Range_rows REAL
--	,eq_rows REAL
--	,distinct_range_rows BIGINT
--	,avg_range_rows REAL
--	);

--CREATE NONCLUSTERED INDEX IDX_StatHistogram_StatName ON DBA_SQL01p..t_StatsHistogram (StatName ASC);

-- IMPORTANT
-- =========
-- On doit se positionner sur la bd à investiguer
--
DECLARE @stat_name SYSNAME;
DECLARE @table_name SYSNAME;
DECLARE @schema_name SYSNAME;
DECLARE @no_recompute BIT;
DECLARE @sql VARCHAR(max);

--
-- Sélectionner les stats pour lesquelles ont veut conserver le détail, ceux avec le flag no_recomture à 1
--
DECLARE stats_cursor CURSOR
FOR
SELECT a.NAME stat_name
	,b.NAME stat_owner
	,c.NAME schema_name
	,a.no_recompute
FROM sys.stats a
INNER JOIN sys.objects b ON a.object_id = b.object_id
INNER JOIN sys.schemas c ON b.schema_id = c.schema_id
WHERE a.object_id > 255
	AND b.type <> 'IT';

OPEN stats_cursor;

FETCH NEXT
FROM stats_cursor
INTO @stat_name
	,@table_name
	,@schema_name
	,@no_recompute;

WHILE @@FETCH_STATUS = 0
BEGIN
	SET @sql = 'DBCC SHOW_STATISTICS (''' + QUOTENAME(@schema_name) + '.' + QUOTENAME(@table_name) + ''', ' + QUOTENAME(@stat_name) + ') WITH NO_INFOMSGS, STAT_HEADER;'

	PRINT @sql

	BEGIN TRY
		INSERT INTO DBA_SQL01p..t_StatsHeader (
			[Name]
			,[Updated]
			,[Rows]
			,[Rows Sampled]
			,[Steps]
			,[Density]
			,[Average key length]
			,[String Index]
			,[Filter Expression]
			,[Unfiltered Rows]
			)
		EXEC (@sql);

		UPDATE DBA_SQL01p..t_StatsHeader
		SET TableName = @table_name
		WHERE TableName IS NULL;-- les TableName sont les derniers insérés
	END TRY

	BEGIN CATCH
		PRINT 'ErrorMessage: ' + ERROR_MESSAGE();

		INSERT INTO DBA_SQL01p..t_StatsHeader ([ErrorMessage])
		VALUES (ERROR_MESSAGE());
	END CATCH;

	--
	-- Sauvegarder le détail des statistiques pour les fullscan
	--
	IF (
			SELECT count(*)
			FROM DBA_SQL01p..t_StatsHeader
			WHERE rows = [Rows Sampled]
				AND ErrorMessage IS NULL
				AND id = SCOPE_IDENTITY()
			) = 1
		AND @no_recompute = 1
	BEGIN
		SET @sql = 'DBCC SHOW_STATISTICS (''' + QUOTENAME(@schema_name) + '.' + QUOTENAME(@table_name) + ''', ' + QUOTENAME(@stat_name) + ') WITH NO_INFOMSGS, DENSITY_VECTOR;'

		PRINT @sql

		BEGIN TRY
			INSERT INTO DBA_SQL01p..t_StatsDensity (
				[All density]
				,[Average Length]
				,[Columns]
				)
			EXEC (@sql);

			UPDATE DBA_SQL01p..t_StatsDensity
			SET StatName = @stat_name
				,TableName = @table_name
			WHERE StatName IS NULL
				AND TableName IS NULL;
		END TRY

		BEGIN CATCH
			PRINT 'ErrorMessage: ' + ERROR_MESSAGE();

			INSERT INTO DBA_SQL01p..t_StatsDensity ([ErrorMessage])
			VALUES (ERROR_MESSAGE());
		END CATCH;

		SET @sql = 'DBCC SHOW_STATISTICS (''' + QUOTENAME(@schema_name) + '.' + QUOTENAME(@table_name) + ''', ' + QUOTENAME(@stat_name) + ') WITH NO_INFOMSGS, HISTOGRAM;'

		PRINT @sql

		BEGIN TRY
			INSERT INTO DBA_SQL01p..t_StatsHistogram (
				Range_hi_key
				,Range_rows
				,eq_rows
				,distinct_range_rows
				,avg_range_rows
				)
			EXEC (@sql);

			UPDATE DBA_SQL01p..t_StatsHistogram
			SET StatName = @stat_name
				,TableName = @table_name
			WHERE StatName IS NULL
				AND TableName IS NULL;
		END TRY

		BEGIN CATCH
			PRINT 'ErrorMessage: ' + ERROR_MESSAGE();

			INSERT INTO DBA_SQL01p..t_StatsHistogram ([ErrorMessage])
			VALUES (ERROR_MESSAGE());
		END CATCH;
	END;

	FETCH NEXT
	FROM stats_cursor
	INTO @stat_name
		,@table_name
		,@schema_name
		,@no_recompute;
END;

CLOSE stats_cursor;

DEALLOCATE stats_cursor;
GO


