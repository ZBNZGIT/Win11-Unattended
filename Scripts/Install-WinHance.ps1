Write-Host "Downloading Winhance..."
$installerPath = "$env:TEMP\Winhance.Installer.exe"
$wc = New-Object System.Net.WebClient
$wc.DownloadFile("https://github.com/memstechtips/Winhance/releases/latest/download/Winhance.Installer.exe", $installerPath)
Start-Process -FilePath $installerPath
exit
