extends RefCounted

const ITERACIONES = 100000
const ALGORITMO = "PBKDF2-HMAC-SHA256-v1"
var ruta_config: String = "user://evaluador.cfg"

func estado() -> Error:
	var config = ConfigFile.new()
	var error = config.load(ruta_config)
	if error != OK:
		return error
	var sal = str(config.get_value("acceso", "sal", ""))
	var clave = str(config.get_value("acceso", "clave", ""))
	if config.get_value("acceso", "algoritmo", "") != ALGORITMO:
		return ERR_FILE_CORRUPT
	if sal.length() != 32 or clave.length() != 64:
		return ERR_FILE_CORRUPT
	if not sal.is_valid_hex_number() or not clave.is_valid_hex_number():
		return ERR_FILE_CORRUPT
	return OK

func configurar(clave: String) -> Error:
	if FileAccess.file_exists(ruta_config):
		return ERR_ALREADY_EXISTS
	if clave.length() < 8 or clave.length() > 128 or clave.strip_edges().is_empty():
		return ERR_INVALID_PARAMETER
	var sal = Crypto.new().generate_random_bytes(16)
	if sal.size() != 16:
		return ERR_CANT_CREATE
	var config = ConfigFile.new()
	config.set_value("acceso", "algoritmo", ALGORITMO)
	config.set_value("acceso", "sal", sal.hex_encode())
	config.set_value("acceso", "clave", derivar_clave(clave, sal).hex_encode())
	return config.save(ruta_config)

func verificar(clave: String) -> bool:
	if clave.length() > 128 or estado() != OK:
		return false
	var config = ConfigFile.new()
	if config.load(ruta_config) != OK:
		return false
	var sal = str(config.get_value("acceso", "sal")).hex_decode()
	var esperado = str(config.get_value("acceso", "clave")).hex_decode()
	return Crypto.new().constant_time_compare(esperado, derivar_clave(clave, sal))

# PBKDF2 de un bloque (32 bytes), sin guardar la contraseña en texto legible.
static func derivar_clave(clave: String, sal: PackedByteArray, iteraciones: int = ITERACIONES) -> PackedByteArray:
	var crypto = Crypto.new()
	var llave = clave.to_utf8_buffer()
	var mensaje = sal.duplicate()
	mensaje.append_array(PackedByteArray([0, 0, 0, 1]))
	var bloque = crypto.hmac_digest(HashingContext.HASH_SHA256, llave, mensaje)
	var resultado = bloque.duplicate()
	for vuelta in range(1, iteraciones):
		bloque = crypto.hmac_digest(HashingContext.HASH_SHA256, llave, bloque)
		for indice in resultado.size():
			resultado[indice] = resultado[indice] ^ bloque[indice]
	return resultado
