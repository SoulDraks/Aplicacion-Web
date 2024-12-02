extends Control
@onready var Productos := $Productos
@onready var Oscurecer := $Panel2/AnimationPlayer
@onready var Borrar := $Borrar
@onready var Borrar_Animaciones := $Borrar/AnimationPlayer
@onready var Si := $Borrar/Si
@onready var No := $Borrar/No
@onready var Añadir_Producto := $"Añadir Producto"
@onready var Añadir := $"Añadir"
@onready var Producto_Añadir := $"Producto_Añadir"
signal Respuesta
var Eliminar := false

func _ready():
	init()
	Si.disabled = true
	No.disabled = true
	Añadir.disabled = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func init():
	var consulta_id = MySQLConnector.query("""
		SELECT * FROM productos
		ORDER BY id_producto ASC;
	""")
	while not MySQLConnector.querys.has(consulta_id):
		await MySQLConnector.query_finished
	var resultado = MySQLConnector.querys[consulta_id]
	for registro in resultado:
		var producto_escena = preload("res://Scenes/producto.tscn").instantiate()
		var Textos = producto_escena.get_node("Texto").get_children()
		Textos[0].text = registro["nombre"]
		Textos[1].text += registro["descripcion"]
		Textos[3].text = "Precio: $" + SoulMath.DevolverElNumeroConComas(registro["precio"])
		Textos[4].text = "X" + SoulMath.DevolverElNumeroConComas(registro["cantidad_stock"])
		producto_escena.get_node("Cartel/imagen/TextureRect").texture = load(registro["ruta_imagen"])
		Productos.get_node("GridContainer").add_child(producto_escena)
		producto_escena.Editar.connect(_on_editar)
		producto_escena.Eliminar.connect(_on_eliminar)
		producto_escena.owner = Productos
		producto_escena.Ruta = registro["ruta_imagen"]

func _on_editar(Self: Control):
	Oscurecer.play("oscurecer")
	var Posicion_Original = Self.global_position
	var Posicion_Original_Del_Añadir = Producto_Añadir.global_position
	var tween = get_tree().create_tween()
	var center_position = get_viewport().get_visible_rect().size
	var final_position = (center_position - Self.get_node("Cartel").size) / 2
	tween.tween_property(Self, "global_position", final_position, 1.5)\
	.set_ease(Tween.EASE_IN_OUT)\
	.set_trans(Tween.TRANS_CUBIC)
	Self.z_index = 2
	await tween.finished
	Producto_Añadir.modulate = Color.WHITE
	Producto_Añadir.global_position = final_position
	Producto_Añadir.visible = true
	var Textos = Self.get_node("Texto").get_children()
	Producto_Añadir.Nombre.text = Textos[0].text
	Producto_Añadir.Descripcion.text = Textos[1].text
	Producto_Añadir.Categoria.selected = Producto_Añadir.get_index_from_text(Textos[2].text)
	Producto_Añadir.Precio.text = Textos[3].text.erase(0, 9)
	Producto_Añadir.Cantidad.text = Textos[4].text.erase(0, 1)
	Producto_Añadir.get_node("Cartel/imagen/TextureRect").texture = Self.get_node("Cartel/imagen/TextureRect").texture
	Self.visible = false
	Añadir.visible = true
	Añadir.disabled = false
	Añadir.get_node("Texto").text = "Guardar"
	
	await Añadir.pressed
	
	var otro_tween = get_tree().create_tween()
	otro_tween.tween_property(Producto_Añadir, "global_position", Posicion_Original, 1.5)\
	.set_ease(Tween.EASE_IN_OUT)\
	.set_trans(Tween.TRANS_CUBIC)
	await otro_tween.finished
	var consulta_id = MySQLConnector.query("""
	UPDATE productos
	SET nombre = ?, descripcion = ?, precio = ?, cantidad_stock = ?, ruta_imagen = ?
	WHERE nombre = ?;
	""", [Producto_Añadir.Nombre.text, Producto_Añadir.Descripcion.text.erase(0, 13), int(Producto_Añadir.Precio.text), int(Producto_Añadir.Cantidad.text), Self.Ruta, Textos[0].text])
	while not MySQLConnector.querys.has(consulta_id):
		await MySQLConnector.query_finished
	Textos[0].text = Producto_Añadir.Nombre.text
	Textos[1].text = Producto_Añadir.Descripcion.text
	Textos[2].text = Producto_Añadir.Categoria.get_item_text(Producto_Añadir.Categoria.selected)
	Textos[3].text = "$" + SoulMath.DevolverElNumeroConComas(int(Producto_Añadir.Precio.text))
	Textos[4].text = "X" + SoulMath.DevolverElNumeroConComas(int(Producto_Añadir.Cantidad.text))
	Producto_Añadir._reset()
	Producto_Añadir.visible = false
	tween.kill()
	otro_tween.kill()
	Self.z_index = 0
	Self.visible = true
	Oscurecer.play_backwards("oscurecer")
	await Oscurecer.animation_finished
	Oscurecer.get_parent().visible = false
	Añadir.visible = false
	Añadir.get_node("Texto").text = "Añadir"
	Producto_Añadir.global_position = Posicion_Original_Del_Añadir

func _on_eliminar(Self: Control):
	Borrar.get_node("Descripcion").text = "¿Esta seguro que desea eliminar el producto '%s'?" % Self.get_node("Texto/Nombre").text
	Oscurecer.play("oscurecer")
	Borrar_Animaciones.play("aparecer")
	await Oscurecer.animation_finished
	Si.disabled = false
	No.disabled = false
	await Respuesta
	if Eliminar:
		var consulta_id = MySQLConnector.query("""
		DELETE FROM productos WHERE nombre = ?;
		""", [Self.get_node("Texto/Nombre").text])
		await MySQLConnector.await_query(consulta_id)
		Self.queue_free()
	Borrar_Animaciones.play_backwards("aparecer")
	Oscurecer.play_backwards("oscurecer")
	await Oscurecer.animation_finished
	Oscurecer.get_parent().visible = false
	Borrar.visible = false

func _on_si_pressed():
	Eliminar = true
	Respuesta.emit()

func _on_no_pressed():
	Eliminar = false
	Respuesta.emit()

func _on_añadir_producto_pressed():
	var Animaciones: AnimationPlayer = Producto_Añadir.get_node("AnimationPlayer")
	Oscurecer.play("oscurecer")
	Animaciones.play("aparecer")
	await Oscurecer.animation_finished
	Añadir.disabled = false
	Añadir.visible = true
	
	await Añadir.pressed
	
	var Nuevo_Producto = preload("res://Scenes/producto.tscn").instantiate()
	var Textos = Nuevo_Producto.get_node("Texto").get_children()
	Textos[0].text = Producto_Añadir.Nombre.text
	Textos[1].text = Producto_Añadir.Descripcion.text
	Textos[2].text = Producto_Añadir.Categoria.get_item_text(Producto_Añadir.Categoria.selected)
	Textos[3].text = "$" + SoulMath.DevolverElNumeroConComas(int(Producto_Añadir.Precio.text))
	Textos[4].text = "X" + SoulMath.DevolverElNumeroConComas(int(Producto_Añadir.Cantidad.text))
	var consulta_id = MySQLConnector.query("""
	INSERT INTO productos (nombre, descripcion, precio, cantidad_stock, ruta_imagen)
	VALUES (?, ?, ?, ?, ?);
	""", [Producto_Añadir.Nombre.text, Producto_Añadir.Descripcion.text.erase(0, 13), int(Producto_Añadir.Precio.text), int(Producto_Añadir.Cantidad.text), ""])
	await MySQLConnector.await_query(consulta_id)
	Animaciones.play_backwards("aparecer")
	Oscurecer.play_backwards("oscurecer")
	await Oscurecer.animation_finished
	Oscurecer.get_parent().visible = false
	Producto_Añadir.visible = false
	Producto_Añadir._reset()
	Añadir.visible = false
	Productos.get_node("GridContainer").add_child(Nuevo_Producto)

func _input(event):
	if event is InputEventKey:
		if event.keycode == KEY_ESCAPE:
			var Main = get_tree().root.get_node("Main")
			var Panelcito = get_tree().root.get_node("Panel2")
			var Oscurecer_Raiz = Panelcito.get_node("AnimationPlayer")
			Panelcito.visible = true
			Oscurecer_Raiz.play("oscurecer")
			await Oscurecer_Raiz.animation_finished
			queue_free()
			Panelcito.move_to_front()
			Main.visible = true
			Oscurecer_Raiz.play_backwards("oscurecer")
			Main.inhabilitar()
