extends Node2D

@onready var nombre_completo = $CanvasLayer/panelMenuContainer/MarginContainer/GridContainer/PanelContainer/MarginContainer/GridContainer/VBoxContainer/nameCompletInput
@onready var edad_jugador = $CanvasLayer/panelMenuContainer/MarginContainer/GridContainer/PanelContainer/MarginContainer/GridContainer/VBoxContainer3/ageInput
@onready var genero_jugador = $CanvasLayer/panelMenuContainer/MarginContainer/GridContainer/PanelContainer/MarginContainer/GridContainer/VBoxContainer4/genderOptionButton
@onready var grado_jugador = $CanvasLayer/panelMenuContainer/MarginContainer/GridContainer/PanelContainer/MarginContainer/GridContainer/VBoxContainer5/gradeOptionButton
@onready var error_window = $CanvasLayer/panelMenuContainer/MarginContainer/GridContainer/ErrorWindow


var db : SQLite = null
const verbosity_level : int = SQLite.VERBOSE
var db_name := "user://baseDatos"
var table_name := "DatosPersonales"
var tabla := "CREATE TABLE IF NOT EXISTS DatosPersonales (id INTEGER PRIMARY KEY AUTOINCREMENT, nombre TEXT, edad NUMERIC, genero TEXT, gradoAcademico NUMERIC);"


# Called when the node enters the scene tree for the first time.

func _on_back_button_pressed() -> void:
	SoundManager.play_click()
	#Volver a la escena principal
	get_tree().change_scene_to_file("res://menuPrincipal/menu.tscn")


func _on_resset_button_pressed() -> void:
	SoundManager.play_click()
	# Reiniciar los campos
	nombre_completo.text = ""
	edad_jugador.text = ""
	genero_jugador.text = ""
	grado_jugador.text = ""

func _on_play_botton_mouse_entered():
	SoundManager.play_hover()
	
	
	
func _on_play_select_pressed_click():
	SoundManager.play_select_pressed()
	
func _on_save_button_pressed() -> void:
	SoundManager.play_click()
	if not validar_campos():
		mostrar_error("Favor de rellenar todos los campos correctamente.")
		return

	var dir = DirAccess.open("user://BaseDeDatos")
	db = SQLite.new()
	db.path = db_name
	db.verbosity_level = verbosity_level
	db.open_db()
	db.query(tabla)

	db.query_with_bindings(
		"INSERT INTO DatosPersonales (nombre, edad, genero, gradoAcademico) VALUES (?, ?, ?, ?);",
		[nombre_completo.text, int(edad_jugador.text), genero_jugador.text, grado_jugador.text]
	)
	db.query("SELECT * FROM DatosPersonales;")
	
	Global.registrar_nombre_completo(nombre_completo.text)
	Global.reiniciar_partida()
	
	get_tree().change_scene_to_file("res://Escenas/EscenasDialogos/dialogo_inicial.tscn")

func validar_campos() -> bool:
	if nombre_completo.text.strip_edges().is_empty() or edad_jugador.text.strip_edges().is_empty() or not edad_jugador.text.is_valid_int():
		return false
	if genero_jugador.selected == -1:  # -1 indica que no se seleccionó ninguna opción
		return false
	if grado_jugador.selected == -1:
		return false
	return true

func mostrar_error(mensaje: String) -> void:
	SoundManager.play_error()
	error_window.set_title("Error")
	error_window.set_text(mensaje)
	error_window.popup_centered()


func _on_name_complet_input_text_changed(new_text: String) -> void:
	SoundManager.play_type_sound()
	pass # Replace with function body.




func _on_gender_option_button_item_selected(index: int) -> void:
	SoundManager.play_click()
	pass # Replace with function body.
