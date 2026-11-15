# Exportar para Windows

La configuracion `Windows Desktop` genera una version **release para Windows x64**
con Godot **4.3 stable**, en `output/Windows/El Gato Milaneso.exe`.
Los datos del juego quedan en el archivo PCK y SQLite en su DLL. Los tres archivos
son necesarios. Las pruebas, archivos temporales, bases locales y PDF no se incluyen.

## En esta computadora

La plantilla oficial de Godot 4.3 esta preparada en
`output/plantillas-godot-4.3/windows_release_x86_64.exe`.
Se reutilizo la copia local de la plantilla oficial cuya procedencia esta en
`tmp/.tmp/restauracion-godot43/procedencia-plantillas.json`.

Desde PowerShell, en la carpeta del proyecto:

```powershell
./exportar_windows.ps1
```

El script utiliza el motor 4.3 local y crea
`output/El-Gato-Milaneso-Windows-x64.zip`, con instrucciones y avisos de licencia.
Puedes indicar otra ubicacion del motor 4.3:

```powershell
./exportar_windows.ps1 -Godot43 'C:\ruta\Godot_v4.3-stable_win64_console.exe'
```

Para exportar desde el editor, abre el proyecto con **Godot 4.3**, entra a
**Proyecto > Exportar > Windows Desktop > Exportar proyecto** y desmarca
**Exportar con depuracion**. Usa la ruta propuesta. El script tambien prepara
el ZIP; la exportacion desde el editor solo genera los archivos del juego.

Los registros quedan en `tmp/exportacion-windows/`. Dialogue Manager 2 puede
mostrar errores al retirar su autoload durante el cierre del editor, despues
de `savepack: end`; el script comprueba los errores de importacion y de
empaquetado antes de ese cierre. Comprueba tambien el juego exportado.

## En otra computadora o despues de borrar output

`output/` y `tmp/` son archivos locales, excluidos de Git. Instala las plantillas
oficiales **4.3 stable** desde **Editor > Administrar plantillas de exportacion**.
Copia `windows_release_x86_64.exe` de
`%APPDATA%\Godot\export_templates\4.3.stable\` a
`output/plantillas-godot-4.3/` (crea la carpeta), y proporciona al script la ruta
de Godot 4.3. La plantilla personalizada del preset usa esa ubicacion relativa.

## Enviar al profesor

Envia **El-Gato-Milaneso-Windows-x64.zip completo**. El profesor debe extraerlo y
abrir **El Gato Milaneso.exe**. No necesita Godot ni un instalador. Enviar solo
el EXE dejaria fuera los recursos y SQLite.

La exportacion conserva Forward Plus, como el proyecto; requiere una computadora
compatible con ese renderizador. Comprueba el ZIP extraido antes de entregarlo.
Esta entrega es para la prueba solicitada; el inventario de licencias pendientes
de los recursos originales sigue documentado en `AUTORIAS_Y_LICENCIAS.md`.

## Verificacion de esta entrega

Se comprobo el ZIP extraido con el ejecutable release de Godot 4.3:

- Arranque con Forward Plus, menu y cuatro opciones de dialogo renderizados.
- Escritura en SQLite y generacion de PDF con datos ficticios aislados.
- Recorrido automatico hasta la pantalla final: 26 entradas de escena, cinco
  retos y diez respuestas. El recorrido es asistido; no evalua dificultad humana.
- Integridad del ZIP y ausencia de `pruebas/`, `tmp/`, `output/`, bases locales
  y PDF en los 1328 recursos del PCK.

En el recorrido headless aparecieron errores internos de desconexion de las
senales `tree_entered` y `tree_exiting` del jugador al cambiar escenas. No
impidieron completar la partida ni generar el reporte. No se modifico la logica
del juego para preparar esta exportacion. Los registros `recorrido.stdout.log`
y `recorrido.stderr.log` conservan el resultado en `tmp/exportacion-windows/`.
La prueba grafica `visual-corta` termino sin errores con un perfil temporal corto;
una ruta temporal muy larga produjo errores de cache de shaders en la primera
comprobacion grafica. Estos perfiles de prueba no forman parte del ZIP.

### Actualizacion de fuentes numericas

Los contadores de tiempo, monedas, puntos y rondas y los porcentajes de audio
usan Amplify en el label completo. Las instrucciones con cifras duplican sus
LabelSettings antes de cambiar la fuente; las instrucciones sin cifras conservan
su fuente. Los alias con numeros sobre el jugador tambien usan Amplify. La
captura de alias, la edad, los grados escolares y los mensajes numericos del
evaluador y de validacion quedan legibles con la misma fuente.

Se revisaron 11 capturas y se registraron 33 textos numericos, todos con Amplify,
desde el ZIP extraido. Evidencia local: `tmp/fuentes/capturas/` y
`tmp/fuentes/visual.stdout.log`; la captura grafica termino sin errores.
Para permitir nuevas exportaciones, el explorador de dialogos del complemento
ahora respeta `.gdignore` y omite directorios que no puede abrir; asi no recorre
los perfiles temporales y caches de las pruebas.
