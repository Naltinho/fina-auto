# Instala Flutter no Windows (winget ou Chocolatey)
$ErrorActionPreference = "Continue"

function Test-FlutterInstalled {
    try {
        $null = Get-Command flutter -ErrorAction Stop
        flutter --version
        return $true
    } catch {
        return $false
    }
}

if (Test-FlutterInstalled) {
    Write-Host "Flutter ja instalado." -ForegroundColor Green
    exit 0
}

Write-Host "A instalar Flutter..." -ForegroundColor Cyan

if (Get-Command winget -ErrorAction SilentlyContinue) {
    winget install --id Google.Flutter -e --accept-source-agreements --accept-package-agreements
}

if (-not (Test-FlutterInstalled)) {
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        choco install flutter -y
    }
}

if (-not (Test-FlutterInstalled)) {
    Write-Host ""
    Write-Host "Instalacao automatica falhou. Instale manualmente:" -ForegroundColor Yellow
    Write-Host "https://docs.flutter.dev/get-started/install/windows"
    Write-Host "Depois adicione ao PATH: C:\flutter\bin"
    exit 1
}

Write-Host "Flutter instalado com sucesso!" -ForegroundColor Green
flutter doctor
