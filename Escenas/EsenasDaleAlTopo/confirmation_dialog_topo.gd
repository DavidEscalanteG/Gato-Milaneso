extends ConfirmationDialog

func _on_confirmed() -> void:
	get_tree().set_pause(false)
	get_tree().reload_current_scene()


func _on_canceled() -> void:
	get_tree().set_pause(false)
	#TODO: Salir del minijuego
	pass
