extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_save_button_pressed() -> void:
	SoundManager.play_click()
	get_tree().change_scene_to_file("res://menuPrincipal/menu.tscn")


func _on_play_botton_mouse_entered():
	SoundManager.play_hover()
