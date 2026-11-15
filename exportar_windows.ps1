param([string]$Godot43 = "")

$ErrorActionPreference = "Stop"
$proyecto = $PSScriptRoot
if (-not $Godot43) {
    $Godot43 = Join-Path $proyecto "tmp/.tmp/restauracion-godot43/motor/Godot_v4.3-stable_win64_console.exe"
}
$motor = (Resolve-Path -LiteralPath $Godot43).Path
$version = (& $motor --version | Out-String).Trim()
if ($LASTEXITCODE -ne 0 -or $version -notmatch '^4\.3\.stable\.') {
    throw "Usa Godot 4.3 stable. Version recibida: $version"
}
$plantilla = Join-Path $proyecto "output/plantillas-godot-4.3/windows_release_x86_64.exe"
if (-not (Test-Path -LiteralPath $plantilla)) {
    throw "Falta $plantilla. Consulta EXPORTAR_WINDOWS.md para instalar las plantillas."
}
$salida = Join-Path $proyecto "output/Windows"
$logs = Join-Path $proyecto "tmp/exportacion-windows"
New-Item -ItemType Directory -Force -Path $salida, $logs | Out-Null
Set-Content -LiteralPath (Join-Path $proyecto "output/.gdignore") -Value "" -Encoding ascii
$ejecutable = Join-Path $salida "El Gato Milaneso.exe"
$log = Join-Path $logs "exportacion.log"
$importacion = Join-Path $logs "importacion.log"
& $motor --headless --editor --path $proyecto --import *> $importacion
if ($LASTEXITCODE -ne 0 -or (Get-Content -LiteralPath $importacion -Raw) -match 'SCRIPT ERROR:|^ERROR:|\nERROR:') {
    throw "Fallo la importacion. Revisa $importacion"
}
& $motor --headless --path $proyecto --export-release "Windows Desktop" $ejecutable *> $log
$codigoExportacion = $LASTEXITCODE
$textoExportacion = Get-Content -LiteralPath $log -Raw
$finPaquete = $textoExportacion.LastIndexOf("savepack: end")
# Dialogue Manager 2 puede recargar scripts al quitar su autoload durante el
# cierre del editor. Los errores de empaquetado se comprueban antes de ese cierre.
if ($codigoExportacion -ne 0 -or $finPaquete -lt 0) {
    throw "Fallo la exportacion. Revisa $log"
}
if ($textoExportacion.Substring(0, $finPaquete) -match 'SCRIPT ERROR:|^ERROR:|\nERROR:') {
    throw "Fallo la exportacion. Revisa $log"
}
$archivos = @("El Gato Milaneso.exe", "El Gato Milaneso.pck", "libgdsqlite.windows.template_release.x86_64.dll")
foreach ($archivo in $archivos) {
    if (-not (Test-Path -LiteralPath (Join-Path $salida $archivo))) {
        throw "Falta un archivo de la exportacion: $archivo"
    }
}
Copy-Item -LiteralPath (Join-Path $proyecto "GUIA_EVALUADOR.md") -Destination $salida
$licencias = Join-Path $salida "Licencias"
New-Item -ItemType Directory -Force -Path $licencias | Out-Null
$avisos = @{
    "licencias/Godot-4.3-LICENSE.txt" = "Godot-MIT.txt"
    "LICENSE" = "Proyecto-MIT.txt"
    "addons/dialogue_manager/LICENSE" = "Dialogue-Manager-MIT.txt"
    "addons/godot-sqlite/LICENSE.md" = "godot-sqlite-MIT.txt"
    "Assets/FreeCatCharacterAnimations/License.txt" = "FreeCatCharacterAnimations.txt"
    "AUTORIAS_Y_LICENCIAS.md" = "AUTORIAS_Y_LICENCIAS.md"
}
foreach ($origen in $avisos.Keys) {
    Copy-Item -LiteralPath (Join-Path $proyecto $origen) -Destination (Join-Path $licencias $avisos[$origen])
}
@'
EL GATO MILANESO - Prueba para Windows de 64 bits

1. Extrae TODO el ZIP en una carpeta.
2. Abre "El Gato Milaneso.exe". No necesitas instalar Godot.
3. Conserva juntos el EXE, el PCK y la DLL de SQLite.

Movimiento: WASD o flechas. Interactuar: E o clic. Pausa: Escape.
El juego solicita nombre y alias; para esta prueba puedes usar datos ficticios.
Consulta GUIA_EVALUADOR.md para abrir los resultados (Ctrl + Shift + E en el menu).
'@ | Set-Content -LiteralPath (Join-Path $salida "LEEME.txt") -Encoding utf8
$paquete = Join-Path $proyecto "output/El-Gato-Milaneso-Windows-x64.zip"
# La lista explicita evita agregar archivos antiguos o datos de otras pruebas.
$contenido = @($archivos | ForEach-Object { Join-Path $salida $_ })
$contenido += @("LEEME.txt", "GUIA_EVALUADOR.md", "Licencias") | ForEach-Object { Join-Path $salida $_ }
Compress-Archive -LiteralPath $contenido -DestinationPath $paquete -Force
Write-Output "Exportacion lista ($version): $paquete"
