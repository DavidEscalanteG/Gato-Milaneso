extends Node2D

# Referencias a los nodos relevantes
@export var cabello : Sprite2D = null
@export var cabellos : ItemList = null
@export var color_picker : ColorPickerButton = null

@export var personaje : Sprite2D = null
@export var personajes : ItemList = null

# Método para inicializar las señales de los paneles de cabello
func _ready() -> void:
	personajes.select(0)
	cabellos.select(0)
	
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
	var config = ConfigFile.new()
	
	# Llenar el archivo
	config.set_value("player", "id_personaje", personajes.get_selected_items())
	config.set_value("player", "id_cabello", cabellos.get_selected_items())
	config.set_value("player", "color_cabello", cabello.material.get_shader_parameter("tint"))
	
	config.save("user://player.cfg")
	
	get_tree().change_scene_to_file("res://NickUsuario/usuario.tscn")

## Limpiar personaje
func _on_resset_button_pressed() -> void:
	SoundManager.play_click()
	personajes.select(0)
	personaje.set_texture(personajes.get_item_icon(0))
	cabellos.select(0)
	cabello.set_texture(null)
	color_picker.set_pick_color(
		Color(0,0,0)
	)
	
	#var config = ConfigFile.new() 
	#
	#var err = config.load("res://player.cfg")
	#
	#if err != OK:
		#printerr(err)
		#return
	#
	#var id_cabello: PackedInt32Array = config.get_value("player", "id_cabello", 0)
	#var color_cabello: Vector4 = config.get_value("player", "color_cabello", Vector4(0., 0., 0., 1))
	#
	## Cargando estilo del pelo
	#cabellos.select(id_cabello[0])
	#cabello.set_texture(cabellos.get_item_icon(id_cabello[0]))
	#
	## Cargando color del pelod
	#color.set_pick_color(Color(dg
		#color_cabello[0], color_cgabello[1], color_cabello[2]
	#))
	#cabello.material.set_shader_parameter("tint", color_cabello);


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
