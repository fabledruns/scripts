[Console]::CursorVisible = $false

function Get-Bar($percent) {
    if ($percent -lt 0)   { $percent = 0 }
    if ($percent -gt 100) { $percent = 100 }

    $filled = [math]::Floor($percent / 5)
    $empty  = 20 - $filled

    return ("█" * $filled) + ("░" * $empty)
}

try {
    while ($true) {

        $counters = Get-Counter @(
            '\Processor(_Total)\% Processor Time',
            '\Memory\% Committed Bytes In Use',
            '\PhysicalDisk(_Total)\% Disk Time'
        ) -SampleInterval 1 -MaxSamples 1

        $cpu  = ($counters.CounterSamples | Where-Object Path -like '*Processor(_Total)*').CookedValue
        $ramP = ($counters.CounterSamples | Where-Object Path -like '*Memory*').CookedValue
        $disk = ($counters.CounterSamples | Where-Object Path -like '*PhysicalDisk*').CookedValue

        # GPU usage (sum of 3D engines)
        $gpuCounters = Get-Counter '\GPU Engine(*)\Utilization Percentage'
        $gpu = ($gpuCounters.CounterSamples |
            Where-Object { $_.Path -like '*engtype_3D*' } |
            Measure-Object CookedValue -Sum).Sum

        if (-not $gpu) { $gpu = 0 }

        # System info
        $os = Get-CimInstance Win32_OperatingSystem
        $cpuInfo = Get-CimInstance Win32_Processor
        $gpuInfo = Get-CimInstance Win32_VideoController

        $totalRam = [math]::Round($os.TotalVisibleMemorySize / 1MB,2)
        $freeRam  = [math]::Round($os.FreePhysicalMemory / 1MB,2)
        $usedRam  = $totalRam - $freeRam

        $uptime = (Get-Date) - $os.LastBootUpTime
        $uptimeStr = "{0}d {1}h {2}m" -f $uptime.Days, $uptime.Hours, $uptime.Minutes

        # Colors
        $cpuColor  = if ($cpu  -gt 80) { "Red" } elseif ($cpu  -gt 50) { "Yellow" } else { "Green" }
        $ramColor  = if ($ramP -gt 80) { "Red" } elseif ($ramP -gt 50) { "Yellow" } else { "Green" }
        $diskColor = if ($disk -gt 80) { "Red" } elseif ($disk -gt 50) { "Yellow" } else { "Green" }
        $gpuColor  = if ($gpu  -gt 80) { "Red" } elseif ($gpu  -gt 50) { "Yellow" } else { "Green" }

        Clear-Host

        Write-Host ""
        Write-Host "   SYSTEM MONITOR" -ForegroundColor Cyan
        Write-Host "   --------------"
        Write-Host ""

        Write-Host (" CPU   [{0}] {1,6:N2} %" -f (Get-Bar $cpu), $cpu) -ForegroundColor $cpuColor
        Write-Host (" RAM   [{0}] {1,6:N2} %  ({2} / {3} GB)" -f (Get-Bar $ramP), $ramP, $usedRam, $totalRam) -ForegroundColor $ramColor
        Write-Host (" DISK  [{0}] {1,6:N2} %" -f (Get-Bar $disk), $disk) -ForegroundColor $diskColor
        Write-Host (" GPU   [{0}] {1,6:N2} %" -f (Get-Bar $gpu), $gpu) -ForegroundColor $gpuColor

        Write-Host ""
        Write-Host (" CPU Model : {0}" -f $cpuInfo.Name)
        Write-Host (" GPU Model : {0}" -f $gpuInfo.Name)
        Write-Host (" Uptime    : {0}" -f $uptimeStr)
    }
}
finally {
    [Console]::CursorVisible = $true
}