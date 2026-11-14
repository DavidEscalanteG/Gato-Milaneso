extends Node2D

@onready var input_username = $CanvasLayer/panelMenuContainer/MarginContainer/GridGeneralContainer/PanelUserContainer/VBoxContainer/Username
var aviso_nombre: AcceptDialog

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	aviso_nombre = AcceptDialog.new()
	aviso_nombre.title = "Nombre de jugador"
	aviso_nombre.dialog_text = "Escribe un nombre de jugador para continuar."
	add_child(aviso_nombre)
	var panel = aviso_nombre.get_theme_stylebox("panel").duplicate()
	panel.bg_color = Color("fff4dc")
	aviso_nombre.add_theme_stylebox_override("panel", panel)
	aviso_nombre.get_label().add_theme_color_override("font_color", Color("30251c"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_save_button_pressed() -> void:
	SoundManager.play_click()
	var username = input_username.get_text()
	if username.strip_edges().is_empty():
		SoundManager.play_error()
		aviso_nombre.popup_centered()
		return
	
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
	Global.borrador_personaje = preload("res://Escenas/Player/datos_apariencia.gd").cargar()
	get_tree().change_scene_to_file("res://CreacionPersonaje/personaje.tscn")
