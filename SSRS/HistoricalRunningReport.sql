USE ReportServer;
GO
SELECT
--Sélectionne les exécutions d'un rapport ou un groupe de rapport passé en paramètre
EL.InstanceName,
COALESCE(SUBSTRING(c.Path, CHARINDEX('/', SUBSTRING(Path, 2, LEN(c.Path)))+2, LEN(c.path)-LEN(SUBSTRING(path, 1, CHARINDEX('/', SUBSTRING(c.Path, 2, LEN(c.Path)))))-1), 'Unknown') AS ItemPath,
SUBSTRING(c.Path, 2, CHARINDEX('/', SUBSTRING(Path, 2, LEN(c.Path)))-1) AS BIApplication,
c.Name,
EL.ReportID,
EL.UserName, 
--    EL.ExecutionId, 
EL.RequestType,
EL.Format,
EL.Parameters, 
--   EL.ItemAction, 
EL.TimeStart,
EL.TimeEnd,
EL.TimeDataRetrieval,
EL.TimeProcessing,
EL.TimeRendering,
EL.Source,
EL.Status,
EL.ByteCount,
EL.[RowCount]
--    EL.AdditionalInfo
FROM dbo.ExecutionLog AS EL WITH (NOLOCK) -- joindre avec le catalog pour avoir le chemin et le nom du rapport
     LEFT OUTER JOIN dbo.Catalog AS C WITH (NOLOCK) ON EL.ReportID = C.ItemID
WHERE c.Name = 'SondageBilingue'
      AND COALESCE(c.Path, 'Unknown') <> ' '
      AND CHARINDEX('/', SUBSTRING(Path, 2, LEN(path))) > 0
ORDER BY TimeStart DESC;