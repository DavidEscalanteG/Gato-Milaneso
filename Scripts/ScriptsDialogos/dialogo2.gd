extends Node2D

var balloon_layer : CanvasLayer = null

func _ready() -> void:
	Global.derrotas_perros = 0
	var resource = preload("res://Dialogos/test.dialogue")

	# Mostrar el balloon
	balloon_layer = DialogueManager.show_example_dialogue_balloon(resource, "conv2")


func _process(delta: float) -> void:
	if balloon_layer and not is_instance_valid(balloon_layer):
		# El balloon fue removido => diálogo terminó
		print("¡El diálogo terminó! Cambio a personaje.tscn")
		balloon_layer = null
		Transicion.cambiar_escena("res://Escenas/EscenasCartera/calle.tscn")
