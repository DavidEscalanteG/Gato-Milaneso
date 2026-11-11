extends Node2D

const TipoNota = preload("res://Scripts/ScriptsJuegoBolitas/hoyo.gd")

var area_entrante: TipoNota = null

@export var color: TipoNota.ColorBolita = TipoNota.ColorBolita.AMARILLO
@export var limit: Marker2D = null
@export var nota: PackedScene = null
@export var panel: Sprite2D = null

@export var gestor: Node = null

func _ready() -> void:
	match color:
		TipoNota.ColorBolita.AMARILLO:
			panel.set_frame(7)
		TipoNota.ColorBolita.ROJO:
			panel.set_frame(8)
		TipoNota.ColorBolita.ROSA:
			panel.set_frame(9)
		TipoNota.ColorBolita.VERDE:
			panel.set_frame(5)
		TipoNota.ColorBolita.AZUL:
			panel.set_frame(6)
	
func intentar_acierto() -> void:
	if is_instance_valid(area_entrante) and not area_entrante.muerto:
		area_entrante.explotar_nota()
		area_entrante = null

func spawn_bolita():
	if !limit: return
	
	var instancia: TipoNota = nota.instantiate()
	instancia.color = color
	instancia.gestor = gestor
	instancia.position = to_local(limit.global_position)
	# Lanes share the same vertical start but keep their own horizontal column.
	instancia.position.x = 0
	add_child(instancia)

func _on_panel_area_entered(area: Area2D) -> void:
	if area is TipoNota and not area.muerto:
		area_entrante = area

func _on_panel_area_exited(area: Area2D) -> void:
	if area == area_entrante:
		area_entrante = null
