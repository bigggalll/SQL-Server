function Get-LoadedAssemblies {
  	[appdomain]::currentdomain.getassemblies() | sort -property fullname | format-table fullname 
}
