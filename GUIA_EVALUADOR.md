# Consulta y conservación de resultados

## Preparar el equipo

1. Si recibiste el ZIP de Windows, extrae todo su contenido y abre
   **El Gato Milaneso.exe**, conservando el PCK y la DLL en la misma carpeta.
   Si trabajas desde el proyecto, ábrelo con **Godot 4.3 stable**, espera la
   importación y ejecuta el juego completo con F5.
2. En el menú principal, presiona **Ctrl + Shift + E** para abrir el acceso del
   responsable. El menú del participante no muestra un botón de resultados.
3. Crea y confirma una contraseña de al menos ocho caracteres. No hay una
   contraseña predeterminada. Consérvala solo con el responsable del equipo.
4. Comprueba la fecha y la hora de Windows y cierra el acceso antes de comenzar.

La contraseña y los datos corresponden a la cuenta de Windows utilizada. Otra
cuenta requiere su propia configuración. Cada partida nueva reinicia las diez
respuestas como pendientes; una respuesta cero no equivale a una pendiente.

## Consultar los reportes

Durante una partida, **Escape** abre la pausa con volumen de música y efectos.
También se ajustan desde **AUDIO** en el menú principal. Los ajustes se conservan
entre sesiones. Volver al menú desde la pausa solicita confirmar que se perderá
el progreso; no hay reanudación de partida después de cerrar el juego.
La pantalla final mantiene el reintento de guardado y su salida propia.

1. Al terminar la partida, vuelve al menú principal.
2. Presiona **Ctrl + Shift + E**, escribe la contraseña y selecciona
   **Abrir carpeta de resultados**.
3. Busca el nombre o la fecha del participante. Los PDF se conservan después de
   cerrar y volver a abrir el juego.
4. Cierra los documentos y el Explorador antes de cerrar el acceso y volver al
   juego. Cerrar el acceso bloquea el apartado; no cierra ventanas externas.

Carpeta de reportes:

```text
%APPDATA%\El Gato Milaneso\Resultados\
```

Ejemplo ficticio:

```text
María_Fernanda_López_Pérez_14-11-2026_15-30-25_Folio-A4B8C20F9D31.pdf
```

El nombre contiene nombre completo, fecha día-mes-año, hora y folio. Si una ruta
ya existe, se usa otra sin sobrescribirla. El nombre del archivo limita a 80
caracteres su parte de nombre; el interior conserva el nombre y alias completos.
El PDF se guarda al terminar, sin abrirlo ante el participante.

## Si no se pudo guardar al terminar

La pantalla final permite pulsar **R** para reintentar. Solo permite volver al
menú con Espacio después de guardar. Conserva la partida mientras se reintenta;
no hace falta volver a contestar.

Antes de exportar se intenta conservar una instantánea de las respuestas. Si el
juego se cerró después de ese guardado, entra con contraseña y selecciona
**Recuperar reportes pendientes**. El botón aparece únicamente si hay copias
pendientes. El resultado indica cuántas se recuperaron y cuántas siguen pendientes.
Las copias se eliminan de la cola solo después de exportar correctamente; los
fallidos permanecen disponibles. No utiliza las respuestas de otro participante.

Si ambas ubicaciones de almacenamiento rechazan escrituras, no se puede garantizar
una copia en disco: mantén el juego abierto, libera espacio o recupera permisos y
pulsa R. Los errores de captura personal también conservan los campos para reintentar.

Una copia incompleta o dañada no se convierte en un reporte definitivo. Si persiste
el fallo, conserva una copia de la carpeta de datos antes de solicitar revisión.
No edites sus respuestas ni la clasificación manualmente.

## Ubicaciones para respaldo

| Contenido | Ubicación por cuenta de Windows |
| --- | --- |
| PDF terminados | `%APPDATA%\El Gato Milaneso\Resultados\` |
| Base de datos personales | `%APPDATA%\Godot\app_userdata\MapaOriginal_v2.0\baseDatos.db` |
| Apariencia y alias | Misma carpeta, `player.cfg` |
| Ajustes de audio | Misma carpeta, `audio.cfg` |
| Acceso del responsable | Misma carpeta, `evaluador.cfg` |
| Reportes pendientes | Misma carpeta, subcarpeta `reportes_pendientes\` |

Cierra el juego antes de copiar las dos carpetas de datos. Guarda el respaldo en
una ubicación a la que solo acceda el responsable y comprueba que contiene los
PDF y la base. Para restaurarlo, conserva primero los datos actuales y copia el
respaldo con el juego cerrado. Evita mezclar reportes pendientes ya recuperados:
reintroducirlos puede generar otro PDF de la misma sesión.

El responsable decide cuándo borrar los datos según el uso del proyecto. Para
hacerlo, revisa por separado PDF, copias pendientes, base, `player.cfg`, logs y
respaldos. Borrar solamente los PDF no borra los datos personales de SQLite. No hay
borrado automático ni sincronización con una nube implementados por el juego.

## Recuperar la contraseña

Con el juego cerrado y acceso autorizado al equipo, renombra `evaluador.cfg` a
`evaluador.cfg.bak` en su carpeta de datos. Vuelve a abrir y configura una contraseña
nueva antes de entregar el equipo. Esto conserva los PDF. Una configuración dañada
bloquea el acceso hasta recuperarlo de esta forma.

Se guarda una derivación PBKDF2-HMAC-SHA256 con sal aleatoria y 100 000 iteraciones,
sin contraseña legible. Tras tres intentos fallidos se esperan 15 segundos.

## Alcance de la protección

La contraseña controla el apartado del juego. PDF, SQLite, configuraciones y
copias pendientes **no están cifrados**: una persona con acceso a la misma cuenta
de Windows puede leerlos desde fuera del juego. La cola contiene nombre, alias y
respuestas; protégela como los PDF. Los nuevos logs omiten identidad y respuestas;
los logs y respaldos de versiones anteriores pueden conservarlas.

Las pruebas utilizan datos ficticios y APPDATA aislado en `tmp/`. No deben
confundirse con resultados reales. Consulta [la revisión técnica](pruebas/REVISION_JUEGO.md)
y [el estado de las recomendaciones](pruebas/ESTADO_AUDITORIA.md).
