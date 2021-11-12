DECLARE @svr_name varchar(100)
select @svr_name = CAST(SERVERPROPERTY('ServerName')AS sysname)
CREATE TABLE #temp (
       Id INT IDENTITY(1,1), 
       ParentObject VARCHAR(255),
       [OBJECT] VARCHAR(255),
       Field VARCHAR(255),
       [VALUE] VARCHAR(255)
)
 
CREATE TABLE #DBCCRes (
       Id INT IDENTITY(1,1)PRIMARY KEY CLUSTERED,
       ServerName varchar(100), 
       DBName sysname ,
       dbccLastKnownGood DATETIME,
       RowNum	INT
)
 
DECLARE
	@DBName SYSNAME,
	@SQL    VARCHAR(512);
 
DECLARE dbccpage CURSOR
	LOCAL STATIC FORWARD_ONLY READ_ONLY
	FOR SELECT name
		FROM sys.databases
	WHERE 1 = 1
		AND STATE = 0
		 
OPEN dbccpage;
FETCH NEXT FROM dbccpage INTO @DBName;
WHILE @@FETCH_STATUS = 0
BEGIN
	SET @SQL = 'Use [' + @DBName +'];' + CHAR(10)+ CHAR(13)
	SET @SQL = @SQL + 'DBCC Page ( ['+ @DBName +'],1,9,3) WITH TABLERESULTS;' + CHAR(10)+ CHAR(13)
 
	INSERT INTO #temp
		EXECUTE (@SQL);
	SET @SQL = ''
 
	INSERT INTO #DBCCRes
			( ServerName,DBName, dbccLastKnownGood,RowNum )
		SELECT @svr_name,@DBName, VALUE
				, ROW_NUMBER() OVER (PARTITION BY Field ORDER BY VALUE) AS Rownum
			FROM #temp
			WHERE Field = 'dbi_dbccLastKnownGood';
 
	TRUNCATE TABLE #temp;
 
	FETCH NEXT FROM dbccpage INTO @DBName;
END
CLOSE dbccpage;
DEALLOCATE dbccpage;
 
SELECT ServerName,DBName,dbccLastKnownGood
	FROM #DBCCRes
	WHERE RowNum = 1;
 
DROP TABLE #temp
DROP TABLE #DBCCRes
