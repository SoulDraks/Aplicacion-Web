extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	await MySQLConnector.query_with_bindings("""
		SELECT * FROM stock.productos
		WHERE nombre = ?;
	""", [$TextEdit.text])
	var Datos = MySQLConnector.query_result
	$Label.text = "Precio: " + str(Datos[0]["precio"])
