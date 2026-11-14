extends Node

const ReportePDF = preload("res://Scripts/reportes/resultados_pdf.gd")
const ArchivoResultados = preload("res://Scripts/reportes/archivo_resultados.gd")

var username = "username"
var borrador_personaje: ConfigFile = null
### Usado para controlar el nivel actual (base 0)
### En niveles, es el nivel que estará desbloqueados
var ronda = 0
var puntaje = 0
var salud = 0
var ronda_local = 0
var derrotas_perros: int = 0
var nombre_jugador: String = " "
var nombre_completo_jugador: String = ""
var severidad_depresion: String = "Sin clasificar"

#var dialogos = {
	#0: [
		#["Yo", "Creo que debo darme por vencido"],
		#["Mente", "Por que no lo intentas"],
		#["Yo", "No lo sé"]
	#],
	#1: [
		#["Yo", "Lol"],
		#["Diego", "XD"]
	#]
	#
#}



# Variables para las 10 preguntas
var respuestas_test := {
	"p1": 0,
	"p2": 0,
	"p3": 0,
	"p4": 0,
	"p5": 0,
	"p6": 0,
	"p7": 0,
	"p8": 0,
	"p9": 0,
	"p10": -1, # Unanswered is different from "No ha sido difícil" (0).
}

# Total
var total_test := 0

func set_respuesta(num: int, valor: int) -> void:
	var key = "p%d" % num
	if respuestas_test.has(key) and valor >= 0 and valor <= 3:
		respuestas_test[key] = valor
		if num <= 9:
			_calcular_total()

func _calcular_total() -> void:
	total_test = 0
	# Question 10 is recorded separately; the original score uses questions 1-9.
	for numero in range(1, 10):
		total_test += respuestas_test["p%d" % numero]
	_determinar_severidad()

func _determinar_severidad() -> void:
	if total_test >= 1 and total_test <= 4:
		severidad_depresion = "Depresión mínima"
	elif total_test >= 5 and total_test <= 9:
		severidad_depresion = "Depresión leve"
	elif total_test >= 10 and total_test <= 14:
		severidad_depresion = "Depresión moderada"
	elif total_test >= 15 and total_test <= 19:
		severidad_depresion = "Depresión moderadamente severa"
	elif total_test >= 20:
		severidad_depresion = "Depresión severa"
	else:
		severidad_depresion = "Sin síntomas significativos"
		
func reiniciar_test() -> void:
	for key in respuestas_test.keys():
		respuestas_test[key] = -1 if key == "p10" else 0
	total_test = 0
	severidad_depresion = "Sin clasificar"

func reiniciar_partida() -> void:
	ronda = 0
	ronda_local = 0
	derrotas_perros = 0
	puntaje = 0
	salud = 0
	username = "Jugador"
	borrador_personaje = null
	reiniciar_test()
	
	
	#Función para ver el puntaje, de manera de prueba.
#func debug_print_respuesta(pregunta: int) -> void:
	#var key = "p%d" % pregunta
	#print("Valor ", key, ":", respuestas_test[key])

# Imprime todas las respuestas y el total en consola
func debug_print_respuestas() -> void:
	print("=== Resultados del test ===")
	for key in respuestas_test.keys():
		print(key, ": ", respuestas_test[key])
	print("Total del test: ", total_test)
	print("Diagnóstico: ", severidad_depresion)
	print("===========================")


#func obtenerDialogo(index: int):
	#return dialogos[index]


var contador = 0
var ultimo_pdf_path: String = ""

func registrar_nombre_completo(nombre: String) -> void:
	var limpio = nombre.replace("\t", " ").replace("\n", " ").replace("\r", " ")
	nombre_completo_jugador = " ".join(limpio.split(" ", false))
	nombre_jugador = nombre_completo_jugador.get_slice(" ", 0)

func respuestas_a_pdf(prefix: String = "", destino: String = "") -> bool:
	ultimo_pdf_path = ""
	var nombre = nombre_completo_jugador if not nombre_completo_jugador.is_empty() else nombre_jugador
	var path = destino
	if path.is_empty():
		var carpeta = ArchivoResultados.carpeta_resultados()
		if DirAccess.make_dir_recursive_absolute(carpeta) != OK:
			push_error("No se pudo crear la carpeta de resultados.")
			return false
		var filename = ArchivoResultados.nombre_pdf(nombre)
		if not prefix.is_empty():
			filename = prefix.validate_filename() + "-" + filename
		path = ArchivoResultados.ruta_disponible(carpeta, filename)
	ReportePDF.new().generar(PDF, nombre, username, respuestas_test, total_test, severidad_depresion)
	var status = PDF.export(path)
	if status:
		ultimo_pdf_path = ProjectSettings.globalize_path(path)
	else:
		push_error("No se pudo guardar el reporte de la partida.")
	return status
