extends Control

func _ready():
	visible = false
	$SaltarNivel.pressed.connect(_continuar_sin_perros)

func mostrar():
	visible = true
	$SaltarNivel.visible = Global.derrotas_perros >= 3
	set_process_unhandled_input(true)  # Permitir entrada aunque el juego esté "pausado"
	get_viewport().set_input_as_handled()  # Asegura que capture la entrada

func ocultar():
	visible = false
	set_process_unhandled_input(false)

func _unhandled_input(event):  
	if visible and event.is_action_pressed("ui_accept") and not event.is_echo():
		reiniciar_juego()

func _continuar_sin_perros() -> void:
	get_tree().current_scene.continuar_sin_perros()

func reiniciar_juego():
	print("Reiniciando juego...")
	visible = false

	# Rehabilitar el movimiento del gato
	var gato = get_tree().current_scene.get_node("Gato")  
	if gato:
		gato.set_process(true)
		gato.set_physics_process(true)

	# Rehabilitar el movimiento de los perros
	var perros = get_tree().get_nodes_in_group("perros")
	for perro in perros:
		perro.set_process(true)
		perro.set_physics_process(true)

	# Recargar la escena
	get_tree().reload_current_scene()
