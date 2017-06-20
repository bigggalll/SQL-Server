SELECT SUBSTRING(a.FILENAME, 1, 1) Drive,
       [FILE_SIZE_MB] = CONVERT(  DECIMAL(12, 2), ROUND(a.size / 128.000, 2)),
       [SPACE_USED_MB] = CONVERT( DECIMAL(12, 2), ROUND(FILEPROPERTY(a.name, 'SpaceUsed')/128.000, 2)),
       [FREE_SPACE_MB] = CONVERT( DECIMAL(12, 2), ROUND((a.size-FILEPROPERTY(a.name, 'SpaceUsed'))/128.000, 2)),
       [FREE_SPACE_%] = CONVERT(  DECIMAL(12, 2), (CONVERT(DECIMAL(12, 2), ROUND((a.size-FILEPROPERTY(a.name, 'SpaceUsed'))/128.000, 2))/CONVERT(DECIMAL(12, 2), ROUND(a.size / 128.000, 2))*100)),
       a.NAME,
       a.FILENAME
FROM dbo.sysfiles a
ORDER BY Drive,
         [Name];