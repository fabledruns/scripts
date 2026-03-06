if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -ArgumentList "-File `"$PSCommandPath`"" -Verb RunAs
    exit
}

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

Write-Host "==== Dev Machine Bootstrap ===="

if (!(Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "Winget not found. Install 'App Installer' from Microsoft Store."
    pause
    exit
}

function Install-WingetApp {
    param([string]$id)
    try {
        Write-Host "Installing $id"
        winget install --id $id -e --silent --accept-package-agreements --accept-source-agreements
    } catch {
        Write-Host "Failed to install $id`: $_"
    }
}

$wingetApps = @(
    "Brave.Brave",
    "Microsoft.VisualStudioCode.Insiders",
    "JetBrains.IntelliJIDEA.Community",
    "JetBrains.WebStorm",
    "Modrinth.ModrinthApp",
    "Discord.Discord",
    "9NKSQGP7F2NH",
    "Microsoft.PowerToys",
    "RamenSoftware.Windhawk",
    "ToEverything.AFFiNE",
    "9PFXXSHC64H3",
    "9N7JSXC1SJK6"
)

Write-Host "`n==== Installing Winget Apps ===="
foreach ($app in $wingetApps) {
    Install-WingetApp $app
}

$devTools = @(
    "Git.Git",
    "OpenJS.NodeJS",
    "7zip.7zip"
)

Write-Host "`n==== Installing Dev Tools ===="
foreach ($tool in $devTools) {
    Install-WingetApp $tool
}

Write-Host "`n==== Removing Windows Bloat ===="
$bloat = @(
    "Microsoft.XboxApp",
    "Microsoft.GamingApp",
    "Microsoft.GetHelp",
    "Microsoft.ZuneMusic",
    "Microsoft.ZuneVideo",
    "Microsoft.MicrosoftSolitaireCollection",
    "Microsoft.People",
    "Microsoft.BingNews",
    "Microsoft.BingWeather"
)

foreach ($app in $bloat) {
    try {
        $pkg = Get-AppxPackage $app -AllUsers
        if ($pkg) {
            Write-Host "Removing $app"
            Remove-AppxPackage $pkg
        }
    } catch {
        Write-Host "Failed to remove $app`: $_"
    }
}

Write-Host "`n==== Bootstrap Complete ===="
pause