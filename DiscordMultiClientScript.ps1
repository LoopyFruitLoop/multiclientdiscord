<#
.SYNOPSIS
    Launches a new instance of Discord with a separate profile to prevent loading freezes.

.AUTHOR
    Succulent_Sauze

.DESCRIPTION
    Recent Discord updates prevent multiple instances from sharing the same data folder 
    (causing infinite loading). This script:
    1. Finds the latest Discord version.
    2. Sets a custom User Data Directory (e.g., Discord_Alt) to isolate the new instance.
    3. Launches Discord with the necessary environment variables.

.PARAMETER ProfileName
    Optional. The name of the profile to load. Defaults to "Alt".
    Change this if you want a 3rd or 4th instance (e.g., -ProfileName "Alt2").

.NOTES
    This will create a new folder in %AppData%\Discord_<ProfileName> for the new instance's data.
    You will need to log in again for this new instance, but it will remember you next time.
#>

param(
    [string]$ProfileName = "Alt"
)

# 1. Define the default Discord installation path
$basePath = "$env:LOCALAPPDATA\Discord"

# Check if the directory exists
if (-not (Test-Path $basePath)) {
    Write-Error "Discord installation folder not found at: $basePath"
    exit
}

# 2. Find the subfolder with the highest version number
$latestVersionDir = Get-ChildItem -Path $basePath -Filter "app-*" -Directory | 
                    Sort-Object Name -Descending | 
                    Select-Object -First 1

if ($null -eq $latestVersionDir) {
    Write-Error "No version folders (app-*) found in $basePath"
    exit
}

# 3. Define the custom User Data Directory for this profile
# This is crucial! It tells Discord to use a different folder for settings/cache
# so it doesn't lock up with your main instance.
$customDataDir = "$env:APPDATA\Discord_$ProfileName"

# 4. Set the Environment Variable (Discord uses this to find the data path)
$env:DISCORD_USER_DATA_DIR = $customDataDir

# 5. Construct the full path to the executable
$exePath = Join-Path -Path $latestVersionDir.FullName -ChildPath "Discord.exe"

# 6. Launch the process
if (Test-Path $exePath) {
    Write-Host "Found latest Discord version: $($latestVersionDir.Name)" -ForegroundColor Cyan
    Write-Host "Profile: $ProfileName" -ForegroundColor Yellow
    Write-Host "Data Directory: $customDataDir" -ForegroundColor DarkGray
    Write-Host "Launching new instance..." -ForegroundColor Green
    
    # We pass --multi-instance, but the magic is really in the $env:DISCORD_USER_DATA_DIR above.
    Start-Process -FilePath $exePath -ArgumentList "--multi-instance" -WorkingDirectory $latestVersionDir.FullName
}
else {
    Write-Error "Discord.exe not found at expected path: $exePath"
}