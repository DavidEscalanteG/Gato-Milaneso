extends Node2D

# Misma interpretación de player.cfg en el mapa y en los minijuegos.
const Datos = preload("res://Escenas/Player/datos_apariencia.gd")

@export var sprite: Sprite2D
@export var cabello: Sprite2D
@export var animation: AnimationPlayer
var id_personaje: int = 0

func _ready() -> void:
	cabello.material = cabello.material.duplicate()
	sprite.frame_changed.connect(_alinear_cabello)
	configurar(Datos.cargar())

func configurar(config: ConfigFile) -> void:
	id_personaje = Datos.indice(config, "id_personaje", 0, 3)
	var id_cabello = Datos.indice(config, "id_cabello", 1, 4)
	sprite.region_rect = Rect2(0, 192 * id_personaje, 128, 192)
	cabello.visible = id_cabello > 0
	cabello.region_rect = Rect2(0, 192 * maxi(0, id_cabello - 1), 128, 192)
	cabello.material.set_shader_parameter("active", true)
	cabello.material.set_shader_parameter("tint", Datos.color(config))
	_alinear_cabello()

func animar(direccion: Vector2) -> void:
	if direccion.is_zero_approx():
		animation.pause()
		return
	var lateral = is_zero_approx(direccion.y)
	sprite.flip_h = lateral and direccion.x < 0
	cabello.flip_h = sprite.flip_h
	var nombre = "derecha" if lateral else ("abajo" if direccion.y > 0 else "arriba")
	if animation.current_animation != nombre or not animation.is_playing():
		animation.play(nombre)
		animation.advance(0)

func mirar_al_frente() -> void:
	animation.stop()
	sprite.flip_h = false
	cabello.flip_h = false
	sprite.frame = 8
	cabello.frame = 8
	_alinear_cabello()

func _alinear_cabello() -> void:
	# La cabeza de la silla está más alta en los fotogramas laterales.
	cabello.position = sprite.position
	if id_personaje == 3 and sprite.frame >= 16:
		cabello.position.y -= 6.0 * sprite.scale.y
