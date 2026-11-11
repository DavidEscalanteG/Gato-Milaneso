extends Area2D
class_name Tarjeta

@onready var comida: int = randi_range(0,100)
@onready var animation: AnimatedSprite2D = $AnimatedSprite2D


func get_fruta_id() -> String:
	return animation.animation

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if comida < 40:
		animation.play("6")
	elif comida < 60:
		animation.play("5")
	elif comida < 75:
		animation.play("4")
	elif comida < 85:
		animation.play("3")
	elif comida < 93:
		animation.play("2")
	elif comida < 98:
		animation.play("1")
	else:
		animation.play("0")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
