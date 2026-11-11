extends Node2D

@onready var input_username = $CanvasLayer/panelMenuContainer/MarginContainer/GridGeneralContainer/PanelUserContainer/VBoxContainer/Username

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_save_button_pressed() -> void:
	SoundManager.play_click()
	var username = input_username.get_text()
	
	## Cargar configuracion personaje personalizado
	var config = ConfigFile.new() 
	
	var err = config.load("user://player.cfg")
	
	if err != OK:
		printerr(err)
		return
	
	config.set_value("player", "username", username)
	
	config.save("user://player.cfg")
	Global.username = username
	
	Transicion.cambiar_escena("res://Escenas/EscenasDialogos/dialogo1.tscn")


func _on_play_botton_mouse_entered():
	SoundManager.play_hover()


func _on_resset_button_pressed() -> void:
	SoundManager.play_click()
	input_username.text = ""
	input_username.grab_focus()
	


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://CreacionPersonaje/personaje.tscn")
