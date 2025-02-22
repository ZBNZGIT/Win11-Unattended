# stop edge running
$stop = "MicrosoftEdgeUpdate", "OneDrive", "WidgetService", "Widgets", "msedge", "msedgewebview2"
$stop | ForEach-Object { Stop-Process -Name $_ -Force -ErrorAction SilentlyContinue }

# uninstall copilot
Get-AppxPackage -allusers *Microsoft.Windows.Ai.Copilot.Provider* | Remove-AppxPackage

# disable edge updates regedit
reg add "HKLM\SOFTWARE\Microsoft\EdgeUpdate" /v "DoNotUpdateToEdgeWithChromium" /t REG_DWORD /d "1" /f | Out-Null

# allow edge uninstall regedit
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdateDev" /v "AllowUninstall" /t REG_SZ /f | Out-Null

# new folder to uninstall edge
New-Item -Path "$env:SystemRoot\SystemApps\Microsoft.MicrosoftEdge_8wekyb3d8bbwe" -ItemType Directory -ErrorAction SilentlyContinue | Out-Null

# new file to uninstall edge
New-Item -Path "$env:SystemRoot\SystemApps\Microsoft.MicrosoftEdge_8wekyb3d8bbwe" -ItemType File -Name "MicrosoftEdge.exe" -ErrorAction SilentlyContinue | Out-Null

# find edge uninstall string
$regview = [Microsoft.Win32.RegistryView]::Registry32
$microsoft = [Microsoft.Win32.RegistryKey]::OpenBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $regview).
OpenSubKey("SOFTWARE\Microsoft", $true)
$uninstallregkey = $microsoft.OpenSubKey("Windows\CurrentVersion\Uninstall\Microsoft Edge")
try {
    $uninstallstring = $uninstallregkey.GetValue("UninstallString") + " --force-uninstall"
}
catch {
}

# uninstall edge
Start-Process cmd.exe "/c $uninstallstring" -WindowStyle Hidden -Wait

# remove folder file
Remove-Item -Recurse -Force "$env:SystemRoot\SystemApps\Microsoft.MicrosoftEdge_8wekyb3d8bbwe" -ErrorAction SilentlyContinue | Out-Null

# find edgeupdate.exe
$edgeupdate = @(); "LocalApplicationData", "ProgramFilesX86", "ProgramFiles" | ForEach-Object {
    $folder = [Environment]::GetFolderPath($_)
    $edgeupdate += Get-ChildItem "$folder\Microsoft\EdgeUpdate\*.*.*.*\MicrosoftEdgeUpdate.exe" -rec -ea 0
}

# find edgeupdate & allow uninstall regedit
$global:REG = "HKCU:\SOFTWARE", "HKLM:\SOFTWARE", "HKCU:\SOFTWARE\Policies", "HKLM:\SOFTWARE\Policies", "HKCU:\SOFTWARE\WOW6432Node", "HKLM:\SOFTWARE\WOW6432Node", "HKCU:\SOFTWARE\WOW6432Node\Policies", "HKLM:\SOFTWARE\WOW6432Node\Policies"
foreach ($location in $REG) { Remove-Item "$location\Microsoft\EdgeUpdate" -recurse -force -ErrorAction SilentlyContinue }

# uninstall edgeupdate
foreach ($path in $edgeupdate) {
    if (Test-Path $path) { Start-Process -Wait $path -Args "/unregsvc" | Out-Null }
    do { Start-Sleep 3 } while ((Get-Process -Name "setup", "MicrosoftEdge*" -ErrorAction SilentlyContinue).Path -like "*\Microsoft\Edge*")
    if (Test-Path $path) { Start-Process -Wait $path -Args "/uninstall" | Out-Null }
    do { Start-Sleep 3 } while ((Get-Process -Name "setup", "MicrosoftEdge*" -ErrorAction SilentlyContinue).Path -like "*\Microsoft\Edge*")
}

# remove edgewebview regedit
cmd /c "reg delete `"HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft EdgeWebView`" /f >nul 2>&1"
cmd /c "reg delete `"HKCU\Software\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft EdgeWebView`" /f >nul 2>&1"

# remove folders edge edgecore edgeupdate edgewebview temp
Remove-Item -Recurse -Force "$env:SystemDrive\Program Files (x86)\Microsoft" -ErrorAction SilentlyContinue | Out-Null

# remove edge shortcuts
Remove-Item -Recurse -Force "$env:SystemDrive\Windows\System32\config\systemprofile\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\Microsoft Edge.lnk" -ErrorAction SilentlyContinue | Out-Null
Remove-Item -Recurse -Force "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Microsoft Edge.lnk" -ErrorAction SilentlyContinue | Out-Null

$fileSystemProfiles = Get-ChildItem -Path "C:\Users" -Directory | Where-Object { 
    $_.Name -notin @('Public', 'Default', 'Default User', 'All Users') -and 
    (Test-Path -Path "$($_.FullName)\NTUSER.DAT")
}

# Loop through each user profile and clean up Edge shortcuts
foreach ($profile in $fileSystemProfiles) {
    $userProfilePath = $profile.FullName
    
    # Define user-specific paths to clean
    $edgeShortcutPaths = @(
        "$userProfilePath\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\Microsoft Edge.lnk",
        "$userProfilePath\Desktop\Microsoft Edge.lnk",
        "$userProfilePath\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\Microsoft Edge.lnk",
        "$userProfilePath\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\Tombstones\Microsoft Edge.lnk",
        "$userProfilePath\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Microsoft Edge.lnk"
    )

    # Remove Edge shortcuts for each user
    foreach ($path in $edgeShortcutPaths) {
        if (Test-Path -Path $path -PathType Leaf) {
            Remove-Item -Path $path -Force -ErrorAction SilentlyContinue
        }
    }
}

# Clean up common locations
$commonShortcutPaths = @(
    "$env:PUBLIC\Desktop\Microsoft Edge.lnk",
    "$env:ALLUSERSPROFILE\Microsoft\Windows\Start Menu\Programs\Microsoft Edge.lnk",
    "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Microsoft Edge.lnk"
)

foreach ($path in $commonShortcutPaths) {
    if (Test-Path -Path $path -PathType Leaf) {
        Remove-Item -Path $path -Force -ErrorAction SilentlyContinue
    }
}

# Removes Edge in Task Manager Startup Apps for All Users
# Get all user profiles on the system
$userProfiles = Get-CimInstance -ClassName Win32_UserProfile | 
Where-Object { -not $_.Special -and $_.SID -notmatch 'S-1-5-18|S-1-5-19|S-1-5-20' }

foreach ($profile in $userProfiles) {
    $sid = $profile.SID
    $hiveLoaded = $false

    if (-not (Test-Path "Registry::HKEY_USERS\$sid")) {
        $userRegPath = Join-Path $profile.LocalPath "NTUSER.DAT"
        if (Test-Path $userRegPath) {
            reg load "HKU\$sid" $userRegPath | Out-Null
            $hiveLoaded = $true
            Start-Sleep -Seconds 2
        }
    }

    $runKeyPath = "Registry::HKEY_USERS\$sid\Software\Microsoft\Windows\CurrentVersion\Run"

    if (Test-Path $runKeyPath) {
        $properties = Get-ItemProperty -Path $runKeyPath
        $edgeEntries = $properties.PSObject.Properties | 
        Where-Object { $_.Name -like 'MicrosoftEdgeAutoLaunch*' }

        foreach ($entry in $edgeEntries) {
            Remove-ItemProperty -Path $runKeyPath -Name $entry.Name -Force
        }
    }

    if ($hiveLoaded) {
        [gc]::Collect()
        Start-Sleep -Seconds 2
        reg unload "HKU\$sid" | Out-Null
    }
}
