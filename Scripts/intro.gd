extends Node2D

@onready var label = $Timer/Label

func _ready():
	await get_tree().create_timer(5.0).timeout
	Transicion.cambiar_escena("res://menuPrincipal/menu.tscn")
	

# Esta función se conecta desde el nodo Timer (señal timeout)
func _on_timer_timeout() -> void:
	# Reproducir sonido
	SoundManager.play_sound_end()
	
	# Alternar visibilidad (Si está visible se oculta, si está oculto se ve)
	label.visible = not label.visible


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
