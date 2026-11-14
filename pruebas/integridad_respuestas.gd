extends Node

const Cola = preload("res://Scripts/reportes/reportes_pendientes.gd")
var _fallos: Array[String] = []

func _ready() -> void:
	Global.reiniciar_test()
	_comprobar(Global.respuestas_test.values().all(func(v): return v == -1), "Todas las respuestas deben comenzar pendientes.")
	Global.set_respuesta(1, 0)
	_comprobar(Global.respuestas_test.p1 == 0 and Global.severidad_depresion == "Sin clasificar", "Una respuesta cero debe distinguirse de una pendiente.")
	for faltante in range(1, 11):
		Global.reiniciar_test()
		for numero in range(1, 11):
			if numero != faltante:
				Global.set_respuesta(numero, 2)
		_comprobar(not Global.respuestas_completas() and not Global.guardar_reporte_final(), "No entregar una partida si falta una respuesta.")
		_comprobar(not Global.respuestas_a_pdf(), "La exportación directa también debe impedir reportes incompletos.")
	for numero in range(1, 11):
		Global.set_respuesta(numero, 0)
	_comprobar(Global.respuestas_completas() and Global.total_test == 0 and Global.severidad_depresion == "Sin síntomas significativos", "Diez ceros son respuestas válidas.")
	for numero in range(1, 11):
		Global.set_respuesta(numero, 3)
	_comprobar(Global.total_test == 27, "El máximo debe conservarse en 27, sin sumar la pregunta diez.")
	Global.set_respuesta(10, 0)
	_comprobar(Global.total_test == 27, "Cambiar dificultad no debe alterar el puntaje.")
	if _fallos.is_empty():
		print("INTEGRIDAD OK: diez pendientes comprobadas, cero válido y puntaje original.")
	else:
		for fallo in _fallos:
			push_error(fallo)
	get_tree().quit(0 if _fallos.is_empty() else 1)

func _comprobar(condicion: bool, mensaje: String) -> void:
	if not condicion:
		_fallos.append(mensaje)
