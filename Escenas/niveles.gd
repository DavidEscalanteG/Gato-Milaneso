
extends Node2D

@export var indicador: Sprite2D
@export var player: CharacterBody2D

@export var niveles: Node2D = null
var nivel: Area2D = null

func _ready() -> void:
	var ronda = Global.ronda
	SoundManager.fade_out_ambiente()
	
	nivel = niveles.get_child(ronda)
	
	print_debug(nivel.name)
	nivel.disponible = true
	
	if ronda > 0:
		var pos = niveles.get_child(ronda - 1).get_global_position()
		player.set_global_position(pos)
	
	crear_flecha_simple()

func crear_flecha_simple():
	if indicador:
		var size = Vector2i(64, 128)
		var image = Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
		image.fill(Color.TRANSPARENT)
		
		# Puntos para un triángulo simple
		var points = [
			Vector2(size.x / 2, 5),           # Punta
			Vector2(5, size.y - 5),           # Base izquierda
			Vector2(size.x - 5, size.y - 5)   # Base derecha
		]
		
		# Dibujar triángulo relleno
		for y in range(size.y):
			for x in range(size.x):
				if punto_en_triangulo(Vector2(x, y), points):
					image.set_pixel(x, y, Color.YELLOW)
		
		var texture = ImageTexture.create_from_image(image)
		indicador.texture = texture
		indicador.centered = true
		indicador.offset = Vector2(0, -128)

func punto_en_triangulo(p: Vector2, triangle: Array) -> bool:
	var p0 = triangle[0]
	var p1 = triangle[1]
	var p2 = triangle[2]
	
	var area = 0.5 * (-p1.y * p2.x + p0.y * (-p1.x + p2.x) + p0.x * (p1.y - p2.y) + p1.x * p2.y)
	var s = 1 / (2 * area) * (p0.y * p2.x - p0.x * p2.y + (p2.y - p0.y) * p.x + (p0.x - p2.x) * p.y)
	var t = 1 / (2 * area) * (p0.x * p1.y - p0.y * p1.x + (p0.y - p1.y) * p.x + (p1.x - p0.x) * p.y)
	
	return s > 0 and t > 0 and (1 - s - t) > 0

func _process(delta: float) -> void:
	if indicador:
		if nivel:
			var player_pos = player.get_global_position()
			var nivel_pos = nivel.get_global_position()
			
			var dis = pow(nivel_pos.y - player_pos.y ,2) + pow(nivel_pos.x - player_pos.x ,2)
			
			if dis > 200:
				indicador.visible = true
				indicador.look_at(nivel_pos)
				indicador.rotation += PI/2
			else:
				indicador.visible = false
		else:
			indicador.visible= false
