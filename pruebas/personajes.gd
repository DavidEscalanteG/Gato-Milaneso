extends Node

const Datos = preload("res://Escenas/Player/datos_apariencia.gd")
var fallos: Array[String] = []
var capturas: String = ""

func _ready() -> void:
	AudioServer.set_bus_mute(0, true)
	for argumento in OS.get_cmdline_user_args():
		if argumento.begins_with("--capturas="):
			capturas = argumento.trim_prefix("--capturas=")
	await _creador_y_apariencias()
	await _movimiento()
	await _victoria(KEY_ENTER)
	await _victoria(KEY_SPACE)
	_reinicio()
	_detener_audio(SoundManager)
	await get_tree().create_timer(0.2).timeout
	if fallos.is_empty():
		print("PRUEBAS PERSONAJES OK: creador, 20 combinaciones, silla, mapa, perros, movimiento, victoria y nueva partida.")
	else:
		for fallo in fallos:
			push_error(fallo)
	get_tree().quit(0 if fallos.is_empty() else 1)

func _detener_audio(nodo: Node) -> void:
	if nodo is AudioStreamPlayer or nodo is AudioStreamPlayer2D:
		nodo.stop()
	for hijo in nodo.get_children():
		_detener_audio(hijo)

func comprobar(condicion: bool, mensaje: String) -> void:
	if not condicion:
		fallos.append(mensaje)

func _capturar(nombre: String) -> void:
	if capturas.is_empty() or DisplayServer.get_name() == "headless":
		return
	DirAccess.make_dir_recursive_absolute(capturas)
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(capturas.path_join(nombre + ".png"))

func _creador_y_apariencias() -> void:
	var creador = load("res://CreacionPersonaje/personaje.tscn").instantiate()
	add_child(creador)
	await get_tree().process_frame
	comprobar(creador.cabello.texture != null and creador.cabellos.get_selected_items()[0] == 1, "Creador: debe iniciar con pelo visible.")
	comprobar(creador.color_picker.color == Color.BLACK, "Creador: el selector debe coincidir con el color real.")
	await _capturar("creador-pelo-inicial")
	var config = ConfigFile.new()
	config.parse(creador.crear_configuracion().encode_to_text())
	var mapa = load("res://Escenas/Player/Player.tscn").instantiate()
	var perros = load("res://Escenas/EscenasCartera/gato.tscn").instantiate()
	add_child(mapa)
	add_child(perros)
	mapa.set_physics_process(false)
	perros.set_physics_process(false)
	var a = mapa.get_node("Apariencia")
	var b = perros.get_node("Apariencia")
	a.configurar(config)
	comprobar(a.cabello.visible and a.cabello.region_rect.position.y == 0, "Mapa: el aspecto inicial guardado debe conservar el primer peinado.")
	comprobar(a.cabello.material != b.cabello.material, "Las instancias no deben compartir el tinte mutable.")
	for cuerpo in 4:
		for pelo in 5:
			creador.personajes.select(cuerpo)
			creador._on_item_list_personajes_item_clicked(cuerpo, Vector2.ZERO, MOUSE_BUTTON_LEFT)
			creador.cabellos.select(pelo)
			creador._on_item_list_item_clicked(pelo, Vector2.ZERO, MOUSE_BUTTON_LEFT)
			creador._on_color_picker_button_color_changed(Color.CORAL)
			config.parse(creador.crear_configuracion().encode_to_text())
			for avatar in [a, b]:
				avatar.configurar(config)
				comprobar(avatar.sprite.region_rect.position.y == cuerpo * 192, "Aspecto: cuerpo incorrecto.")
				comprobar(avatar.cabello.visible == (pelo > 0), "Aspecto: Sin pelo debe conservarse.")
				comprobar(avatar.cabello.region_rect.position.y == maxi(0, pelo - 1) * 192, "Aspecto: peinado incorrecto.")
				comprobar(avatar.cabello.material.get_shader_parameter("tint") == Vector4(Color.CORAL.r, Color.CORAL.g, Color.CORAL.b, 1), "Aspecto: color incorrecto.")
				for direccion in [Vector2.LEFT, Vector2.UP, Vector2.RIGHT, Vector2.DOWN]:
					avatar.animar(direccion)
					for fotograma in 4:
						avatar.animation.advance(0.2)
						comprobar(avatar.sprite.frame == avatar.cabello.frame, "Animación: pelo y cuerpo desincronizados.")
						var ajuste = -30 if cuerpo == 3 and is_zero_approx(direccion.y) else 0
						comprobar(avatar.cabello.position.y == avatar.sprite.position.y + ajuste, "Silla: alineación incorrecta al cambiar de dirección.")
					comprobar(avatar.sprite.flip_h == (direccion == Vector2.LEFT), "Animación: espejo lateral heredado en otra vista.")
				avatar.animar(Vector2.ZERO)
				comprobar(not avatar.animation.is_playing(), "El avatar debe detenerse al soltar las teclas.")
	creador._on_resset_button_pressed()
	comprobar(creador.cabello.texture == creador.cabellos.get_item_icon(1) and creador.color_picker.color == Color.BLACK, "Limpiar debe restaurar pelo y color iniciales.")
	config.set_value("player", "id_personaje", PackedInt32Array([3]))
	config.set_value("player", "id_cabello", PackedInt32Array([4]))
	Global.borrador_personaje = config
	var regreso = load("res://CreacionPersonaje/personaje.tscn").instantiate()
	add_child(regreso)
	comprobar(regreso.personajes.get_selected_items()[0] == 3 and regreso.cabellos.get_selected_items()[0] == 4, "Volver desde el nombre no debe borrar la apariencia.")
	regreso.queue_free()
	Global.borrador_personaje = null
	for valor in [PackedInt32Array(), PackedInt32Array([-1]), PackedInt32Array([50]), "inválido"]:
		config.set_value("player", "id_personaje", valor)
		config.set_value("player", "id_cabello", valor)
		a.configurar(config)
		comprobar(a.id_personaje == 0 and a.cabello.visible, "Configuración incompleta: deben aplicarse valores válidos.")
	creador.queue_free()
	mapa.queue_free()
	perros.queue_free()
	await get_tree().process_frame

func _movimiento() -> void:
	var mapa = load("res://Escenas/niveles.tscn").instantiate()
	add_child(mapa)
	var player = mapa.get_node("Player")
	Input.action_press("derecha")
	Input.action_press("arriba")
	await get_tree().physics_frame
	await get_tree().physics_frame
	comprobar(is_equal_approx(player.velocity.length(), player.velocidad), "Mapa: caminar en diagonal no debe acelerar.")
	Input.action_release("derecha")
	Input.action_release("arriba")
	await get_tree().physics_frame
	await get_tree().physics_frame
	comprobar(player.velocity.is_zero_approx() and not player.apariencia.animation.is_playing(), "Mapa: soltar las teclas debe parar movimiento y animación.")
	await _capturar("mapa-personaje")
	mapa.queue_free()
	await get_tree().process_frame

func _victoria(tecla: Key) -> void:
	var calle = load("res://Escenas/EscenasCartera/calle.tscn").instantiate()
	get_tree().root.add_child(calle)
	get_tree().current_scene = calle
	calle.get_node("InstruccionesUI")._on_boton_jugar_pressed()
	await get_tree().process_frame
	var config = ConfigFile.new()
	config.set_value("player", "id_personaje", PackedInt32Array([3]))
	config.set_value("player", "id_cabello", PackedInt32Array([4]))
	config.set_value("player", "color_cabello", Vector4(0.7, 0.2, 0.1, 1))
	calle.get_node("Gato/Apariencia").configurar(config)
	await _capturar("perros-personaje-silla")
	Input.action_press("izquierda")
	await get_tree().physics_frame
	await get_tree().physics_frame
	await _capturar("perros-silla-lateral")
	Input.action_release("izquierda")
	calle.get_node("Gato").win()
	await _capturar("perros-victoria")
	var evento = InputEventKey.new()
	evento.keycode = tecla
	evento.pressed = true
	Input.parse_input_event(evento)
	await get_tree().process_frame
	comprobar(Transicion.en_transicion, "Victoria: Enter y Espacio deben iniciar la transición.")
	Transicion.cambiar_escena("res://menuPrincipal/menu.tscn") # A duplicate must be ignored.
	await get_tree().create_timer(2.5).timeout
	comprobar(get_tree().current_scene.scene_file_path.ends_with("dialogo3.tscn") and Global.ronda == 1, "Victoria: debe continuar al diálogo correcto una sola vez.")
	get_tree().current_scene.queue_free()
	get_tree().current_scene = self
	await get_tree().process_frame

func _reinicio() -> void:
	Global.ronda = 6
	Global.ronda_local = 1
	Global.derrotas_perros = 3
	Global.set_respuesta(1, 3)
	Global.reiniciar_partida()
	comprobar(Global.ronda == 0 and Global.ronda_local == 0 and Global.derrotas_perros == 0 and Global.total_test == 0, "Nueva partida: no debe heredar progreso anterior.")
