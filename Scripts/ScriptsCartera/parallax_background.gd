extends ParallaxBackground

var activo = true  # Variable para controlar si el fondo se mueve

func _process(delta: float) -> void:
	if activo:
		var velocidad = 100
		scroll_base_offset.y += velocidad * delta

func detener_fondo():
	activo = false  # Detiene el movimiento del fondo
