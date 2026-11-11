extends Node

# MENÚ
@onready var player_click := AudioStreamPlayer.new()
@onready var player_hover := AudioStreamPlayer.new()
@onready var error := AudioStreamPlayer.new()
@onready var select_pressed := AudioStreamPlayer.new()
@onready var type_sound := AudioStreamPlayer.new()

# NIVELES
@onready var woosh_tp :=  AudioStreamPlayer.new()
@onready var available :=  AudioStreamPlayer.new()

# DIÁLOGOS
@onready var type_dialogue := AudioStreamPlayer.new()

# CARTERA
@onready var lose_life :=  AudioStreamPlayer.new()
@onready var dog_bark :=  AudioStreamPlayer.new()
@onready var win_sound := AudioStreamPlayer.new()
@onready var lose_sound := AudioStreamPlayer.new()


# SLOT MACHINE
@onready var lever_pull : = AudioStreamPlayer.new()
@onready var win_coin : = AudioStreamPlayer.new()
@onready var slot_wheel : = AudioStreamPlayer.new()
@onready var slot_lock : = AudioStreamPlayer.new()
@onready var use_coin : = AudioStreamPlayer.new()


# MONEDAS
@onready var lose_round : = AudioStreamPlayer.new()

## Sonidos de ambiente
@onready var ambiente_menu := AudioStreamPlayer.new()
@onready var ambiente_cartera := AudioStreamPlayer.new()
@onready var ambiente_slot_machine : = AudioStreamPlayer.new()
@onready var ambiente_monedas : = AudioStreamPlayer.new()

# FINAL

@onready var sonido_final : = AudioStreamPlayer.new()


func _ready() -> void:
	# --- configuracion inicial ---
	process_mode = Node.PROCESS_MODE_ALWAYS
	# MENÚ
	add_child(player_click)
	add_child(player_hover)
	add_child(error)
	add_child(select_pressed)
	add_child(type_sound)
	
	#NIVELES
	add_child(woosh_tp)
	add_child(available)
	
	# DIÁLOGOS
	add_child(type_dialogue)
	
	# CARTERA
	add_child(lose_life)
	add_child(dog_bark)
	add_child(win_sound)
	add_child(lose_sound)
	
	# SLOT MACHINE
	add_child(lever_pull)
	add_child(win_coin)
	add_child(slot_wheel)
	add_child(slot_lock)	
	add_child(use_coin)
	
	#CARTERA
	add_child(lose_round)
	
	## Ambientes
	add_child(ambiente_menu)
	add_child(ambiente_cartera)
	add_child(ambiente_slot_machine)
	add_child(ambiente_monedas)
	
	#FINAL
	add_child(sonido_final)
	

	
	
	
	# MENÚ
	player_click.stream = preload("res://Assets/EfectosDeSonido/hover_click.wav")
	player_hover.stream = preload("res://Assets/EfectosDeSonido/arcade_game_coin.wav")
	error.stream = preload("res://Assets/EfectosDeSonido/click_error.wav")
	select_pressed.stream = preload("res://Assets/EfectosDeSonido/select_click.wav")
	type_sound.stream = preload("res://Assets/EfectosDeSonido/type_sound.wav")
	
	# NIVELES
	woosh_tp.stream = preload("res://Assets/EfectosDeSonido/woosh_tp2.wav")
	available.stream = preload("res://Assets/EfectosDeSonido/available.wav")
	
	# DIÁLOGOS
	type_dialogue.stream = preload("res://Assets/EfectosDeSonido/type2.wav")
	
	# CARTERA
	lose_life.stream = preload("res://Assets/EfectosDeSonido/lose_life.wav")
	dog_bark.stream = preload("res://Assets/EfectosDeSonido/bark.mp3")
	win_sound.stream = preload("res://Assets/EfectosDeSonido/win_sound.wav")
	lose_sound.stream = preload("res://Assets/EfectosDeSonido/lose_cartera.wav")
	
	# SLOT MACHINE
	lever_pull.stream = preload("res://Assets/EfectosDeSonido/Lever-pull-sound-effect.mp3")
	win_coin.stream = preload("res://Assets/EfectosDeSonido/win_coin.wav")
	slot_wheel.stream = preload("res://Assets/EfectosDeSonido/slot_machine_wheel.wav")
	slot_lock.stream = preload("res://Assets/EfectosDeSonido/slot_lock.wav")
	use_coin.stream = preload("res://Assets/EfectosDeSonido/coin.wav")
	
	#MONEDAS
	lose_round.stream = preload("res://Assets/EfectosDeSonido/lose_roundv2.wav")
	
	## Preload ambiente
	ambiente_menu.stream = preload("res://Assets/EfectosDeSonido/mixkit-lo-fi-05-767.mp3")
	ambiente_cartera.stream = preload("res://Assets/EfectosDeSonido/ambient_run.mp3")
	ambiente_slot_machine.stream = preload("res://Assets/EfectosDeSonido/ambient_slot_machine.mp3")	
	ambiente_monedas.stream = preload("res://Assets/EfectosDeSonido/ambiente_monedas.mp3")	
	
	#FINAL
	sonido_final.stream = preload("res://Assets/EfectosDeSonido/anysound.wav")
	
	# --- Configuración del ambiente ----
	
	ambiente_menu.volume_db = -15
	ambiente_cartera.volume_db = -15
	ambiente_slot_machine.volume_db = -60
	ambiente_monedas.volume_db = -60
	
# ------------------------
# AMBIENTE
# ------------------------
#func play_ambiente():
	#if not ambiente_menu.playing:
		#ambiente_menu.play()
#
#func stop_ambiente():
	#if ambiente_menu and ambiente_menu.playing:
		#ambiente_menu.stop()

func fade_out_ambiente() -> Tween:
	var tween = create_tween()
	tween.tween_property(ambiente_menu, "volume_db", -80, 1.5)
	return tween 

func fade_in_ambiente():
	if not ambiente_menu.is_playing():
		ambiente_menu.volume_db = -80
		ambiente_menu.play()
		

	var tween = create_tween()
	tween.tween_property(ambiente_menu, "volume_db", -8, 1.5)
	
func fade_out_ambiente_cartera() -> Tween:
	var tween = create_tween()
	tween.tween_property(ambiente_cartera, "volume_db", -80, 1.5)
	return tween 

func fade_in_ambiente_cartera():
	if not ambiente_cartera.is_playing():
		ambiente_cartera.volume_db = -80
		ambiente_cartera.play()
		

	var tween = create_tween()
	tween.tween_property(ambiente_cartera, "volume_db", -8, 1.5)

func fade_out_ambiente_slot_machine() -> Tween:
	var tween = create_tween()
	tween.tween_property(ambiente_slot_machine, "volume_db", -80, 1.5)
	return tween 

func fade_in_ambiente_slot_machine():
	if not ambiente_slot_machine.is_playing():
		ambiente_slot_machine.volume_db = -80
		ambiente_slot_machine.play()
		

	var tween = create_tween()
	tween.tween_property(ambiente_slot_machine, "volume_db", -8, 1.5)
	
	
func fade_out_ambiente_monedas() -> Tween:
	var tween = create_tween()
	tween.tween_property(ambiente_monedas, "volume_db", -80, 1.5)
	return tween 

func fade_in_ambiente_monedas():
	if not ambiente_monedas.is_playing():
		ambiente_monedas.volume_db = -80
		ambiente_monedas.play()
		

	var tween = create_tween()
	tween.tween_property(ambiente_monedas, "volume_db", -8, 1.5)







# ------------------------
# EFECTOS
# ------------------------


## MENÚ
func play_click():
	player_click.play()

func play_hover():
	player_hover.play()
	return
	
func play_error():
	error.play()
	return
	
func play_select_pressed():
	select_pressed.play()
	return
	
	
func play_type_sound():
	type_sound.play()
	return

## NIVELES
	
func play_woosh_sound():
	woosh_tp.play()
	return
	
	
func play_available():
	available.play()
	return


## DIÁLOGOS
func play_type_dialogue():
	type_dialogue.play()
	return
	

## CARTERA
func play_lose_life():
	lose_life.play()
	return
	
	
func play_bark_sound():
	dog_bark.play()
	return

func play_win_sound():
	win_sound.play()
	return

func play_lose_sound():
	lose_sound.play()
	return
	
	
## SLOT MACHINE
func play_pull_lever():
	lever_pull.play()
	return
	
	
func play_win_coin():
	win_coin.play()
	return

func play_slot_wheel():
	if not slot_wheel.is_playing():
		slot_wheel.play()
	return

func stop_slot_wheel():
	slot_wheel.stop()
	return

func play_slot_lock():
	slot_lock.play()
	return
	

func play_lose_round():
	lose_round.play()
	return
	
	
func play_use_coin():
	use_coin.play()
	return
	
	
	
func play_sound_end():
	sonido_final.play()
	return
