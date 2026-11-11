extends CanvasLayer
class_name DialogManager

@export var a_escena: String = ""
@export var num_dialogo: int = 0
@export var label: Label = null

var _dialogos_actuales = []
var _count = 0

func _ready() -> void:
	self.set_visible(false)

func comenzar_dialogos(index: int):
	_dialogos_actuales = Global.obtenerDialogo(num_dialogo)
	
	if (_count>=_dialogos_actuales.size()): return
	self.set_visible(true)
	get_tree().paused = true
	mostrar_dialogo()

func mostrar_dialogo():
	label.set_text(_dialogos_actuales[_count][0] + ": " + _dialogos_actuales[_count][1])


func _on_button_pressed() -> void:
	_count += 1
	
	if (_count >= _dialogos_actuales.size()):
		print_debug("Cambiar escena")
		if (!a_escena.is_empty()): get_tree().change_scene_to_file(a_escena)
		get_tree().paused = false
		self.set_visible(false)
	else:
		mostrar_dialogo()
