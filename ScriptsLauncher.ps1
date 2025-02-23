$InstallApps = "https://raw.githubusercontent.com/ZBNZGIT/Win11-Unattended-Scripts/main/Scripts/AppsInstallerChocolatey.bat"     
$RemoveEdge = "https://raw.githubusercontent.com/ZBNZGIT/Win11-Unattended-Scripts/main/Scripts/RemoveEdge.ps1" 
$MASActivation = "https://get.activated.win"

function Run-Script {
    param (
        [string]$scriptUrl,
        [string]$extension = ".ps1"
    )
    try {
        $scriptContent = Invoke-RestMethod -Uri $scriptUrl
        $tempFile = [System.IO.Path]::GetTempFileName() + $extension
        Set-Content -Path $tempFile -Value $scriptContent

        if ($extension -eq ".bat") {
            Start-Process -FilePath "cmd.exe" -ArgumentList "/c $tempFile" -WindowStyle Normal
        } else {
            if ($scriptUrl -eq $MASActivation) {
                # Hide PowerShell window for MAS Activation
                Start-Process -FilePath "powershell.exe" -ArgumentList "-ExecutionPolicy Bypass -File $tempFile" -WindowStyle Hidden
            } else {
                # Show PowerShell window for other scripts
                Start-Process -FilePath "powershell.exe" -ArgumentList "-ExecutionPolicy Bypass -File $tempFile" -WindowStyle Normal
            }
        }
    }
    catch {
        Write-Host "An error occurred while executing the script: $_" -ForegroundColor Yellow
    }
}

function Show-Menu {
    Clear-Host
    Write-Host @"
1. Install Apps
2. Remove Edge
3. Activate Windows
4. Exit
"@
}

do {
    Show-Menu
    $choice = Read-Host "Please select an option (1-4)"
    
    switch ($choice) {
        '1' { Run-Script -scriptUrl $InstallApps -extension ".bat"; exit }
        '2' { Run-Script -scriptUrl $RemoveEdge -extension ".ps1"; exit }
        '3' { Run-Script -scriptUrl $MASActivation -extension ".ps1"; exit }
        '4' { exit }
        default { Write-Host "Invalid choice, please try again." -ForegroundColor Red }
    }
} while ($true)
