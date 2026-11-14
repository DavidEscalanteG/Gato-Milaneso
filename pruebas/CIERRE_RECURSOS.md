# Cierre de escenas en Godot 4.3

A07 se investigó con `--verbose`, sin ocultar los avisos del motor. La prueba de
minijuegos retenía `SceneTreeTimer`, `Tween` y una corutina de
`mostrar_mensaje_central` después de abandonar la escena.

Las esperas de juego ahora se cancelan al salir su nodo del árbol. Las animaciones
pertenecen al nodo que las crea y las esperas de animación también reciben la
cancelación. Así no se reanuda lógica de una escena que ya se ha cerrado.

Validación en **4.3.stable.official.77dcf97d8**:

- `pruebas/ciclo_vida.tscn`: cancelación de esperas de 30 segundos al liberar su
  nodo y finalización de esperas normales.
- `pruebas/minijuegos.tscn`: mantiene las reglas y deja de registrar objetos
  `SceneTreeTimer`/`Tween` filtrados al cerrar.
- `pruebas/personajes.tscn`: conserva apariencia, movimiento y transiciones y
  deja de registrar objetos filtrados al cerrar.

En salida detallada de 4.3 pueden quedar mensajes de internado de `StringName`
(`Start`, `End` o `finished`). Se distinguen de `Leaked instance`, de recursos
todavía en uso y de errores de script; no se suprime ninguna salida del motor.
