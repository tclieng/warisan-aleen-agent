$node = "C:\Program Files\QClaw\v0.2.35.624\resources\openclaw\config\skills\xbrowser\scripts\xb.cjs"
$nodeArgs = "run --browser chrome"
$out = "C:\Users\MK-User\.qclaw\workspace\warisan-agent"

function xb($cmd) {
    node $node $nodeArgs $cmd 2>&1 | Select-Object -Last 2
}

function wait($ms) {
    Start-Sleep -Milliseconds $ms
}

# Click Copy Token (e74)
xb("click e74")
wait 800

Add-Type -AssemblyName System.Windows.Forms
$clip = [System.Windows.Forms.Clipboard]::GetText()
Write-Host ("CLIP_LEN=" + $clip.Length)
if ($clip.Length -gt 100) {
    Write-Host "=== TOKEN COPY OK ==="
    $clip | Out-File -FilePath "$out\clip_result.txt" -Encoding UTF8
    Write-Host $clip.Substring(0, 300)
} else {
    Write-Host "CLIP_TOO_SHORT"
    Write-Host $clip
}
