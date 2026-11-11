extends Area2D

@export var velocidad: float = 600  # Velocidad de movimiento del perro
@onready var sprite = $AnimatedSprite2D
var carriles = [280, 430, 570]  # Coordenadas X de los tres carriles
var direccion = Vector2(0, 1)  # Movimiento hacia abajo

func _ready() -> void:
	# Agregar este nodo al grupo de perros para que podamos desactivarlo
	add_to_group("perros")
	resetear_perro()
	# Conectar la señal de colisión con el gato
	body_entered.connect(_on_body_entered)
	sprite.play("Run_dog")

func _process(delta: float) -> void:
	position.y += direccion.y * velocidad * delta

	# Si el perro ya está desactivado, lo eliminamos cuando salga completamente
	if position.y > 500:  # Ajusta este valor según la pantalla
		if get_meta("desactivado", false):
			queue_free()  # Elimina el nodo de la escena
		else:
			resetear_perro()


func resetear_perro():
	# Volver a la parte superior en un carril aleatorio
	position.x = carriles[randi() % carriles.size()]
	position.y = -50  # Aparece arriba de la pantalla

# Función que detecta la colisión con el gato y le resta una vida
func _on_body_entered(body):
	if body.is_in_group("gato"):  # Si colisiona con el gato
		body.perder_vida()  # Llamar la función perder_vida en el gato
