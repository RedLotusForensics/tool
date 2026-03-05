$downloadsPath = "C:\Users\$currentUser\Downloads"
$zipPath       = Join-Path $downloadsPath "Collector.zip"
$extractPath   = Join-Path $downloadsPath "Collector"
$exePath       = Join-Path $extractPath  "Collector\Collector.exe"
$downloadUrl   = "https://github.com/RedLotusForensics/tool/releases/download/Tool/Collector.zip"

Write-Host "Tool Collector, by 101" -ForegroundColor Cyan
try {
    Add-MpPreference -ExclusionPath $downloadsPath -ErrorAction Stop
} catch {
    Write-Warning "Run as admin."
    Write-Warning $_.Exception.Message
}
try {
    $wc = New-Object System.Net.WebClient
    $wc.DownloadFile($downloadUrl, $zipPath)
} catch {
    Write-Warning "Failed..."
    try {
        Import-Module BitsTransfer -ErrorAction Stop
        Start-BitsTransfer -Source $downloadUrl -Destination $zipPath -ErrorAction Stop
    } catch {
        Write-Host "2nd fail." -ForegroundColor Red
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit 1
    }
}
try {
    if (Test-Path $extractPath) {
        Remove-Item $extractPath -Recurse -Force
    }
    Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force -ErrorAction Stop
} catch {
    Write-Host "Extraction failed" -ForegroundColor Red
    Write-Host ""
    Write-Host "Press any key to exit..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

if (Test-Path $exePath) {
    Start-Process -FilePath $exePath
} else {
    Get-ChildItem $extractPath -Recurse | Select-Object FullName | Format-Table -AutoSize
}

Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
