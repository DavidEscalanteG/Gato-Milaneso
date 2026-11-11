extends CharacterBody2D

var direccion: Vector2 = Vector2.ZERO
@export var velocidad: float = 200.0

# componentes
@export var sprite: Sprite2D = null
@export var cabello: Sprite2D = null
@export var animation: AnimationPlayer = null

func _ready():
	cabello.set_visible(true)
	cabello.material.set_shader_parameter("active", true)
	cabello.set_region_enabled(true)
	
	## Cargar configuracion personaje personalizado
	var config = ConfigFile.new() 
	
	var err = config.load("user://player.cfg")
	
	if err != OK:
		printerr(err)
		return
	
	var id_personaje: PackedInt32Array = config.get_value("player", "id_personaje", [0])
	var id_cabello: PackedInt32Array = config.get_value("player", "id_cabello", [0])
	var color_cabello: Vector4 = config.get_value("player", "color_cabello", Vector4(0., 0., 0., 1))
	var username: String = config.get_value("player", "username", "username")
	
	$Username.set_text(username)
	Global.username = username
	cabello.material.set_shader_parameter("tint", color_cabello)
	
	sprite.set_region_rect(Rect2(
		0, 192 * id_personaje[0], # Ajuste para la posicion de la región
		128.0, 192.0 # Region de sprites para un personaje
	))
	
	if id_cabello[0] > 0:
		cabello.set_region_rect(Rect2(
			0, 192 * (id_cabello[0] - 1), # Ajuste para la posición de la región
			128.0, 192.0 # Region de sprites para un cabello
		))

func _physics_process(_delta: float) -> void:
	animacion()
	movimiento()
	
	move_and_slide()

func _input(event: InputEvent) -> void:
	if event.is_action("derecha"):
		sprite.set_flip_h(false)
		cabello.set_flip_h(false)
	
	if event.is_action("izquierda"):
		sprite.set_flip_h(true)
		cabello.set_flip_h(true)

func movimiento() -> void:
	direccion.x = Input.get_action_strength("derecha") - Input.get_action_strength("izquierda")
	direccion.y = Input.get_action_strength("abajo") - Input.get_action_strength("arriba")
	
	set_velocity(direccion * velocidad)

## Metodo para coordinar las animacion
func animacion() -> void:
	if direccion.x != 0 and direccion.y == 0:
		if animation.current_animation != "derecha":
			animation.play("derecha")
	elif direccion.y != 0:
		if direccion.y > 0:
			if animation.current_animation != "abajo":
				animation.play("abajo")
		elif direccion.y < 0:
			if animation.current_animation != "arriba":
				animation.play("arriba")
	else:
		animation.stop()
