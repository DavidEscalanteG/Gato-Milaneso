extends RefCounted

static func cargar() -> ConfigFile:
	var config = ConfigFile.new()
	config.load("user://player.cfg")
	return config

static func indice(config: ConfigFile, clave: String, defecto: int, maximo: int) -> int:
	var valor = config.get_value("player", clave, PackedInt32Array([defecto]))
	if valor is Array or valor is PackedInt32Array or valor is PackedInt64Array:
		if valor.is_empty():
			return defecto
		valor = valor[0]
	if not (valor is int) or valor < 0 or valor > maximo:
		return defecto
	return valor

static func color(config: ConfigFile) -> Vector4:
	var valor = config.get_value("player", "color_cabello", Vector4(0, 0, 0, 1))
	return valor if valor is Vector4 else Vector4(0, 0, 0, 1)
