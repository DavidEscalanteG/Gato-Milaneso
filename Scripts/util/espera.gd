extends RefCounted

# Cancela la espera si su escena sale del árbol, sin dejar corutinas pendientes.
static func segundos(nodo: Node, duracion: float) -> bool:
	if not nodo.is_inside_tree() or nodo.is_queued_for_deletion():
		return false
	# Las esperas del juego también se detienen al abrir la pausa.
	var temporizador = nodo.get_tree().create_timer(duracion, false)
	var cancelada = [false]
	var cancelar = func():
		cancelada[0] = true
		temporizador.time_left = 0.0
		temporizador.timeout.emit()
	nodo.tree_exiting.connect(cancelar, CONNECT_ONE_SHOT)
	await temporizador.timeout
	if nodo.tree_exiting.is_connected(cancelar):
		nodo.tree_exiting.disconnect(cancelar)
	return not cancelada[0]

static func animacion(nodo: Node, tween: Tween) -> bool:
	if not nodo.is_inside_tree() or nodo.is_queued_for_deletion():
		tween.kill()
		return false
	var cancelada = [false]
	var cancelar = func():
		cancelada[0] = true
		tween.kill()
		tween.finished.emit()
	nodo.tree_exiting.connect(cancelar, CONNECT_ONE_SHOT)
	await tween.finished
	if nodo.tree_exiting.is_connected(cancelar):
		nodo.tree_exiting.disconnect(cancelar)
	return not cancelada[0]
