# Exportación del cuestionario

## Qué incluye el PDF

- Las diez preguntas completas, con el mismo texto que aparece en el juego.
- La respuesta elegida en texto y su valor numérico.
- Nombre, alias, fecha de exportación, puntaje de las preguntas 1 a 9 y clasificación registrada por el juego.
- Tabla con colores alternados, encabezados repetidos y números de página. Las preguntas y respuestas de una fila permanecen juntas.

La pregunta 10 tiene cuatro opciones: **No ha sido difícil**, **Un poco difícil**, **Muy difícil** y **Extremadamente difícil**. Ahora cada opción llama a `Global.set_respuesta(10, valor)` desde el diálogo y aparece en el reporte. Se almacena como `p10`, con valores 0 a 3; si todavía no fue respondida, se representa internamente con -1 y en el PDF con **Sin responder**.

El puntaje conserva la suma de las preguntas 1 a 9, con máximo de 27. La pregunta 10 se presenta por separado y no modifica ni el total ni la clasificación. Las respuestas continúan viviendo en `Global` durante la ejecución; el PDF es la exportación a disco. No se añadió una nueva base de datos de resultados.

## Prueba sin recorrer los minijuegos

1. Abre `pruebas/exportacion_pdf.tscn` en Godot y presiona **F6**.
2. La escena comprueba las cuatro opciones de la pregunta 10 utilizando Dialogue Manager y genera reportes con datos ficticios.
3. Busca **PRUEBA PDF OK** y la carpeta de salida en el panel **Salida**. La prueba se cierra automáticamente.
4. Abre `exportacion-prueba.pdf`: debe tener dos páginas, las diez preguntas y sus respuestas; el puntaje de ejemplo es **15 / 27** y la respuesta 10 es **Muy difícil**.
5. Los archivos `pregunta10-0.pdf` a `pregunta10-3.pdf` comprueban cada opción. `exportacion-incompleta.pdf` muestra **Sin responder** para la pregunta 10. `exportacion-larga.pdf` prueba nombres de gran longitud y paginación.

La prueba no escribe en SQLite ni en `player.cfg`, y restaura las variables que modifica. Reemplaza sus propios archivos de ejemplo cuando se ejecuta de nuevo.

Desde PowerShell, en la carpeta del proyecto:

```powershell
godot_console.exe --headless --path . res://pruebas/exportacion_pdf.tscn -- --salida=res://tmp/pdfs
```

Sustituye el ejecutable si tu instalación utiliza otro nombre. Si omites `--salida`, la prueba utiliza la carpeta de datos del juego.

Con Python, `pypdf` y `pdfplumber` instalados, puedes comprobar además las diez filas, el texto completo, las respuestas, los márgenes y la paginación de los archivos generados:

```powershell
python pruebas/validar_pdf.py tmp/pdfs
```

La prueba con F6 no requiere Python. Se incluye un reporte de ejemplo en `output/pdf/exportacion-prueba.pdf`.

## Prueba dentro del juego

Deja que Godot reimporte `Dialogos/test.dialogue` después de detectar los cambios. Para probar el final sin recorrer los minijuegos, abre `Escenas/EscenasDialogos/dialogo12.tscn` con F6, avanza hasta la pregunta 10 y elige una opción. Al entrar en `pantalla_final.tscn` se exporta automáticamente el PDF. En esa prueba directa, las primeras nueve respuestas conservarán sus valores iniciales.

Durante una partida completa, las diez respuestas elegidas aparecen en el reporte final. La consola muestra la ruta del archivo, normalmente en:

```text
%APPDATA%\Godot\app_userdata\MapaOriginal_v2.0\
```

El botón de `Escenas/Admin/amindExportar.tscn` sigue exportando los valores de la ejecución actual y muestra la ubicación del archivo. Ejecutarlo en un proceso nuevo no recupera respuestas de una partida anterior.
