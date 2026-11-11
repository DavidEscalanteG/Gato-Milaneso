extends Node2D
class_name Hoyo

@export_range(0, 10) var nivel: int = 0
@export var animation_player: AnimationPlayer = null
@export var hit: AudioStreamPlayer2D = null
@export var area: Area2D = null

@export var animales: Node2D = null

@export var timer_sacar: Timer = null
@export var timer_fuera: Timer = null

@export var mouse_dentro = false
@export var animal_fuera = false

@export var raiz: Node = null

var index

func _ready() -> void:
	comenzar_timer()
	animation_player.set_speed_scale(3 + nivel * 0.5)

func _input(event: InputEvent) -> void:
	if raiz and raiz.juego_terminado:
		return
	if (event is InputEventMouseButton 
		and event.button_index == MOUSE_BUTTON_LEFT
		and event.is_pressed() 
		and mouse_dentro):
		#print_debug("Le diste al animal: ", self.name, self.get_index(true))
		
		if animal_fuera:
			animal_fuera = false
			hit.set_pitch_scale(
				randf_range(1,1.25)
			)
			hit.play()
			
			timer_fuera.stop()
			timer_fuera.emit_signal("timeout")
			
			
			if index == 1:
				Global.puntaje+=100
			else:
				if raiz and raiz.has_method("quitar_vida"):
					raiz.quitar_vida()
		

func _on_area_2d_mouse_entered() -> void:
	mouse_dentro = true

func _on_area_2d_mouse_exited() -> void:
	mouse_dentro = false


func comenzar_timer() -> void:
	timer_sacar.set_wait_time(randf_range(5 - nivel * 0.49, 7 - nivel*0.5))
	timer_sacar.start()


func _on_timer_timeout() -> void:
	var anims = ["mostrar_zari", "mostrar_topo"]
	index = randi_range(0,1)
	
	animales.set_scale(Vector2(1 - randi_range(0, 1) * 2, 1))
	animation_player.play(anims[index])
	
	await animation_player.animation_finished
	animal_fuera = true
	
	timer_fuera.set_wait_time(
		randf_range(0.45 - nivel * 0.01, 1.8 - nivel * 0.058)
	)
	timer_fuera.start()
	
	await timer_fuera.timeout
	animal_fuera = false
	
	animation_player.play_backwards(anims[index])
	
	comenzar_timer()
