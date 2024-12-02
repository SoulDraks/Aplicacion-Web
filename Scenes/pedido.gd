extends Control
signal Editar(Self: Control)
signal Borrar(Self: Control)
signal Detalles(Self: Control)

func _ready():
	pass

func _process(delta):
	pass

func _on_editar_pressed():
	Editar.emit(self)

func _on_borrar_pressed():
	Borrar.emit(self)

func _on_detalles_pressed():
	Detalles.emit(self)
