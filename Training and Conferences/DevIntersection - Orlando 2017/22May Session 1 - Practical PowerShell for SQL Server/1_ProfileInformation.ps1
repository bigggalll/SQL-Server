$profile  # This is where the startup code lives

# Profile in the PowerShell console lives in users documents \ WindowsPowerShell folder
# C:\Users\Administrator\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1

# Profile in the ISE lives in the same directory with a different file name
# C:\Users\Administrator\Documents\WindowsPowerShell\Microsoft.PowerShellISE_profile.ps1

# Examples of startup code
# Loading SMO Assemblies or importing a module you will use
# Functions to start a transcript or stop a transcript
# Commonly used Functions preloaded into your shell

# If the WindowsPowerShell folder does not exist in the Documents folder
# New-Item -ItemType Directory -Path (Split-Path $profile) -Force
# Notepad $profile
# Answer Yes to create it. Otherwise you can do this
# New-Item -ItemType File -Path $profile

