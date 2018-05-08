Param(
    [string] $LocalTempPath = "C:\OpenSSHExtensionTempFolder",
    [string] $OpenSSHDownloadUrl = "https://github.com/PowerShell/Win32-OpenSSH/releases/download/v7.6.1.0p1-Beta",
    [string] $OpenSSHDownloadFilename = "OpenSSH-Win64.zip",
    [string] $InstallationFolder = "C:\Program Files\OpenSSH" 
	)
  
Try {  
    New-Item $LocalTempPath -type directory -force
} catch {
	Write-Host "Folder found. Deleting all files..."
    Get-ChildItem $LocalTempPath -Recurse | Remove-Item -Force
}

# Download from Github
$DownloadUrl = "$OpenSSHDownloadUrl/$OpenSSHDownloadFilename"
$LocalFile = "$LocalTempPath\$OpenSSHDownloadFilename"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-RestMethod $DownloadUrl -Method Get -OutFile $LocalFile

# Extract to the temp folder 
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory("$LocalFile", "$LocalTempPath")

# Copy files to installation folder and run Installation script
New-Item $InstallationFolder -type directory -force
Copy-Item -Path "$LocalTempPath\OpenSSH-Win64\*" -Destination $InstallationFolder
& "$InstallationFolder\install-sshd.ps1"

# Open Firewall port
New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22

# Start the service
net start sshd
