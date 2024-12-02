extends Control
@onready var Productos := $Productos
@onready var Oscurecer := $Panel2/AnimationPlayer
@onready var Borrar := $Borrar
@onready var Borrar_Animaciones := $Borrar/AnimationPlayer
@onready var Si := $Borrar/Si
@onready var No := $Borrar/No
@onready var Añadir_Pedido := $"Añadir Pedido"
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
		SELECT * FROM clientes 
		ORDER BY id_cliente ASC;
	""")
	while not MySQLConnector.querys.has(consulta_id):
		await MySQLConnector.query_finished
	var resultado = MySQLConnector.querys[consulta_id]
	for registro in resultado:
		var producto_escena = preload("res://Scenes/Cliente.tscn").instantiate()
		var Textos = producto_escena.get_node("Texto").get_children()
		var Fechita: String = registro["fecha_registro"]
		Textos[0].text = "Cliente #" + str(registro["id_cliente"])
		Textos[1].text = "Nombre: " + registro["nombre"]
		Textos[2].text = "Email: " + str(registro["email"])
		Textos[3].text = "Telefono: " + str(registro["telefono"])
		Textos[4].text = "Fecha De Registro: %s-%s-%s" % [Fechita.substr(8, 2), Fechita.substr(5, 2), Fechita.substr(0, 4)]
		producto_escena.Editar.connect(_on_editar)
		producto_escena.Eliminar.connect(_on_eliminar)
		Productos.get_node("GridContainer").add_child(producto_escena)

func _on_editar(Self: Control):
	Oscurecer.play("oscurecer")
	var Posicion_Original2 = Producto_Añadir.global_position
	var Posicion_Original = Self.global_position
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
	Producto_Añadir.ID_Cliente.text = Textos[0].text
	Producto_Añadir.Nombre.text = Textos[1].text.erase(0, 8)
	Producto_Añadir.Email.text = Textos[2].text.erase(0, 7)
	Producto_Añadir.Telefono.text = Textos[3].text.erase(0, 10)
	Producto_Añadir.Fecha_de_Registro.Dia.text = Textos[4].text.substr(19, 2)
	Producto_Añadir.Fecha_de_Registro.Mes.text = Textos[4].text.substr(19 + 3, 2)
	Producto_Añadir.Fecha_de_Registro.Año.text = Textos[4].text.substr(19 + 6, 4)
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
	UPDATE clientes
	SET nombre = ?, email = ?, telefono = ?, fecha_registro = ?
	WHERE nombre = ?;
	""", [Producto_Añadir.Nombre.text, Producto_Añadir.Email.text, Producto_Añadir.Telefono.text, "%s-%s-%s 00:00:00" % [Producto_Añadir.Fecha_de_Registro.Año.text, Producto_Añadir.Fecha_de_Registro.Mes.text, Producto_Añadir.Fecha_de_Registro.Dia.text], Textos[1].text.erase(0, 8)])
	while not MySQLConnector.querys.has(consulta_id):
		await MySQLConnector.query_finished
	Textos[0].text = Producto_Añadir.ID_Cliente.text
	Textos[1].text = "Nombre: " + Producto_Añadir.Nombre.text
	Textos[2].text = "Email: " + Producto_Añadir.Email.text
	Textos[3].text = "Telefono: " + Producto_Añadir.Telefono.text
	Textos[4].text = "Fecha de Registro: %s-%s-%s" % [Producto_Añadir.Fecha_de_Registro.Dia.text, Producto_Añadir.Fecha_de_Registro.Mes.text, Producto_Añadir.Fecha_de_Registro.Año.text]
	Producto_Añadir._reset()
	Producto_Añadir.visible = false
	tween.kill()
	otro_tween.kill()
	Self.z_index = 0
	Self.visible = true
	Añadir.get_node("Texto").text = "Añadir"
	Añadir.visible = false
	Oscurecer.play_backwards("oscurecer")
	await Oscurecer.animation_finished
	Oscurecer.get_parent().visible = false
	Producto_Añadir.global_position = Posicion_Original2

func _on_eliminar(Self: Control):
	Borrar.get_node("Descripcion").text = "¿Esta seguro que desea eliminar al cliente '%s'? Todos sus pedidos se borraran." % Self.get_node("Texto/Nombre").text.erase(0, 8)
	Oscurecer.play("oscurecer")
	Borrar_Animaciones.play("aparecer")
	await Oscurecer.animation_finished
	Si.disabled = false
	No.disabled = false
	await Respuesta
	if Eliminar:
		var consulta_id = MySQLConnector.query("""
		DELETE FROM clientes WHERE nombre = ?;
		""", [Self.get_node("Texto/Nombre").text.erase(0, 8)])
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

func _on_añadir_pedido_pressed():
	var consulta_id = MySQLConnector.query("""
	SELECT AUTO_INCREMENT
	FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_SCHEMA = 'tiendita'
	  AND TABLE_NAME = 'clientes';
	""")
	while not MySQLConnector.querys.has(consulta_id):
		await MySQLConnector.query_finished
	var resultado = MySQLConnector.querys[consulta_id].duplicate(true)
	Producto_Añadir.ID_Cliente.text = "Cliente #" + str(resultado[0]["AUTO_INCREMENT"])
	var Animaciones: AnimationPlayer = Producto_Añadir.get_node("AnimationPlayer")
	Oscurecer.play("oscurecer")
	Animaciones.play("aparecer")
	await Oscurecer.animation_finished
	Añadir.disabled = false
	Añadir.visible = true
	
	await Añadir.pressed
	
	var Nuevo_Producto = preload("res://Scenes/Cliente.tscn").instantiate()
	var Textos = Nuevo_Producto.get_node("Texto").get_children()
	Textos[0].text = Producto_Añadir.ID_Cliente.text
	Textos[1].text = "Nombre: " + Producto_Añadir.Nombre.text
	Textos[2].text = "Email: " + Producto_Añadir.Email.text
	Textos[3].text = "Telefono: " + Producto_Añadir.Telefono.text
	Textos[4].text = "Fecha de Registro: %s-%s-%s" % [Producto_Añadir.Fecha_de_Registro.Dia.text, Producto_Añadir.Fecha_de_Registro.Mes.text, Producto_Añadir.Fecha_de_Registro.Año.text]
	consulta_id = MySQLConnector.query("""
	INSERT INTO clientes (nombre, email, telefono, fecha_registro)
	VALUES (?, ?, ?, ?);
	""", [Producto_Añadir.Nombre.text, Producto_Añadir.Email.text, Producto_Añadir.Telefono.text, "%s-%s-%s 00:00:00" % [Producto_Añadir.Fecha_de_Registro.Año.text, Producto_Añadir.Fecha_de_Registro.Mes.text, Producto_Añadir.Fecha_de_Registro.Dia.text]])
	while not MySQLConnector.querys.has(consulta_id):
		await MySQLConnector.query_finished
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
