[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo")
[System.Reflection.Assembly]::LoadFile("C:\demos\Practical PowerShell\Assemblies\ICSharpCode.SharpZipLib.dll")
[System.Reflection.Assembly]::LoadFrom("C:\demos\Practical PowerShell\Assemblies\ICSharpCode.SharpZipLib.dll")

[System.Reflection.Assembly]::Load("Microsoft.SqlServer.Smo, Version=12.0.0.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91")

Add-Type -AssemblyName Microsoft.SqlServer.Smo

Add-Type -AssemblyName "Microsoft.SqlServer.Smo, Version=11.0.0.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91"


