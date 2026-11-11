extends Node2D

@onready var vida_tex: Texture = preload("res://Assets/corazon.png")
@onready var perder = $Perdiste
@onready var pantalla = $CanvasLayer/ColorRect
@onready var martillo = $Martillo

@export var label: Label = null
@export var label_ronda: Label = null
@export var hoyos: Node2D = null
@export var musica: AudioStreamPlayer = null
@export var vidas_cont: Control = null
@export var cantidad_rondas = 2

var ronda_local: int
var objetivo: int
var juego_terminado = false

func _ready() -> void:
	pantalla.modulate = Color(1, 1, 1, 0)
	pantalla.visible = false
	
	Global.puntaje = 0

	# Each attempt starts with its own lives, regardless of previous minigames.
	Global.salud = 3

	if "ronda_local" in Global:
		ronda_local = Global.ronda_local
	else:
		ronda_local = 0
		Global.ronda_local = 0

	if ronda_local > 0:
		if has_node("InstruccionesUI"):
			var instrucciones = $InstruccionesUI
			instrucciones.visible = false 
			instrucciones.process_mode = Node.PROCESS_MODE_DISABLED 
			instrucciones.queue_free()
			
		get_tree().paused = false 

	objetivo = 1000 + 100 * ronda_local

	print_debug("Ronda local:", ronda_local)
	
	colocar_nivel()

	_llenar_contenedor()
	
	label_ronda.text = "Ronda " + str(ronda_local + 1) + "/" + str(cantidad_rondas)


func _process(delta: float) -> void:
	if juego_terminado:
		return
	label.text = str(Global.puntaje) + "/" + str(objetivo)
	if Global.puntaje >= objetivo and not juego_terminado:
		
		if ronda_local == cantidad_rondas - 1:
			juego_terminado = true 
			
			martillo.process_mode = Node.PROCESS_MODE_DISABLED
			martillo.visible = false
			pantalla.visible = true

			var tween = get_tree().create_tween()
			tween.tween_property(pantalla, "modulate", Color(1, 1, 1, 1), 3)

			tween.tween_callback(func ():
				Global.ronda = 6
				Global.ronda_local = 0 
				Transicion.cambiar_escena("res://Escenas/EscenasDialogos/dialogo11.tscn"))
			tween.play()
			
		else:
			juego_terminado = true
			Global.ronda_local = ronda_local + 1
			get_tree().reload_current_scene()


func _llenar_contenedor():
	for i in range(Global.salud):
		var vida := TextureRect.new()
		vida.texture = vida_tex
		vidas_cont.add_child(vida)


func quitar_vida() -> void:
	if juego_terminado:
		return
	Global.salud = maxi(0, Global.salud - 1)
	musica.pitch_scale += 0.1
	actualizar_contenedor()

func actualizar_contenedor():
	for indice in vidas_cont.get_child_count():
		vidas_cont.get_child(indice).visible = indice < Global.salud
	if Global.salud <= 0 and not juego_terminado:
		juego_terminado = true
		perder.mostrar()


func colocar_nivel() -> void:
	for hoyo in hoyos.get_children():
		hoyo.nivel = ronda_local


func _on_confirmation_dialog_confirmed() -> void:
	pass
