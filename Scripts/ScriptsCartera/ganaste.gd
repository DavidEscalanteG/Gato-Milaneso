extends Control

func _ready():
	visible = false

func mostrar():
	visible = true
	set_process_unhandled_input(true)  # Captura input aunque esté detenido
	get_viewport().set_input_as_handled()

func ocultar():
	visible = false
	set_process_unhandled_input(false)

func _unhandled_input(event):
	if visible and event.is_action_pressed("ui_accept"):  # ESPACIO o Enter
		ir_a_siguiente()

func ir_a_siguiente():
	print("Pasando al siguiente escenario...")
	visible = false
	get_tree().change_scene_to_file("") # <-- Cambia aquí la ruta
