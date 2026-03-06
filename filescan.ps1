Get-ChildItem C:\ -File -Recurse -ErrorAction SilentlyContinue |
Where-Object { $_.Length -gt 500MB } |
Sort-Object Length -Descending |
Select-Object FullName,
@{Name="Size (GB)";Expression={[math]::Round($_.Length / 1GB,2)}}