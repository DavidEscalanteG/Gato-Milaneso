extends Node

const Cola = preload("res://Scripts/reportes/reportes_pendientes.gd")

func _ready() -> void:
	if not OS.get_user_data_dir().replace("\\", "/").contains("/tmp/"):
		get_tree().quit(1)
		return
	var cola = Cola.new()
	var token = Crypto.new().generate_random_bytes(6).hex_encode()
	cola.ruta = "user://pendientes-" + token
	var respuestas: Dictionary = {}
	for numero in range(1, 11):
		respuestas["p%d" % numero] = 2
	var datos = {"version": 1, "nombre": "Persona Ficticia", "alias": "Jugador", "respuestas": respuestas, "total": 18, "clasificacion": "Depresión moderadamente severa"}
	var archivo = cola.guardar(datos)
	var bloqueo = "user://bloqueo-" + token
	var salida = FileAccess.open(bloqueo, FileAccess.WRITE)
	salida.store_string("No es una carpeta.")
	salida.close()
	cola.carpeta_resultados = bloqueo.path_join("resultados")
	var correcto = not archivo.is_empty() and cola.exportar(PDF, archivo).is_empty() and cola.listar().size() == 1
	var reabierta = Cola.new()
	reabierta.ruta = cola.ruta
	reabierta.carpeta_resultados = "user://recuperados-" + token
	var recuperados = reabierta.recuperar(PDF)
	correcto = correcto and recuperados.correctos == 1 and recuperados.fallidos == 0 and reabierta.listar().is_empty()
	var danado = reabierta.ruta.path_join("invalido.json")
	salida = FileAccess.open(danado, FileAccess.WRITE)
	salida.store_string("{incompleto")
	salida.close()
	correcto = correcto and reabierta.leer(danado).is_empty() and reabierta.recuperar(PDF).fallidos == 1
	if correcto:
		print("REPORTES PENDIENTES OK: fallo sin pérdida, reapertura, recuperación y JSON inválido.")
	else:
		push_error("Un fallo de exportación debe conservar las respuestas para reintentar.")
	get_tree().quit(0 if correcto else 1)
