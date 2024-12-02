extends Control
@onready var ID_Pedido := $"Texto/ID Pedido"
@onready var Fecha := {
	Dia = $Texto/Dia,
	Mes = $Texto/Mes,
	Año = $"Texto/Año"
}
@onready var Total := $Texto/Total
@onready var Estado := $Texto/Estado2
@onready var Cliente := $Texto/Cliente
@onready var Detalles_Pedido := $Detalles_Pedido
@onready var Contenedor_Detalles_Pedido := $"Detalles_Pedido/Detalles Pedido/VBoxContainer"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _reset():
	ID_Pedido.text = "Pedito #"
	Fecha.Dia.text = ""
	Fecha.Mes.text = ""
	Fecha.Año.text = ""

func get_index_from_text(text: String):
	for i in range(Cliente.get_item_count()):  # Recorre todos los ítems
		if Cliente.get_item_text(i) == text:  # Compara el texto
			return i  # Devuelve el índice si lo encuentra
	return -1  # Devuelve -1 si no encuentra el tex

func _on_texture_button_pressed():
	var precio := 0
	for producto in Detalles_Pedido.get_node("Detalles Pedido/VBoxContainer").get_children():
		var nodo_producto_elegido = producto.get_node("Opciones/Producto_Elegir")
		var consulta_id = MySQLConnector.query("""
		SELECT precio FROM productos WHERE nombre = ?;
		""", [nodo_producto_elegido.get_item_text(nodo_producto_elegido.selected)])
		var resultado = await MySQLConnector.await_query(consulta_id)
		precio += resultado[0]["precio"] * int(producto.get_node("Opciones/Cantidad_Texto").text)
		Total.text = "Total: $" + str(precio)
	Detalles_Pedido.visible = false

func _on_detalles_pressed():
	Detalles_Pedido.visible = true

func _on_añadir_producto_pressed():
	var DetallePedido = preload("res://Scenes/DetallePedido_Añadir.tscn").instantiate()
	Contenedor_Detalles_Pedido.add_child(DetallePedido)
