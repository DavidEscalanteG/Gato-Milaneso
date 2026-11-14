extends Node

var _fallos: Array[String] = []
var _capturas = ""

func _ready() -> void:
	if not OS.get_user_data_dir().replace("\\", "/").contains("/tmp/"):
		get_tree().quit(1)
		return
	for argumento in OS.get_cmdline_user_args():
		if argumento.begins_with("--capturas="):
			_capturas = argumento.trim_prefix("--capturas=")
	var alias = "María José Álvarez ".repeat(30)
	var config = ConfigFile.new()
	config.set_value("player", "username", alias)
	_comprobar(config.save("user://player.cfg") == OK, "Guardar el alias completo.")
	var mapa = load("res://Escenas/niveles.tscn").instantiate()
	add_child(mapa)
	await get_tree().process_frame
	var etiqueta = mapa.get_node("Player/Username")
	_comprobar(etiqueta.text == alias and Global.username == alias and etiqueta.size.x <= 112, "El alias debe mantenerse completo sin ensanchar su espacio en el mapa.")
	await _capturar("mapa-alias-largo")
	mapa.queue_free()
	await get_tree().process_frame
	var globo = load("res://addons/dialogue_manager/example_balloon/example_balloon.tscn").instantiate()
	add_child(globo)
	var linea = DialogueLine.new()
	linea.character = "Á".repeat(300)
	Global.registrar_nombre_completo(linea.character + " Muñoz")
	globo.dialogue_line = linea
	await get_tree().process_frame
	await get_tree().process_frame
	_comprobar(globo.character_label.text.ends_with("…") and globo.character_label.get_line_count() == 1, "El nombre largo debe ocupar una sola línea.")
	_comprobar(Global.nombre_completo_jugador == linea.character + " Muñoz", "No recortar los datos guardados.")
	await _capturar("dialogo-nombre-largo")
	linea.character = "María"
	globo.dialogue_line = linea
	_comprobar(globo.character_label.text == "María", "Conservar la presentación del nombre normal con acento.")
	globo.queue_free()
	await get_tree().process_frame
	var nick = load("res://NickUsuario/usuario.tscn").instantiate()
	add_child(nick)
	nick.input_username.text = alias
	nick.input_username.caret_column = alias.length()
	await get_tree().process_frame
	_comprobar(nick.input_username.text == alias, "La captura debe conservar el alias completo.")
	await _capturar("captura-alias-largo")
	nick.queue_free()
	await get_tree().process_frame
	if _fallos.is_empty():
		print("NOMBRES LARGOS OK: captura íntegra, mapa acotado y diálogo de una línea.")
	else:
		for fallo in _fallos:
			push_error(fallo)
	get_tree().quit(0 if _fallos.is_empty() else 1)

func _capturar(nombre: String) -> void:
	if _capturas.is_empty() or DisplayServer.get_name() == "headless":
		return
	DirAccess.make_dir_recursive_absolute(_capturas)
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(_capturas.path_join(nombre + ".png"))

func _comprobar(condicion: bool, mensaje: String) -> void:
	if not condicion:
		_fallos.append(mensaje)
