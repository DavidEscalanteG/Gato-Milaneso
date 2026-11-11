extends Area2D
class_name Bolita

enum ColorBolita {AMARILLO, ROJO, ROSA, VERDE, AZUL}
@export var color: ColorBolita = ColorBolita.AMARILLO

@export var speed: float = 200.0
@export var sprite: Sprite2D = null
@export var explosion: CPUParticles2D = null
@export var sfx: AudioStreamPlayer2D = null

@export var gestor: Node = null

var muerto = false

func _ready() -> void:
	add_to_group("bolas")
	match color:
		ColorBolita.AMARILLO:
			sprite.set_frame(2)
		ColorBolita.ROJO:
			sprite.set_frame(3)
		ColorBolita.ROSA:
			sprite.set_frame(4)
		ColorBolita.VERDE:
			sprite.set_frame(0)
		ColorBolita.AZUL:
			sprite.set_frame(1)


func _process(delta: float) -> void:
	if !muerto: position.y += speed * delta

func explotar_nota():
	if muerto:
		return
	muerto = true
	$CollisionShape2D.set_deferred("disabled", true)
	Global.puntaje += 100
	
	# Efecto de explosion
	sprite.set_visible(false)
	explosion.set_emitting(true)
	if sfx: sfx.play()
	await explosion.finished
	
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if muerto:
		return
	muerto = true
	
	if gestor and gestor.has_method("quitar_vida"):
		gestor.quitar_vida()
	else:
		Global.salud = maxi(0, Global.salud - 1)
	
	self.queue_free()
