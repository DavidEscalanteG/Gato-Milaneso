extends Node2D

@onready var fondo = $Fondo
@onready var label_monedas = $Panel/Label
@onready var label_timer = $Panel2/LabelTimer
@onready var label_central = $Panel3/LabelCentral
@onready var panel3 = $Panel3
@onready var perder= $Perdiste

var puntos = 0
var total_monedas = 5
var tiempo_restante = 90  # 1 minuto y 30 segundos
var timer_activo = false  # ← Se inicia en falso para no correr el tiempo antes de empezar
var bloqueo_input = false

var monedas_nodo: Node2D

var posiciones_por_fondo = {
	"Fondo1": [Vector2(66, 313), Vector2(377, 231), Vector2(136, 188), Vector2(259, 147), Vector2(538, 363)],
	"Fondo2": [Vector2(314, 388), Vector2(801, 454), Vector2(646, 254), Vector2(792, 134), Vector2(532, 195)],
	"Fondo3": [Vector2(540, 441), Vector2(190, 232), Vector2(116, 461), Vector2(754, 312), Vector2(716, 70)],
	"Fondo4": [Vector2(377, 231), Vector2(540, 440), Vector2(66, 314), Vector2(188, 231), Vector2(792, 133)],
	"Fondo5": [Vector2(537, 363), Vector2(136, 189), Vector2(116, 463), Vector2(754, 312), Vector2(803, 453)]
}

var fondos = [
	preload("res://Assets/Fondo1.jpg"),
	preload("res://Assets/Fondo2.jpg"),
	preload("res://Assets/Fondo3.jpg"),
	preload("res://Assets/Fondo4.jpg"),
	preload("res://Assets/Fondo5.jpg")
]

func _ready():
	SoundManager.fade_in_ambiente_monedas()
	panel3.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel3.z_index = 100  # Para estar encima
	var estilo_vacio = StyleBoxEmpty.new()
	panel3.add_theme_stylebox_override("panel", estilo_vacio)

	# Primero generamos el fondo y las monedas
	seleccionar_fondo_y_monedas()
	actualizar_label()
	actualizar_timer()

	# Luego mostramos el mensaje inicial encima
	await mostrar_mensaje_central("EMPIEZA LA RONDA", 2.0)
	timer_activo = true  # ← Ahora sí empieza el cronómetro

	set_process(true)

func seleccionar_fondo_y_monedas():
	if monedas_nodo:
		monedas_nodo.queue_free()
	monedas_nodo = Node2D.new()
	add_child(monedas_nodo)

	var fondo_seleccionado = fondos[randi() % fondos.size()]
	fondo.texture = fondo_seleccionado

	var fondo_nombre = fondo_seleccionado.resource_path.get_file().get_basename().get_slice(".", 0)
	var posiciones = posiciones_por_fondo.get(fondo_nombre, [])

	puntos = 0
	total_monedas = posiciones.size()
	actualizar_label()

	for posicion in posiciones:
		var moneda = preload("res://Escenas/EscenasMonedas/monedas.tscn").instantiate() as Area2D
		moneda.position = posicion
		moneda.gestor = self
		moneda.moneda_recolectada.connect(_sumar_punto)
		monedas_nodo.add_child(moneda)

func puede_recoger_monedas() -> bool:
	return timer_activo and not bloqueo_input

func _sumar_punto():
	if puede_recoger_monedas():
		puntos += 1
		actualizar_label()

		if puntos >= total_monedas:
			SoundManager.play_win_sound()
			timer_activo = false
			await mostrar_mensaje_central("¡COMPLETADO!", 2.0)
			await terminar_juego()

# Función para cambiar de escena al finalizar el juego
func terminar_juego():
	SoundManager.fade_out_ambiente_monedas()
	await get_tree().create_timer(2).timeout
	Transicion.cambiar_escena("res://Escenas/EscenasDialogos/dialogo9.tscn")

func actualizar_label():
	label_monedas.text = "=       " + str(puntos) + "/" + str(total_monedas)

func actualizar_timer():
	var minutos = int(tiempo_restante) / 60
	var segundos = int(tiempo_restante) % 60
	label_timer.text = "%02d:%02d" % [minutos, segundos]

func _process(delta):
	if timer_activo:
		tiempo_restante -= delta
		if tiempo_restante <= 0:
			tiempo_restante = 0
			timer_activo = false
			perder_juego()
		actualizar_timer()

func perder_juego():
	SoundManager.play_lose_round()
	print("¡Tiempo agotado! Has perdido.")
	timer_activo = false
	await mostrar_mensaje_central("¡TIEMPO AGOTADO!", 2.5)
	perder.mostrar()

func _input(event):
	if not puede_recoger_monedas():
		return
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var clicked_nodes = get_tree().get_nodes_in_group("monedas")
		var click_correcto = false

		for moneda in clicked_nodes:
			if moneda.get_node("CollisionShape2D").shape is CircleShape2D:
				var distancia = moneda.global_position.distance_to(event.position)
				if distancia <= moneda.get_node("CollisionShape2D").shape.radius:
					click_correcto = true
					break
			elif moneda.get_node("CollisionShape2D").shape is RectangleShape2D:
				var rect = moneda.get_node("CollisionShape2D").shape.get_rect()
				rect.position += moneda.global_position - (rect.size / 2)
				if rect.has_point(event.position):
					click_correcto = true
					break

		if not click_correcto:
			SoundManager.play_error()
			tiempo_restante = max(0, tiempo_restante - 10)
			print("¡Fallaste! -10s")
			avisar_reduccion_tiempo()

func avisar_reduccion_tiempo():
	label_timer.add_theme_color_override("font_color", Color.RED)
	await get_tree().create_timer(0.5).timeout
	label_timer.add_theme_color_override("font_color", Color.WHITE)

func mostrar_mensaje_central(texto: String, duracion := 2.0):
	bloqueo_input = true 
	timer_activo = false

	label_central.text = texto
	label_central.visible = true
	label_central.self_modulate = Color(1, 1, 1, 1)

	panel3.mouse_filter = Control.MOUSE_FILTER_STOP

	var tween = get_tree().create_tween()
	tween.tween_property(label_central, "self_modulate:a", 0.0, 1.0).set_delay(duracion)
	tween.tween_callback(Callable(label_central, "hide"))
	tween.tween_callback(func ():
		bloqueo_input = false     # ⬅️ Rehabilitamos clics
		panel3.mouse_filter = Control.MOUSE_FILTER_IGNORE
	)

	label_central.show()
	return await tween.finished
