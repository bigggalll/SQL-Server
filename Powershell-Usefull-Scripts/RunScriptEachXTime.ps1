$timeout = new-timespan -Minutes 1
$sw = [diagnostics.stopwatch]::StartNew()
while ($sw.elapsed -lt $timeout){
	Invoke-Sqlcmd -ServerInstance cvga11r\ax01p `
		-InputFile "\\portail.jeancoutu.com\DavWWWRoot\CRX\Secteurs\SBE\BDSQL  Requtes de support\TRANSACTIONS - Lister les actives.sql" `
		| Out-File -filePath "ActivesTransactions - cvga11r -$((get-date).ToString("yyyyMMddThhmmss")).txt"
 	Invoke-Sqlcmd -ServerInstance cvga12p\ax01p `
		-InputFile "\\portail.jeancoutu.com\DavWWWRoot\CRX\Secteurs\SBE\BDSQL  Requtes de support\TRANSACTIONS - Lister les actives.sql" `
		| Out-File -filePath "ActivesTransactions - cvga12p -$((get-date).ToString("yyyyMMddThhmmss")).txt"

    start-sleep -seconds 5
}
 
write-host "Timed out"