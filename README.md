The Problem
Previously, you could simply run Discord with --multi-instance. However, recent updates to the Electron framework used by Discord changed how "Singleton Locks" work.
If you try to run two instances on the same user profile, they fight over the LevelDB lock file in your data folder. This results in the second instance getting stuck on the spinner or "Starting..." screen forever.

The Solution

This script automates the fix by:
- Auto-detecting your latest installed Discord version (handling the app-1.0.9xxx folders for you).
- Setting a custom DISCORD_USER_DATA_DIR environment variable.
- Launching Discord in a "sandboxed" data mode.
- This forces the new instance to create its own separate configuration folder (e.g., %AppData%\Discord_Alt), preventing the database lock collision.

How to Use
- Download launch_discord.ps1.
- Right-click the file and select Run with PowerShell.
- A second instance of Discord will open.

Note: You might need to log-in the first time you run this, as it is a fresh profile.

Advanced Usage (Custom Profiles)
You can run as many instances as you want by specifying different profile names via the command line.

Launch a 3rd instance for a gaming account
  .\launch_discord.ps1 -ProfileName "Gaming"
Launch a 4th instance for a work account
  .\launch_discord.ps1 -ProfileName "Work"
Each profile creates a unique folder in %AppData% (e.g., Discord_Gaming, Discord_Work).

Manual Method (Batch/Shortcut)
If you prefer not to use PowerShell, you can create a Windows Shortcut or a .bat file with the following target:

@echo off
set DISCORD_USER_DATA_DIR=%AppData%\Discord_Alt
start "" "%LocalAppData%\Discord\Update.exe" --processStart Discord.exe --process-start-args "--multi-instance"

Disclaimer
This script is not affiliated with Discord Inc. It simply utilizes built-in Electron environment variables and command-line arguments to facilitate multi-instance functionality.
