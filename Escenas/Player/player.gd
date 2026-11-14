extends CharacterBody2D

const Datos = preload("res://Escenas/Player/datos_apariencia.gd")
@export var velocidad: float = 200.0
@onready var apariencia = $Apariencia
var direccion: Vector2 = Vector2.ZERO

func _ready() -> void:
	var config = Datos.cargar()
	var username = str(config.get_value("player", "username", "Jugador"))
	$Username.text = username
	Global.username = username

func _physics_process(_delta: float) -> void:
	direccion = Input.get_vector("izquierda", "derecha", "arriba", "abajo")
	velocity = direccion * velocidad
	apariencia.animar(direccion)
	move_and_slide()
