extends Button


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_pressed():
	var N1 = 0
	var N2 = 0
	var Total = 0
	N1 = float(get_parent().get_node("Num1").text)
	N2 = float(get_parent().get_node("Num2").text)
	Total = N1 + N2
	print("El total es: ", Total)
