# Consulta de resultados

## Preparar el equipo antes de la primera evaluación

1. Abre el juego y llega al menú principal.
2. Presiona **Ctrl + Shift + E** para abrir **Acceso del evaluador**. El menú del participante no muestra un botón de resultados.
3. Crea y confirma una contraseña de al menos ocho caracteres. No hay una contraseña predeterminada. Guarda la contraseña en un lugar al que solo tenga acceso el evaluador.
4. Selecciona **Cerrar acceso y volver al juego** antes de entregar el equipo al participante.

La contraseña se configura por cuenta de Windows. Si se usa otra cuenta, debe prepararse su acceso y sus reportes se guardarán en el perfil de esa cuenta.

## Revisar las evaluaciones

1. Al terminar la partida, vuelve al menú principal.
2. Presiona **Ctrl + Shift + E** y escribe la contraseña.
3. Selecciona **Abrir carpeta de resultados**. Se abre el Explorador con los PDF guardados, incluso después de cerrar y volver a abrir el juego.
4. Busca el nombre del participante o la fecha y abre el PDF correspondiente.
5. Cierra los PDF y las ventanas del Explorador antes de seleccionar **Cerrar acceso y volver al juego**. Volver al menú bloquea nuevamente el apartado del evaluador, pero no cierra las ventanas externas que se hayan abierto.

Los reportes se guardan en:

```text
%APPDATA%\El Gato Milaneso\Resultados\
```

Puedes pegar esa ruta en la barra de direcciones del Explorador. Windows la adapta al usuario de la sesión; no necesitas escribir `C:\Users\...`.

Ejemplo ficticio de un archivo:

```text
María_Fernanda_López_Pérez_11-11-2026_15-30-25_Folio-A4B8C20F9D31.pdf
```

El orden es **nombre completo, día-mes-año, hora-minuto-segundo y folio**. La fecha y la hora son las del equipo, por lo que conviene comprobar su reloj antes de evaluar. El folio distingue sesiones y se evita sobrescribir reportes existentes. Para nombres muy largos, el archivo limita a 80 caracteres la parte del nombre; el PDF conserva el nombre completo.

El juego guarda el reporte al entrar en la pantalla final, sin abrirlo ni mostrar un aviso al participante. Cada partida nueva inicia las respuestas del cuestionario desde cero.

## Recuperar el acceso

Si se olvida la contraseña, cierra el juego y, con acceso autorizado al equipo, renombra `evaluador.cfg` a `evaluador.cfg.bak` en `%APPDATA%\Godot\app_userdata\MapaOriginal_v2.0\`. Vuelve a abrir el juego y configura una contraseña nueva antes de entregar el equipo al participante. Esto no borra los PDF. Una configuración dañada bloquea el acceso hasta que se recupere de esta forma.

La configuración guarda una derivación PBKDF2-HMAC-SHA256 con sal aleatoria y 100 000 iteraciones; no guarda la contraseña en texto legible. Después de tres intentos fallidos seguidos, el formulario espera 15 segundos para permitir otro intento.

## Alcance de la privacidad

La contraseña controla el apartado del juego. Los PDF no están cifrados: alguien con acceso a la misma cuenta de Windows puede abrirlos directamente desde el Explorador. La carpeta y el acceso discreto reducen los encuentros casuales; si se requiere impedir la lectura fuera del juego, se necesita una solución adicional de cifrado o almacenamiento con acceso exclusivo del evaluador.

La ubicación de la base de datos y de la personalización del personaje se conserva. La carpeta de resultados se utiliza únicamente para los reportes.
