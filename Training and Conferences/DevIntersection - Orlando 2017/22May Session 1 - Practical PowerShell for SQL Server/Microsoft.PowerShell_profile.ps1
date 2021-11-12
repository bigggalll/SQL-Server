. "c:\demos\Practical PowerShell\Get-LoadedAssemblies_Function.ps1"

Start-Transcript -Path "$(Split-Path $profile)\Transcript_$(Get-Date -f 'yyyyMMdd_hhmmss')`.txt"

function bye {
	Stop-Transcript
	Exit
}
