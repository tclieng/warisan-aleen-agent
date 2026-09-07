# Check token catcher status and logs
$logFile = "C:\Users\MK-User\.qclaw\workspace\warisan-agent\catcher_log.txt"
if (Test-Path $logFile) {
    Get-Content $logFile -Tail 10
} else {
    Write-Host "No log file found"
}

# Check if token was captured
$tokenFile = "C:\Users\MK-User\.qclaw\workspace\warisan-agent\captured_token.txt"
if (Test-Path $tokenFile) {
    $content = Get-Content $tokenFile -Raw
    if ($content.Length -gt 10) {
        Write-Host "TOKEN_CAPTURED: $content"
    } else {
        Write-Host "TOKEN_EMPTY"
    }
} else {
    Write-Host "NO_TOKEN_FILE"
}
