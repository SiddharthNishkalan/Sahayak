# Install and launch Work Solute debug APK on connected Android device
$apkPath = "build\app\outputs\flutter-apk\app-debug.apk"

if (-not (Test-Path $apkPath)) {
    Write-Host "APK not found at $apkPath. Building debug APK first..." -ForegroundColor Yellow
    flutter build apk --debug
}

Write-Host "Checking for connected Android devices via ADB..." -ForegroundColor Cyan
$devices = (adb devices) | Where-Object { $_ -match "\bdevice\b" -and $_ -notmatch "List of devices" }

if (-not $devices) {
    Write-Host "`n[!] No authorized device detected." -ForegroundColor Yellow
    Write-Host "Waiting for device connection... Please make sure:" -ForegroundColor Cyan
    Write-Host "  1. Phone is connected to PC via USB cable."
    Write-Host "  2. Screen is UNLOCKED."
    Write-Host "  3. USB Debugging is turned ON in Developer Options."
    Write-Host "  4. Check 'Always allow from this computer' on your phone and tap 'Allow'."
    Write-Host "`nWaiting for device..." -ForegroundColor Green

    adb wait-for-device
}

# Re-check device status
$authorized = (adb devices) | Where-Object { $_ -match "\bdevice\b" -and $_ -notmatch "List of devices" }
if (-not $authorized) {
    $unauth = (adb devices) | Where-Object { $_ -match "unauthorized|offline" }
    if ($unauth) {
        Write-Host "`n[!] Device is connected but unauthorized/offline: $unauth" -ForegroundColor Red
        Write-Host "Please unlock your phone and tap 'Allow USB debugging'." -ForegroundColor Yellow
    }
    exit 1
}

Write-Host "`n[+] Device detected! Installing APK..." -ForegroundColor Green
adb install -r --no-streaming -g $apkPath

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n[+] Installation successful! Launching app..." -ForegroundColor Green
    adb shell am start -n com.example.work_solute/.MainActivity
} else {
    Write-Host "`n[-] Installation failed. Retrying with standard install..." -ForegroundColor Yellow
    adb install -r -g $apkPath
    adb shell am start -n com.example.work_solute/.MainActivity
}
