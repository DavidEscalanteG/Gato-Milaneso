extends Node2D

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_E and event.ctrl_pressed and event.shift_pressed:
			get_viewport().set_input_as_handled()
			get_tree().change_scene_to_file("res://Escenas/Admin/amindExportar.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SoundManager.fade_in_ambiente()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_play_botton_mouse_entered():
	SoundManager.play_hover()

func _on_play_botton_pressed():
	SoundManager.play_click()
	get_tree().change_scene_to_file("res://datosUsuario/datosPersonales.tscn") # Replace with function body.


func _on_support_botton_pressed() -> void:
	get_tree().quit()


func _on_credits_botton_pressed() -> void:
	SoundManager.play_click()
	get_tree().change_scene_to_file("res://Creditos/creditos.tscn")


func _on_credits_botton_mouse_entered() -> void:
	pass # Replace with function body.


func _on_support_botton_mouse_entered() -> void:
	pass # Replace with function body.
