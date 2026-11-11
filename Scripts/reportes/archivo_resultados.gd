extends RefCounted

# Los reportes tienen su propia carpeta; player.cfg y la base de datos conservan
# su ubicación original para no perder configuraciones ni registros existentes.
static func carpeta_resultados() -> String:
	return OS.get_data_dir().path_join("El Gato Milaneso").path_join("Resultados")

static func nombre_pdf(nombre: String, fecha: Dictionary = {}, folio: String = "") -> String:
	if fecha.is_empty():
		fecha = Time.get_datetime_dict_from_system()
	if folio.is_empty():
		folio = Crypto.new().generate_random_bytes(6).hex_encode().to_upper()
	var limpio = ""
	for caracter in nombre:
		limpio += caracter if caracter.unicode_at(0) >= 32 else " "
	limpio = limpio.validate_filename()
	limpio = "_".join(limpio.split(" ", false)).left(80).strip_edges().trim_suffix(".")
	if limpio.is_empty():
		limpio = "Sin_nombre"
	return "%s_%02d-%02d-%04d_%02d-%02d-%02d_Folio-%s.pdf" % [
		limpio, fecha.day, fecha.month, fecha.year,
		fecha.hour, fecha.minute, fecha.second, folio.validate_filename()]

static func ruta_disponible(carpeta: String, archivo: String) -> String:
	var ruta = carpeta.path_join(archivo)
	var consecutivo = 2
	while FileAccess.file_exists(ruta):
		ruta = carpeta.path_join("%s_%d.pdf" % [archivo.get_basename(), consecutivo])
		consecutivo += 1
	return ruta
