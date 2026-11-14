extends Node

var _fallos: Array[String] = []
var _entradas = 0

func _ready() -> void:
	AudioServer.set_bus_mute(0, true)
	var escenario = Node2D.new()
	get_tree().root.add_child.call_deferred(escenario)
	await get_tree().process_frame
	get_tree().current_scene = escenario
	var entrada = load("res://Escenas/teleport.tscn").instantiate()
	escenario.add_child(entrada)
	entrada.escena = "res://menuPrincipal/menu.tscn"
	entrada.disponible = true
	entrada.dentro = true
	var evento = InputEventKey.new()
	evento.keycode = KEY_E
	evento.physical_keycode = KEY_E
	evento.pressed = true
	evento.echo = true
	entrada._input(evento)
	_comprobar(not entrada._entrando, "Ignorar la repetición automática de la tecla.")
	evento.echo = false
	evento.pressed = false
	entrada._input(evento)
	_comprobar(not entrada._entrando, "Ignorar la liberación de la tecla.")
	evento.pressed = true
	get_tree().root.child_entered_tree.connect(func(nodo):
		if nodo.scene_file_path == "res://menuPrincipal/menu.tscn":
			_entradas += 1
	)
	for repeticion in 20:
		entrada._input(evento)
	var capas = entrada.get_children().filter(func(nodo): return nodo is CanvasLayer)
	_comprobar(entrada._entrando and capas.size() == 1, "Veinte pulsaciones deben crear un solo fundido.")
	await get_tree().create_timer(1.2).timeout
	_comprobar(_entradas == 1 and get_tree().current_scene.scene_file_path == "res://menuPrincipal/menu.tscn", "Cambiar de escena exactamente una vez.")
	get_tree().current_scene.queue_free()
	get_tree().current_scene = self
	await get_tree().process_frame
	for sonido in SoundManager.get_children():
		if sonido is AudioStreamPlayer:
			sonido.stop()
	await get_tree().create_timer(0.2).timeout
	if _fallos.is_empty():
		print("ENTRADA MAPA OK: sin repetición automática, un fundido y un cambio de escena.")
	else:
		for fallo in _fallos:
			push_error(fallo)
	get_tree().quit(0 if _fallos.is_empty() else 1)

func _comprobar(condicion: bool, mensaje: String) -> void:
	if not condicion:
		_fallos.append(mensaje)
