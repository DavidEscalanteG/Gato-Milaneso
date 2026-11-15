# El Gato Milaneso
Proyecto para el servicio social de un videojuego utilizando Godot.

Repositorio actual: [DavidEscalanteG/Gato-Milaneso](https://github.com/DavidEscalanteG/Gato-Milaneso).

Esta versión reúne el proyecto recibido de generaciones anteriores y los cambios
actuales. El historial de este repositorio comienza con esta versión; el historial
anterior no estaba incluido en la carpeta recibida. Se conserva la licencia MIT
y el reconocimiento de autoría original en [LICENSE](LICENSE).

## Abrir el proyecto

1. Clona el repositorio:

   ```sh
   git clone https://github.com/DavidEscalanteG/Gato-Milaneso.git
   ```

2. Importa el archivo `project.godot` desde **Godot 4.3 stable**, con Forward Plus.
   La revisión actual se validó en `4.3.stable.official.77dcf97d8`; utiliza la ruta
   explícita de su ejecutable, porque `godot` en el PATH puede apuntar a otra versión.
3. Espera a que Godot importe los recursos y ejecuta el proyecto con F6 para la
   escena actual o F5 para el juego completo.

Los complementos necesarios están incluidos en `addons/`. Godot regenera la
carpeta `.godot/` al importar. Las bases de datos locales de jugadores, los
reportes generados y los archivos temporales están excluidos del repositorio.

## Guardar y subir cambios

Desde la carpeta del proyecto, revisa y publica tus cambios con:

```sh
git status
git add -- archivo-que-modificaste
git commit -m "Describe los cambios realizados"
git push
```

Si trabajan varias personas, ejecuten `git pull --ff-only` antes de comenzar una
sesión de trabajo. Revisen `git status` antes de cada commit para comprobar qué
archivos van a subir.

## Pruebas y documentación

Exportación para Windows y paquete para compartir: [Exportar Windows](EXPORTAR_WINDOWS.md).

Cambios y pruebas: [Minijuegos](pruebas/MINIJUEGOS.md).

Pausa, controles de audio y barra del reto de perros:
[Uso y verificación](pruebas/PAUSA_Y_AUDIO.md).

Personajes y recorrido del juego: [Revisión del juego](pruebas/REVISION_JUEGO.md).

Cuestionario y reportes: [Exportación PDF](pruebas/EXPORTACION_PDF.md).

Acceso a los resultados y preparación del equipo: [Guía del evaluador](GUIA_EVALUADOR.md).

Cambios A01-A16 y sus commits: [Estado de la auditoría](pruebas/ESTADO_AUDITORIA.md).

Autoría original, licencias incluidas y documentación de recursos pendiente:
[Autorías y licencias](AUTORIAS_Y_LICENCIAS.md).

Para repetir las trece suites con datos ficticios aislados:

```powershell
./pruebas/ejecutar_pruebas.ps1 -Godot43 'C:\ruta\Godot_v4.3-stable_win64_console.exe'
```

Agrega `-Render` para probar también el renderizado y la selección real con el
ratón. Las instrucciones completas y el alcance del recorrido asistido están en
la revisión del juego. La exportación de Windows se documenta por separado en
la guía de exportación; no se realizaron pruebas con jugadores.
