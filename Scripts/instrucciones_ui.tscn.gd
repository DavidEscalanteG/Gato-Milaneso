extends CanvasLayer


@export_multiline var texto_titulo: String = "Titulo..."
@export_multiline var texto_explicacion: String = "Instrucciones..."

@export var lista_teclas: Array[Texture2D]
@export var texto_controles: String = "Espacio, Click izquierdo..." 


@onready var label_titulo = $LabelTitulo
@onready var label_texto = $LabelInstrucciones
@onready var contenedor_teclas = $HBoxContainer 
@onready var label_controles = $LabelControles

func _ready():
	label_texto.text = texto_explicacion
	label_titulo.text = texto_titulo
	label_controles.text = texto_controles
	
	for hijo in contenedor_teclas.get_children():
		hijo.queue_free()

	for textura in lista_teclas:
		var tecla_imagen = TextureRect.new()
		tecla_imagen.texture = textura

		tecla_imagen.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tecla_imagen.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

		var altura_deseada = 50.0
		
		if textura:
			var aspecto = textura.get_width() / float(textura.get_height())
			var ancho_calculado = altura_deseada * aspecto
		
			tecla_imagen.custom_minimum_size = Vector2(ancho_calculado, altura_deseada)
		else:
			tecla_imagen.custom_minimum_size = Vector2(50, 50)
			 
		contenedor_teclas.add_child(tecla_imagen)

	get_tree().paused = true

func _on_boton_jugar_pressed():
	SoundManager.play_click()
	get_tree().paused = false
	queue_free()


func _on_play_botton_mouse_entered():
	SoundManager.play_hover()
