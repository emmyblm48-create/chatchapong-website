# สร้างรูปพรีวิวทั้งหมดใหม่ (ต้องมี Google Chrome หรือ Microsoft Edge)
#   - previews/og-image.png      รูปตอนแชร์ลิงก์ portfolio (1200x630)
#   - previews/<ชื่อ>.png         ภาพหน้าเว็บที่สร้าง (แคปทั้งความสูง 1440x2400)
# วิธีใช้: คลิกขวา > Run with PowerShell  หรือ  powershell -ExecutionPolicy Bypass -File make-previews.ps1

$sites = [ordered]@{
    'blm48-membership' = 'https://blm48-membership.vercel.app/|1440,900'
    'blm48'            = 'https://blm48.vercel.app/|1440,2400'
    'emmyblm48'        = 'https://emmyblm48.vercel.app/|1440,2400'
    'dormitory-mju88'  = 'https://dormitory-mju88.vercel.app/|1440,900'
    # เพิ่มเว็บใหม่ตรงนี้: 'ชื่อไฟล์' = 'https://...|1440,2400'  (ความกว้าง,ความสูง)
}

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$out  = Join-Path $root 'previews'
New-Item -ItemType Directory -Force $out | Out-Null

$browser = @(
    "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
    "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe",
    "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $browser) { throw 'ไม่พบ Chrome หรือ Edge' }

function Snap($url, $file, $size) {
    $tmpProfile = Join-Path $env:TEMP "emmy-preview-$([guid]::NewGuid())"
    & $browser --headless=new --disable-gpu --hide-scrollbars --user-data-dir="$tmpProfile" `
        --window-size=$size --virtual-time-budget=8000 --screenshot="$file" $url 2>$null | Out-Null
    Remove-Item -Recurse -Force $tmpProfile -ErrorAction SilentlyContinue
    if (Test-Path $file) { Write-Host "OK  $file" -ForegroundColor Green } else { Write-Host "FAIL $url" -ForegroundColor Red }
}

$template = 'file:///' + ((Join-Path $out 'og-template.html') -replace '\\', '/')
Snap $template (Join-Path $out 'og-image.png') '1200,630'

foreach ($name in $sites.Keys) {
    $url, $size = $sites[$name] -split '\|'
    Snap $url (Join-Path $out "$name.png") $size
}
