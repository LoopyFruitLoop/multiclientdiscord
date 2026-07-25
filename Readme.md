# Discord Multi-instance



Past updates to Discord's Electron framework changed how singleton locks function, causing multiple instances sharing a single user profile to collide over the LevelDB lock file and hang indefinitely. This script resolves the database lock collision by automatically locating the latest installed Discord version, isolating the new instance with a custom DISCORD\_USER\_DATA\_DIR environment variable, and launching it in a sandboxed mode that forces the creation of a separate configuration directory.



#### How to Use

\- Download as a zip.

\- Unzip and run the launch shortcut.

\- A second instance of Discord will open



**Note:** You might need to log-in the first time you run this, as it is a fresh profile.



#### Advanced Usage (Custom Profiles)

You can run as many instances as you want by specifying different profile names via the command line.



###### **Windows**

Run the command in PowerShell or Command Prompt inside the repository folder:

Launch a 3rd instance for a gaming account

&#x20; .\\launch\_discord.ps1 -ProfileName "Gaming"

Launch a 4th instance for a work account

&#x20; .\\launch\_discord.ps1 -ProfileName "Work"

Each profile creates a unique folder in %AppData% (e.g., Discord\_Gaming, Discord\_Work).



**Note:** You can also double-click the Launch Discord Multi-Instance shortcut to run the default "Alt" profile.



###### **MacOS**

Open Terminal, navigate to the repository folder using cd, and execute the command using PowerShell Core (pwsh):

&#x20;  pwsh ./src/DiscordMultiClientScript.ps1 -ProfileName "Gaming"



#### Manual Method (Batch/Shortcut)

If you prefer not to use PowerShell, you can create a Windows Shortcut or a .bat file with the following target:



@echo off

set DISCORD\_USER\_DATA\_DIR=%AppData%\\Discord\_Alt

start "" "%LocalAppData%\\Discord\\Update.exe" --processStart Discord.exe --process-start-args "--multi-instance"



*Disclaimer*

*This script is not affiliated with Discord Inc. It simply utilizes built-in Electron environment variables and command-line arguments to facilitate multi-instance functionality.*



