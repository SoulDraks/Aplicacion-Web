extends Control
@onready var Productos := $Productos

func _ready():
	init()

func init():
	await MySQLConnector.query("""
		SELECT nombre, descripcion, precio, cantidad_stock 
		FROM Productos 
		ORDER BY id_producto ASC;
	""")
	var resultado = MySQLConnector.query_result.duplicate(true)
	for registro in resultado:
		var producto_escena = preload("res://Scenes/producto.tscn").instantiate()
		var Textos = producto_escena.get_node("Textos").get_children()
		Textos[0].text = registro["nombre"]
		Textos[1].text += registro["descripcion"]
		Textos[3].text = "Precio: $" + SoulMath.DevolverElNumeroConComas(registro["precio"])
		Textos[4].text = "X" + SoulMath.DevolverElNumeroConComas(registro["cantidad"])
		producto_escena.get_node("Cartel/imagen/TextureRect").texture = load(registro["ruta_imagen"])
		Productos.get_node("GridContainer").add_child(producto_escena)
