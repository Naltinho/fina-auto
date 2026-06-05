# Injeta GOOGLE_MAPS_API_KEY do CONFIG.env nos AndroidManifest
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$ConfigFile = Join-Path $Root "CONFIG.env"

if (-not (Test-Path $ConfigFile)) {
    Write-Host "Crie CONFIG.env a partir de CONFIG.env.template" -ForegroundColor Yellow
    exit 1
}

Get-Content $ConfigFile | ForEach-Object {
    if ($_ -match '^\s*([^#=]+)=(.*)$') {
        Set-Variable -Name $matches[1].Trim() -Value $matches[2].Trim() -Scope Script
    }
}

if (-not $GOOGLE_MAPS_API_KEY -or $GOOGLE_MAPS_API_KEY -eq "SUA_CHAVE_AQUI") {
    Write-Host "Defina GOOGLE_MAPS_API_KEY em CONFIG.env" -ForegroundColor Yellow
    exit 1
}

$manifests = @(
    "$Root\fina_auto_cliente\android\app\src\main\AndroidManifest.xml",
    "$Root\fina_auto_pro\android\app\src\main\AndroidManifest.xml"
)

foreach ($path in $manifests) {
    if (Test-Path $path) {
        (Get-Content $path -Raw) -replace 'SUA_CHAVE_GOOGLE_MAPS', $GOOGLE_MAPS_API_KEY | Set-Content $path -NoNewline
        Write-Host "Atualizado: $path" -ForegroundColor Green
    }
}

Write-Host "Chave Google Maps aplicada." -ForegroundColor Green
