extends Node

const Cuestionario = preload("res://Singleton/Cuestionario.gd")
var _fallos: Array[String] = []

func _ready() -> void:
	var salida = OS.get_user_data_dir()
	for argumento in OS.get_cmdline_user_args():
		if argumento.begins_with("--salida="):
			salida = argumento.trim_prefix("--salida=")
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(salida)) != OK:
		push_error("No se pudo crear la carpeta de prueba PDF.")
		get_tree().quit(1)
		return
	var anterior = [Global.nombre_jugador, Global.username, Global.respuestas_test.duplicate(),
		Global.total_test, Global.severidad_depresion, Global.ultimo_pdf_path]
	var fuente = FileAccess.get_file_as_string("res://Dialogos/test.dialogue")
	for pregunta in Cuestionario.PREGUNTAS:
		_comprobar(fuente.contains(pregunta), "El texto del reporte no coincide con el diálogo: " + pregunta)
	var recurso = DialogueManager.create_resource_from_text(fuente)
	for valor in 4:
		Global.reiniciar_test()
		Global.set_respuesta(10, valor)
		_comprobar(Global.total_test == 0 and Global.severidad_depresion == "Sin clasificar", "La pregunta 10 sola no debe alterar la clasificación.")
		Global.reiniciar_test()
		Global.set_respuesta(1, 2)
		var linea = await DialogueManager.get_next_dialogue_line(recurso, "pregunta10")
		_comprobar(linea.responses.size() == 4, "La pregunta 10 debe tener cuatro opciones.")
		_comprobar(linea.responses[valor].text == Cuestionario.DIFICULTADES[valor], "Texto de opción 10 incorrecto.")
		await DialogueManager.get_next_dialogue_line(recurso, linea.responses[valor].next_id)
		_comprobar(Global.respuestas_test["p10"] == valor, "La elección real del diálogo no guardó la pregunta 10.")
		_comprobar(Global.total_test == 2, "La pregunta 10 no debe cambiar el total de preguntas 1-9.")
	for numero in range(1, 11):
		Global.set_respuesta(numero, 3)
	_comprobar(Global.total_test == 27, "El puntaje máximo debe seguir siendo 27 al responder las diez preguntas.")
	Global.nombre_jugador = "José Muñoz (PRUEBA) \\ áéíóú ü ¡¿"
	Global.username = "niño_prueba"
	var valores = [1, 2, 3, 0, 1, 2, 3, 1, 2, 2]
	var manifiesto = FileAccess.open(salida.path_join("esperado.json"), FileAccess.WRITE)
	manifiesto.store_string(JSON.stringify({"preguntas": Cuestionario.PREGUNTAS,
		"frecuencias": Cuestionario.FRECUENCIAS, "dificultades": Cuestionario.DIFICULTADES,
		"valores": valores}))
	manifiesto.close()
	for indice in valores.size():
		Global.set_respuesta(indice + 1, valores[indice])
	_comprobar(Global.total_test == 15, "El total esperado de preguntas 1-9 es 15.")
	_comprobar(Global.respuestas_a_pdf("", salida.path_join("exportacion-prueba.pdf")), "No se pudo generar el reporte completo.")
	for valor in 4:
		Global.set_respuesta(10, valor)
		_comprobar(Global.respuestas_a_pdf("", salida.path_join("pregunta10-%d.pdf" % valor)), "Falló la exportación de una opción 10.")
	Global.nombre_jugador = "W".repeat(1600) + " FIN_NOMBRE"
	_comprobar(Global.respuestas_a_pdf("", salida.path_join("exportacion-larga.pdf")), "Falló el reporte con nombre largo.")
	Global.nombre_jugador = "PRUEBA SIN RESPUESTA 10"
	Global.reiniciar_test()
	_comprobar(Global.respuestas_test["p10"] == -1, "Reiniciar debe dejar la pregunta 10 sin responder.")
	_comprobar(Global.respuestas_a_pdf("", salida.path_join("exportacion-incompleta.pdf")), "Falló el reporte sin respuesta 10.")
	Global.nombre_jugador = anterior[0]
	Global.username = anterior[1]
	Global.respuestas_test = anterior[2]
	Global.total_test = anterior[3]
	Global.severidad_depresion = anterior[4]
	Global.ultimo_pdf_path = anterior[5]
	if _fallos.is_empty():
		print("PRUEBA PDF OK: diez preguntas, opciones del diálogo, puntaje y paginación. Archivos en: ", ProjectSettings.globalize_path(salida))
		get_tree().quit(0)
	else:
		for fallo in _fallos:
			push_error(fallo)
		get_tree().quit(1)

func _comprobar(condicion: bool, mensaje: String) -> void:
	if not condicion:
		_fallos.append(mensaje)
