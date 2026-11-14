extends Node2D

@onready var input_username = $CanvasLayer/panelMenuContainer/MarginContainer/GridGeneralContainer/PanelUserContainer/VBoxContainer/Username
var aviso_nombre: AcceptDialog
var ruta_personaje: String = "user://player.cfg"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	input_username.text_submitted.connect(func(_texto): _on_save_button_pressed())
	aviso_nombre = AcceptDialog.new()
	aviso_nombre.title = "Nombre de jugador"
	aviso_nombre.dialog_text = "Escribe un nombre de jugador para continuar."
	add_child(aviso_nombre)
	var panel = aviso_nombre.get_theme_stylebox("panel").duplicate()
	panel.bg_color = Color("fff4dc")
	aviso_nombre.add_theme_stylebox_override("panel", panel)
	aviso_nombre.get_label().add_theme_color_override("font_color", Color("30251c"))
	input_username.call_deferred("grab_focus")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_save_button_pressed() -> void:
	if Transicion.en_transicion:
		return
	SoundManager.play_click()
	var username = input_username.get_text()
	if username.strip_edges().is_empty():
		_mostrar_error("Escribe un nombre de jugador para continuar.")
		return
	
	## Cargar configuracion personaje personalizado
	var config = ConfigFile.new() 
	
	var err = config.load(ruta_personaje)
	
	if err != OK:
		_mostrar_error("No se pudo cargar tu personaje. Pulsa VOLVER para guardarlo otra vez.")
		return
	
	config.set_value("player", "username", username)
	
	if config.save(ruta_personaje) != OK:
		_mostrar_error("No se pudo guardar tu nombre. Inténtalo nuevamente.")
		return
	Global.username = username
	Global.borrador_datos_personales.clear()
	Global.registro_datos_personales_id = 0
	
	Transicion.cambiar_escena("res://Escenas/EscenasDialogos/dialogo1.tscn")

func _mostrar_error(texto: String) -> void:
	SoundManager.play_error()
	aviso_nombre.dialog_text = texto
	aviso_nombre.popup_centered()


func _on_play_botton_mouse_entered():
	SoundManager.play_hover()


func _on_resset_button_pressed() -> void:
	SoundManager.play_click()
	input_username.text = ""
	input_username.grab_focus()
	


func _on_back_button_pressed() -> void:
	Global.borrador_personaje = preload("res://Escenas/Player/datos_apariencia.gd").cargar()
	get_tree().change_scene_to_file("res://CreacionPersonaje/personaje.tscn")
