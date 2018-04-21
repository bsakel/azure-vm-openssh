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

$DownloadUrl = "$OpenSSHDownloadUrl/$OpenSSHDownloadFilename"
$LocalFile = "$LocalTempPath\$OpenSSHDownloadFilename"
Invoke-RestMethod $DownloadUrl -Method Get -OutFile $LocalFile

[System.IO.Compression.ZipFile]::ExtractToDirectory("$LocalFile", "$InstallationFolder")

& "$InstallationFolder\install-sshd.ps1"

New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22

net start sshd
