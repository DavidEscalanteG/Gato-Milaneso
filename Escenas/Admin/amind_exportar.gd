extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var btn := $CenterContainer/Button
	btn.pressed.connect(_exportar)

func _exportar() -> void:
	if Global.respuestas_a_pdf():
		$Resultado.dialog_text = "PDF guardado en:\n" + Global.ultimo_pdf_path
	else:
		$Resultado.dialog_text = "No se pudo exportar el PDF. Revisa los errores en la consola."
	$Resultado.popup_centered()
