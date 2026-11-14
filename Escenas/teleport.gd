extends Area2D


@export var disponible: bool = false

@export var escena: String = ""
@export var texto: String = ""

@export var label: Label = null

@onready var tip: Label = $Label2
var dentro: bool = false
var _entrando: bool = false

func _ready() -> void:
	if label: 
		label.set_text(texto)
		label.set_visible(false)
		tip.set_visible(false)

func _input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.is_action_pressed("interactuar"):
		return
	if _entrando or not dentro or not disponible or Transicion.en_transicion:
		return
	if not ResourceLoader.exists(escena, "PackedScene"):
		push_warning("El destino del mapa no está disponible.")
		return
	_entrando = true
	SoundManager.play_woosh_sound()
	var canvas = CanvasLayer.new()
	var pantalla = ColorRect.new()
	pantalla.color = Color(1, 1, 1, 0)
	pantalla.set_anchors_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(pantalla)
	add_child(canvas)
	var tween = create_tween()
	tween.tween_property(pantalla, "color", Color(1, 1, 1, 1), 0.8)
	tween.tween_callback(func():
		if get_tree().change_scene_to_file(escena) != OK:
			_entrando = false
			canvas.queue_free()
			push_warning("No se pudo entrar al destino del mapa.")
	)

func _on_body_entered(body: Node2D) -> void:
	SoundManager.play_available()
	dentro = true
	label.set_visible(true)
	if disponible: tip.set_visible(true)


func _on_body_exited(body: Node2D) -> void:
	dentro = false
	label.set_visible(false)
	tip.set_visible(false)
	
