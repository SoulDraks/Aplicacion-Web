extends Control
@onready var Productos := $Productos
@onready var Pedidos := $Pedidos
@onready var Clientes := $Clientes
@onready var Panelcito := $Panel2
@onready var Oscurecer := $Panel2/AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	remove_child(Panelcito)
	await get_tree().create_timer(0.1).timeout
	get_tree().root.add_child(Panelcito)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_productos_mouse_entered():
	Productos.get_node("AnimationPlayer").play("brillar")

func _on_productos_mouse_exited():
	var Animacion: AnimationPlayer = Productos.get_node("AnimationPlayer")
	Animacion.play("RESET")

func _on_pedidos_mouse_entered():
	Pedidos.get_node("AnimationPlayer").play("brillar")

func _on_pedidos_mouse_exited():
	var Animacion: AnimationPlayer = Pedidos.get_node("AnimationPlayer")
	Animacion.play("RESET")

func _on_clientes_mouse_entered():
	Clientes.get_node("AnimationPlayer").play("brillar")

func _on_clientes_mouse_exited():
	var Animacion: AnimationPlayer = Clientes.get_node("AnimationPlayer")
	Animacion.play("RESET")

func _on_productos_pressed():
	var Productos_Escena = preload("res://Scenes/productos.tscn").instantiate()
	Oscurecer.play("oscurecer")
	await Oscurecer.animation_finished
	get_tree().root.add_child(Productos_Escena)
	Panelcito.move_to_front()
	Oscurecer.play_backwards("oscurecer")
	await Oscurecer.animation_finished
	Panelcito.visible = false
	visible = false

func inhabilitar():
	await Oscurecer.animation_finished
	Panelcito.visible = false

func _on_clientes_pressed():
	var Clientes_Escena = preload("res://Scenes/Clientes.tscn").instantiate()
	Oscurecer.play("oscurecer")
	await Oscurecer.animation_finished
	get_tree().root.add_child(Clientes_Escena)
	Panelcito.move_to_front()
	Oscurecer.play_backwards("oscurecer")
	await Oscurecer.animation_finished
	Panelcito.visible = false
	visible = false

func _on_pedidos_pressed():
	var Pedidos_Escena = preload("res://Scenes/Pedidos.tscn").instantiate()
	Oscurecer.play("oscurecer")
	await Oscurecer.animation_finished
	get_tree().root.add_child(Pedidos_Escena)
	Panelcito.move_to_front()
	Oscurecer.play_backwards("oscurecer")
	await Oscurecer.animation_finished
	Panelcito.visible = false
	visible = false
