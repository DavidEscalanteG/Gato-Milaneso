extends Node

const Espera = preload("res://Scripts/util/espera.gd")

func _esperar_tiempo(nodo: Node, resultados: Array) -> void:
	resultados.append(await Espera.segundos(nodo, 30.0))

func _esperar_animacion(nodo: Node, tween: Tween, resultados: Array) -> void:
	resultados.append(await Espera.animacion(nodo, tween))

func _ready() -> void:
	var resultados: Array = []
	var nodo = Node.new()
	add_child(nodo)
	_esperar_tiempo(nodo, resultados)
	nodo.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame
	var correcto = resultados == [false]
	resultados.clear()
	nodo = Node.new()
	add_child(nodo)
	var tween = nodo.create_tween()
	tween.tween_interval(30.0)
	_esperar_animacion(nodo, tween, resultados)
	nodo.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame
	correcto = correcto and resultados == [false]
	nodo = Node.new()
	add_child(nodo)
	correcto = correcto and await Espera.segundos(nodo, 0.02)
	tween = nodo.create_tween()
	tween.tween_interval(0.02)
	correcto = correcto and await Espera.animacion(nodo, tween)
	nodo.queue_free()
	await get_tree().process_frame
	if correcto:
		print("CICLO DE VIDA OK: cancelación al salir y finalización normal de esperas y animaciones.")
	else:
		push_error("Las esperas deben cancelarse al abandonar su escena.")
	get_tree().quit(0 if correcto else 1)
