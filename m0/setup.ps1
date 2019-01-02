#For Windows, install Chocolately for package management
#This has to be run from an admin console
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

#Now install vault and jq using Chocolatey
choco install vault jq -y