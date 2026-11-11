extends Node

const NotaRitmica = preload("res://Scripts/ScriptsJuegoBolitas/hoyo.gd")

# Runs real scenes with synthetic input. No saved player data is changed.
var fallos: Array[String] = []
var juego: Node = null
var carpeta_capturas: String = ""

func _ready() -> void:
	AudioServer.set_bus_mute(0, true)
	for argumento in OS.get_cmdline_user_args():
		if argumento.begins_with("--capturas="):
			carpeta_capturas = argumento.trim_prefix("--capturas=")
	await _probar_perros()
	await _probar_musica()
	await _probar_monedas()
	await _probar_topo()
	await _cerrar_juego()
	_detener_audio(SoundManager)
	await get_tree().create_timer(0.2).timeout
	if fallos.is_empty():
		print("PRUEBAS MINIJUEGOS OK: perros, música, monedas y topo.")
		get_tree().quit(0)
	else:
		for fallo in fallos:
			push_error(fallo)
		get_tree().quit(1)

func _comprobar(condicion: bool, mensaje: String) -> void:
	if not condicion:
		fallos.append(mensaje)

func _cargar(ruta: String) -> void:
	await _cerrar_juego()
	juego = load(ruta).instantiate()
	get_tree().root.add_child(juego)
	get_tree().current_scene = juego
	await get_tree().process_frame

func _cerrar_juego() -> void:
	get_tree().paused = false
	get_tree().current_scene = self
	if is_instance_valid(juego):
		_detener_audio(juego)
		await get_tree().create_timer(0.05).timeout
		juego.queue_free()
	juego = null
	await get_tree().process_frame
	await get_tree().process_frame

func _detener_audio(nodo: Node) -> void:
	if nodo is AudioStreamPlayer or nodo is AudioStreamPlayer2D or nodo is AudioStreamPlayer3D:
		nodo.stop()
	for hijo in nodo.get_children():
		_detener_audio(hijo)

func _empezar() -> void:
	if juego.has_node("InstruccionesUI"):
		juego.get_node("InstruccionesUI")._on_boton_jugar_pressed()
	await get_tree().process_frame

func _clic(boton: MouseButton = MOUSE_BUTTON_LEFT) -> InputEventMouseButton:
	var evento = InputEventMouseButton.new()
	evento.button_index = boton
	evento.pressed = true
	return evento

func _vidas_visibles(contenedor: Node) -> int:
	var total = 0
	for vida in contenedor.get_children():
		if vida.visible:
			total += 1
	return total

func _capturar(nombre: String) -> void:
	if carpeta_capturas.is_empty():
		return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(carpeta_capturas))
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(carpeta_capturas.path_join(nombre + ".png"))

func _probar_perros() -> void:
	Global.derrotas_perros = 0
	await _cargar("res://Escenas/EscenasCartera/calle.tscn")
	for intento in range(1, 4):
		await _empezar()
		if intento == 3:
			for indice in 2:
				juego.add_child(juego.perro_escena.instantiate())
		var gato = juego.get_node("Gato")
		for golpe in 3:
			gato.inmune = false
			gato.perder_vida()
		gato.perder_vida() # Same terminal collision cannot count two defeats.
		_comprobar(Global.derrotas_perros == intento, "Perros: contador de derrotas incorrecto.")
		var derrota = juego.get_node("perdiste2")
		_comprobar(derrota.get_node("SaltarNivel").visible == (intento >= 3), "Perros: umbral de ayuda incorrecto.")
		if intento < 3:
			derrota.reiniciar_juego()
			await get_tree().process_frame
			await get_tree().process_frame
			juego = get_tree().current_scene
	await _capturar("perros-tercera-derrota")
	await get_tree().process_frame
	await get_tree().process_frame
	# Send actual GUI input so overlays cannot silently cover the help button.
	var boton = juego.get_node("perdiste2/SaltarNivel")
	if DisplayServer.get_name() == "headless":
		# Dummy rendering has no GUI picking. Rendered runs exercise the actual click.
		boton.pressed.emit()
	else:
		var pulsar = _clic()
		pulsar.position = boton.get_global_transform_with_canvas() * (boton.size * 0.5)
		pulsar.global_position = pulsar.position
		Input.parse_input_event(pulsar)
		await get_tree().process_frame
		var soltar = _clic()
		soltar.pressed = false
		soltar.position = pulsar.position
		soltar.global_position = pulsar.position
		Input.parse_input_event(soltar)
	await get_tree().process_frame
	_comprobar(juego.ayuda_activada, "Perros: el botón no recibió el clic.")
	if not juego.ayuda_activada:
		return
	_comprobar(get_tree().get_nodes_in_group("perros").is_empty(), "Perros: quedaron perros tras la ayuda.")
	_comprobar(get_tree().get_nodes_in_group("cartera").size() == 1, "Perros: falta la cartera o está duplicada.")
	_comprobar(juego.get_node("Gato").vidas == 3 and not juego.juego_terminado, "Perros: no se reanudó la partida.")
	var cartera = get_tree().get_first_node_in_group("cartera")
	cartera.set_process(false)
	juego.continuar_sin_perros()
	await get_tree().create_timer(3.2).timeout
	_comprobar(get_tree().get_nodes_in_group("perros").is_empty(), "Perros: la espera anterior volvió a generar perros.")
	_comprobar(get_tree().get_nodes_in_group("cartera").size() == 1, "Perros: la ayuda duplicó la cartera.")
	cartera._on_body_entered(juego.get_node("Gato"))
	_comprobar(juego.get_node("Gato").juego_ganado and Global.derrotas_perros == 0, "Perros: la ayuda no conserva la victoria normal.")
	print("OK: perros, tres derrotas, reintentos, ayuda y recogida de cartera.")

func _probar_musica() -> void:
	await _cargar("res://Escenas/EscenaBolitas/bolitas.tscn")
	# A fixed test seed makes timing checks repeatable; normal play randomizes it.
	juego._generador_intervalos.seed = 123456
	var esperas: Array[float] = []
	for indice in 100:
		juego._programar_siguiente_nota()
		esperas.append(juego.timer_bolitas.wait_time)
	_comprobar(esperas.min() >= 0.7 and esperas.max() <= 1.2, "Música: espera fuera de los límites jugables.")
	_comprobar(esperas.max() - esperas.min() > 0.25, "Música: las esperas deben variar entre notas.")
	_comprobar(juego.timer_bolitas.one_shot, "Música: el temporizador no debe repetir una espera fija.")
	var instantes: Array[int] = []
	for carril in juego.carriles:
		carril.child_entered_tree.connect(func(nota: Node):
			if nota is NotaRitmica:
				nota.ready.connect(func():
					_comprobar(is_equal_approx(nota.global_position.y, -596.0), "Música: altura inicial incorrecta con la escala del carril.")
					nota.process_mode = Node.PROCESS_MODE_DISABLED
				, CONNECT_ONE_SHOT)
				instantes.append(Time.get_ticks_msec())
		)
	await _empezar()
	await get_tree().create_timer(4.9).timeout
	var visibles = get_tree().get_nodes_in_group("bolas")
	for indice in visibles.size():
		visibles[indice].position.y = -180 + indice * 20
	await _capturar("musica-franja")
	juego.timer.stop()
	juego.detener_generacion_bolas()
	_comprobar(instantes.size() >= 4 and instantes.size() <= 7, "Música: cantidad de notas incompatible con la separación.")
	for indice in range(1, instantes.size()):
		var separacion = instantes[indice] - instantes[indice - 1]
		_comprobar(separacion >= 640 and separacion <= 1350, "Música: separación real fuera del margen esperado.")
	var cantidad_detenida = instantes.size()
	juego._on_timer_notas_timeout()
	_comprobar(instantes.size() == cantidad_detenida and juego.timer_bolitas.is_stopped(), "Música: aparecieron notas después de detener la generación.")
	get_tree().call_group("bolas", "queue_free")
	await get_tree().process_frame
	var carril = juego.get_node("Carril")
	for fallo in range(1, 3):
		carril.spawn_bolita()
		var nota = get_tree().get_nodes_in_group("bolas").back()
		nota._on_visible_on_screen_notifier_2d_screen_exited()
		nota._on_visible_on_screen_notifier_2d_screen_exited()
		_comprobar(Global.salud == 3 - fallo and not juego.juego_terminado, "Música: un fallo debe descontar exactamente una vida.")
		await get_tree().process_frame
	carril.spawn_bolita()
	var acierto = get_tree().get_nodes_in_group("bolas").back()
	acierto.position = Vector2(0, -5)
	carril._on_panel_area_entered(acierto)
	var clic = _clic()
	clic.position = juego.get_global_transform_with_canvas() * Vector2(0, -10)
	juego._unhandled_input(clic)
	acierto._on_visible_on_screen_notifier_2d_screen_exited()
	_comprobar(acierto.muerto and Global.salud == 1 and Global.puntaje == 100, "Música: el clic acertado no debe perder vida después.")
	carril.spawn_bolita()
	var acierto_teclado = get_tree().get_nodes_in_group("bolas").back()
	carril._on_panel_area_entered(acierto_teclado)
	var espacio = InputEventKey.new()
	espacio.keycode = KEY_SPACE
	espacio.pressed = true
	juego._unhandled_input(espacio)
	_comprobar(acierto_teclado.muerto and Global.puntaje == 200, "Música: ESPACIO debe acertar al pulsar la tecla.")
	carril.spawn_bolita()
	var ultima = get_tree().get_nodes_in_group("bolas").back()
	ultima._on_visible_on_screen_notifier_2d_screen_exited()
	_comprobar(Global.salud == 0 and juego.juego_terminado and juego.get_node("Perdiste").visible, "Música: la derrota debe ocurrir en el tercer fallo.")
	_comprobar(_vidas_visibles(juego.vidas_cont) == 0, "Música: corazones desincronizados.")
	print("OK: música, pausas aleatorias entre 0.7 y 1.2 s, clic y tres fallos.")

func _probar_monedas() -> void:
	await _cargar("res://Escenas/EscenasMonedas/tienda.tscn")
	var monedas = juego.monedas_nodo.get_children()
	var clic = _clic()
	SoundManager.win_coin.stop()
	monedas[0]._input_event(get_viewport(), clic, 0)
	_comprobar(not monedas[0].marcada and juego.puntos == 0 and not SoundManager.win_coin.playing, "Monedas: el aviso inicial debe bloquear toda recolección.")
	await _empezar()
	monedas[0]._input_event(get_viewport(), clic, 0)
	_comprobar(not monedas[0].marcada and juego.puntos == 0, "Monedas: se recogió una moneda antes de terminar el aviso.")
	await get_tree().create_timer(3.2).timeout
	_comprobar(juego.puede_recoger_monedas(), "Monedas: no se habilitó la ronda.")
	monedas[0]._input_event(get_viewport(), clic, 0)
	monedas[0]._input_event(get_viewport(), clic, 0)
	_comprobar(monedas[0].marcada and juego.puntos == 1, "Monedas: cada moneda debe sumar exactamente una vez.")
	monedas[1]._input_event(get_viewport(), _clic(MOUSE_BUTTON_RIGHT), 0)
	_comprobar(not monedas[1].marcada, "Monedas: el botón derecho no debe recolectar.")
	for indice in range(1, monedas.size()):
		monedas[indice]._input_event(get_viewport(), clic, 0)
	_comprobar(juego.puntos == 5 and not juego.timer_activo, "Monedas: debe poder completarse la ronda después de un clic temprano.")
	_comprobar(juego.label_central.text == "¡COMPLETADO!", "Monedas: no se alcanzó la victoria.")
	print("OK: monedas, clic temprano ignorado y cinco monedas recolectables.")

func _probar_topo() -> void:
	Global.salud = 1
	Global.ronda_local = 0
	await _cargar("res://Escenas/EsenasDaleAlTopo/dale_al_topo.tscn")
	_comprobar(Global.salud == 3 and _vidas_visibles(juego.vidas_cont) == 3, "Topo: se heredaron vidas de otro minijuego.")
	await _empezar()
	await _capturar("topo-tres-vidas")
	var hoyo = juego.hoyos.get_child(0)
	hoyo.mouse_dentro = true
	hoyo.index = 0
	for fallo in range(1, 4):
		hoyo.animal_fuera = true
		hoyo._input(_clic())
		hoyo._input(_clic())
		_comprobar(Global.salud == 3 - fallo, "Topo: un animal debe restar una sola vida.")
		_comprobar(_vidas_visibles(juego.vidas_cont) == 3 - fallo, "Topo: corazones desincronizados.")
	_comprobar(juego.juego_terminado and get_tree().paused, "Topo: falta la derrota al perder las tres vidas.")
	var reintentar = InputEventKey.new()
	reintentar.keycode = KEY_SPACE
	reintentar.pressed = true
	juego.get_node("Perdiste")._input(reintentar)
	await get_tree().process_frame
	await get_tree().process_frame
	juego = get_tree().current_scene
	_comprobar(Global.salud == 3 and _vidas_visibles(juego.vidas_cont) == 3, "Topo: el reintento no repone las tres vidas.")
	Global.ronda_local = 1
	Global.salud = 1
	await _cargar("res://Escenas/EsenasDaleAlTopo/dale_al_topo.tscn")
	_comprobar(Global.salud == 3 and _vidas_visibles(juego.vidas_cont) == 3, "Topo: la segunda ronda no empieza con tres vidas.")
	print("OK: topo, entrada desde otro juego, tres daños, reintento y segunda ronda.")
