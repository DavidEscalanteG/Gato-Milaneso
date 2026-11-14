extends Node2D

const Datos = preload("res://Escenas/Player/datos_apariencia.gd")

# Referencias a los nodos relevantes
@export var cabello : Sprite2D = null
@export var cabellos : ItemList = null
@export var color_picker : ColorPickerButton = null

@export var personaje : Sprite2D = null
@export var personajes : ItemList = null

# Método para inicializar las señales de los paneles de cabello
func _ready() -> void:
	cabello.material = cabello.material.duplicate()
	_restablecer_apariencia()
	if Global.borrador_personaje != null:
		_aplicar_configuracion(Global.borrador_personaje)
	var picker= color_picker.get_picker()
	picker.picker_shape= ColorPicker.SHAPE_HSV_RECTANGLE #NO CAMBIAR LA FORMA IMPORTANTE
	picker.color_modes_visible= false
	picker.edit_alpha = false
	picker.hex_visible= false
	picker.presets_visible= false
	picker.sliders_visible= false
	picker.sampler_visible= false
	picker.can_add_swatches = false
	picker.get_theme_constant("sv_height")


## Método para cambiar el color del pelo
func _on_color_picker_button_color_changed(color: Color) -> void:
	cabello.material.set_shader_parameter("tint", Vector4(color.r, color.g, color.b, 1));

## Método para cambiar el personaje
func _on_item_list_personajes_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	SoundManager.play_select_pressed()
	var nuevo_personaje = personajes.get_item_icon(index)
	personaje.set_texture(nuevo_personaje)

## Método para cambiar el estilo del pelo
func _on_item_list_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	SoundManager.play_select_pressed()
	var nuevo_cabello = cabellos.get_item_icon(index)
	cabello.set_texture(nuevo_cabello)

## Guardar información
func _on_save_button_pressed() -> void:
	SoundManager.play_click()
	var config = crear_configuracion()
	if config.save("user://player.cfg") != OK:
		push_error("No se pudo guardar el personaje.")
		return
	get_tree().change_scene_to_file("res://NickUsuario/usuario.tscn")

func crear_configuracion() -> ConfigFile:
	var config = ConfigFile.new()
	
	# Llenar el archivo
	config.set_value("player", "id_personaje", personajes.get_selected_items())
	config.set_value("player", "id_cabello", cabellos.get_selected_items())
	config.set_value("player", "color_cabello", cabello.material.get_shader_parameter("tint"))
	
	return config

## Limpiar personaje
func _on_resset_button_pressed() -> void:
	SoundManager.play_click()
	_restablecer_apariencia()

func _restablecer_apariencia() -> void:
	personajes.select(0)
	personaje.texture = personajes.get_item_icon(0)
	cabellos.select(1)
	cabello.texture = cabellos.get_item_icon(1)
	cabello.position = personaje.position
	color_picker.color = Color.BLACK
	_on_color_picker_button_color_changed(Color.BLACK)

func _aplicar_configuracion(config: ConfigFile) -> void:
	var cuerpo = Datos.indice(config, "id_personaje", 0, 3)
	var pelo = Datos.indice(config, "id_cabello", 1, 4)
	personajes.select(cuerpo)
	personaje.texture = personajes.get_item_icon(cuerpo)
	cabellos.select(pelo)
	cabello.texture = cabellos.get_item_icon(pelo)
	var tinte = Datos.color(config)
	color_picker.color = Color(tinte.x, tinte.y, tinte.z, 1)
	_on_color_picker_button_color_changed(color_picker.color)

## Aquí debería borrarse el usuario recién creado... y que los datos en el formulario se mantengan.
func _on_back_button_pressed() -> void:
	SoundManager.play_click()
	get_tree().change_scene_to_file("res://datosUsuario/datosPersonales.tscn")
	return

## Sonidos de SoundManager (Botones, pestañas, etc.)
func _on_play_botton_mouse_entered():
	SoundManager.play_hover()
	
	
	
func _on_play_select_pressed_click():
	SoundManager.play_select_pressed()


	

func _on_tab_container_tab_button_pressed(tab: int) -> void:
	SoundManager.play_click()
	pass # Replace with function body.
