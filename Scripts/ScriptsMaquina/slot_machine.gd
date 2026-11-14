extends Node2D

@onready var animacion_palanca : AnimatedSprite2D = $PalancaAnimada
@onready var palanca: Area2D = $Palanca
@onready var hilera_mask : ColorRect = $Mask
@onready var monedas_label : Label = $Panel/MonedasLabel
@onready var resultado_label : Label = $ResultadoLabel
@onready var label_ganador : Label = $PanelGanador/LabelGanador
@onready var boton_reiniciar : Button = $BotonReiniciar


var count_cicles : int = 0
var monedas : int = 6
var juego_terminado : bool = false


@export var costo_jugada : int 
@export var meta_monedas : int 



var premios = {
	"0": {"2": 75, "3": 200},
	"1": {"2": 40, "3": 100},
	"2": {"2": 30, "3": 60},
	"3": {"2": 20, "3": 40},
	"4": {"2": 15, "3": 30},
	"5": {"2": 10, "3": 20},
	"6": {"2": 5, "3": 10}
}


func _ready() -> void:
	SoundManager.fade_in_ambiente_slot_machine()
	for child in hilera_mask.get_children():
		if child is Hilera:
			child.cicle_ended.connect(on_cicle_ended)
	actualizar_monedas_ui()
	if resultado_label:
		resultado_label.visible = false
	label_ganador.visible = false
	label_ganador.modulate.a = 0.0  # Opacidad 0

func _process(delta: float) -> void:
	pass

func _on_palanca_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if juego_terminado:
		return

	if event.is_action_pressed("click") and not palanca.get_child(0).disabled:
		SoundManager.play_pull_lever()
		SoundManager.play_use_coin()
		if monedas >= costo_jugada:
			monedas -= costo_jugada
			actualizar_monedas_ui()

			animacion_palanca.play("activo")
			palanca.get_child(0).disabled = true
			count_cicles = 0

			if resultado_label:
				resultado_label.visible = false

			start_cicle()
		else:
			if resultado_label:
				SoundManager.play_error()
				resultado_label.text = "Sin monedas.\nPulsa REINICIAR para\nintentarlo de nuevo."
				resultado_label.visible = true
				if is_inside_tree() and get_tree():
					await get_tree().create_timer(2.0).timeout
				resultado_label.visible = false



func start_cicle():
	for cosa in get_tree().get_nodes_in_group("hilera"):
		cosa.init_values()

func on_cicle_ended():
	count_cicles += 1
	if count_cicles >= 3:
		SoundManager.stop_slot_wheel()
		verificar_combinaciones()
		palanca.get_child(0).disabled = false

func verificar_combinaciones():
	var frutas_visibles = []
	var hileras = []

	for child in hilera_mask.get_children():
		if child is Hilera:
			hileras.append(child)

	if hileras.size() < 3:
		return

	for hilera in hileras:
		var tarjeta = hilera.get_fruta_visible()
		if tarjeta:
			frutas_visibles.append(tarjeta.get_fruta_id())

	if frutas_visibles.size() == 3:
		calcular_premio(frutas_visibles)

func calcular_premio(frutas: Array):
	var conteo = {}
	for fruta in frutas:
		conteo[fruta] = conteo.get(fruta, 0) + 1

	var premio_total = 0

	for fruta in conteo.keys():
		var cantidad = conteo[fruta]
		if cantidad >= 2 and premios.has(fruta) and premios[fruta].has(str(cantidad)):
			premio_total += premios[fruta][str(cantidad)]

	if premio_total > 0:
		SoundManager.play_win_coin()
		monedas += premio_total
		actualizar_monedas_ui()
		verificar_ganador()
		mostrar_resultado("WIN: " + str(premio_total))
	else:
		resultado_label.visible = false

func mostrar_resultado(texto: String):
	resultado_label.text = texto
	resultado_label.visible = true

	var parpadeos = 6
	for i in range(parpadeos):
		resultado_label.visible = not resultado_label.visible
		if is_inside_tree() and get_tree():
			await get_tree().create_timer(0.5).timeout


	resultado_label.visible = false

func actualizar_monedas_ui():
	if monedas_label:
		monedas_label.text = "PESOS: " + str(monedas)

func mostrar_mensaje_ganador() -> void:
	SoundManager.play_win_sound()
	$GanadoLabel.show()
	label_ganador.text = "¡GANASTE! 🏆"
	label_ganador.visible = true

	var tiempo_total = 2.0  # segundos
	var pasos = 20
	var espera = tiempo_total / pasos

	# FADE IN
	for i in range(pasos):
		label_ganador.modulate.a = float(i) / pasos
		if is_inside_tree() and get_tree():
			await get_tree().create_timer(espera).timeout


	await get_tree().create_timer(1.0).timeout  # Mantener visible

	# FADE OUT
	for i in range(pasos, -1, -1):
		label_ganador.modulate.a = float(i) / pasos
		await get_tree().create_timer(espera).timeout

	label_ganador.visible = false


func verificar_ganador() -> void:
	if monedas >= meta_monedas and not juego_terminado:
		juego_terminado = true
		Global.ronda = 3

		# Mostrar mensaje de GANADOR y esperar que termine
		await mostrar_mensaje_ganador()
		SoundManager.fade_out_ambiente_slot_machine()

		# Esperar 2 segundos adicionales antes de cambiar de escena
		await get_tree().create_timer(2.0).timeout

		# Cambiar escena
		Transicion.cambiar_escena("res://Escenas/EscenasDialogos/dialogo8.tscn")



func reiniciar_juego() -> void:
	monedas = 6
	actualizar_monedas_ui()
	$GanadoLabel.hide()


	resultado_label.visible = false
	label_ganador.visible = false
	label_ganador.modulate.a = 0.0


	if palanca.get_child_count() > 0:
		palanca.get_child(0).disabled = false


	count_cicles = 0
	juego_terminado = false
	get_tree().paused = false 



func añadir_monedas(cantidad: int):
	monedas += cantidad
	actualizar_monedas_ui()


func _on_boton_reiniciar_pressed() -> void:
	reiniciar_juego()
