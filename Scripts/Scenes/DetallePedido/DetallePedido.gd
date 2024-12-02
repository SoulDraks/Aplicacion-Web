extends Control
@onready var Producto_Elegir := $Opciones/Producto_Elegir
@onready var Cantidad_Texto := $Opciones/Cantidad_Texto
var Items: Array[Dictionary] = []
var ready_called: bool = false
var id: int = -1

func _ready():
	if not ready_called:
		ready_called = true
		init()

func init():
	ready_called = true
	var Opciones_Productos := $Opciones/Producto_Elegir
	var consulta_id = MySQLConnector.query("""
	SELECT id_producto, nombre, precio FROM productos;
	""")
	while not MySQLConnector.querys.has(consulta_id):
		await MySQLConnector.query_finished
	var Resultado = MySQLConnector.querys[consulta_id]
	for i in range(Resultado.size()):
		Opciones_Productos.add_item(Resultado[i]["nombre"], i)
		var Informacion_producto = {
			"id": Resultado[i]["id_producto"],
			"nombre": Resultado[i]["nombre"],
			"precio": Resultado[i]["precio"]
		}
		Items.append(Informacion_producto)

func _process(delta):
	pass

func _on_cerrar_pressed():
	if get_parent().get_child_count() > 1:
		queue_free()

func get_index_from_text(text: String, node: OptionButton):
	for i in range(node.get_item_count()):  # Recorre todos los ítems
		if node.get_item_text(i) == text:  # Compara el texto
			return i  # Devuelve el índice si lo encuentra
	return -1  # Devuelve -1 si no encuentra el tex
