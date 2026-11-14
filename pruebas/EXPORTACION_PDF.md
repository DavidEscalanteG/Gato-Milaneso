# Cuestionario y reportes PDF

## Contenido y reglas conservadas

El PDF contiene nombre completo, alias, fecha local, diez preguntas y sus
respuestas, puntaje de las preguntas 1 a 9 y clasificación registrada. Conserva
el texto del cuestionario del juego; esta revisión no modifica ni valida su
interpretación. La pregunta 10 no suma al total, cuyo máximo sigue siendo 27.

Todas las preguntas comienzan en `-1` (pendiente). Una respuesta con valor cero
es válida y distinta de una pendiente. La pantalla final y la recuperación
requieren diez respuestas entre 0 y 3. Un diagnóstico incompleto solo se genera
si una prueba solicita expresamente `permitir_incompleto = true`; sus filas dicen
«Sin responder» y no se entrega como reporte definitivo.

La tabla conserva juntas las filas y repite encabezados, fecha y paginación. Los
nombres y alias largos se distribuyen en líneas/páginas sin perder su contenido.
Se comprobaron acentos, ñ, ü, signos españoles, paréntesis y barras. La fuente
actual utiliza WinAnsi; otros alfabetos o emojis no se certifican en esta revisión.

## Pruebas reproducibles con 4.3

Abre `project.godot` con **Godot 4.3 stable** y espera la importación. Desde la raíz:

```powershell
$motor43 = 'C:\ruta\Godot_v4.3-stable_win64_console.exe'
& $motor43 --version
& $motor43 --headless --path . res://pruebas/exportacion_pdf.tscn -- --salida=res://tmp/pdfs
```

También puedes abrir esa escena con F6 en el editor 4.3. La salida predeterminada
es `tmp/pdfs`; no se guardan ejemplos en la carpeta real de resultados. La suite
produce 18 archivos sintéticos y `esperado.json`: ejemplo completo, cuatro
respuestas finales, vista incompleta, nombre/alias largos y once puntajes frontera.
Se espera **PRUEBA PDF OK**. Al repetir, reemplaza únicamente sus ejemplos.

Con Python y los paquetes indicados:

```powershell
# validar_pdf.py requiere pypdf y pdfplumber
python pruebas/validar_pdf.py tmp/pdfs
# renderizar_pdf.py requiere pypdfium2 y Pillow
python pruebas/renderizar_pdf.py tmp/pdfs
```

El primer comando verifica texto, campos completos, valores, clasificación, diez
filas, márgenes y paginación. El segundo crea PNG por página y contactos bajo
`tmp/pdfs/render/`; deben revisarse visualmente. La evidencia de esta revisión
está descrita en [VERIFICACION_PDF.md](VERIFICACION_PDF.md).

Para ejecutar también almacenamiento, recuperación, acceso y el recorrido real
con un perfil aislado, utiliza [ejecutar_pruebas.ps1](ejecutar_pruebas.ps1):

```powershell
./pruebas/ejecutar_pruebas.ps1 -Godot43 $motor43 -Render -PythonPDF 'C:\ruta\python.exe'
```

Este comando guarda los ejemplos en `tmp/verificacion/pdfs`. `-PythonPDF` es
opcional y necesita los cuatro paquetes; las doce suites Godot no requieren Python.

## Flujo del juego

Al terminar una partida completa se guarda el PDF sin abrirlo. Abrir directamente
el último diálogo con F6 no representa una partida completa: faltarán las primeras
respuestas y el guardado definitivo se rechazará.

Los reportes se guardan en `%APPDATA%\El Gato Milaneso\Resultados\`, con nombre
completo, fecha día-mes-año, hora y folio aleatorio. El nombre de archivo limita a
80 caracteres su parte de nombre; el interior conserva el texto completo. Si una
ruta ya existe, se usa un consecutivo, conservando el archivo anterior.

Ante un fallo, se conserva una instantánea en
`user://reportes_pendientes/`. La pantalla final permite reintentar con **R** y
continuar al menú con **Espacio** después de guardar. Si se cierra el juego, el
responsable puede recuperar la copia desde su apartado protegido, sin depender de
las respuestas de otra partida. Una instantánea incompleta o dañada no se entrega
como un reporte válido. Consulta [GUIA_EVALUADOR.md](../GUIA_EVALUADOR.md).
