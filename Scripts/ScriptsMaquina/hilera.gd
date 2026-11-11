extends Node2D
class_name Hilera

signal cicle_ended()

var count : int = 150
var size : int = 32 #pixeles del slot
var slot: PackedScene = preload("res://Escenas/EscenasMaquina/tarjeta.tscn")

var twen : Tween
var tick : float
var tick_variation_inicial : float = 0.0005
var tick_variation : float = 0.0005
var tick_final_variation : float = 0.08
var moves: int
@onready var real_size : float = size * scale.y
@onready var my_init_pos : Vector2 = position
@export var extra_slots : int = 20
@export var last_if : float = 0.1

# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
#	init_values()
	
	
	
func init_values():
	genera_slots()
	position = my_init_pos
	tick_variation = tick_variation_inicial
	tick = randf_range(0.01,0.03)
	moves = randi_range(70,145)
	SoundManager.play_slot_wheel()
	roll()


func genera_slots():
	for child in get_children():
		if child is Tarjeta:
			child.queue_free()
	for i in range(1, count):
		var new_slot = slot.instantiate()
		new_slot.position.y = i * 32
		add_child(new_slot)
		
		
func roll():
	twen = create_tween()
	twen.tween_property(self, "position", Vector2(position.x, (position.y - real_size)) , tick)
	if tick < 0.01 + last_if: #valor inicial 0.15
		tick += tick_variation
		tick_variation += 0.0004
		twen.tween_callback(roll)
	elif tick < 0.2:	#valor inicial 0.4
		tick += tick_final_variation
		twen.tween_callback(roll)
	else:
		twen.tween_callback(roll_end)
		
func roll_end():
	SoundManager.play_slot_lock()
	emit_signal("cicle_ended")


func get_fruta_visible() -> Tarjeta:
	var mejor_distancia = INF
	var tarjeta_visible = null 
	
	var posicion_central_y = get_viewport().get_visible_rect().size.y / 2  # Esto pone la línea central en el centro de la pantalla
	
	for child in get_children():
		if child is Tarjeta:
			var distancia = abs((child.global_position.y + real_size / 2) - posicion_central_y)
			if distancia < mejor_distancia:
				mejor_distancia = distancia
				tarjeta_visible = child
	# Depuración: Ver en consola cuál fruta se detectó y su posición
	if tarjeta_visible:
		print("Fruta visible seleccionada:", tarjeta_visible.get_fruta_id(), 
	  "Posición Y:", tarjeta_visible.global_position.y, 
	  "Referencia Y:", posicion_central_y)


	return tarjeta_visible




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
