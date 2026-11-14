extends CanvasLayer

const MENU = "res://menuPrincipal/menu.tscn"
const ESCENAS_SIN_PAUSA = [
	"res://Escenas/Intro.tscn", MENU, "res://Creditos/creditos.tscn",
	"res://Escenas/Admin/amindExportar.tscn",
	"res://Escenas/EscenasDialogos/pantalla_final.tscn",
]

var abierta: bool = false
var _pausa_anterior: bool = false
var _solo_audio: bool = false
var _escena_origen: Node
var _foco_anterior: WeakRef
var _cursor_anterior: int
var _modales: Array[Dictionary] = []
var _reproductores: Array[Dictionary] = []

@onready var pantalla: Control = $Pantalla
@onready var contenido: VBoxContainer = %Contenido
@onready var confirmacion: VBoxContainer = %Confirmacion
@onready var continuar: Button = %Continuar
@onready var musica: HSlider = %Musica
@onready var efectos: HSlider = %Efectos
@onready var guardar_timer: Timer = $GuardarTimer


func _ready() -> void:
	pantalla.hide()
	continuar.pressed.connect(reanudar)
	%VolverMenu.pressed.connect(pedir_volver_menu)
	%SeguirJugando.pressed.connect(cancelar_salida)
	%ConfirmarSalida.pressed.connect(confirmar_salida)
	musica.value_changed.connect(_cambiar_musica)
	efectos.value_changed.connect(_cambiar_efectos)
	guardar_timer.timeout.connect(_guardar_audio)
	for boton in [continuar, %VolverMenu, %SeguirJugando, %ConfirmarSalida]:
		boton.mouse_entered.connect(SoundManager.play_hover)


func _input(event: InputEvent) -> void:
	if SoundManager.cerrando:
		return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		if abierta:
			if confirmacion.visible:
				cancelar_salida()
			else:
				reanudar()
		elif puede_pausar():
			abrir()
		else:
			return
		get_viewport().set_input_as_handled()


func puede_pausar() -> bool:
	var escena = get_tree().current_scene
	return is_instance_valid(escena) and not SoundManager.cerrando and not Transicion.en_transicion \
		and escena.scene_file_path.begins_with("res://") \
		and not escena.scene_file_path.begins_with("res://pruebas/") \
		and escena.scene_file_path not in ESCENAS_SIN_PAUSA


func abrir() -> void:
	if puede_pausar():
		_abrir(false)


func abrir_audio() -> void:
	if is_instance_valid(get_tree().current_scene) and get_tree().current_scene.scene_file_path == MENU:
		_abrir(true)


func _abrir(solo_audio: bool) -> void:
	if abierta or SoundManager.cerrando or Transicion.en_transicion:
		return
	abierta = true
	_solo_audio = solo_audio
	_escena_origen = get_tree().current_scene
	_pausa_anterior = get_tree().paused
	var foco = get_viewport().gui_get_focus_owner()
	_foco_anterior = weakref(foco) if is_instance_valid(foco) else null
	_cursor_anterior = Input.get_current_cursor_shape()
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	_bloquear_modales(_escena_origen)
	if not solo_audio:
		_pausar_audio(_escena_origen)
		_pausar_audio(SoundManager)
	get_tree().paused = true
	musica.set_value_no_signal(SoundManager.volumen_musica)
	efectos.set_value_no_signal(SoundManager.volumen_efectos)
	_actualizar_porcentajes()
	%Titulo.text = "AUDIO" if solo_audio else "PAUSA"
	%Ayuda.text = "Ajusta el sonido a tu gusto" if solo_audio else "ESC para continuar"
	continuar.text = "VOLVER" if solo_audio else "CONTINUAR"
	%VolverMenu.visible = not solo_audio
	%EstadoAudio.text = ""
	contenido.show()
	confirmacion.hide()
	pantalla.show()
	continuar.grab_focus()
	SoundManager.play_click()


func _bloquear_modales(nodo: Node) -> void:
	# Instrucciones y derrota funcionan cuando el árbol está pausado. El menú
	# debe bloquearlas temporalmente para que Enter no actúe detrás del panel.
	if nodo.process_mode in [Node.PROCESS_MODE_ALWAYS, Node.PROCESS_MODE_WHEN_PAUSED]:
		_modales.append({"nodo": weakref(nodo), "modo": nodo.process_mode})
		nodo.process_mode = Node.PROCESS_MODE_PAUSABLE
	for hijo in nodo.get_children():
		_bloquear_modales(hijo)


func _pausar_audio(nodo: Node) -> void:
	if nodo is AudioStreamPlayer or nodo is AudioStreamPlayer2D or nodo is AudioStreamPlayer3D:
		# Los botones del propio menú siguen teniendo respuesta sonora.
		if nodo not in [SoundManager.player_click, SoundManager.player_hover]:
			_reproductores.append({"nodo": weakref(nodo), "pausado": nodo.stream_paused})
			nodo.stream_paused = true
	for hijo in nodo.get_children():
		_pausar_audio(hijo)


func reanudar() -> void:
	if not abierta:
		return
	_cerrar()
	SoundManager.play_click()


func _cerrar() -> void:
	_guardar_audio()
	guardar_timer.stop()
	pantalla.hide()
	abierta = false
	for dato in _modales:
		var nodo = dato.nodo.get_ref()
		if is_instance_valid(nodo):
			nodo.process_mode = dato.modo
	_modales.clear()
	get_tree().paused = _pausa_anterior
	for dato in _reproductores:
		var nodo = dato.nodo.get_ref()
		if is_instance_valid(nodo):
			nodo.stream_paused = dato.pausado
	_reproductores.clear()
	Input.set_default_cursor_shape(_cursor_anterior)
	get_viewport().gui_release_focus()
	if _foco_anterior != null:
		var foco = _foco_anterior.get_ref()
		if is_instance_valid(foco) and foco.is_visible_in_tree():
			foco.grab_focus()
	_foco_anterior = null
	_escena_origen = null


func pedir_volver_menu() -> void:
	SoundManager.play_click()
	%Ayuda.text = "ESC para cancelar"
	contenido.hide()
	confirmacion.show()
	%SeguirJugando.grab_focus()


func cancelar_salida() -> void:
	SoundManager.play_click()
	%Ayuda.text = "ESC para continuar"
	confirmacion.hide()
	contenido.show()
	%VolverMenu.grab_focus()


func confirmar_salida() -> void:
	if not abierta or _solo_audio or not confirmacion.visible:
		return
	var origen = _escena_origen
	_cerrar()
	# Mantener congelada la escena saliente durante el fundido. De lo contrario
	# un cronómetro podría acabar y abrir otra pantalla antes de llegar al menú.
	_bloquear_modales(origen)
	get_tree().paused = true
	SoundManager.detener_audio(get_tree().root)
	Global.reiniciar_partida()
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	await Transicion.cambiar_escena(MENU)
	_modales.clear()
	get_tree().paused = false


func _cambiar_musica(valor: float) -> void:
	SoundManager.ajustar_musica(valor)
	_actualizar_porcentajes()
	guardar_timer.start()


func _cambiar_efectos(valor: float) -> void:
	SoundManager.ajustar_efectos(valor)
	_actualizar_porcentajes()
	guardar_timer.start()


func _actualizar_porcentajes() -> void:
	%ValorMusica.text = "%d %%" % roundi(SoundManager.volumen_musica)
	%ValorEfectos.text = "%d %%" % roundi(SoundManager.volumen_efectos)


func _guardar_audio() -> void:
	if not SoundManager.guardar_ajustes_audio():
		%EstadoAudio.text = "No se pudieron guardar. Se aplican en esta sesión."
	else:
		%EstadoAudio.text = ""
