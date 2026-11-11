# Script para Camera2D (ej: CameraShake.gd)
extends Camera2D

@onready var shake_timer = Timer.new()
var shake_strength = 0.0

func _ready():
	# Configura el Timer que controlará la duración del shake
	shake_timer.wait_time = 0.2 # Duración por defecto
	shake_timer.one_shot = true
	shake_timer.connect("timeout", _on_shake_timer_timeout)
	add_child(shake_timer)

func _physics_process(delta):
	# Mientras la "fuerza" del shake sea mayor a 0, muévelo
	if shake_strength > 0:
		# Genera una posición aleatoria dentro de un rango
		offset.x = randf_range(-shake_strength, shake_strength)
		offset.y = randf_range(-shake_strength, shake_strength)

# --- ¡ESTA ES LA FUNCIÓN QUE LLAMAREMOS DESDE EL GATO! ---
func start_shake(strength: float, duration: float):
	shake_strength = strength
	shake_timer.wait_time = duration
	shake_timer.start()

# Cuando el Timer se acaba, resetea todo
func _on_shake_timer_timeout():
	shake_strength = 0.0
	offset = Vector2.ZERO # ¡Muy importante! Devuelve la cámara a su posición original
