# Cambios y pruebas de minijuegos

## Comprobación automática

Abre `pruebas/minijuegos.tscn` en Godot y presiona **F6**. La prueba recorre las escenas con datos y entradas simuladas, se cierra al terminar y escribe en **Salida**:

```text
PRUEBAS MINIJUEGOS OK: perros, música, monedas y topo.
```

También puedes ejecutarla desde la carpeta del proyecto:

```powershell
godot_console.exe --headless --path . res://pruebas/minijuegos.tscn
```

La prueba no escribe en la base de datos, en `player.cfg` ni en los PDF. Silencia el audio solamente durante su propia ejecución. Comprueba reintentos reales, el clic del botón de ayuda, notas falladas y acertadas, pulsos separados, monedas durante el aviso inicial y las vidas del topo.

La suite pasó en Godot 4.3 y 4.7.2. Con renderizado se comprobó también el clic real del botón y se revisaron visualmente el botón, la franja y los corazones. En modo headless, la comprobación del botón utiliza su señal porque el renderizador Dummy no realiza la selección de controles con el ratón.

## Pruebas manuales con F6

| Juego | Escena |
| --- | --- |
| Perros y cartera | `Escenas/EscenasCartera/calle.tscn` |
| Música del bebé | `Escenas/EscenaBolitas/bolitas.tscn` |
| Monedas | `Escenas/EscenasMonedas/tienda.tscn` |
| Dale al topo | `Escenas/EsenasDaleAlTopo/dale_al_topo.tscn` |

### Perros

1. Pierde las tres vidas. En la primera y segunda derrota debe aparecer únicamente la opción habitual de reintentar con ESPACIO.
2. Reintenta hasta perder la partida por tercera vez. Ahora aparece **Continuar sin perros** debajo del aviso de derrota. Puedes seguir reintentando si prefieres.
3. Pulsa el botón: los perros desaparecen, se reanuda el movimiento del jugador y del fondo, y aparece la cartera. Recógela normalmente y pulsa ESPACIO para continuar con el diálogo de Kati.
4. No deben reaparecer perros ni duplicarse la cartera al cumplirse las esperas que estaban pendientes.

El contador cuenta partidas perdidas, no golpes. Se conserva al reintentar y se reinicia al comenzar la misión desde el diálogo de Kati o al recoger la cartera. Se eliminó la captura del ratón por parte del destello rojo para que el botón sea pulsable.

### Música

1. Comprueba que se vea una franja amarilla con una línea brillante en la parte inferior. La indicación de ESPACIO o clic debe ser legible.
2. Pulsa **ESPACIO**, o haz clic izquierdo en la franja, cuando una esfera cruce la línea. Cada nota acertada suma una sola vez y no descuenta vida al desaparecer.
3. Deja pasar una nota: deben quedar dos corazones. La segunda deja uno; la tercera muestra la derrota.
4. Las notas aparecen de una en una, con pausas aleatorias de **0.7 a 1.2 segundos**, repartidas entre los cinco carriles. Se detiene su generación durante los últimos cinco segundos para permitir terminar las que ya están en pantalla.

Los límites se pueden ajustar en **Inspector > intervalo_minimo_notas / intervalo_maximo_notas**, seleccionando el nodo raíz de `bolitas.tscn`. Cada nota programa una nueva espera aleatoria, con un mínimo de seguridad de 0.7 segundos. El temporizador compartido evita las acumulaciones que causaban los cinco temporizadores aleatorios independientes. No es una transcripción de las notas de la pista de audio.

La causa de las vidas dobles era que tanto la nota como el controlador restaban salud por el mismo fallo. Ahora solamente lo hace el controlador y cada nota se procesa una vez.

### Monedas

1. Mientras aparezca **EMPIEZA LA RONDA**, intenta pulsar sobre alguna moneda. No debe sonar, marcarse ni contarse; el clic se ignora.
2. Cuando desaparezca el aviso, pulsa esa misma moneda: debe marcarse en verde y el contador debe subir.
3. Recoge las otras cuatro. El contador debe llegar a 5/5 y aparecer **¡COMPLETADO!**.
4. Pulsar de nuevo una moneda ya recogida no debe sumar otra vez. Los clics equivocados durante la ronda conservan la penalización de diez segundos.

La moneda consulta el mismo estado de ronda que utiliza el contador, antes de reproducir sonido o marcarse. Esto evita que una moneda se consuma durante los mensajes de inicio o fin.

### Topo

1. Abre la escena directamente: debe mostrar tres corazones desde el primer intento.
2. Compruébalo también llegando desde la música con una sola vida restante: el topo debe empezar con tres.
3. Golpea tres zarigüeyas. Los corazones deben pasar de 3 a 2, a 1 y a 0; entonces aparece la derrota. Golpear varias veces el mismo animal no debe restar vidas adicionales.
4. Reintenta: se reponen los tres corazones. Cada nueva ronda también empieza con tres vidas.

El juego antes conservaba cualquier salud positiva de `Global`, por eso heredaba la vida restante de la música. Ahora reinicia las vidas en cada intento y actualiza todos los corazones según la salud real.
