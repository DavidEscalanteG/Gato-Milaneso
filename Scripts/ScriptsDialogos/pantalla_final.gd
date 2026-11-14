extends Node2D

@onready var mi_label = $Timer/Label2
var _guardado_correcto: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	_reintentar_guardado()

func _reintentar_guardado() -> void:
	_guardado_correcto = Global.guardar_reporte_final()
	mi_label.text = "Presiona ESPACIO para regresar al menú" if _guardado_correcto else "No se pudo guardar. Presiona R para reintentar."

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_R and not _guardado_correcto:
		get_viewport().set_input_as_handled()
		_reintentar_guardado()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if _guardado_correcto and Input.is_key_pressed(KEY_SPACE):
		mi_label.visible = false
		Transicion.cambiar_escena("res://menuPrincipal/menu.tscn")

func _on_timer_timeout() -> void:
	SoundManager.play_sound_end()
	mi_label.visible = !mi_label.visible
