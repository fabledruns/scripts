param(
    [string[]]$CriticalServices = @(
        "wuauserv",
        "WinDefend",
        "Dnscache",
        "EventLog",
        "LanmanWorkstation"
    ),
    [switch]$AutoRestart,
    [switch]$IncludeRunning
)

Write-Host ""
Write-Host "SERVICE MONITOR" -ForegroundColor Cyan
Write-Host "---------------" -ForegroundColor Cyan
Write-Host ""

$results = foreach ($serviceName in $CriticalServices) {
    $svc = Get-Service -Name $serviceName -ErrorAction SilentlyContinue

    if (-not $svc) {
        [PSCustomObject]@{
            Name = $serviceName
            DisplayName = "(not found)"
            Status = "Missing"
            StartMode = "Unknown"
            Action = "None"
            Result = "Service not present"
            IsProblem = $true
        }
        continue
    }

    $cim = Get-CimInstance Win32_Service -Filter "Name='$serviceName'" -ErrorAction SilentlyContinue
    $startMode = if ($cim) { $cim.StartMode } else { "Unknown" }

    $action = "None"
    $result = "Healthy"
    $isProblem = $false

    if ($svc.Status -ne "Running") {
        if ($startMode -eq "Auto") {
            $result = "Not running"
            $isProblem = $true
        }
        elseif ($startMode -eq "Manual") {
            $result = "On-demand (stopped)"
        }
        elseif ($startMode -eq "Disabled") {
            $result = "Disabled service"
        }
        else {
            $result = "Stopped"
            $isProblem = $true
        }

        if ($AutoRestart) {
            if ($startMode -eq "Disabled") {
                $action = "Skipped"
                $result = "Disabled service"
            }
            elseif ($startMode -ne "Auto") {
                $action = "Skipped"
            }
            else {
                try {
                    Start-Service -Name $serviceName -ErrorAction Stop
                    Start-Sleep -Milliseconds 500
                    $svc = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
                    if ($svc.Status -eq "Running") {
                        $action = "Start-Service"
                        $result = "Recovered"
                        $isProblem = $false
                    }
                    else {
                        $action = "Start-Service"
                        $result = "Still not running"
                        $isProblem = $true
                    }
                }
                catch {
                    $action = "Start-Service"
                    $result = $_.Exception.Message
                    $isProblem = $true
                }
            }
        }
    }

    [PSCustomObject]@{
        Name = $serviceName
        DisplayName = $svc.DisplayName
        Status = $svc.Status.ToString()
        StartMode = $startMode
        Action = $action
        Result = $result
        IsProblem = $isProblem
    }
}

if (-not $IncludeRunning) {
    $results = $results | Where-Object { $_.IsProblem }
}

if (-not $results) {
    Write-Host "All monitored services are healthy." -ForegroundColor Green
    exit 0
}

$results |
    Select-Object Name, DisplayName, Status, StartMode, Action, Result |
    Format-Table -AutoSize

$problemCount = ($results | Where-Object { $_.IsProblem }).Count
if ($problemCount -gt 0) {
    exit 1
}
