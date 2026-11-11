extends CanvasLayer

@onready var anim = $AnimationPlayer
@onready var cortina = $Cortina

func _ready():
	# Al iniciar, ocultamos la cortina y la hacemos transparente por si acaso
	cortina.visible = false
	cortina.modulate.a = 0.0

# Esta es la función que llamarás desde tus niveles
func cambiar_escena(path_escena: String):
	# 1. Aparecemos la cortina (transparente)
	cortina.visible = true
	
	# 2. Reproducimos el fundido a negro
	anim.play("dissolve")
	await anim.animation_finished
	
	# 3. ¡CAMBIO DE ESCENA! (Ocurre mientras todo está negro)
	get_tree().change_scene_to_file(path_escena)
	
	# 4. Reproducimos la animación al revés (de negro a transparente)
	anim.play_backwards("dissolve")
	await anim.animation_finished
	
	# 5. Ocultamos la cortina para que no estorbe a los clicks
	cortina.visible = false
