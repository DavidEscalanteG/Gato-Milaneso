extends Control

const AccesoEvaluador = preload("res://Scripts/reportes/acceso_evaluador.gd")
const ArchivoResultados = preload("res://Scripts/reportes/archivo_resultados.gd")
var acceso = AccesoEvaluador.new()
var _configurando = false
var _autorizado = false
var _ocupado = false
var _intentos = 0

@onready var formulario = $CenterContainer/Panel/Margen/Contenido/Formulario
@onready var instrucciones = $CenterContainer/Panel/Margen/Contenido/Instrucciones
@onready var clave = $CenterContainer/Panel/Margen/Contenido/Formulario/Clave
@onready var confirmacion = $CenterContainer/Panel/Margen/Contenido/Formulario/Confirmacion
@onready var entrar = $CenterContainer/Panel/Margen/Contenido/Formulario/Entrar
@onready var mensaje = $CenterContainer/Panel/Margen/Contenido/Mensaje
@onready var acciones = $CenterContainer/Panel/Margen/Contenido/Acciones

func _ready() -> void:
	entrar.pressed.connect(_acceder)
	clave.text_submitted.connect(func(_texto): _acceder())
	confirmacion.text_submitted.connect(func(_texto): _acceder())
	acciones.get_node("Abrir").pressed.connect(_abrir_resultados)
	$CenterContainer/Panel/Margen/Contenido/Volver.pressed.connect(_volver)
	var estado = acceso.estado()
	_configurando = estado == ERR_FILE_NOT_FOUND
	confirmacion.visible = _configurando
	if _configurando:
		instrucciones.text = "Primer acceso: crea una contraseña de al menos 8 caracteres.\nConfigura este acceso antes de entregar el juego al participante."
		entrar.text = "Crear contraseña y entrar"
	elif estado == OK:
		instrucciones.text = "Escribe tu contraseña para consultar los reportes guardados."
	else:
		instrucciones.text = "No se pudo leer la configuración de acceso.\nConsulta la guía del evaluador para recuperarla."
		formulario.hide()
	clave.grab_focus()

func _acceder() -> void:
	if _ocupado or _autorizado:
		return
	var valor = clave.text
	if _configurando and (valor.length() < 8 or valor.strip_edges().is_empty()):
		mensaje.text = "Usa una contraseña de al menos 8 caracteres."
		return
	if _configurando and valor != confirmacion.text:
		mensaje.text = "Las contraseñas no coinciden."
		return
	_ocupado = true
	entrar.disabled = true
	mensaje.text = "Verificando acceso..."
	await get_tree().process_frame
	var valido = false
	if _configurando:
		var error = acceso.configurar(valor)
		valido = error == OK
		if not valido:
			mensaje.text = "No se pudo guardar la contraseña. Inténtalo nuevamente."
	else:
		valido = acceso.verificar(valor)
		if not valido:
			_intentos += 1
			mensaje.text = "Contraseña incorrecta."
	clave.clear()
	confirmacion.clear()
	if valido:
		_autorizado = true
		formulario.hide()
		acciones.show()
		instrucciones.text = "Consulta las evaluaciones guardadas."
		mensaje.text = "Carpeta de resultados:\n" + ArchivoResultados.carpeta_resultados()
		acciones.get_node("Abrir").grab_focus()
	elif _intentos >= 3:
		mensaje.text = "Espera 15 segundos antes de intentarlo otra vez."
		await get_tree().create_timer(15.0).timeout
		_intentos = 0
		mensaje.text = "Ya puedes volver a intentarlo."
	_ocupado = false
	entrar.disabled = false

func _abrir_resultados() -> void:
	if not _autorizado:
		return
	var carpeta = ArchivoResultados.carpeta_resultados()
	if DirAccess.make_dir_recursive_absolute(carpeta) != OK:
		mensaje.text = "No se pudo crear o acceder a la carpeta de resultados."
		return
	_abrir_carpeta(carpeta)

func _abrir_carpeta(carpeta: String) -> void:
	if OS.shell_open(carpeta) != OK:
		mensaje.text = "No se pudo abrir la carpeta. Puedes abrirla desde el Explorador:\n" + carpeta

func _volver() -> void:
	get_tree().change_scene_to_file("res://menuPrincipal/menu.tscn")
