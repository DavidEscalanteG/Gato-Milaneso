extends Node2D

const Espera = preload("res://Scripts/util/espera.gd")

@onready var label = $Timer/Label

func _ready():
	if not await Espera.segundos(self, 5.0):
		return
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
