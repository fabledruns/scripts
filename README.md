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
| netcheck.ps1 | PowerShell | Runs quick DNS, gateway, internet, and port checks |
| servicemon.ps1 | PowerShell | Audits critical services and can auto-restart them |
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

---

## netcheck.ps1

Runs a fast network health check:
- Detects and pings the default gateway
- Verifies DNS resolution for known domains
- Tests internet reachability with ICMP ping
- Checks common TCP ports on a target host

Returns exit code `1` when key checks fail.

---

## servicemon.ps1

Monitors critical Windows services and reports anything unhealthy.

Optional behavior:
- `-AutoRestart` tries to start services that are stopped
- `-IncludeRunning` shows healthy services too (by default only issues are shown)

Returns exit code `1` when service problems remain.

---

## iptracer.js

Interactive traceroute helper for domains and IPs.

Features:
- Prompts for a target in the terminal
- Runs `tracert -d` and shows hop-by-hop latency
- Colors pings by quality (fast/medium/slow/timeout)
- Resolves and prints final IP after trace completes

Run with:
```powershell
node .\iptracer.js
```

Type `exit` or `quit` to close.
