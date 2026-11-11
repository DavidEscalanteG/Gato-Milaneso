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

2. Importa el archivo `project.godot` desde Godot 4.3 (versión indicada por el proyecto).
3. Espera a que Godot importe los recursos y ejecuta el proyecto con F6 para la
   escena actual o F5 para el juego completo.

Los complementos necesarios están incluidos en `addons/`. Godot regenera la
carpeta `.godot/` al importar. Las bases de datos locales de jugadores, los
reportes generados y los archivos temporales están excluidos del repositorio.

## Guardar y subir cambios

Desde la carpeta del proyecto, revisa y publica tus cambios con:

```sh
git status
git add .
git commit -m "Describe los cambios realizados"
git push
```

Si trabajan varias personas, ejecuten `git pull --ff-only` antes de comenzar una
sesión de trabajo. Revisen `git status` antes de cada commit para comprobar qué
archivos van a subir.

## Pruebas y documentación

Cambios y pruebas: [Minijuegos](pruebas/MINIJUEGOS.md).

Cuestionario y reportes: [Exportación PDF](pruebas/EXPORTACION_PDF.md).

Acceso a los resultados y preparación del equipo: [Guía del evaluador](GUIA_EVALUADOR.md).
