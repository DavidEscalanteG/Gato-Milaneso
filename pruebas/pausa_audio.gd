extends Node

const Espera = preload("res://Scripts/util/espera.gd")
var fallos: Array[String] = []
var juego: Node
var capturas: String = ""


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var temporal = ProjectSettings.globalize_path("res://tmp").replace("\\", "/") + "/"
	if not OS.get_data_dir().replace("\\", "/").begins_with(temporal):
		push_error("Ejecuta pausa_audio con APPDATA aislado bajo tmp/.")
		get_tree().quit(1)
		return
	AudioServer.set_bus_mute(0, true)
	for argumento in OS.get_cmdline_user_args():
		if argumento.begins_with("--capturas="):
			capturas = argumento.trim_prefix("--capturas=")
	Global.reiniciar_partida()
	await _perros_y_esperas()
	await _musica_y_derrota()
	await _dialogo_y_salida()
	await _ajustes_audio()
	await _cargar("res://Escenas/EscenasMaquina/slot_machine.tscn")
	comprobar(SoundManager.ambiente_slot_machine.playing, "Cierre: reproducir el MP3 que causaba el aviso.")
	Pausa.abrir()
	# Emite la misma señal que el botón de cierre de la ventana. No realiza
	# limpieza de audio desde la prueba: debe hacerla el código del producto.
	get_tree().root.close_requested.emit()
	get_tree().root.close_requested.emit()
	comprobar(SoundManager.cerrando and not SoundManager.ambiente_slot_machine.playing,
		"Cierre: detener el audio una sola vez antes de terminar.")
	if fallos.is_empty():
		print("PAUSA Y AUDIO OK: temporizadores, progreso, instrucciones, derrota, diálogo, ajustes y cierre real.")
	else:
		for fallo in fallos:
			push_error(fallo)
		get_tree().quit(1)


func comprobar(condicion: bool, mensaje: String) -> void:
	if not condicion:
		fallos.append(mensaje)


func _cargar(ruta: String) -> void:
	if Pausa.abierta:
		Pausa.reanudar()
	get_tree().paused = false
	get_tree().current_scene = self
	if is_instance_valid(juego):
		SoundManager.detener_audio(juego)
		juego.queue_free()
	await get_tree().process_frame
	juego = load(ruta).instantiate()
	# Establecer la escena antes de _ready: DialogueManager añade el globo
	# a current_scene. La raíz de esta prueba procesa incluso durante la pausa.
	juego.tree_entered.connect(func(): get_tree().current_scene = juego, CONNECT_ONE_SHOT)
	get_tree().root.add_child(juego)
	await get_tree().process_frame
	await get_tree().process_frame


func _tecla(tecla: Key) -> void:
	var pulsar = InputEventKey.new()
	pulsar.keycode = tecla
	pulsar.physical_keycode = tecla
	pulsar.pressed = true
	Input.parse_input_event(pulsar)
	Input.flush_buffered_events()
	await get_tree().process_frame
	var soltar = pulsar.duplicate()
	soltar.pressed = false
	Input.parse_input_event(soltar)
	Input.flush_buffered_events()
	await get_tree().process_frame


func _clic_continuar() -> void:
	if DisplayServer.get_name() == "headless":
		Pausa.continuar.pressed.emit()
	else:
		await get_tree().process_frame
		var evento = InputEventMouseButton.new()
		evento.button_index = MOUSE_BUTTON_LEFT
		evento.pressed = true
		evento.position = Pausa.continuar.get_global_transform_with_canvas() * (Pausa.continuar.size * 0.5)
		evento.global_position = evento.position
		Input.parse_input_event(evento)
		Input.flush_buffered_events()
		await get_tree().process_frame
		evento = evento.duplicate()
		evento.pressed = false
		Input.parse_input_event(evento)
		Input.flush_buffered_events()
	await get_tree().process_frame


func _esperar_juego(nodo: Node, resultados: Array) -> void:
	resultados.append(await Espera.segundos(nodo, 0.15))


func _capturar(nombre: String) -> void:
	if capturas.is_empty() or DisplayServer.get_name() == "headless":
		return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(capturas))
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(capturas.path_join(nombre + ".png"))


func _perros_y_esperas() -> void:
	await _cargar("res://Escenas/EscenasCartera/calle.tscn")
	comprobar(get_tree().paused and not juego.panel_progreso.visible, "Perros: esperar a JUGAR antes del progreso.")
	await _tecla(KEY_ESCAPE)
	comprobar(Pausa.abierta and get_tree().paused, "Pausa: Escape debe funcionar también sobre instrucciones.")
	comprobar(juego.get_node("InstruccionesUI").process_mode == Node.PROCESS_MODE_PAUSABLE,
		"Pausa: bloquear la interfaz que normalmente procesa durante la pausa.")
	await _clic_continuar()
	comprobar(not Pausa.abierta and get_tree().paused and juego.has_node("InstruccionesUI"),
		"Pausa: continuar no debe empezar el reto ni saltar instrucciones.")
	comprobar(juego.get_node("InstruccionesUI").process_mode == Node.PROCESS_MODE_ALWAYS,
		"Pausa: restaurar el modo de proceso original.")
	juego.get_node("InstruccionesUI")._on_boton_jugar_pressed()
	await get_tree().process_frame
	await get_tree().create_timer(0.1).timeout
	comprobar(juego.tiempo_para_cartera == 50 and juego.panel_progreso.visible,
		"Perros: conservar los 50 segundos originales y mostrar la barra.")
	var resultados: Array = []
	_esperar_juego(juego, resultados)
	# Solo para la captura: mostrar un estado intermedio sin esperar 53 segundos.
	juego.tiempo_busqueda = juego._duracion_busqueda * 0.5
	await get_tree().process_frame
	await _capturar("perros-progreso")
	await _tecla(KEY_ESCAPE)
	var tiempo = juego.tiempo_busqueda
	var progreso = juego.barra_progreso.value
	var fotograma = juego.get_node("Gato/Apariencia/Personaje").frame
	await get_tree().create_timer(0.3).timeout
	comprobar(is_equal_approx(juego.tiempo_busqueda, tiempo) and juego.barra_progreso.value == progreso,
		"Perros: congelar el progreso mientras está en pausa.")
	comprobar(resultados.is_empty(), "Pausa: la espera compartida no debe terminar por tiempo de reloj.")
	comprobar(juego.get_node("Gato/Apariencia/Personaje").frame == fotograma,
		"Perros: la caminata continua debe detenerse durante la pausa.")
	await _capturar("pausa-perros")
	await _tecla(KEY_ESCAPE)
	await get_tree().create_timer(0.2).timeout
	comprobar(resultados == [true] and juego.tiempo_busqueda > tiempo,
		"Pausa: reanudar esperas y progreso desde el punto anterior.")
	juego.generar_cartera()
	comprobar(juego.barra_progreso.value == 100.0 and not juego._busqueda_en_curso,
		"Perros: completar la barra al aparecer la cartera.")
	await _capturar("perros-cartera")
	var gato = juego.get_node("Gato")
	for golpe in 3:
		gato.inmune = false
		gato.perder_vida()
	var id = juego.get_instance_id()
	Pausa.abrir()
	get_viewport().gui_release_focus()
	await _tecla(KEY_SPACE)
	comprobar(Pausa.abierta and get_tree().current_scene.get_instance_id() == id,
		"Perros: Espacio dentro de la pausa no debe reintentar detrás del panel.")
	Pausa.reanudar()
	await _tecla(KEY_SPACE)
	juego = get_tree().current_scene
	comprobar(juego.get_instance_id() != id and juego.barra_progreso.value == 0.0,
		"Perros: reintentar repone la barra sin alterar la derrota.")


func _musica_y_derrota() -> void:
	await _cargar("res://Escenas/EscenaBolitas/bolitas.tscn")
	juego.get_node("InstruccionesUI")._on_boton_jugar_pressed()
	await get_tree().process_frame
	await get_tree().create_timer(0.1).timeout
	var reproductor = juego.get_node("AudioStreamPlayer")
	comprobar(reproductor.bus == &"Musica", "Audio: la canción debe usar el bus de música.")
	Pausa.abrir()
	var tiempo = juego.timer.time_left
	var posicion = reproductor.get_playback_position()
	await get_tree().create_timer(0.3).timeout
	comprobar(absf(juego.timer.time_left - tiempo) < 0.01 and reproductor.stream_paused,
		"Música: detener juntos el cronómetro y la canción.")
	comprobar(absf(reproductor.get_playback_position() - posicion) < 0.1,
		"Música: mantener la posición de reproducción durante la pausa.")
	await _clic_continuar()
	await get_tree().create_timer(0.15).timeout
	comprobar(juego.timer.time_left < tiempo and not reproductor.stream_paused,
		"Música: continuar la canción y el cronómetro, sin reiniciarlos.")
	juego.fin_del_juego_derrota()
	var id = juego.get_instance_id()
	Pausa.abrir()
	get_viewport().gui_release_focus()
	await _tecla(KEY_SPACE)
	comprobar(get_tree().current_scene.get_instance_id() == id and Pausa.abierta,
		"Derrota: la interfaz ALWAYS no debe recibir Espacio detrás de la pausa.")
	Pausa.reanudar()
	comprobar(get_tree().paused and juego.get_node("Perdiste").process_mode == Node.PROCESS_MODE_ALWAYS,
		"Derrota: continuar conserva su pausa y habilita su reintento.")
	await _tecla(KEY_SPACE)
	juego = get_tree().current_scene
	comprobar(juego.get_instance_id() != id and juego.has_node("InstruccionesUI"),
		"Derrota: el reintento debe seguir funcionando después de usar pausa.")
	juego.get_node("InstruccionesUI")._on_boton_jugar_pressed()
	await get_tree().process_frame
	juego.timer.start(0.05)
	Pausa.abrir()
	Pausa.pedir_volver_menu()
	Pausa.confirmar_salida()
	await get_tree().create_timer(2.3).timeout
	juego = get_tree().current_scene
	comprobar(juego.scene_file_path == Pausa.MENU and not get_tree().paused,
		"Salida: un cronómetro a punto de terminar no debe desviar el regreso al menú.")


func _dialogo_y_salida() -> void:
	await _cargar("res://Escenas/EscenasDialogos/dialogo1.tscn")
	var globo = juego.balloon_layer
	# El recurso del diálogo se obtiene de forma asíncrona al entrar.
	while globo.dialogue_line == null:
		await get_tree().process_frame
	await get_tree().create_timer(0.05).timeout
	Pausa.abrir()
	var caracteres = globo.dialogue_label.visible_characters
	await get_tree().create_timer(0.2).timeout
	comprobar(globo.dialogue_label.visible_characters == caracteres and Global.respuestas_test.p1 == -1,
		"Diálogo: pausar la escritura y conservar la pregunta pendiente.")
	Pausa.pedir_volver_menu()
	await _capturar("pausa-confirmacion")
	await _tecla(KEY_ESCAPE)
	comprobar(Pausa.abierta and Pausa.contenido.visible and get_tree().current_scene == juego,
		"Salida: Escape cancela el aviso sin abandonar la partida.")
	Pausa.reanudar()
	await get_tree().create_timer(0.1).timeout
	comprobar(globo.dialogue_label.visible_characters >= caracteres,
		"Diálogo: recuperar la escritura al continuar.")
	Pausa.abrir()
	Pausa.pedir_volver_menu()
	Pausa.confirmar_salida()
	await get_tree().create_timer(2.3).timeout
	juego = get_tree().current_scene
	comprobar(juego.scene_file_path == Pausa.MENU and not get_tree().paused and not Pausa.abierta,
		"Salida: regresar al menú sin conservar el árbol pausado.")
	comprobar(Global.ronda == 0 and Global.respuestas_test.p1 == -1,
		"Salida: limpiar el progreso de la partida abandonada.")


func _ajustes_audio() -> void:
	await _capturar("menu-principal")
	var boton = juego.get_node("CanvasLayer/panelMenuContainer/MarginContainer/GridContainer/VBottonContainer/audioBotton")
	boton.grab_focus()
	boton.pressed.emit()
	comprobar(Pausa.abierta and not Pausa.get_node("%VolverMenu").visible,
		"Audio: abrir ajustes desde el menú sin ofrecer abandonar una partida.")
	if DisplayServer.get_name() == "headless":
		Pausa.musica.value = 35
	else:
		await get_tree().process_frame
		var clic = InputEventMouseButton.new()
		clic.button_index = MOUSE_BUTTON_LEFT
		clic.pressed = true
		clic.position = Pausa.musica.get_global_transform_with_canvas() * (Pausa.musica.size * Vector2(0.35, 0.5))
		clic.global_position = clic.position
		Input.parse_input_event(clic)
		Input.flush_buffered_events()
		await get_tree().process_frame
		clic = clic.duplicate()
		clic.pressed = false
		Input.parse_input_event(clic)
		Input.flush_buffered_events()
		await get_tree().process_frame
	comprobar(SoundManager.volumen_musica > 20 and SoundManager.volumen_musica < 50,
		"Audio: el deslizador debe responder al clic real sobre su carril.")
	Pausa.musica.grab_focus()
	var volumen = SoundManager.volumen_musica
	await _tecla(KEY_RIGHT)
	comprobar(SoundManager.volumen_musica > volumen, "Audio: permitir ajuste del volumen con flechas.")
	Pausa.musica.value = 0
	Pausa.efectos.value = 40
	await get_tree().create_timer(0.4).timeout
	var bus_musica = AudioServer.get_bus_index(&"Musica")
	var bus_efectos = AudioServer.get_bus_index(&"Efectos")
	comprobar(AudioServer.is_bus_mute(bus_musica) and not AudioServer.is_bus_mute(bus_efectos),
		"Audio: silenciar música sin silenciar efectos.")
	comprobar(is_equal_approx(db_to_linear(AudioServer.get_bus_volume_db(bus_efectos)), 0.4),
		"Audio: aplicar el volumen de efectos sin cambiar la mezcla original.")
	SoundManager.ajustar_musica(100)
	SoundManager.ajustar_efectos(100)
	SoundManager.cargar_ajustes_audio()
	comprobar(SoundManager.volumen_musica == 0 and SoundManager.volumen_efectos == 40,
		"Audio: recuperar los ajustes guardados en un archivo independiente.")
	Pausa.musica.value = 70
	Pausa.efectos.value = 60
	await _capturar("audio-menu")
	Pausa.reanudar()
	comprobar(not get_tree().paused and boton.has_focus(), "Audio: volver al menú y restaurar su foco.")
	var config = ConfigFile.new()
	config.set_value("audio", "musica", "inválido")
	config.set_value("audio", "efectos", -10)
	config.save(SoundManager.RUTA_AJUSTES_AUDIO)
	SoundManager.cargar_ajustes_audio()
	comprobar(SoundManager.volumen_musica == 100 and SoundManager.volumen_efectos == 0,
		"Audio: recuperar valores seguros de una configuración dañada.")
	SoundManager.ajustar_musica(100)
	SoundManager.ajustar_efectos(100)
	SoundManager.guardar_ajustes_audio()
