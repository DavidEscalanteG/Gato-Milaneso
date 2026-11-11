extends CharacterBody2D

var vidas = 3  # Número de vidas del gato
var inmune = false  # Variable para controlar inmunidad temporal
@onready var animacion_player : AnimatedSprite2D = $GatoAnimado
@onready var sprite = $GatoAnimado

var juego_ganado = false

func _ready():
	#$AnimationPlayer.play("movement_cat")
	animacion_player.play("walk")
	add_to_group("gato")  # Asegura que el gato está en el grupo correcto

func _physics_process(delta):
	# Obtener la dirección del movimiento según las teclas
	var direction = Input.get_vector("izquierda", "derecha", "arriba", "abajo")
	if direction.x != 0:
		velocity = Vector2(direction.x * 400, 0)
		
		# Reproducir animación de caminar
		animacion_player.play("walk")

		# Orientación (la corrección que hicimos antes)
		if direction.x > 0:
			sprite.flip_h = true
		else:
			sprite.flip_h = false

	# --- SI ESTÁ QUIETO ---
	else:
		velocity = Vector2.ZERO # Detener el movimiento inmediatamente
		
		# AQUÍ cambias a la animación de mirar al frente
		# Asegúrate de que este nombre exista en tus SpriteFrames
		animacion_player.play("idle_front")

	# Calcular la velocidad del gato
	velocity = Vector2(direction.x * 400, 0)

	# Mover al gato
	move_and_slide()

	# Cambiar la animación según la dirección del movimiento
	#if direction.length() > 0:
	#	$AnimationPlayer.play("movement_cat")
	#else:
	#	$AnimationPlayer.stop()
		
		
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
	
	animacion_player.play("stand")

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

func _unhandled_input(event):
	if not juego_ganado:
		return
	
	if event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		Global.ronda = 1
		Transicion.cambiar_escena("res://Escenas/EscenasDialogos/dialogo3.tscn")
	
	
