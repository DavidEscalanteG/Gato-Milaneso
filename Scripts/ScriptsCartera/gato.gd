extends CharacterBody2D

var vidas = 3  # Número de vidas del gato
var inmune = false  # Variable para controlar inmunidad temporal
@onready var apariencia = $Apariencia

var juego_ganado = false

func _ready():
	add_to_group("gato")

func _physics_process(_delta):
	var horizontal = Input.get_axis("izquierda", "derecha")
	velocity = Vector2(horizontal * 400, 0)
	apariencia.animar(Vector2(horizontal, 0))
	move_and_slide()

func perder_vida():
	if inmune or vidas <= 0 or juego_ganado:
		return
	
	
	vidas -= 1
	print("Vidas restantes:", vidas)

	# Buscar la escena principal y actualizar la UI de vidas
	var calle = get_tree().current_scene
	if calle.has_method("actualizar_vidas"):
		calle.actualizar_vidas(vidas)

	if vidas <= 0:
		game_over()
	else:
		SoundManager.play_lose_life()
		
		var camera = get_tree().current_scene.get_node_or_null("Camera2D") 
		if camera and camera.has_method("start_shake"):
			camera.start_shake(15.0, 0.3)
		
		var flash = get_tree().current_scene.get_node_or_null("EfectosUI/FlashRojo")
		if flash:
			var tween = create_tween()
			tween.tween_property(flash, "modulate:a", 0.5, 0.1)
			tween.tween_property(flash, "modulate:a", 0.0, 0.3)
		activar_inmunidad()

func activar_inmunidad():
	inmune = true  # Activar inmunidad
	#print("Gato inmune")

	# Hacer parpadear al gato para indicar inmunidad
	var tween = create_tween()
	for i in range(5):  # Parpadea 5 veces en 2 segundos
		tween.tween_property(self, "modulate:a", 0.3, 0.2)
		tween.tween_property(self, "modulate:a", 1.0, 0.2)

	await get_tree().create_timer(2.0).timeout  # Esperar 2 segundos
	inmune = false  # Desactivar inmunidad
	#print("Gato ya no es inmune")

func game_over():
	apariencia.animar(Vector2.ZERO)
	Global.derrotas_perros += 1
	SoundManager.play_lose_sound()
	var calle = get_tree().current_scene
	if calle.has_method("detener_parallax"):
		calle.detener_parallax()

	if calle.has_method("marcar_juego_terminado"):
		calle.marcar_juego_terminado()

	# Mostrar la UI de Game Over
	var game_over_ui = get_tree().current_scene.get_node("perdiste2")  
	if game_over_ui:
		game_over_ui.mostrar()

	# Detener al gato
	set_process(false)
	set_physics_process(false)
	velocity = Vector2.ZERO

	# Detener a los perros
	var perros = get_tree().get_nodes_in_group("perros")
	for perro in perros:
		perro.set_process(false)
		perro.set_physics_process(false)


func win():
	if juego_ganado:
		return
	juego_ganado = true
	Global.derrotas_perros = 0
	SoundManager.fade_out_ambiente_cartera()
	
	apariencia.mirar_al_frente()

	# Detener gato
	set_process(false)
	set_physics_process(false)
	velocity = Vector2.ZERO  

	# Detener perros
	var perros = get_tree().get_nodes_in_group("perros")
	for perro in perros:
		perro.set_process(false)
		perro.set_physics_process(false)

	# Detener parallax
	var calle = get_tree().current_scene
	if calle.has_method("detener_parallax"):
		calle.detener_parallax()

	# Desactivar carteras
	var carteras = get_tree().get_nodes_in_group("cartera")
	for cartera in carteras:
		cartera.set_process(false)
		cartera.set_physics_process(false)

	var ganaste_ui = get_tree().current_scene.get_node("ganaste")  
	if ganaste_ui:
		ganaste_ui.mostrar()

