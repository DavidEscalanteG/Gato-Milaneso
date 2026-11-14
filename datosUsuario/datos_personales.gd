extends Node2D

@onready var nombre_completo = $CanvasLayer/panelMenuContainer/MarginContainer/GridContainer/PanelContainer/MarginContainer/GridContainer/VBoxContainer/nameCompletInput
@onready var edad_jugador = $CanvasLayer/panelMenuContainer/MarginContainer/GridContainer/PanelContainer/MarginContainer/GridContainer/VBoxContainer3/ageInput
@onready var genero_jugador = $CanvasLayer/panelMenuContainer/MarginContainer/GridContainer/PanelContainer/MarginContainer/GridContainer/VBoxContainer4/genderOptionButton
@onready var grado_jugador = $CanvasLayer/panelMenuContainer/MarginContainer/GridContainer/PanelContainer/MarginContainer/GridContainer/VBoxContainer5/gradeOptionButton
@onready var error_window = $CanvasLayer/panelMenuContainer/MarginContainer/GridContainer/ErrorWindow


var db : SQLite = null
const verbosity_level : int = 0
var db_name := "user://baseDatos"
var table_name := "DatosPersonales"
var tabla := "CREATE TABLE IF NOT EXISTS DatosPersonales (id INTEGER PRIMARY KEY AUTOINCREMENT, nombre TEXT, edad NUMERIC, genero TEXT, gradoAcademico NUMERIC);"
var _campo_por_corregir: Control

func _ready() -> void:
	error_window.confirmed.connect(_enfocar_campo_por_corregir)
	error_window.canceled.connect(_enfocar_campo_por_corregir)
	var datos = Global.borrador_datos_personales
	if not datos.is_empty():
		nombre_completo.text = datos.nombre
		edad_jugador.text = datos.edad
		genero_jugador.select(datos.genero)
		grado_jugador.select(datos.grado)

func _enfocar_campo_por_corregir() -> void:
	if is_instance_valid(_campo_por_corregir):
		_campo_por_corregir.call_deferred("grab_focus")

# Called when the node enters the scene tree for the first time.

func _on_back_button_pressed() -> void:
	SoundManager.play_click()
	Global.borrador_datos_personales.clear()
	Global.registro_datos_personales_id = 0
	#Volver a la escena principal
	get_tree().change_scene_to_file("res://menuPrincipal/menu.tscn")


func _on_resset_button_pressed() -> void:
	SoundManager.play_click()
	# Reiniciar los campos
	nombre_completo.text = ""
	edad_jugador.text = ""
	genero_jugador.select(-1)
	grado_jugador.select(-1)
	genero_jugador.text = ""
	grado_jugador.text = ""
	Global.borrador_datos_personales.clear()

func _on_play_botton_mouse_entered():
	SoundManager.play_hover()
	
	
	
func _on_play_select_pressed_click():
	SoundManager.play_select_pressed()
	
func _on_save_button_pressed() -> void:
	SoundManager.play_click()
	var mensaje = _mensaje_error_campos()
	if not mensaje.is_empty():
		mostrar_error(mensaje)
		return

	var registro_id = _guardar_registro()
	if registro_id <= 0:
		mostrar_error("No se pudieron guardar tus datos. Inténtalo nuevamente.")
		return
	
	Global.registrar_nombre_completo(nombre_completo.text)
	Global.reiniciar_partida()
	Global.registro_datos_personales_id = registro_id
	Global.borrador_datos_personales = {
		"nombre": nombre_completo.text,
		"edad": edad_jugador.text,
		"genero": genero_jugador.selected,
		"grado": grado_jugador.selected,
	}
	
	get_tree().change_scene_to_file("res://Escenas/EscenasDialogos/dialogo_inicial.tscn")

func _guardar_registro() -> int:
	db = SQLite.new()
	db.path = db_name
	db.verbosity_level = verbosity_level
	if not db.open_db():
		return 0
	var valores = [nombre_completo.text, int(edad_jugador.text), genero_jugador.text, grado_jugador.text]
	var registro_id = Global.registro_datos_personales_id
	var correcto = db.query(tabla)
	if correcto and registro_id > 0:
		correcto = db.query_with_bindings("SELECT id FROM DatosPersonales WHERE id = ?;", [registro_id]) and not db.query_result.is_empty()
		if correcto:
			valores.append(registro_id)
			correcto = db.query_with_bindings("UPDATE DatosPersonales SET nombre = ?, edad = ?, genero = ?, gradoAcademico = ? WHERE id = ?;", valores)
	elif correcto:
		correcto = db.query_with_bindings("INSERT INTO DatosPersonales (nombre, edad, genero, gradoAcademico) VALUES (?, ?, ?, ?);", valores)
		if correcto:
			correcto = db.query("SELECT last_insert_rowid() AS id;")
			if correcto and not db.query_result.is_empty():
				registro_id = int(db.query_result[0].id)
	db.close_db()
	return registro_id if correcto else 0

func validar_campos() -> bool:
	return _mensaje_error_campos().is_empty()

func _mensaje_error_campos() -> String:
	if nombre_completo.text.strip_edges().is_empty():
		_campo_por_corregir = nombre_completo
		return "Escribe tu nombre completo."
	if not _edad_valida():
		_campo_por_corregir = edad_jugador
		return "Escribe una edad entre 6 y 18 años."
	if genero_jugador.selected == -1:  # -1 indica que no se seleccionó ninguna opción
		_campo_por_corregir = genero_jugador
		return "Selecciona tu género."
	if grado_jugador.selected == -1:
		_campo_por_corregir = grado_jugador
		return "Selecciona tu grado académico."
	_campo_por_corregir = null
	return ""

func _edad_valida() -> bool:
	var texto = edad_jugador.text.strip_edges()
	if not texto.is_valid_int():
		return false
	var edad = texto.to_int()
	return edad >= 6 and edad <= 18

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
