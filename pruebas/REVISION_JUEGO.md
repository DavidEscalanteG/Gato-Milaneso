# Revisión vigente del juego - 14 de noviembre de 2026

El motor de referencia es **Godot 4.3 stable**, validado con
`4.3.stable.official.77dcf97d8` y Forward Plus. El proyecto no requiere migrar a 4.7.

## Cambios actuales

- Escape abre una pausa con continuar, música, efectos y salida confirmada al
  menú. AUDIO permite ajustar el sonido desde el menú principal. Los ajustes se
  conservan en `audio.cfg`; los cronómetros y la música del reto se reanudan.
- Perros muestra una barra hasta la aparición de la cartera, sin cambiar sus
  esperas ni la ayuda existente. El cierre detiene el audio antes de salir.
- [Pausa y audio](PAUSA_Y_AUDIO.md) documenta estos cambios, sus controles y las
  pruebas nuevas. Se mantiene la legibilidad aprobada y el triángulo de orientación.
- El creador conserva las 20 combinaciones de cuerpo y cabello, el color, la
  opción sin pelo y la alineación de la silla en mapa y perros.
- Flechas, Tab y Enter permiten recorrer las selecciones del creador. Volver
  conserva la apariencia y el borrador de datos personales.
- El formulario valida nombre y edad de **6 a 18 años**; sus avisos usan panel
  claro y texto oscuro. El alias rechaza una captura vacía.
- Corregir los datos de una misma partida actualiza su registro; otro
  participante obtiene uno distinto. Los fallos de escritura conservan la captura.
- El mapa conserva la velocidad diagonal normalizada y su animación. Una entrada
  ignora pulsaciones repetidas durante el fundido.
- Los nombres largos conservan sus datos completos. En el mapa quedan dentro de
  su espacio y el nombre del hablante utiliza puntos suspensivos si lo necesita.
- La victoria de perros acepta Enter/Espacio una sola vez. Se conserva la ayuda
  que aparece después de tres derrotas y la dificultad acordada de cada reto.
- Música, monedas y topo controlan una sola vez cada acierto/fallo y respetan las
  vidas y estados de ronda. Las instrucciones describen las reglas actuales.
- Todas las respuestas comienzan pendientes; un reporte final requiere las diez.
  La pregunta 10 se registra por separado y no cambia el puntaje de 0 a 27.
- Una exportación fallida conserva una copia recuperable de las respuestas. El
  apartado protegido del responsable permite recuperar esos reportes.
- Las esperas y animaciones de las escenas se cancelan al abandonarlas. La nueva
  partida reinicia progreso y respuestas.

El diseño habitual, la intro con «Cargando...», las preguntas, la máquina de
premios y sus dos mensajes de victoria se conservan. A los avisos y correcciones
anteriores se añaden únicamente el panel de pausa/audio, sus accesos y la barra
de perros acordados en esta ronda.

## Repetir la verificación

La ejecución integrada anterior del 14 de noviembre de 2026 terminó con
**VERIFICACION COMPLETA OK: 12 suites**, con `-Render` y la comprobación Python
de los 18 PDF. Incluyó el fallo real de guardar el alias en un archivo de solo
lectura y no dejó errores de script ni avisos de objetos filtrados al cerrar.

Después de incorporar pausa y audio, la verificación integrada terminó con
**13 suites correctas** sin `-Render`, y la nueva suite se ejecutó además con
renderizado y revisión de capturas. Esta pasada no repitió la inspección externa
de las páginas PDF.

Desde PowerShell en la raíz del proyecto, indica el ejecutable **console de 4.3**:

```powershell
$motor43 = 'C:\ruta\Godot_v4.3-stable_win64_console.exe'
& $motor43 --version
./pruebas/ejecutar_pruebas.ps1 -Godot43 $motor43
```

La ruta utilizada en esta estación es
`tmp/.tmp/restauracion-godot43/motor/Godot_v4.3-stable_win64_console.exe`;
no pertenece al repositorio. No se usa el comando genérico `godot` del PATH.
Abre antes `project.godot` con el editor 4.3 y espera la importación de recursos.
En una copia sin caché puede ser necesario cerrar y volver a importar para que
el editor resuelva todos los autoloads después de importar imágenes y audio.

El comando ejecuta trece suites, aísla APPDATA/LOCALAPPDATA bajo
`tmp/v`, conserva logs bajo `tmp/verificacion` y restaura las variables
al terminar. Comprueba código de salida, marcador de éxito y errores de script o
recursos al cerrar. Las pruebas de fallos provocan deliberadamente errores de
almacenamiento, que no se confunden con fallos de la suite.

La ruta corta del perfil evita errores de caché de shaders de 4.3 en rutas Windows
muy largas. Si el proyecto está en una ruta extensa y aparecen errores en
`_initialize_cache`, cópialo a una ruta más corta para repetir la prueba renderizada;
no es necesario cambiar la versión ni el renderizador del proyecto.

Para verificar también la selección real con el ratón y el renderizado:

```powershell
./pruebas/ejecutar_pruebas.ps1 -Godot43 $motor43 -Render
```

`recorrido_completo.tscn` integra la captura, los diálogos, las entradas del mapa,
los cinco retos y el PDF final: **26 entradas de escena, diez respuestas**. Resuelve
los retos de forma asistida; no mide dificultad ni comprensión humana. Requiere
APPDATA bajo `tmp/`. No se debe ejecutar contra los datos reales del responsable.

Para obtener capturas de personajes o nombres largos, ejecuta su escena sin
`--headless` y agrega `-- --capturas=res://tmp/capturas`.

## Controles vigentes

| Contexto | Control |
| --- | --- |
| Formulario y creador | Ratón; Tab para cambiar foco; flechas y Enter en selecciones. |
| Mapa | WASD o flechas para moverse; E junto al destino disponible. |
| Diálogos | Clic o Enter/Espacio para avanzar cuando corresponde; seleccionar una opción para responder. |
| Perros | A/D o flechas izquierda/derecha; Enter/Espacio tras recoger la cartera. |
| Música | Espacio o clic en la franja amarilla al cruzar una esfera. |
| Máquina | Clic en la palanca, Enter o Espacio para girar. |
| Monedas y topo | Clic izquierdo sobre el objeto. |
| Derrota | Espacio para reintentar; perros ofrece ayuda tras tres derrotas. |
| Pausa durante la partida | Escape; CONTINUAR o Escape para regresar al punto anterior. |
| Ajustes de audio | AUDIO en el menú principal, o deslizadores de la pausa. |
| Pantalla final | Espacio al guardar correctamente; R para reintentar si falla. |
| Responsable, desde menú | Ctrl + Shift + E y contraseña. |

## Alcance del cierre

Los cambios y commits A01-A16 están en [ESTADO_AUDITORIA.md](ESTADO_AUDITORIA.md).
A09, A13 y A16 permanecen excluidos por decisión del usuario. Esta verificación
no certifica una distribución Windows nueva ni una partida con jugadores reales.
Se incorporó la pausa descrita arriba. No se añadieron ajustes de destellos,
guardado general de progreso ni un rediseño de las pantallas existentes.
