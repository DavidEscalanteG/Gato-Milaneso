extends RefCounted

const Archivo = preload("res://Scripts/reportes/archivo_resultados.gd")
const Reporte = preload("res://Scripts/reportes/resultados_pdf.gd")
var ruta: String = "user://reportes_pendientes"
var carpeta_resultados: String = Archivo.carpeta_resultados()

func guardar(datos: Dictionary) -> String:
	if not _validos(datos) or DirAccess.make_dir_recursive_absolute(ruta) != OK:
		return ""
	var destino = ruta.path_join(Crypto.new().generate_random_bytes(12).hex_encode() + ".json")
	var temporal = destino + ".tmp"
	var archivo = FileAccess.open(temporal, FileAccess.WRITE)
	if archivo == null:
		return ""
	archivo.store_string(JSON.stringify(datos))
	archivo.flush()
	var correcto = archivo.get_error() == OK
	archivo.close()
	if not correcto or DirAccess.rename_absolute(temporal, destino) != OK:
		return ""
	return destino

func listar() -> PackedStringArray:
	var resultados = PackedStringArray()
	var carpeta = DirAccess.open(ruta)
	if carpeta != null:
		for archivo in carpeta.get_files():
			if archivo.ends_with(".json"):
				resultados.append(ruta.path_join(archivo))
	return resultados

func leer(archivo: String) -> Dictionary:
	if archivo.get_base_dir() != ruta:
		return {}
	var entrada = FileAccess.open(archivo, FileAccess.READ)
	if entrada == null or entrada.get_length() > 65536:
		return {}
	var contenido = entrada.get_as_text()
	entrada.close()
	var json = JSON.new()
	if json.parse(contenido) != OK:
		return {}
	var datos = json.data
	return datos if datos is Dictionary and _validos(datos) else {}

func exportar(pdf: Node, archivo: String) -> String:
	var datos = leer(archivo)
	if datos.is_empty() or DirAccess.make_dir_recursive_absolute(carpeta_resultados) != OK:
		return ""
	for valor in datos.respuestas.values():
		if valor < 0:
			return ""
	var destino = Archivo.ruta_disponible(carpeta_resultados, Archivo.nombre_pdf(datos.nombre))
	Reporte.new().generar(pdf, datos.nombre, datos.alias, datos.respuestas, int(datos.total), datos.clasificacion)
	if not pdf.export(destino):
		return ""
	DirAccess.remove_absolute(archivo)
	return ProjectSettings.globalize_path(destino)

func recuperar(pdf: Node) -> Dictionary:
	var resultado = {"correctos": 0, "fallidos": 0}
	for archivo in listar():
		var clave = "fallidos" if exportar(pdf, archivo).is_empty() else "correctos"
		resultado[clave] += 1
	return resultado

func _validos(datos: Dictionary) -> bool:
	if datos.get("version") != 1 or not datos.get("nombre") is String or not datos.get("alias") is String or not datos.get("clasificacion") is String:
		return false
	if not datos.get("respuestas") is Dictionary or datos.respuestas.size() != 10 or not (datos.get("total") is int or datos.get("total") is float):
		return false
	var suma = 0
	for numero in range(1, 11):
		var valor = datos.respuestas.get("p%d" % numero)
		if not (valor is int or valor is float) or valor < -1 or valor > 3 or int(valor) != valor:
			return false
		if numero <= 9:
			suma += maxi(0, int(valor))
	return datos.total == suma
