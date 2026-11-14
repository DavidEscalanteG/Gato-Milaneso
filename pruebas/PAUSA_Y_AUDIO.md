# Pausa, audio y progreso de perros — 14 de noviembre de 2026

## Alcance acordado

Se añadieron pausa, ajustes de audio y una barra de progreso al reto de perros.
Se conserva la legibilidad aprobada, el triángulo de orientación, los diálogos,
las preguntas, la dificultad, los premios y los tiempos indicados por el profesor.
No se añadió guardado general de partida ni se generó una distribución nueva.

## Uso

- **Escape** abre la pausa durante la partida. Escape o **CONTINUAR** recuperan
  el punto anterior. Se puede abrir también sobre instrucciones y derrota; al
  volver se recupera esa pantalla, sin empezar ni reintentar automáticamente.
- **Música** y **Efectos** se ajustan por separado entre 0 y 100 %. Cero silencia
  esa categoría. Los cambios se aplican al momento y se conservan en
  `user://audio.cfg`, separados de la identidad y las respuestas del participante.
- El menú principal tiene un botón **AUDIO**. En ese apartado su música continúa
  para poder escuchar los cambios. Durante la pausa de una partida se detiene
  la reproducción para conservar la sincronía de los retos.
- **VOLVER AL MENÚ** muestra un aviso de pérdida de progreso. **SEGUIR JUGANDO**
  o Escape cancelan el aviso y vuelven al panel de pausa. La salida confirmada
  mantiene el reto congelado durante el fundido y reinicia el progreso.
- La pantalla final de guardado y el apartado del responsable mantienen sus
  controles propios. La pausa no permite saltarse la exportación del reporte.
- En perros, la barra empieza al pulsar **JUGAR**, se detiene durante la pausa
  y se llena al aparecer la cartera. Entonces indica **¡Recoge la cartera!**.
  Reintentar repone la barra; continuar con la ayuda existente la completa.

## Diseño e implementación

El nuevo panel utiliza `resources/bottonsTheme.tres`: fondo claro, botones
anaranjados y tipografía Pixelify. La escena está en `Escenas/Pausa.tscn` y su
controlador en `Scripts/pausa.gd`, como autoload. La barra reutiliza el marco
dorado de las instrucciones (`Assets/Framers.png`), un icono de la cartera y un
relleno claro con relieve pixelado. Queda centrada arriba, separada de las vidas
y del personaje.

En perros, el personaje reproduce continuamente su animación existente de
caminata hacia arriba mientras el fondo avanza, incluso al desplazarse con A/D.
El desplazamiento real sigue siendo solo horizontal y conserva su velocidad.
La animación se congela con la pausa y la derrota; al ganar, mira al frente.

La pausa conserva el foco anterior, el estado de pausa previo y los modos de
proceso de instrucciones/derrota. Impide que las entradas actúen detrás del menú.
Las esperas compartidas de juego respetan `SceneTree.paused`; sus duraciones y
su cancelación al salir de escena se conservan.

La barra representa las tres esperas que ya tenía perros:
`3 + max(0.1, tiempo_para_cartera - 3) + 3`. Con el valor original de 50,
la cartera se genera tras esas esperas, aproximadamente a los 53 segundos.
La barra no adelanta su aparición ni modifica la velocidad de los perros.

Los buses `Musica` y `Efectos` conservan la mezcla anterior al estar al 100 %.
La música de mapa, bebé y topo usa el primero; los aciertos y los sonidos de
botones usan el segundo. No se modifica el volumen del sistema operativo.

El cierre por la ventana ahora detiene los reproductores y deja 0.2 segundos al
mezclador antes de salir. También se libera la espera de escritura de un diálogo
si se abandona a mitad de un mensaje. Son correcciones de ciclo de vida; no
modifican la apariencia o el ritmo del texto durante la partida.

## Verificación

Motor: **Godot 4.3 stable / Forward Plus**. Perfil ficticio aislado bajo `tmp/`.

Se ejecutó la verificación integrada con **13 suites correctas**, incluido el
recorrido completo, y la suite nueva con renderizado y clics de GUI. Se revisaron
las capturas de pausa, confirmación, ajustes y barra. El recorrido integrado
conserva sus cinco retos, diez respuestas y PDF final.

`pausa_audio.tscn` comprueba:

- Escape y clic en CONTINUAR; conservación de instrucciones y de su pausa.
- Esperas, barra y canción detenidas y reanudadas desde el mismo punto.
- Derrota y reintento de perros y música sin entradas filtradas detrás del panel.
- Escritura del diálogo detenida sin contestar preguntas.
- Cancelación de salida y regreso al menú con el cronómetro a punto de terminar.
- Volúmenes independientes, silencio, persistencia, recuperación de valores
  inválidos y devolución del foco al botón AUDIO.
- Cierre mediante la señal real de la ventana con el MP3 de la máquina activo
  y la pausa abierta, sin avisos de objetos o recursos retenidos al salir.

Para repetir todo:

```powershell
./pruebas/ejecutar_pruebas.ps1 -Godot43 './tmp/.tmp/restauracion-godot43/motor/Godot_v4.3-stable_win64_console.exe'
```

Para las capturas específicas, con APPDATA y LOCALAPPDATA previamente redirigidos
a una carpeta del proyecto bajo `tmp/`:

```powershell
& $motor43 --path . res://pruebas/pausa_audio.tscn -- --capturas=res://tmp/pausa-capturas
```

La prueba genera únicamente datos ficticios. No permite ejecutarse contra el
perfil real. Las capturas de esta revisión están en `tmp/pausa14/capturas/`.
No se efectuaron pruebas con participantes ni se validó una distribución Windows.

El ajuste posterior del marco de la barra y la caminata continua se verificó
con las suites de personajes y minijuegos, y con pausa/audio renderizada. Incluye
avance de fotogramas sin pulsar teclas, desplazamiento lateral conservando la
vista hacia arriba, inmovilidad vertical, congelación en pausa y pose de victoria.
Las capturas de ese ajuste están en `tmp/perros-estilo/capturas/`.
