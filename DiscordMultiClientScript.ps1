<#
.SYNOPSIS
    Launches a new instance of Discord with a separate profile.
    V2.0 - Uses .NET ProcessStartInfo for robust environment variable injection.

.AUTHOR
    Succulent_Sauze

.DESCRIPTION
    Launches Discord with a custom User Data Directory to prevent "Singleton Lock" errors
    and infinite loading screens.
#>

param(
    [string]$ProfileName = "Alt"
)

# 1. Platform Detection & Path Setup
$runningOnMac = $IsMacOS -or ($PSVersionTable.OS -match 'Darwin')
$runningOnWin = $IsWindows -or ($env:OS -match 'Windows_NT')

if ($runningOnWin) {
    # Windows: Standard LocalAppData Loaction
    $basePath = "$env:LOCALAPPDATA\Discord"

    if (-not (Test-Path $basePath)) {
        Write-Error "Discord installation folder not found at: $basePath"
        exit
    }

    # Find the latest version folder (app-*)
    $latestVersionDir = Get-ChildItem -Path $basePath -Filter "app-*" -Directory |
    Sort-Object Name -Descending |
    Select-Object -First 1

    if ($null -eq $latestVersionDir) {
        Write-Error "No version folders (app-*) found in $basePath"
        exit
    }

    $exePath = Join-Path -Path $latestVersionDir.FullName -ChildPath "Discord.exe"
    $workingDir = $latestVersionDir.FullName
    $customDataDir = "$env:APPDATA\Discord_$ProfileName"
}
elseif ($runningOnMac) {
    # macOS: Standard Application Path
    $basePath = "/Applications/Discord.app"

    if (-not (Test-Path $basePath)) {
        Write-Error "Discord application not found at: $basePath"
        exit
    }

    # Detailed executable path inside the .app bundle
    $exePath = "$basePath/Contents/MacOS/Discord"
    $workingDir = "$basePath/Contents/MacOS" # Context usually matters less on macOS but good to set

    # macOS Application Support for data
    $customDataDir = "$HOME/Library/Application Support/discord_$ProfileName"
}
else {
    Write-Error "Unsupported Operating System. This script supports Windows and macOS."
    exit
}

if (Test-Path $exePath) {
    Write-Host "Found Discord Executable: $exePath" -ForegroundColor Cyan
    Write-Host "Target Profile: $ProfileName" -ForegroundColor Yellow
    Write-Host "Data Directory: $customDataDir" -ForegroundColor Gray
    Write-Host "Launching isolated instance..." -ForegroundColor Green

    # 3. Use .NET ProcessStartInfo for environment variable injection
    $startInfo = New-Object System.Diagnostics.ProcessStartInfo
    $startInfo.FileName = $exePath
    $startInfo.Arguments = "--multi-instance"
    $startInfo.WorkingDirectory = $workingDir
    $startInfo.UseShellExecute = $false # Required to modify EnvironmentVariables

    # Explicitly set the environment variable for THIS process only
    if ($startInfo.EnvironmentVariables.ContainsKey("DISCORD_USER_DATA_DIR")) {
        $startInfo.EnvironmentVariables["DISCORD_USER_DATA_DIR"] = $customDataDir
    }
    else {
        $startInfo.EnvironmentVariables.Add("DISCORD_USER_DATA_DIR", $customDataDir)
    }

    try {
        [System.Diagnostics.Process]::Start($startInfo) | Out-Null
        Write-Host "Success! New instance started." -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to start process: $_"
    }
}
else {
    Write-Error "Discord executable not found at suspected path: $exePath"
}