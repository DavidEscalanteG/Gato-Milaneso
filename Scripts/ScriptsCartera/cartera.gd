extends Area2D

@export var velocidad: float = 200  # Velocidad de movimiento de la cartera
var carriles = [280, 430, 570]  # Coordenadas X de los tres carriles
var direccion = Vector2(0, 1)  # Movimiento hacia abajo

func _ready() -> void:
	# Agregar este nodo al grupo "cartera" para identificarlo
	add_to_group("cartera")
	resetear_cartera()
	# Conectar la señal de colisión con el gato
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	# Mover la cartera hacia abajo
	position.y += direccion.y * velocidad * delta

	# Si la cartera sale de la pantalla, reiniciar en otro carril
	if position.y > 450:  # Ajusta este valor según el tamaño de la pantalla
		resetear_cartera()

func resetear_cartera():
	# Volver a la parte superior en un carril aleatorio
	position.x = carriles[randi() % carriles.size()]
	position.y = -50  # Aparece arriba de la pantalla

# Función que detecta la colisión con el gato y permite ganar
func _on_body_entered(body):
	if body.is_in_group("gato") and body.vidas > 0 and not body.juego_ganado:
		SoundManager.play_win_sound()
		body.win()  # Ejecutar victoria
		queue_free()  # Elimina la cartera de la escena
