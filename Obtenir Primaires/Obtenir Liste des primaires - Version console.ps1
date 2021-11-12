$GetCIRXPrimaries = $PSScriptRoot + "\Get-CIRXPrimaries.ps1"

If (Test-Path -Path $GetCIRXPrimaries)
{
    .$GetCIRXPrimaries
}

Get-CIRXPrimaries -Outgrid 