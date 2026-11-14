# Verificación PDF - A15, 14 de noviembre de 2026

Motor usado: **4.3.stable.official.77dcf97d8**. Datos sintéticos, perfil APPDATA
aislado y archivos fuera del control de versiones. No se alteraron las preguntas,
las opciones ni las reglas de clasificación existentes.

- Se generaron 18 PDF / 37 páginas: ejemplo completo, cuatro opciones de la
  pregunta 10, diagnóstico incompleto, nombre/alias largos y once puntajes frontera.
- Puntajes comprobados: **0, 1, 4, 5, 9, 10, 14, 15, 19, 20 y 27**. Se verificó el
  texto de su clasificación y que la pregunta 10 no altere el total.
- El nombre largo conserva 1600 letras consecutivas y su marcador final; el alias
  conserva 80 repeticiones con `ñ` y `Á`, también con marcador final.
- `validar_pdf.py` pasó en los 18 archivos: metadatos, fechas, campos completos,
  diez filas sin duplicaciones, preguntas y respuestas exactas, números de página,
  dimensiones y márgenes. Las filas permanecen dentro de la página.
- Se renderizaron las 37 páginas con PDFium y se revisaron los diez contactos:
  sin texto recortado, superposiciones ni caracteres españoles ausentes. El caso
  largo ocupa tres páginas; los restantes, dos.
- `acceso_resultados.tscn` pasó con dos exportaciones consecutivas: rutas distintas
  y conservación del primer archivo. El acceso sigue requiriendo contraseña.

Los PNG y PDF son evidencia temporal en
`tmp/.tmp/implementacion-auditoria/pdfs/`, con contactos bajo `render/`. Se pueden
regenerar con las instrucciones de [EXPORTACION_PDF.md](EXPORTACION_PDF.md).
`renderizar_pdf.py` requiere `pypdfium2` y Pillow; la validación textual requiere
`pypdf` y `pdfplumber`. Se utilizaron las dependencias del runtime de Codex.

Un reporte definitivo requiere diez respuestas válidas. El PDF incompleto de la
suite es exclusivamente una vista diagnóstica solicitada mediante el parámetro
explícito `permitir_incompleto`; no se utiliza en la pantalla final ni en la
recuperación de reportes pendientes.

Esta comprobación acredita el formato y las reglas programadas; no certifica la
interpretación del cuestionario ni sustituye la validación con jugadores de A16.
