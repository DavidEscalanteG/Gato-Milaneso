extends Node

func _ready() -> void:
	AudioServer.set_bus_mute(0, true)
	if not OS.get_user_data_dir().replace("\\", "/").contains("/tmp/"):
		get_tree().quit(1)
		return
	Global.reiniciar_partida()
	var bloqueo = "user://bloqueo-" + Crypto.new().generate_random_bytes(6).hex_encode()
	var archivo = FileAccess.open(bloqueo, FileAccess.WRITE)
	archivo.store_string("Archivo de prueba, no es una carpeta.")
	archivo.close()
	var formulario = load("res://datosUsuario/datosPersonales.tscn").instantiate()
	add_child(formulario)
	formulario.nombre_completo.text = "Persona Ficticia"
	formulario.edad_jugador.text = "12"
	formulario.genero_jugador.select(0)
	formulario.grado_jugador.select(0)
	formulario.db_name = bloqueo.path_join("base")
	formulario._on_save_button_pressed()
	var correcto = formulario.error_window.visible and formulario.nombre_completo.text == "Persona Ficticia" and Global.registro_datos_personales_id == 0
	formulario.error_window.hide()
	var creador = load("res://CreacionPersonaje/personaje.tscn").instantiate()
	add_child(creador)
	creador.ruta_personaje = bloqueo.path_join("player.cfg")
	creador._on_save_button_pressed()
	correcto = correcto and creador.aviso_guardado.visible and creador.cabellos.get_selected_items()[0] == 1
	creador.aviso_guardado.hide()
	var alias = load("res://NickUsuario/usuario.tscn").instantiate()
	add_child(alias)
	alias.ruta_personaje = bloqueo.path_join("player.cfg")
	alias.input_username.text = "Nombre Conservado"
	alias._on_save_button_pressed()
	correcto = correcto and alias.aviso_nombre.visible and alias.input_username.text == "Nombre Conservado" and not Transicion.en_transicion
	alias.aviso_nombre.hide()
	for argumento in OS.get_cmdline_user_args():
		if argumento.begins_with("--solo-lectura="):
			alias.ruta_personaje = argumento.trim_prefix("--solo-lectura=")
			alias._on_save_button_pressed()
			correcto = correcto and alias.aviso_nombre.visible and alias.aviso_nombre.dialog_text.begins_with("No se pudo guardar") and not Transicion.en_transicion
	for sonido in SoundManager.get_children():
		if sonido is AudioStreamPlayer:
			sonido.stop()
	formulario.queue_free()
	creador.queue_free()
	alias.queue_free()
	await get_tree().create_timer(0.2).timeout
	if correcto:
		print("GUARDADO OK: errores de base, personaje y alias mantienen la captura y bloquean el avance.")
	else:
		push_error("Un fallo de almacenamiento no debe descartar la captura ni iniciar una transición.")
	get_tree().quit(0 if correcto else 1)
