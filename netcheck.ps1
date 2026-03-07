param(
    [string[]]$DnsTargets = @("microsoft.com", "github.com", "cloudflare.com"),
    [string[]]$InternetHosts = @("1.1.1.1", "8.8.8.8", "www.microsoft.com"),
    [string]$PortHost = "www.microsoft.com",
    [int[]]$CommonPorts = @(53, 80, 443, 3389)
)

function Write-Status {
    param(
        [string]$Label,
        [bool]$Ok,
        [string]$Detail
    )

    $color = if ($Ok) { "Green" } else { "Red" }
    $state = if ($Ok) { "OK" } else { "FAIL" }
    Write-Host ("[{0}] {1} - {2}" -f $state, $Label, $Detail) -ForegroundColor $color
}

function Test-TcpPort {
    param(
        [string]$ComputerName,
        [int]$Port,
        [int]$TimeoutMs = 2000
    )

    if (Get-Command Test-NetConnection -ErrorAction SilentlyContinue) {
        return Test-NetConnection -ComputerName $ComputerName -Port $Port -InformationLevel Quiet -WarningAction SilentlyContinue
    }

    $client = New-Object System.Net.Sockets.TcpClient
    try {
        $async = $client.BeginConnect($ComputerName, $Port, $null, $null)
        if (-not $async.AsyncWaitHandle.WaitOne($TimeoutMs, $false)) {
            return $false
        }

        $client.EndConnect($async)
        return $true
    }
    catch {
        return $false
    }
    finally {
        $client.Dispose()
    }
}

Write-Host ""
Write-Host "NETWORK HEALTH CHECK" -ForegroundColor Cyan
Write-Host "--------------------" -ForegroundColor Cyan
Write-Host ""

$defaultRoute = Get-NetRoute -DestinationPrefix "0.0.0.0/0" -ErrorAction SilentlyContinue |
    Where-Object { $_.NextHop -and $_.NextHop -ne "0.0.0.0" } |
    Sort-Object RouteMetric |
    Select-Object -First 1

$gateway = if ($defaultRoute) { $defaultRoute.NextHop } else { $null }
$gatewayOk = $false

if ($gateway) {
    $gatewayOk = Test-Connection -ComputerName $gateway -Count 2 -Quiet -ErrorAction SilentlyContinue
    Write-Status -Label "Gateway Ping" -Ok $gatewayOk -Detail $gateway
}
else {
    Write-Status -Label "Gateway Detection" -Ok $false -Detail "No default gateway found"
}

Write-Host ""
Write-Host "DNS Resolution:" -ForegroundColor Yellow
$dnsResults = foreach ($target in $DnsTargets) {
    try {
        $record = Resolve-DnsName -Name $target -Type A -ErrorAction Stop |
            Select-Object -First 1

        [PSCustomObject]@{
            Target = $target
            Ok = $true
            Detail = $record.IPAddress
        }
    }
    catch {
        [PSCustomObject]@{
            Target = $target
            Ok = $false
            Detail = $_.Exception.Message
        }
    }
}

foreach ($item in $dnsResults) {
    Write-Status -Label ("DNS {0}" -f $item.Target) -Ok $item.Ok -Detail $item.Detail
}

Write-Host ""
Write-Host "Internet Reachability:" -ForegroundColor Yellow
$internetResults = foreach ($targetHost in $InternetHosts) {
    $ok = Test-Connection -ComputerName $targetHost -Count 2 -Quiet -ErrorAction SilentlyContinue
    [PSCustomObject]@{
        Host = $targetHost
        Ok = $ok
    }
}

foreach ($item in $internetResults) {
    Write-Status -Label ("Ping {0}" -f $item.Host) -Ok $item.Ok -Detail "icmp"
}

Write-Host ""
Write-Host ("Port Checks ({0}):" -f $PortHost) -ForegroundColor Yellow
$portResults = foreach ($port in $CommonPorts) {
    $ok = Test-TcpPort -ComputerName $PortHost -Port $port
    [PSCustomObject]@{
        Port = $port
        Ok = $ok
    }
}

foreach ($item in $portResults) {
    Write-Status -Label ("TCP {0}:{1}" -f $PortHost, $item.Port) -Ok $item.Ok -Detail "tcp"
}

$dnsPass = ($dnsResults | Where-Object { $_.Ok }).Count
$internetPass = ($internetResults | Where-Object { $_.Ok }).Count
$portPass = ($portResults | Where-Object { $_.Ok }).Count

Write-Host ""
Write-Host "Summary:" -ForegroundColor Cyan
Write-Host ("DNS       : {0}/{1} passed" -f $dnsPass, $dnsResults.Count)
Write-Host ("Internet  : {0}/{1} passed" -f $internetPass, $internetResults.Count)
Write-Host ("TCP Ports : {0}/{1} passed" -f $portPass, $portResults.Count)

$overallOk = $gatewayOk -and $dnsPass -gt 0 -and $internetPass -gt 0 -and $portPass -gt 0
if (-not $overallOk) {
    exit 1
}
