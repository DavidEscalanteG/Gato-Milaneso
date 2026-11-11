extends Node2D

var balloon_layer : CanvasLayer = null

func _ready() -> void:
	var resource = preload("res://Dialogos/test.dialogue")
	# Mostrar el balloon
	balloon_layer = DialogueManager.show_example_dialogue_balloon(resource, "conv9")


func _process(delta: float) -> void:
	if balloon_layer and not is_instance_valid(balloon_layer):
		balloon_layer = null
		Transicion.cambiar_escena("res://Escenas/EsenasDaleAlTopo/dale_al_topo.tscn")
