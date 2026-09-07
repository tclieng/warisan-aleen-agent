$node = "C:\Program Files\QClaw\v0.2.35.624\resources\openclaw\config\skills\xbrowser\scripts\xb.cjs"
$out = "C:\Users\MK-User\.qclaw\workspace\warisan-agent"

# Close all popups first
$null = & node $node run --browser chrome click e77 2>&1 | Out-Null
Start-Sleep -Milliseconds 300
$null = & node $node run --browser chrome click e78 2>&1 | Out-Null
Start-Sleep -Milliseconds 300
$null = & node $node run --browser chrome click e84 2>&1 | Out-Null
Start-Sleep -Milliseconds 300
$null = & node $node run --browser chrome click e5 2>&1 | Out-Null
Start-Sleep -Milliseconds 300
$null = & node $node run --browser chrome click e6 2>&1 | Out-Null
Start-Sleep -Milliseconds 300
$null = & node $node run --browser chrome click e7 2>&1 | Out-Null
Start-Sleep -Milliseconds 300
$null = & node $node run --browser chrome click e8 2>&1 | Out-Null
Start-Sleep -Milliseconds 300

# Get full snapshot
$snap = & node $node run --browser chrome snapshot 2>&1 | Out-String
$snap | Out-File "$out\explorer_snap.txt" -Encoding UTF8

# Extract key refs
$lines = $snap -split "`n"
$lines | Where-Object { $_ -match "token|Generate|Copy|permission|explorer|Graph API" } | Select-Object -First 15

# Check for EA token
if ($snap -match 'EA[A-Za-z0-9+/=]{50,}') {
    $Matches[0] | Out-File "$out\explorer_token.txt" -Encoding UTF8
    Write-Host "TOKEN_IN_SNAPSHOT"
} else {
    Write-Host "NO_TOKEN_IN_SNAPSHOT"
}
