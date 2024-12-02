extends Control
signal Editar(Self: Control)
signal Eliminar(Self: Control)
var Ruta := String()

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_editar_pressed():
	Editar.emit(self)

func _on_borrar_pressed():
	Eliminar.emit(self)
