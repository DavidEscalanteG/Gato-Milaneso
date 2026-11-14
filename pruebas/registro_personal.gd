extends Node

func _ready() -> void:
	AudioServer.set_bus_mute(0, true)
	if not OS.get_user_data_dir().replace("\\", "/").contains("/tmp/"):
		push_error("Usa APPDATA aislado bajo tmp para esta prueba.")
		get_tree().quit(1)
		return
	Global.reiniciar_partida()
	var formulario = load("res://datosUsuario/datosPersonales.tscn").instantiate()
	add_child(formulario)
	formulario.db_name = "user://registro-" + Crypto.new().generate_random_bytes(6).hex_encode()
	formulario.nombre_completo.text = "Persona Ficticia"
	formulario.edad_jugador.text = "12"
	formulario.genero_jugador.select(2)
	formulario.grado_jugador.select(1)
	var primero = formulario._guardar_registro()
	Global.registro_datos_personales_id = primero
	formulario.edad_jugador.text = "13"
	var editado = formulario._guardar_registro()
	var base = SQLite.new()
	base.path = formulario.db_name
	base.open_db()
	base.query("SELECT id, edad FROM DatosPersonales;")
	var correcto = primero > 0 and editado == primero and base.query_result.size() == 1 and int(base.query_result[0].edad) == 13
	Global.reiniciar_partida()
	var siguiente = formulario._guardar_registro()
	base.query("SELECT COUNT(*) AS cantidad FROM DatosPersonales;")
	correcto = correcto and siguiente != primero and int(base.query_result[0].cantidad) == 2
	base.close_db()
	formulario.queue_free()
	for sonido in SoundManager.get_children():
		if sonido is AudioStreamPlayer:
			sonido.stop()
	await get_tree().create_timer(0.2).timeout
	if correcto:
		print("REGISTRO OK: edición sin duplicados y nuevo registro para otro participante.")
	else:
		push_error("El registro debe actualizar la partida existente y separar participantes.")
	get_tree().quit(0 if correcto else 1)
