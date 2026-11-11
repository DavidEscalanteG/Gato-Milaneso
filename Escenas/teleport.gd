extends Area2D


@export var disponible: bool = false

@export var escena: String = ""
@export var texto: String = ""

@export var label: Label = null

@onready var tip: Label = $Label2
var dentro: bool = false

func _ready() -> void:
	if label: 
		label.set_text(texto)
		label.set_visible(false)
		tip.set_visible(false)

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if Input.is_action_just_pressed("interactuar") and dentro:
			if not disponible: return
			SoundManager.play_woosh_sound()
			var canvas: CanvasLayer = CanvasLayer.new()
			var pantalla: ColorRect = ColorRect.new()
			pantalla.color = Color(1,1,1,0)
			pantalla.set_anchors_preset(Control.PRESET_FULL_RECT)

			canvas.add_child(pantalla)
			add_child(canvas)

			var tween = get_tree().create_tween()
			tween.tween_property(pantalla, "color", Color(1,1,1,1), 0.8)
			tween.tween_callback(func(): 
				# TODO: Transportar al jugador
				get_tree().change_scene_to_file(escena)
				)
			tween.play()

func _on_body_entered(body: Node2D) -> void:
	SoundManager.play_available()
	dentro = true
	label.set_visible(true)
	if disponible: tip.set_visible(true)


func _on_body_exited(body: Node2D) -> void:
	dentro = false
	label.set_visible(false)
	tip.set_visible(false)
	
