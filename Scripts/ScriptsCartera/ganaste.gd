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
	if visible and event.is_action_pressed("ui_accept") and not event.is_echo():
		get_viewport().set_input_as_handled()
		ir_a_siguiente()

func ir_a_siguiente():
	print("Pasando al siguiente escenario...")
	visible = false
	Global.ronda = 1
	Transicion.cambiar_escena("res://Escenas/EscenasDialogos/dialogo3.tscn")
