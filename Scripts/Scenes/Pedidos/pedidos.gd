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
@onready var Cartel_DetallesPedido := $Cartel_DetallesPedido
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
		SELECT * FROM pedidos
		ORDER BY id_pedido ASC;
	""")
	while not MySQLConnector.querys.has(consulta_id):
		await MySQLConnector.query_finished
	var resultado = MySQLConnector.querys[consulta_id]
	for registro in resultado:
		var producto_escena = preload("res://Scenes/pedido.tscn").instantiate()
		var Textos = producto_escena.get_node("Texto").get_children()
		var Fechita = registro["fecha_pedido"]
		consulta_id = MySQLConnector.query("""
			SELECT nombre FROM clientes
			WHERE id_cliente = ?;
		""", [registro["id_cliente"]])
		while not MySQLConnector.querys.has(consulta_id):
			await MySQLConnector.query_finished
		var resultado2 = MySQLConnector.querys[consulta_id]
		var nombre_cliente = resultado2[0]["nombre"]
		Textos[0].text = "Pedido #" + str(registro["id_pedido"])
		Textos[1].text = "Fecha: %s-%s-%s" % [Fechita.substr(8, 2), Fechita.substr(5, 2), Fechita.substr(0, 4)]
		Textos[2].text = "Total: $" + SoulMath.DevolverElNumeroConComas(registro["total"])
		Textos[3].text = "Estado: " + registro["estado"]
		Textos[4].text = "Cliente: " + nombre_cliente
		Productos.get_node("GridContainer").add_child(producto_escena)
		producto_escena.Editar.connect(_on_editar)
		producto_escena.Borrar.connect(_on_eliminar)
		producto_escena.Detalles.connect(_on_detalles)

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
	Producto_Añadir.ID_Pedido.text = Textos[0].text
	Producto_Añadir.Fecha.Dia.text = Textos[1].text.substr(7, 2)
	Producto_Añadir.Fecha.Mes.text = Textos[1].text.substr(10, 2)
	Producto_Añadir.Fecha.Año.text = Textos[1].text.substr(13, 4)
	Producto_Añadir.Total.text = Textos[2].text
	Producto_Añadir.Estado.text = Textos[3].text.erase(0, 8)
	Producto_Añadir.Cliente.text = Textos[4].text.erase(0, 9)
	var consulta_id = MySQLConnector.query("""
	SELECT id_detalle, id_producto, cantidad FROM detallespedido WHERE id_pedido = ?;
	""", [int(Textos[0].text.erase(0, 8))])
	while not MySQLConnector.querys.has(consulta_id):
		await MySQLConnector.query_finished
	var Resultado = MySQLConnector.querys[consulta_id]
	var Contenedor_Productos = Producto_Añadir.Detalles_Pedido.get_node("Detalles Pedido/VBoxContainer")
	for Nodo in Contenedor_Productos.get_children():
		Nodo.queue_free()
	for Registro in Resultado:
		var DetallePedido = preload("res://Scenes/DetallePedido_Añadir.tscn").instantiate()
		Producto_Añadir.Contenedor_Detalles_Pedido.add_child(DetallePedido)
		consulta_id = MySQLConnector.query("""
		SELECT nombre FROM productos WHERE id_producto = ?;
		""", [Registro["id_producto"]])
		var Resultado2 = await MySQLConnector.await_query(consulta_id)
		var Nombre_Producto = Resultado2[0]["nombre"]
		DetallePedido.Producto_Elegir.selected = DetallePedido.get_index_from_text(Nombre_Producto, DetallePedido.Producto_Elegir)
		DetallePedido.Cantidad_Texto.text = str(Registro["cantidad"])
		DetallePedido.id = Registro["id_detalle"]
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
	var nombre_cliente = Producto_Añadir.Cliente.get_item_text(Producto_Añadir.Cliente.selected)
	consulta_id = MySQLConnector.query("SELECT id_cliente FROM clientes WHERE nombre = ?;", [nombre_cliente])
	var resultado = await MySQLConnector.await_query(consulta_id)
	var id_cliente = resultado[0]["id_cliente"]
	var id_pedido = int(Producto_Añadir.ID_Pedido.text.erase(0, 8))
	consulta_id = MySQLConnector.query("""
	UPDATE pedidos
	SET id_cliente = ?, fecha_pedido = ?, total = ?, estado = ?
	WHERE id_pedido = ?;
	""", [id_cliente, "%s-%s-%s 00:00:00" % [Producto_Añadir.Fecha.Año.text, Producto_Añadir.Fecha.Mes.text, Producto_Añadir.Fecha.Dia.text], int(Producto_Añadir.Total.text.erase(0, 8)), Producto_Añadir.Estado.get_item_text(Producto_Añadir.Estado.selected), id_pedido])
	await MySQLConnector.await_query(consulta_id)
	for producto in Producto_Añadir.Contenedor_Detalles_Pedido.get_children():
		if producto.id != -1:
			MySQLConnector.query("""
			UPDATE detallespedido
			SET id_pedido = ?, id_producto = ?, cantidad = ?, subtotal = ?
			WHERE id_detalle = ?;
			""", [id_pedido, producto.Items[producto.Producto_Elegir.selected]["id"], int(producto.Cantidad_Texto.text), producto.Items[producto.Producto_Elegir.selected]["precio"] * int(producto.Cantidad_Texto.text), producto.id])
		else:
			MySQLConnector.query("""
			INSERT INTO detallespedido(id_pedido, id_producto, cantidad, subtotal)
			VALUES (?, ?, ?, ?);
			""", [id_pedido, producto.Items[producto.Producto_Elegir.selected]["id"], int(producto.Cantidad_Texto.text), producto.Items[producto.Producto_Elegir.selected]["precio"] * int(producto.Cantidad_Texto.text)])
	Textos[0].text = Producto_Añadir.ID_Pedido.text
	Textos[1].text = "Fecha: %s-%s-%s" % [Producto_Añadir.Fecha.Dia.text, Producto_Añadir.Fecha.Mes.text, Producto_Añadir.Fecha.Año.text]
	Textos[2].text = Producto_Añadir.Total.text
	Textos[3].text = "Estado: " + Producto_Añadir.Estado.get_item_text(Producto_Añadir.Estado.selected)
	Textos[4].text = "Cliente: " + Producto_Añadir.Cliente.get_item_text(Producto_Añadir.Cliente.selected)
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
	Borrar.get_node("Descripcion").text = "¿Esta seguro que desea eliminar el pedido $%s?" % Self.get_node("Texto/ID Pedido").text.erase(0, 8)
	Oscurecer.play("oscurecer")
	Borrar_Animaciones.play("aparecer")
	await Oscurecer.animation_finished
	Si.disabled = false
	No.disabled = false
	await Respuesta
	if Eliminar:
		var consulta_id = MySQLConnector.query("""
		DELETE FROM pedidos WHERE id_pedido = ?;
		""", [Self.get_node("Texto/ID Pedido").text.erase(0, 8)])
		while not MySQLConnector.querys.has(consulta_id):
			await MySQLConnector.query_finished
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
	var consulta_id = MySQLConnector.query("""
	SELECT AUTO_INCREMENT
	FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_SCHEMA = 'tiendita'
	  AND TABLE_NAME = 'pedidos';
	""")
	var resultado = await MySQLConnector.await_query(consulta_id)
	var id_pedido = resultado[0]["AUTO_INCREMENT"]
	Producto_Añadir.ID_Pedido.text += str(id_pedido)
	var Animaciones: AnimationPlayer = Producto_Añadir.get_node("AnimationPlayer")
	Oscurecer.play("oscurecer")
	Animaciones.play("aparecer")
	await Oscurecer.animation_finished
	Añadir.disabled = false
	Añadir.visible = true
	for nodo in Producto_Añadir.Contenedor_Detalles_Pedido.get_children():
		nodo.queue_free()
	Producto_Añadir.Contenedor_Detalles_Pedido.add_child(preload("res://Scenes/DetallePedido_Añadir.tscn").instantiate())
	
	await Añadir.pressed
	
	var Nuevo_Producto = preload("res://Scenes/pedido.tscn").instantiate()
	var Textos = Nuevo_Producto.get_node("Texto").get_children()
	Textos[0].text = Producto_Añadir.ID_Pedido.text
	Textos[1].text = "Fecha: %s-%s-%s" % [Producto_Añadir.Fecha.Dia.text, Producto_Añadir.Fecha.Mes.text, Producto_Añadir.Fecha.Año.text]
	Textos[2].text = Producto_Añadir.Total.text
	Textos[3].text = "Estado: " + Producto_Añadir.Estado.get_item_text(Producto_Añadir.Estado.selected)
	Textos[4].text = "Cliente: " + Producto_Añadir.Cliente.get_item_text(Producto_Añadir.Cliente.selected)
	consulta_id = MySQLConnector.query("""
	INSERT INTO pedidos (id_cliente, fecha_pedido, total, estado)
	VALUES (?, ?, ?, ?);
	""", [Producto_Añadir.Cliente.clientes[Producto_Añadir.Cliente.selected]["id"], "%s-%s-%s 00:00:00" % [Producto_Añadir.Fecha.Año.text, Producto_Añadir.Fecha.Mes.text, Producto_Añadir.Fecha.Dia.text], int(Producto_Añadir.Total.text.erase(0, 8)), Producto_Añadir.Estado.get_item_text(Producto_Añadir.Estado.selected)])
	await MySQLConnector.await_query(consulta_id)
	for producto in Producto_Añadir.Contenedor_Detalles_Pedido.get_children():
		MySQLConnector.query("""
		INSERT INTO detallespedido(id_pedido, id_producto, cantidad, subtotal)
		VALUES (?, ?, ?, ?);
		""", [id_pedido, producto.Items[producto.Producto_Elegir.selected]["id"], int(producto.Cantidad_Texto.text), producto.Items[producto.Producto_Elegir.selected]["precio"] * int(producto.Cantidad_Texto.text)])
	Animaciones.play_backwards("aparecer")
	Oscurecer.play_backwards("oscurecer")
	await Oscurecer.animation_finished
	Oscurecer.get_parent().visible = false
	Producto_Añadir.visible = false
	Producto_Añadir._reset()
	Añadir.visible = false
	Productos.get_node("GridContainer").add_child(Nuevo_Producto)

func _on_detalles(Self: Control):
	Cartel_DetallesPedido.visible = true
	var consulta_id = MySQLConnector.query("SELECT id_producto, cantidad FROM detallespedido;")
	var resultado = await MySQLConnector.await_query(consulta_id)
	for nodo in Cartel_DetallesPedido.Contenedor_Detalles_Pedido.get_children():
		nodo.queue_free()
	for registro in resultado:
		var DetallePedido = preload("res://Scenes/DetallePedido.tscn").instantiate()
		Cartel_DetallesPedido.Contenedor_Detalles_Pedido.add_child(DetallePedido)
		consulta_id = MySQLConnector.query("SELECT nombre FROM productos WHERE id_producto = ?;", [registro["id_producto"]])
		var resultado2 = await MySQLConnector.await_query(consulta_id)
		DetallePedido.Producto.text += resultado2[0]["nombre"]
		DetallePedido.Cantidad.text += str(registro["cantidad"])
	var Animaciones: AnimationPlayer = Cartel_DetallesPedido.get_node("AnimationPlayer")
	Oscurecer.play("oscurecer")
	Animaciones.play("aparecer")
	await Oscurecer.animation_finished
	await Cartel_DetallesPedido.get_node("Detalles_Pedido/TextureButton").pressed
	Animaciones.play_backwards("aparecer")
	Oscurecer.play_backwards("oscurecer")
	await Oscurecer.animation_finished
	Cartel_DetallesPedido.visible = false
	Oscurecer.get_parent().visible = false

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
