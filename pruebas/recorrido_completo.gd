extends Node

# Integra las escenas reales. Resuelve los retos de forma asistida: no mide dificultad humana.
var fallos: Array[String] = []
var escenas_visitadas: Array[String] = []
var _ultimo_id: int = 0
var _mapas_activados: Dictionary = {}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var temporal = ProjectSettings.globalize_path("res://tmp").replace("\\", "/") + "/"
	# En un paquete res:// no siempre tiene una ruta física globalizable.
	# La prueba externa solo admite además tmp junto al ejecutable exportado.
	var temporal_paquete = OS.get_executable_path().get_base_dir().path_join("tmp").replace("\\", "/") + "/"
	var carpeta_datos = OS.get_data_dir().replace("\\", "/")
	var datos_de_prueba = carpeta_datos.begins_with(temporal) or (not OS.has_feature("editor") and carpeta_datos.begins_with(temporal_paquete))
	if not datos_de_prueba:
		push_error("Redirige APPDATA a tmp antes del recorrido completo.")
		get_tree().quit(1)
		return
	AudioServer.set_bus_mute(0, true)
	Global.reiniciar_partida()
	await get_tree().process_frame
	var formulario = load("res://datosUsuario/datosPersonales.tscn").instantiate()
	get_tree().root.add_child(formulario)
	get_tree().current_scene = formulario
	formulario.nombre_completo.text = "Participante Ficticio"
	formulario.edad_jugador.text = "12"
	formulario.genero_jugador.select(2)
	formulario.grado_jugador.select(1)
	formulario._on_save_button_pressed()
	var inicio = Time.get_ticks_msec()
	while Time.get_ticks_msec() - inicio < 180000:
		await get_tree().create_timer(0.04).timeout
		var escena = get_tree().current_scene
		if escena == null or Transicion.en_transicion:
			continue
		var ruta: String = escena.scene_file_path
		if escena.get_instance_id() != _ultimo_id:
			_ultimo_id = escena.get_instance_id()
			escenas_visitadas.append(ruta)
			print("RECORRIDO: ", ruta)
		if "balloon_layer" in escena:
			var globo = escena.balloon_layer
			if not is_instance_valid(globo) or not globo.is_node_ready() or globo.dialogue_line == null:
				continue
			if globo.dialogue_label.is_typing:
				globo.dialogue_label.skip_typing()
				continue
			if globo.is_waiting_for_input and globo.dialogue_line.responses.is_empty():
				globo.next(globo.dialogue_line.next_id)
				continue
			if not globo.responses_menu.visible:
				continue
			var respuestas: Array = globo.dialogue_line.responses
			if not respuestas.is_empty():
				var indice = 2 if respuestas.size() == 4 else 0
				globo.responses_menu.response_selected.emit(respuestas[indice])
		elif ruta == "res://CreacionPersonaje/personaje.tscn":
			escena._on_save_button_pressed()
		elif ruta == "res://NickUsuario/usuario.tscn":
			escena.input_username.text = "GatoPrueba"
			escena._on_save_button_pressed()
		elif ruta == "res://Escenas/niveles.tscn":
			if _mapas_activados.has(escena.get_instance_id()):
				continue
			_mapas_activados[escena.get_instance_id()] = true
			var destino = escena.nivel
			escena.player.global_position = destino.global_position
			for fotograma in 12:
				await get_tree().physics_frame
				await get_tree().process_frame
				if destino.dentro:
					break
			comprobar(destino.dentro and destino.disponible, "Mapa: destino actual accesible mediante colisión.")
			var entrar = InputEventKey.new()
			entrar.physical_keycode = KEY_E
			entrar.keycode = KEY_E
			entrar.pressed = true
			Input.parse_input_event(entrar)
			Input.flush_buffered_events()
			await get_tree().process_frame
			entrar = entrar.duplicate()
			entrar.pressed = false
			Input.parse_input_event(entrar)
			Input.flush_buffered_events()
		elif ruta == "res://Escenas/EscenasCartera/calle.tscn":
			await iniciar_reto(escena)
			escena.get_node("Gato").win()
			var aceptar = InputEventKey.new()
			aceptar.keycode = KEY_ENTER
			aceptar.pressed = true
			Input.parse_input_event(aceptar)
			Input.flush_buffered_events()
			aceptar = aceptar.duplicate()
			aceptar.pressed = false
			Input.parse_input_event(aceptar)
			Input.flush_buffered_events()
		elif ruta == "res://Escenas/EscenaBolitas/bolitas.tscn":
			await iniciar_reto(escena)
			escena._on_timer_timeout()
		elif ruta == "res://Escenas/EscenasMaquina/slot_machine.tscn":
			await iniciar_reto(escena)
			if not escena.juego_terminado:
				escena.calcular_premio(["0", "0", "0"])
		elif ruta == "res://Escenas/EscenasMonedas/tienda.tscn":
			await iniciar_reto(escena)
			if not escena.puede_recoger_monedas():
				continue
			var clic = InputEventMouseButton.new()
			clic.button_index = MOUSE_BUTTON_LEFT
			clic.pressed = true
			for moneda in escena.monedas_nodo.get_children():
				moneda._input_event(get_viewport(), clic, 0)
		elif ruta == "res://Escenas/EsenasDaleAlTopo/dale_al_topo.tscn":
			await iniciar_reto(escena)
			Global.puntaje = escena.objetivo
		elif ruta == "res://Escenas/EscenasDialogos/pantalla_final.tscn":
			comprobar(Global.total_test == 18 and Global.respuestas_test.p10 == 2, "Final: conservar las diez respuestas reales del recorrido.")
			comprobar(FileAccess.file_exists(Global.ultimo_pdf_path), "Final: producir el reporte.")
			for juego in ["res://Escenas/EscenasCartera/calle.tscn", "res://Escenas/EscenaBolitas/bolitas.tscn", "res://Escenas/EscenasMaquina/slot_machine.tscn", "res://Escenas/EscenasMonedas/tienda.tscn", "res://Escenas/EsenasDaleAlTopo/dale_al_topo.tscn"]:
				comprobar(juego in escenas_visitadas, "Recorrido: faltó el reto " + juego)
			await terminar()
			return
	fallos.append("Recorrido: no se alcanzó el final dentro del límite de tiempo.")
	await terminar()

func iniciar_reto(escena: Node) -> void:
	if escena.has_node("InstruccionesUI"):
		escena.get_node("InstruccionesUI")._on_boton_jugar_pressed()
	await get_tree().process_frame

func comprobar(condicion: bool, mensaje: String) -> void:
	if not condicion and mensaje not in fallos:
		fallos.append(mensaje)

func terminar() -> void:
	get_tree().paused = false
	var actual = get_tree().current_scene
	get_tree().current_scene = self
	if actual != self:
		actual.queue_free()
	await get_tree().process_frame
	for sonido in SoundManager.get_children():
		if sonido is AudioStreamPlayer:
			sonido.stop()
	await get_tree().create_timer(0.2).timeout
	if fallos.is_empty():
		print("RECORRIDO COMPLETO OK: %d entradas de escena, cinco retos, diez respuestas y PDF final." % escenas_visitadas.size())
	else:
		for fallo in fallos:
			push_error(fallo)
	get_tree().quit(0 if fallos.is_empty() else 1)
