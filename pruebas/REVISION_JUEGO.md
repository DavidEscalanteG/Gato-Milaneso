# Revisión del juego — 11 de noviembre de 2026

## Correcciones realizadas

- **Pelo inicial:** el creador muestra y guarda el primer peinado desde el inicio. El selector de color coincide con el cabello. Limpiar restaura esos mismos valores.
- **Sin pelo:** elegir explícitamente esa opción se respeta en el mapa y en el juego de perros. Se conserva el significado de los índices de las configuraciones existentes.
- **Personaje en los perros:** se sustituyó el modelo genérico por la misma escena de apariencia que utiliza el mapa. Conserva cuerpo, ayudas de movilidad, peinado y color; también participa en el parpadeo de inmunidad.
- **Silla de ruedas:** el cabello sube seis píxeles del atlas al mirar de lado, tanto a la izquierda como a la derecha. Recupera su posición al mirar al frente o hacia atrás.
- **Volver desde el nombre:** conserva la apariencia que se acababa de guardar, en lugar de reiniciar la personalización.
- **Movimiento del mapa:** misma velocidad en diagonal y en línea recta; la animación responde al movimiento del fotograma actual. Las vistas frontal y trasera dejan de heredar el espejo de la vista izquierda.
- **Victoria de los perros:** Enter y Espacio continúan al diálogo correcto. Se eliminó una ruta vacía y la doble captura de Espacio. Las transiciones ignoran solicitudes simultáneas.
- **Nueva partida:** reinicia nivel, ronda local, derrotas, puntos y vidas. Antes podía conservar el nivel 6 de una partida terminada y solicitar un destino inexistente del mapa.
- **Configuraciones incompletas:** las selecciones vacías, incorrectas o fuera de rango utilizan valores válidos sin interrumpir la carga del personaje.

La apariencia se concentra en `Escenas/Player/Apariencia.tscn`, `apariencia.gd` y `datos_apariencia.gd`, para que futuros cambios se reflejen en mapa y perros.

## Validación

Se ejecutó en Godot **4.7.2**, con datos de prueba aislados mediante APPDATA. La revisión combinó lectura del código, interacción con el creador, capturas con renderizado y recorridos automatizados de las escenas; no fue una sesión manual completa de principio a fin.

`pruebas/personajes.tscn` comprueba:

- Inicio y limpieza del creador, conversión de su configuración y regreso a editar.
- Las **20 combinaciones** de cuatro cuerpos y cinco opciones de cabello en los dos contextos.
- Fotogramas de las cuatro direcciones, posición del pelo de la silla, color, ausencia de pelo e independencia de materiales.
- Velocidad diagonal y parada del jugador en el mapa real.
- Victoria real de los perros con Enter y Espacio, destino de la transición y rechazo de una solicitud duplicada.
- Reinicio de una partida que había llegado al final.

También pasó `pruebas/minijuegos.tscn`: reintentos y ayuda de perros, notas acertadas/falladas, monedas y vidas del topo. Un recorrido adicional procesó **23 títulos y 90 líneas de diálogo**, cargó 20 escenas de la ruta principal y comprobó el premio y reinicio de la máquina.

Para repetir las comprobaciones desde la carpeta del proyecto:

```powershell
godot_console.exe --headless --path . res://pruebas/personajes.tscn
godot_console.exe --headless --path . res://pruebas/minijuegos.tscn
```

La prueba de personajes no guarda `player.cfg`, registros personales ni reportes. Para obtener capturas se puede ejecutar sin `--headless`, agregando `-- --capturas=C:/ruta/de/capturas`.

## Mejoras siguientes sugeridas

1. **Navegación por teclado en el creador.** Las listas tienen el foco desactivado y dependen de `item_clicked`. Conviene permitir flechas, Tab y Enter, con foco visible.
2. **Pausa y ajustes accesibles desde el juego.** Un menú común permitiría revisar controles y ajustar audio; también ofrecer una opción para reducir el destello y la sacudida de cámara de los perros.
3. **Validación del nombre de jugador.** Actualmente admite un nombre vacío o compuesto solamente por espacios. Conviene indicar el error junto al campo.
4. **Continuar una partida.** El progreso vive en `Global`, mientras que `player.cfg` conserva la apariencia. Faltan puntos de guardado para recuperar una sesión tras cerrar el juego.
5. **Coherencia de retratos.** Los diálogos siguen mostrando un retrato genérico cuando habla el protagonista. Se podría generar su retrato con la misma apariencia compartida.

### Compatibilidad del editor

La importación en el editor **4.7.2** detectó una incompatibilidad previa del complemento Dialogue Manager: `editor_translation_parser_plugin.gd` implementa la firma antigua de `_parse_file`. La ejecución de las pruebas del juego sí pasó. Se conservó la configuración del proyecto para **4.3**; una migración del editor requiere actualizar ese complemento y volver a validar las traducciones. No se verificó esta revisión ejecutándola en 4.3.
