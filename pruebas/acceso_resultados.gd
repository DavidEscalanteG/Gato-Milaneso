extends Node

const Acceso = preload("res://Scripts/reportes/acceso_evaluador.gd")
const Archivo = preload("res://Scripts/reportes/archivo_resultados.gd")
const EscenaAcceso = preload("res://Escenas/Admin/amindExportar.tscn")
var _fallos: Array[String] = []

func _ready() -> void:
	# APPDATA debe redirigirse a tmp/test-appdata al ejecutar esta prueba.
	# Evita tocar la contraseña real o crear reportes junto a evaluaciones reales.
	var temporal = ProjectSettings.globalize_path("res://tmp/test-appdata").replace("\\", "/")
	if not OS.get_data_dir().replace("\\", "/").begins_with(temporal + "/") and OS.get_data_dir().replace("\\", "/") != temporal:
		push_error("Redirige APPDATA a tmp/test-appdata antes de ejecutar esta prueba.")
		get_tree().quit(1)
		return
	var carpeta = "res://tmp/acceso-" + Crypto.new().generate_random_bytes(6).hex_encode()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(carpeta))
	var acceso = Acceso.new()
	acceso.ruta_config = carpeta.path_join("evaluador.cfg")
	_comprobar(acceso.estado() == ERR_FILE_NOT_FOUND, "Primera ejecución debe pedir configuración.")
	_comprobar(acceso.configurar("corta") == ERR_INVALID_PARAMETER, "Rechazar contraseña demasiado corta.")
	var vector = Acceso.derivar_clave("password", "salt".to_utf8_buffer(), 2).hex_encode()
	_comprobar(vector == "ae4d0c95af6b46d32d0adff928f06dd02a303f8ef3c251dfd6e2d85a95474c43", "Derivación PBKDF2 incorrecta.")
	var panel = EscenaAcceso.instantiate()
	panel.acceso = acceso
	add_child(panel)
	_comprobar(not panel._autorizado and not panel.acciones.visible, "No mostrar resultados antes de autenticar.")
	panel._abrir_resultados() # No debe abrir el Explorador sin autorización.
	panel.clave.text = "Prueba temporal 2026"
	panel.confirmacion.text = "otra contraseña"
	await panel._acceder()
	_comprobar(acceso.estado() == ERR_FILE_NOT_FOUND, "No guardar contraseñas si no coinciden.")
	panel.confirmacion.text = panel.clave.text
	await panel._acceder()
	_comprobar(panel._autorizado and panel.acciones.visible, "Configurar y habilitar acceso inicial.")
	_comprobar(acceso.estado() == OK, "Configuración válida después del primer acceso.")
	_comprobar(not FileAccess.get_file_as_string(acceso.ruta_config).contains("Prueba temporal 2026"), "No guardar contraseña legible.")
	panel.free()
	var nuevo = Acceso.new()
	nuevo.ruta_config = acceso.ruta_config
	_comprobar(nuevo.configurar("Otra contraseña") == ERR_ALREADY_EXISTS, "No sobrescribir la contraseña existente.")
	panel = EscenaAcceso.instantiate()
	panel.acceso = nuevo
	add_child(panel)
	_comprobar(not panel._autorizado and not panel.confirmacion.visible, "Reabrir el acceso debe bloquear los reportes.")
	panel.clave.text = "incorrecta"
	await panel._acceder()
	_comprobar(not panel._autorizado and not panel.acciones.visible, "Contraseña incorrecta no debe permitir acceso.")
	panel.clave.text = "Prueba temporal 2026"
	await panel._acceder()
	_comprobar(panel._autorizado, "Contraseña debe funcionar tras recrear el panel y el servicio.")
	panel.free()
	var corrupto = FileAccess.open(carpeta.path_join("corrupto.cfg"), FileAccess.WRITE)
	corrupto.store_string("[acceso]\nalgoritmo=\"otro\"\n")
	corrupto.close()
	nuevo.ruta_config = carpeta.path_join("corrupto.cfg")
	_comprobar(nuevo.estado() == ERR_FILE_CORRUPT and not nuevo.verificar("cualquiera"), "Configuración inválida debe bloquear acceso.")
	var fecha = {"day": 9, "month": 4, "year": 2026, "hour": 13, "minute": 5, "second": 8}
	_comprobar(Archivo.nombre_pdf("José Pérez López", fecha, "ABC123") == "José_Pérez_López_09-04-2026_13-05-08_Folio-ABC123.pdf", "Nombre debe incluir apellidos y fecha mexicana.")
	var seguro = Archivo.nombre_pdf("../Ana: Gómez\\Ruiz\n", fecha, "ABC123")
	_comprobar(seguro.is_valid_filename() and seguro.get_file() == seguro, "Sanear separadores y caracteres inválidos.")
	Global.registrar_nombre_completo("  María   Fernanda López Pérez  ")
	_comprobar(Global.nombre_jugador == "María" and Global.nombre_completo_jugador == "María Fernanda López Pérez", "Separar nombre de diálogo y nombre completo.")
	_comprobar(Global.respuestas_a_pdf(), "Guardar un PDF en la carpeta predeterminada.")
	var primera = Global.ultimo_pdf_path
	_comprobar(primera.get_base_dir() == Archivo.carpeta_resultados(), "Usar la nueva carpeta de resultados.")
	_comprobar(primera.get_file().begins_with("María_Fernanda_López_Pérez_"), "Usar nombre completo en el archivo.")
	_comprobar(Archivo.ruta_disponible(primera.get_base_dir(), primera.get_file()) != primera, "Evitar sobrescribir archivos si coincide el nombre.")
	_comprobar(Global.respuestas_a_pdf() and Global.ultimo_pdf_path != primera, "Dos exportaciones deben conservar archivos distintos.")
	_comprobar(FileAccess.file_exists(primera), "Conservar la primera evaluación.")
	if _fallos.is_empty():
		print("PRUEBA ACCESO OK: contraseña persistente, bloqueo, nombre completo, fecha y guardado sin sobrescritura.")
		get_tree().quit(0)
	else:
		for fallo in _fallos:
			push_error(fallo)
		get_tree().quit(1)

func _comprobar(condicion: bool, mensaje: String) -> void:
	if not condicion:
		_fallos.append(mensaje)
