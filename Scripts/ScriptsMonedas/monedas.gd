extends Area2D

signal moneda_recolectada

@onready var collision_shape = $CollisionShape2D
var marcada = false
var gestor: Node = null

func _ready():
	add_to_group("monedas")

func _input_event(viewport, event, shape_idx):
	if not is_instance_valid(gestor) or not gestor.puede_recoger_monedas():
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not marcada:
		SoundManager.play_win_coin()
		marcar_colision()
		moneda_recolectada.emit()

func marcar_colision():
	marcada = true
	var shape = collision_shape.shape
	if shape is CircleShape2D:
		var radio = shape.radius
		var marco = Line2D.new()
		marco.width = 3
		marco.default_color = Color(0, 1, 0)
		marco.closed = true
		var segmentos = 32
		for i in range(segmentos + 1):
			var angle = i * TAU / segmentos
			var point = Vector2(cos(angle) * radio, sin(angle) * radio)
			marco.add_point(point)
		add_child(marco)
