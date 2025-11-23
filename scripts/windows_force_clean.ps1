[CmdletBinding()]
param(
    [switch]$KillJava,
    [switch]$KillGradle
)

<#
    Windows ortamında `flutter clean` komutunun "Failed to remove build" hatasıyla
    karşılaşılması durumunda kullanılır. Çalışan süreçleri durdurur ve kilitli
    derleme klasörlerini zorla temizler.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Continue"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Resolve-Path (Join-Path $scriptDir '..')
Set-Location $repoRoot

# Potansiyel kilit oluşturan süreçleri sonlandır
$processNames = @('flutter', 'dart', 'adb')
if ($KillJava) { $processNames += 'java' }
if ($KillGradle) { $processNames += 'gradle' }

foreach ($name in $processNames) {
    Get-Process -Name $name -ErrorAction SilentlyContinue | ForEach-Object {
        try {
            Stop-Process -Id $_.Id -Force -ErrorAction Stop
            Write-Host "Stopped process: $($name) (PID=$($_.Id))"
        } catch {
            Write-Warning "Could not stop $($name) (PID=$($_.Id)): $($_.Exception.Message)"
        }
    }
}

# Kilitlenmeye sebep olabilecek klasörleri kaldır
$cleanupTargets = @(
    'build',
    '.dart_tool',
    '.gradle',
    'android/.gradle',
    'windows/runner/Debug',
    'windows/runner/Release'
)

foreach ($target in $cleanupTargets) {
    $fullPath = Join-Path $repoRoot $target
    if (Test-Path $fullPath) {
        Write-Host "Removing $target ..."
        try {
            Remove-Item $fullPath -Recurse -Force -ErrorAction Stop
        } catch {
            Write-Warning "Could not remove $target: $($_.Exception.Message)"
        }
    }
}

Write-Host "Cleanup finished. You can now run 'flutter pub get' and 'flutter clean'."