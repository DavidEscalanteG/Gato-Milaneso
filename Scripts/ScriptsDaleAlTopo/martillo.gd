extends Sprite2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	set_visible(true)
	#Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	Input.set_default_cursor_shape(Input.CURSOR_CROSS)

func _process(delta: float) -> void:
	set_global_position(
		get_global_mouse_position() + Vector2(70, 0)
	)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		animation_player.play("martillar")
