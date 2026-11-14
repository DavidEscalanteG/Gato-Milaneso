param(
    [Parameter(Mandatory = $true)][string]$Godot43,
    [switch]$Render,
    [string]$PythonPDF = ""
)

$ErrorActionPreference = "Stop"
$motor = (Resolve-Path -LiteralPath $Godot43).Path
$version = (& $motor --version | Out-String).Trim()
if ($LASTEXITCODE -ne 0 -or $version -notmatch '^4\.3\.stable\.') {
    throw "Se requiere Godot 4.3 stable. Ejecutable recibido: $version"
}
$proyecto = Split-Path -Parent $PSScriptRoot
$perfil = Join-Path $proyecto "tmp/v"
$salida = Join-Path $proyecto "tmp/verificacion"
New-Item -ItemType Directory -Force $perfil, $salida | Out-Null
$appdataAnterior = $env:APPDATA
$localappdataAnterior = $env:LOCALAPPDATA
$pruebas = [ordered]@{
    registro_personal = "REGISTRO OK"
    errores_guardado = "GUARDADO OK"
    reportes_pendientes = "REPORTES PENDIENTES OK"
    integridad_respuestas = "INTEGRIDAD OK"
    ciclo_vida = "CICLO DE VIDA OK"
    entrada_mapa = "ENTRADA MAPA OK"
    nombres_largos = "NOMBRES LARGOS OK"
    personajes = "PRUEBAS PERSONAJES OK"
    minijuegos = "PRUEBAS MINIJUEGOS OK"
    pausa_audio = "PAUSA Y AUDIO OK"
    exportacion_pdf = "PRUEBA PDF OK"
    acceso_resultados = "PRUEBA ACCESO OK"
    recorrido_completo = "RECORRIDO COMPLETO OK"
}
try {
    $env:APPDATA = $perfil
    $env:LOCALAPPDATA = $perfil
    foreach ($nombre in $pruebas.Keys) {
        $argumentos = @("--path", $proyecto, "res://pruebas/$nombre.tscn", "--quit-after", "18000")
        if (-not $Render) { $argumentos = @("--headless") + $argumentos }
        $adicionales = @()
        $soloLectura = $null
        if ($nombre -eq "errores_guardado") {
            $soloLectura = Join-Path $salida "alias-readonly.cfg"
            Set-Content -LiteralPath $soloLectura -Value "[player]`nusername=`"Prueba`"" -Encoding utf8
            (Get-Item -LiteralPath $soloLectura).IsReadOnly = $true
            $adicionales += "--solo-lectura=$soloLectura"
        }
        if ($nombre -eq "exportacion_pdf") { $adicionales += "--salida=res://tmp/verificacion/pdfs" }
        if ($adicionales.Count -gt 0) { $argumentos += @("--") + $adicionales }
        $log = Join-Path $salida "$nombre.log"
        try {
            & $motor @argumentos *> $log
            $codigo = $LASTEXITCODE
        } finally {
            if ($soloLectura) { (Get-Item -LiteralPath $soloLectura).IsReadOnly = $false }
        }
        $texto = Get-Content -LiteralPath $log -Raw
        if ($codigo -ne 0 -or $texto -notmatch [regex]::Escape($pruebas[$nombre]) -or
            $texto -match 'SCRIPT ERROR:|ObjectDB instances leaked|resources still in use') {
            throw "Falló $nombre. Revisa $log"
        }
        # Solo esta prueba provoca deliberadamente un error de carpeta de salida.
        $errores = ($texto -split "`n") | Where-Object { $_ -match '^ERROR:' }
        foreach ($errorMotor in $errores) {
            if ($nombre -ne "reportes_pendientes" -or $errorMotor -notmatch 'Could not create directory: user://bloqueo-') {
                throw "Error inesperado en $nombre. Revisa $log"
            }
        }
        Write-Output "$nombre OK"
    }
    if ($PythonPDF) {
        & $PythonPDF (Join-Path $PSScriptRoot "validar_pdf.py") (Join-Path $salida "pdfs")
        if ($LASTEXITCODE -ne 0) { throw "Falló validar_pdf.py" }
        & $PythonPDF (Join-Path $PSScriptRoot "renderizar_pdf.py") (Join-Path $salida "pdfs")
        if ($LASTEXITCODE -ne 0) { throw "Falló renderizar_pdf.py" }
    }
    Write-Output "VERIFICACION COMPLETA OK: $($pruebas.Count) suites en Godot $version. Logs: $salida"
} finally {
    $env:APPDATA = $appdataAnterior
    $env:LOCALAPPDATA = $localappdataAnterior
}
