Here's how to enable script execution in PowerShell: 
Open PowerShell as Administrator:
Search for "PowerShell" in the Start Menu.
Right-click on "Windows PowerShell" and select "Run as administrator."
Set-ExecutionPolicy Unrestricted
Set-ExecutionPolicy RemoteSigned
Set-ExecutionPolicy Restricted

Download wav from 
https://github.com/marcos-patroni/nam_plugin_tonex/raw/refs/heads/main/GuitarAudio.wav
https://github.com/marcos-patroni/nam_plugin_tonex/raw/refs/heads/main/BassAudio.wav
https://github.com/marcos-patroni/nam_plugin_tonex/blob/main/nam_plugin_tonex.ps1

Render guitar or bass wav using your favorite FX plugin


Write nam_plugin_tonex.ps1 in the same folder that are your waves with FX rendered

Start nam_plugin_tonex.ps1 with PowerShell
