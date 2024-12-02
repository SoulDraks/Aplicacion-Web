extends Control
@onready var Nombre := $Texto/Nombre
@onready var Descripcion := $Texto/Descripcion
@onready var Categoria := $Texto/OptionButton
@onready var Cantidad := $Texto/Cantidad2
@onready var Precio := $Texto/Precio2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _reset():
	Nombre.text = "Nombre"
	Descripcion.text = "Descripcion: "
	Categoria.selected = -1
	Cantidad.text = "XX"
	Precio.text = ""

func get_index_from_text(text: String):
	for i in range(Categoria.get_item_count()):  # Recorre todos los ítems
		if Categoria.get_item_text(i) == text:  # Compara el texto
			return i  # Devuelve el índice si lo encuentra
	return -1  # Devuelve -1 si no encuentra el tex

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
