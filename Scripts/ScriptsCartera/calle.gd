extends Node2D

var perro_escena = preload("res://Escenas/EscenasCartera/perro_2.tscn")
var cartera_escena = preload("res://Escenas/EscenasCartera/cartera.tscn")

@onready var ui_vidas = $UI/UI_Vidas  # Asegúrate de que este nodo exista en la escena
@export var textura_corazon: Texture  # Asigna la imagen del corazón en el editor
@export var tiempo_para_cartera = 50

@onready var spawn_timer = Timer.new()
@onready var instrucciones = $InstruccionesUI

var generando_perros = true 
var juego_terminado = false
var ayuda_activada = false

func _ready():
	SoundManager.fade_in_ambiente_cartera()
	actualizar_vidas(3)
	spawn_timer.wait_time = 8.0
	spawn_timer.timeout.connect(_on_bark_ambience_timer_timeout)
	add_child(spawn_timer)
	
	if has_node("InstruccionesUI"):
		$InstruccionesUI.tree_exited.connect(iniciar_juego)

	else:
		iniciar_juego()
		
func iniciar_juego():
	# Verificación inicial por seguridad
	if not is_inside_tree(): return
	
	# --- ESPERA 1 ---
	await get_tree().create_timer(3.0).timeout
	if not is_inside_tree(): return # <--- AGREGA ESTO

	if juego_terminado or ayuda_activada:
		return
		
	spawn_timer.start()
	
	for i in range(2):
		SoundManager.play_bark_sound()
		var perro = perro_escena.instantiate()
		add_child(perro)

	actualizar_vidas(3)
	
	# --- ESPERA 2 ---
	# Nota: Asegúrate que el tiempo no sea negativo
	var tiempo_espera = max(0.1, tiempo_para_cartera - 3) 
	await get_tree().create_timer(tiempo_espera).timeout
	if not is_inside_tree(): return # <--- AGREGA ESTO

	if juego_terminado or ayuda_activada:
		return 

	desactivar_perros()

	# --- ESPERA 3 ---
	await get_tree().create_timer(3).timeout
	if not is_inside_tree(): return # <--- AGREGA ESTO

	if juego_terminado or ayuda_activada:
		return 

	generar_cartera()

func _on_bark_ambience_timer_timeout():
	# Si el juego terminó, detenemos este timer y no hacemos nada
	if juego_terminado or not generando_perros:
		spawn_timer.stop()
		return
		
	# ¡Solo reproduce el sonido! No genera un perro.
	SoundManager.play_bark_sound()
	

func actualizar_vidas(cantidad):
	# Si aún no se han creado los corazones, agrégales una sola vez
	if ui_vidas.get_child_count() == 0:
		for i in range(3):  # Número máximo de vidas
			var corazon = TextureRect.new()
			corazon.texture = textura_corazon
			corazon.custom_minimum_size = Vector2(40, 40)  # Tamaño fijo para evitar reacomodo
			corazon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			ui_vidas.add_child(corazon)

	# Ocultar corazones de derecha a izquierda
	for i in range(ui_vidas.get_child_count()):
		ui_vidas.get_child(i).visible = i < cantidad


func generar_cartera():
	if not generando_perros or juego_terminado:  # Evita que se genere más de una vez
		return
	
	generando_perros = false  # Detener la generación de perros
	var cartera = cartera_escena.instantiate()
	cartera.position = Vector2(430, -50)  # Ajusta la posición según tu diseño
	add_child(cartera)
	print("¡La cartera ha aparecido!")


func marcar_juego_terminado():
	juego_terminado = true
	spawn_timer.stop()

func continuar_sin_perros() -> void:
	if not juego_terminado or Global.derrotas_perros < 3 or ayuda_activada:
		return
	ayuda_activada = true
	spawn_timer.stop()
	for perro in get_tree().get_nodes_in_group("perros"):
		perro.queue_free()
	$perdiste2.ocultar()
	$FondoCalle.activo = true
	var gato = $Gato
	gato.vidas = 3
	gato.inmune = false
	gato.modulate.a = 1.0
	gato.set_process(true)
	gato.set_physics_process(true)
	actualizar_vidas(3)
	juego_terminado = false
	generar_cartera()


func detener_parallax():
	var fondo = $FondoCalle  # Asegúrate de que este es el nodo ParallaxBackground
	if fondo.has_method("detener_fondo"):
		fondo.detener_fondo()


# Modificar para permitir que los perros terminen su recorrido antes de desaparecer
func desactivar_perros():
	var perros = get_tree().get_nodes_in_group("perros")
	for perro in perros:
		# Deshabilitar la colisión para evitar interacciones
		var collision = perro.get_node_or_null("CollisionShape2D")
		if collision:
			collision.disabled = true  
		
		# Permitir que sigan moviéndose, pero que no reaparezcan
		perro.set_meta("desactivado", true)  
