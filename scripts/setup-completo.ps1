# Setup completo Fina-Auto — execute como Administrador se possivel
$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $Root

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  FINA-AUTO — Setup Completo" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# 1. Flutter
& "$Root\scripts\install-flutter.ps1"
if ($LASTEXITCODE -ne 0 -and -not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Host "Continuando sem Flutter no PATH..." -ForegroundColor Yellow
}

function Invoke-Flutter {
    param([string[]]$Args)
    if (Get-Command flutter -ErrorAction SilentlyContinue) {
        & flutter @Args
    } else {
        Write-Host "SKIP (flutter nao encontrado): flutter $($Args -join ' ')" -ForegroundColor DarkYellow
    }
}

# 2. Projetos Flutter
$apps = @("fina_auto_cliente", "fina_auto_pro")
foreach ($app in $apps) {
    Write-Host "`n--- $app ---" -ForegroundColor Cyan
    $path = Join-Path $Root $app
    Set-Location $path

    if (-not (Test-Path "android\local.properties")) {
        Invoke-Flutter create . --project-name ($app -replace '-', '_') --org com.finaauto
    }
    Invoke-Flutter pub get
}

Set-Location $Root

# 3. CONFIG.env
if (-not (Test-Path "CONFIG.env")) {
    Copy-Item "CONFIG.env.template" "CONFIG.env"
    Write-Host "`nCriado CONFIG.env — EDITE com as suas chaves!" -ForegroundColor Yellow
}

if (Test-Path "CONFIG.env") {
    & "$Root\scripts\inject-config.ps1"
}

# 4. Firebase CLI
if (-not (Get-Command firebase -ErrorAction SilentlyContinue)) {
    Write-Host "`nA instalar Firebase CLI (npm)..." -ForegroundColor Cyan
    if (Get-Command npm -ErrorAction SilentlyContinue) {
        npm install -g firebase-tools
    } else {
        Write-Host "Instale Node.js: https://nodejs.org" -ForegroundColor Yellow
    }
}

# 5. FlutterFire CLI
if (Get-Command dart -ErrorAction SilentlyContinue) {
    dart pub global activate flutterfire_cli 2>$null
}

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "  Codigo pronto! Falta apenas CONSOLE:" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host @"

1. Firebase Console (5 min):
   https://console.firebase.google.com
   - Criar projeto: fina-auto
   - Authentication > Email/Password > Ativar
   - Firestore > Criar base de dados
   - Adicionar app Android: com.finaauto.cliente
   - Adicionar app Android: com.finaauto.pro
   - Descarregar google-services.json para cada android/app/

2. Em cada app (com Firebase CLI logado):
   cd fina_auto_cliente
   dart run flutterfire_cli:flutterfire configure
   cd ..\fina_auto_pro
   dart run flutterfire_cli:flutterfire configure

3. Google Cloud Console:
   - Ativar Maps SDK for Android
   - Criar API Key > colar em CONFIG.env > executar inject-config.ps1

4. Deploy regras Firestore:
   firebase login
   firebase deploy --only firestore

5. Executar:
   cd fina_auto_cliente && flutter run
   cd fina_auto_pro && flutter run

Guia detalhado: SETUP_COMPLETO.md

"@ -ForegroundColor White
