$Host.UI.RawUI.WindowTitle = "Scripts Launcher"
$Host.UI.RawUI.WindowSize = New-Object System.Management.Automation.Host.Size(54, 6)

$scripts = @{
    "Install Apps" = "https://raw.githubusercontent.com/ZBNZGIT/Win11-Unattended-Scripts/main/Scripts/AppsInstallerChocolatey.bat"
    "Remove Edge" = "https://raw.githubusercontent.com/ZBNZGIT/Win11-Unattended-Scripts/main/Scripts/RemoveEdge.ps1"
    "Activate Windows" = "https://get.activated.win"
}

$scriptNames = @("Install Apps", "Remove Edge", "Activate Windows")
$index = 0
$confirm = $false

[System.Console]::CursorVisible = $false

function Show-Menu {
    $Host.UI.RawUI.BackgroundColor = 'Black'
    $Host.UI.RawUI.ForegroundColor = 'Green'
    Clear-Host

    Write-Host "Select an option (Use Arrow keys, Enter to confirm)" -ForegroundColor White

    for ($i = 0; $i -lt $scriptNames.Count; $i++) {
        if ($i -eq $index) {
            Write-Host "> $($scriptNames[$i])" -BackgroundColor White -ForegroundColor Black
        } else {
            Write-Host "  $($scriptNames[$i])" -ForegroundColor White
        }
    }
}

function Run-Script {
    param (
        [string]$scriptUrl
    )
    try {
        $extension = if ($scriptUrl -match "\.bat$") { ".bat" } else { ".ps1" }
        $scriptContent = Invoke-RestMethod -Uri $scriptUrl
        $tempFile = [System.IO.Path]::GetTempFileName() + $extension
        Set-Content -Path $tempFile -Value $scriptContent

        if ($extension -eq ".bat") {
            Start-Process -FilePath "cmd.exe" -ArgumentList "/c $tempFile" -WindowStyle Normal
        } else {
            Start-Process -FilePath "powershell.exe" -ArgumentList "-ExecutionPolicy Bypass -File $tempFile" -WindowStyle Normal
        }
    }
    catch {
        Write-Host "An error occurred while executing the script: $_" -ForegroundColor Yellow
    }
}


Show-Menu

while (-not $confirm) {
    $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").VirtualKeyCode
    switch ($key) {
        38 { if ($index -gt 0) { $index-- } }
        40 { if ($index -lt $scriptNames.Count - 1) { $index++ } }
        13 { $confirm = $true }
    }
    Show-Menu
}

[System.Console]::CursorVisible = $true

Clear-Host
Run-Script -scriptUrl $scripts[$scriptNames[$index]]
Start-Sleep -Seconds 2
exit
