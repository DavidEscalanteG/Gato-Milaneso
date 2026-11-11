extends Node2D

@onready var mi_label = $Timer/Label2


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	var timestamp = Time.get_unix_time_from_system()
	var status = Global.respuestas_a_pdf(str(timestamp))
	print("pdf exportado: ", status)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_SPACE):
		mi_label.visible = false
		Transicion.cambiar_escena("res://menuPrincipal/menu.tscn")

func _on_timer_timeout() -> void:
	SoundManager.play_sound_end()
	mi_label.visible = !mi_label.visible
