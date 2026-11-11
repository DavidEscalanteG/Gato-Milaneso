extends RefCounted

const Cuestionario = preload("res://Singleton/Cuestionario.gd")
const TINTA = Color(0.12, 0.19, 0.23)
const VERDE = Color(0.05, 0.36, 0.38)
const GRIS = Color(0.37, 0.43, 0.47)
const BORDE = Color(0.83, 0.88, 0.89)
const FONDO = Color(0.94, 0.97, 0.97)
const LIMITE = 724

var _pdf: Node
var _pagina = 0
var _y = 0
var _fecha = ""

func generar(pdf: Node, nombre: String, usuario: String, respuestas: Dictionary, total: int, clasificacion: String) -> void:
	_pdf = pdf
	_pagina = 0
	var fecha = Time.get_datetime_dict_from_system()
	_fecha = "%02d/%02d/%04d %02d:%02d:%02d" % [fecha.day, fecha.month, fecha.year,
		fecha.hour, fecha.minute, fecha.second]
	_pdf.newPDF("Resultados del cuestionario", "El Gato Milaneso")
	_nueva_pagina()
	_campo("Jugador", nombre.strip_edges() if not nombre.strip_edges().is_empty() else "Sin indicar")
	_campo("Usuario", usuario if not usuario.is_empty() else "Sin indicar")
	_y += 10
	_asegurar_espacio(102)
	_rect(40, _y, 532, 92, FONDO)
	_rect(40, _y, 4, 92, VERDE)
	_texto(56, _y + 12, "PUNTAJE (PREGUNTAS 1 A 9)", 9, GRIS)
	_texto(56, _y + 31, "%d / 27" % total, 25, VERDE)
	_texto(252, _y + 12, "CLASIFICACIÓN REGISTRADA", 9, GRIS)
	_lineas(_envolver(clasificacion, 300, 12), 252, _y + 34, 12, TINTA)
	_texto(56, _y + 72, "La pregunta 10 se registra por separado y no modifica el puntaje.", 9, GRIS)
	_y += 112
	_asegurar_espacio(130)
	_texto(40, _y, "Respuestas del cuestionario", 16, TINTA)
	_y += 28
	_encabezado_tabla()
	for indice in Cuestionario.PREGUNTAS.size():
		_fila(indice + 1, Cuestionario.PREGUNTAS[indice], int(respuestas.get("p%d" % (indice + 1), -1)))
	for pagina in range(1, _pagina + 1):
		_pdf.newBox(pagina, Vector2i(40, 744), Vector2i(532, 1), BORDE)
		_pdf.newLabel(pagina, Vector2i(40, 756), "El Gato Milaneso - Registro de respuestas", 8, "Helvetica", GRIS)
		_pdf.newLabel(pagina, Vector2i(492, 756), "Página %d de %d" % [pagina, _pagina], 8, "Helvetica", GRIS)

func _nueva_pagina() -> void:
	if _pagina > 0:
		_pdf.newPage()
	_pagina += 1
	_rect(40, 34, 5, 46, VERDE)
	_texto(58, 34, "EL GATO MILANESO", 10, VERDE)
	_texto(58, 51, "Resultados del cuestionario", 23, TINTA)
	_texto(40, 91, "Registro de respuestas de la partida", 10, GRIS)
	_texto(432, 86, _fecha, 9, GRIS)
	_y = 120

func _asegurar_espacio(alto: int) -> void:
	if _y + alto > LIMITE:
		_nueva_pagina()

func _campo(etiqueta: String, valor: String) -> void:
	var lineas = _envolver(etiqueta + ": " + valor, 532, 11)
	for linea in lineas:
		_asegurar_espacio(16)
		_texto(40, _y, linea, 11, TINTA)
		_y += 16
	_y += 6

func _encabezado_tabla() -> void:
	_rect(40, _y, 532, 28, VERDE)
	_texto(51, _y + 8, "N°", 10, Color.WHITE)
	_texto(86, _y + 8, "Pregunta", 10, Color.WHITE)
	_texto(414, _y + 8, "Respuesta", 10, Color.WHITE)
	_y += 28

func _fila(numero: int, pregunta: String, valor: int) -> void:
	var pregunta_lineas = _envolver(pregunta, 304, 11)
	var respuesta_lineas = _envolver(Cuestionario.texto_respuesta(numero, valor), 146, 11)
	var alto = maxi(64, maxi(pregunta_lineas.size() * 15, respuesta_lineas.size() * 15 + 20) + 24)
	if _y + alto > LIMITE:
		_nueva_pagina()
		_encabezado_tabla()
	_rect(40, _y, 532, alto, FONDO if numero % 2 == 0 else Color.WHITE)
	_rect(40, _y + alto - 1, 532, 1, BORDE)
	_rect(401, _y, 1, alto, BORDE)
	_texto(51, _y + 13, str(numero), 12, VERDE)
	_lineas(pregunta_lineas, 86, _y + 12, 11, TINTA)
	_lineas(respuesta_lineas, 414, _y + 12, 11, TINTA)
	if valor >= 0 and valor <= 3:
		var detalle = "Valor: %d" % valor
		if numero == 10:
			detalle += " - no suma"
		_texto(414, _y + 16 + respuesta_lineas.size() * 15, detalle, 9, GRIS)
	_y += alto

func _envolver(valor: String, ancho: int, tamano: int) -> Array[String]:
	var lineas: Array[String] = []
	var pendiente = valor.replace("\r", " ").replace("\n", " ").replace("\t", " ")
	while not pendiente.is_empty():
		var corte = 0
		while corte < pendiente.length() and _pdf.getHelveticaTextWidth(pendiente.left(corte + 1), tamano) <= ancho:
			corte += 1
		corte = maxi(1, corte)
		if corte < pendiente.length():
			var espacio = pendiente.rfind(" ", corte)
			if espacio > 0:
				corte = espacio
		lineas.append(pendiente.left(corte))
		pendiente = pendiente.substr(corte).strip_edges()
	if lineas.is_empty():
		lineas.append("")
	return lineas

func _lineas(lineas: Array[String], x: int, y: int, tamano: int, color: Color) -> void:
	for indice in lineas.size():
		_texto(x, y + indice * 15, lineas[indice], tamano, color)

func _texto(x: int, y: int, valor: String, tamano: int, color: Color) -> void:
	_pdf.newLabel(_pagina, Vector2i(x, y), valor, tamano, "Helvetica", color)

func _rect(x: int, y: int, ancho: int, alto: int, color: Color) -> void:
	_pdf.newBox(_pagina, Vector2i(x, y), Vector2i(ancho, alto), color)
