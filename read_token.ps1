$node = "C:\Program Files\QClaw\v0.2.35.624\resources\openclaw\config\skills\xbrowser\scripts\xb.cjs"
$out = "C:\Users\MK-User\.qclaw\workspace\warisan-agent"

# Close all overlays first
$null = node $node run --browser chrome click e63 2>&1 | Select-Object -Last 1
Start-Sleep -Milliseconds 300
$null = node $node run --browser chrome click e75 2>&1 | Select-Object -Last 1
Start-Sleep -Milliseconds 300
$null = node $node run --browser chrome click e77 2>&1 | Select-Object -Last 1
Start-Sleep -Milliseconds 300
$null = node $node run --browser chrome click e78 2>&1 | Select-Object -Last 1
Start-Sleep -Milliseconds 300

# Get full snapshot JSON
$snap = node $node run --browser chrome snapshot 2>&1 | Out-String
$snap | Out-File -FilePath "$out\snapshot_raw.txt" -Encoding UTF8

# Extract token from the textbox that looks like a token (starts with EA...)
if ($snap -match 'EA[A-Za-z0-9+/=]{50,}') {
    $token = $Matches[0]
    Write-Host "TOKEN_FOUND length=$($token.Length)"
    $token | Out-File -FilePath "$out\user_token.txt" -Encoding UTF8
    Write-Host $token
} else {
    Write-Host "TOKEN_NOT_FOUND"
    Write-Host "Searching for EA pattern..."
    $snap -split "`n" | Where-Object { $_ -match 'EA[A-Za-z0-9]' } | ForEach-Object { Write-Host $_ }
}
