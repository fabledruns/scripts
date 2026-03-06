# scripts

Personal PowerShell scripts for Windows.

## Usage

Right-click any `.ps1` file → **Run with PowerShell**

Or from a terminal:
```powershell
.\scriptname.ps1
```

| Script | Language | Description |
|--------|----------|-------------|
| bootstrap.ps1 | PowerShell | Sets up a fresh Windows machine |
| filescan.ps1 | PowerShell | Lists files larger than 500MB on C: |
| ramhog.ps1 | PowerShell | Shows top 5 RAM-hungry processes |
| sysinfo.ps1 | PowerShell | Live CPU/RAM/Disk/GPU monitor |
| iptracer.js | JavaScript | Traces route to a domain or IP |
| setup.bat | Batch | Downloads all scripts and runs them |


## bootstrap.ps1

Sets up a fresh Windows machine. Installs all apps, dev tools, and removes bloat.
Run as administrator. It will auto-elevate if you forget.

**Installs:** Brave, VS Code Insiders, IntelliJ, WebStorm, Modrinth, Discord, WhatsApp, PowerToys, Windhawk, AFFiNE, Raycast, Blip, Git, Node.js, 7-Zip

**Removes:** Xbox, Gaming App, Get Help, Groove Music, Movies & TV, Solitaire, People, News, Weather

---

## sysinfo.ps1

Live system monitor. Shows CPU, RAM, Disk, and GPU usage with progress bars. Updates every second. Color goes yellow above 50% and red above 80%.
Press `Ctrl+C` to exit.

---

## ramhog.ps1

Shows the top 5 processes eating the most RAM right now.

---

## filescan.ps1

Scans the entire C: drive and lists files larger than 500MB, sorted by size.
