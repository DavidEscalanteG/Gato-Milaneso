extends CanvasLayer

@export var fn_perdiste: Callable

signal perdiste

func _ready() -> void:
	set_visible(false)
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event: InputEvent) -> void:
	if event.is_action("ui_accept") and is_visible():
		if not fn_perdiste:
			get_tree().paused = false
			
		if not fn_perdiste:
			get_tree().reload_current_scene()
		else:
			fn_perdiste.call()

func mostrar() -> void:
	get_tree().paused = true
	set_visible(true)
