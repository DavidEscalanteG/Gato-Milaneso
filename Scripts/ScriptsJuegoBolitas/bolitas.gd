extends Node2D

@onready var vida_tex: Texture = preload("res://Assets/corazon.png")
@onready var perder = $Perdiste

@export var etiqueta: Label = null
@export var timer: Timer = null
@export var vidas_cont: Control = null
@export var timer_bolitas: Timer = null 
@export_range(0.7, 2.0, 0.05) var intervalo_minimo_notas: float = 0.7
@export_range(0.7, 2.0, 0.05) var intervalo_maximo_notas: float = 1.2

var _generador_intervalos = RandomNumberGenerator.new()

@onready var carriles: Array[Node2D] = [$Carril, $Carril2, $Carril3, $Carril4, $Carril5]
var siguiente_carril: int = 0

# Banderas
var juego_terminado: bool = false
var bolas_detenidas: bool = false 

func _ready() -> void:
	Global.salud = 3
	Global.puntaje = 0
	_llenar_contenedor()
	carriles.shuffle()
	_generador_intervalos.randomize()
	_programar_siguiente_nota()

func _programar_siguiente_nota() -> void:
	if juego_terminado or bolas_detenidas:
		return
	# Keep a safe gap even if the Inspector's minimum and maximum are reversed.
	var minimo = maxf(0.7, minf(intervalo_minimo_notas, intervalo_maximo_notas))
	var maximo = maxf(minimo, maxf(intervalo_minimo_notas, intervalo_maximo_notas))
	timer_bolitas.start(_generador_intervalos.randf_range(minimo, maximo))

func _on_timer_notas_timeout() -> void:
	if juego_terminado or bolas_detenidas:
		return
	if timer.time_left <= 5.0:
		detener_generacion_bolas()
		return
	# One shared timer prevents different lanes from spawning overlapping notes.
	carriles[siguiente_carril].spawn_bolita()
	siguiente_carril += 1
	if siguiente_carril == carriles.size():
		siguiente_carril = 0
		carriles.shuffle()
	_programar_siguiente_nota()

func _unhandled_input(event: InputEvent) -> void:
	if juego_terminado:
		return
	var pulsacion = event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_SPACE
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var posicion = get_global_transform_with_canvas().affine_inverse() * event.position
		pulsacion = Rect2(-216, -40, 432, 60).has_point(posicion)
	if pulsacion:
		for carril in carriles:
			carril.intentar_acierto()
		get_viewport().set_input_as_handled()

func _process(_delta: float) -> void:
	if juego_terminado:
		return

	if etiqueta and timer:
		etiqueta.set_text(str(round(timer.time_left)) + "s")
	
	if not bolas_detenidas and timer.time_left <= 5.0:
		detener_generacion_bolas()

	if Global.salud <= 0:
		fin_del_juego_derrota()


func detener_generacion_bolas() -> void:
	bolas_detenidas = true
	timer_bolitas.stop()

func _llenar_contenedor():
	for i in range(Global.salud):
		var vida: TextureRect = TextureRect.new()
		vida.set_texture(vida_tex)
		vidas_cont.add_child(vida)

func quitar_vida():
	if juego_terminado: return 
		
	Global.salud = maxi(0, Global.salud - 1)
	
	if Global.salud >= 0: 
		if vidas_cont.get_child_count() > Global.salud:
			vidas_cont.get_child(Global.salud).set_visible(false)
	
	print_debug("Salud restante:", Global.salud)
	if Global.salud == 0:
		fin_del_juego_derrota()

func _on_timer_timeout() -> void:
	if juego_terminado: return 
	if Global.salud <= 0:
		fin_del_juego_derrota()
		return
	
	print_debug("SE ACABÓ EL TIEMPO - ¡GANASTE!")
	juego_terminado = true 

	if timer_bolitas: timer_bolitas.stop()

	get_tree().call_group("bolas", "queue_free") 
	
	Global.ronda = 2
	Transicion.cambiar_escena("res://Escenas/EscenasDialogos/dialogo5.tscn")

func fin_del_juego_derrota() -> void:
	if juego_terminado: return
	juego_terminado = true
	
	if timer: timer.stop() 
	if timer_bolitas: timer_bolitas.stop() 
	get_tree().call_group("bolas", "queue_free")
	
	perder.mostrar()
