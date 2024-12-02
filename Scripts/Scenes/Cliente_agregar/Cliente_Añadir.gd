extends Control
@onready var ID_Cliente := $"Texto/ID Cliente"
@onready var Nombre := $Texto/Nombre2
@onready var Email := $Texto/Email2
@onready var Telefono := $Texto/Telefono2
@onready var Fecha_de_Registro := {
	Dia = $Texto/Dia,
	Mes = $Texto/Mes,
	Año = $"Texto/Año"
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _reset():
	ID_Cliente.text = "Cliente #"
	Nombre.text = ""
	Email.text = ""
	Telefono.text = ""
	Fecha_de_Registro.Dia.text = ""
	Fecha_de_Registro.Mes.text = ""
	Fecha_de_Registro.Año.text = ""
