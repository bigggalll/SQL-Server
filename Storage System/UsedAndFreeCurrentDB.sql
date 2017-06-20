SELECT DB_NAME() AS DbName
	,NAME ASFileName
	,size / 128.0 AS CurrentSizeMB
	,size / 128.0 - CAST(FILEPROPERTY(NAME, 'SpaceUsed') AS INT) / 128.0 AS FreeSpaceMB
FROM sys.database_files;
