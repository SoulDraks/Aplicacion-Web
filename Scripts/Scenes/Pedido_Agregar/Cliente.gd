extends OptionButton
var clientes: Array[Dictionary] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	var consulta_id = MySQLConnector.query("SELECT id_cliente, nombre FROM clientes;")
	var resultado = await MySQLConnector.await_query(consulta_id)
	for i in range(resultado.size()):
		var cliente = resultado[i]
		var datos_cliente = {"id": cliente["id_cliente"], "nombre": cliente["nombre"]}
		add_item(cliente["nombre"], i)
		clientes.append(datos_cliente)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
