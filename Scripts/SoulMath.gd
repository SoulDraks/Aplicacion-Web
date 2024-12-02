class_name SoulMath

static var point_this = Vector2(0, 0)
static var point_target = Vector2(0, 0)
static var this_distance = 0
static var Xd = 0
static var Yd = 0
static var radAngle = 0
static var rotation_result = 0

static func calculate_rotation(source_x, source_y, target_x, target_y):
	Xd = target_x - source_x
	Yd = target_y - source_y
	radAngle = atan2(Yd, Xd)
	rotation_result = int(radAngle * 180 / PI + 90)
	if rotation_result > 180:
		rotation_result = -180 + (rotation_result - 180)
	return rotation_result

static func move_me(this_mc, this_rotation, this_speed):
	if this_rotation > 180:
		this_mc.position.y += this_speed * cos(deg_to_rad(this_rotation))
		this_mc.position.x -= this_speed * sin(deg_to_rad(this_rotation))
	else:
		this_mc.position.y -= this_speed * cos(deg_to_rad(this_rotation))
		this_mc.position.x += this_speed * sin(deg_to_rad(this_rotation))

static func move_me2(this_axis, this_rotation, this_speed):
	if this_rotation > 180:
		if this_axis == "y":
			return this_speed * cos(deg_to_rad(this_rotation))
		elif this_axis == "x":
			return - this_speed * sin(deg_to_rad(this_rotation))
	else:
		if this_axis == "y":
			return - this_speed * cos(deg_to_rad(this_rotation))
		elif this_axis == "x":
			return this_speed * sin(deg_to_rad(this_rotation))

static func get_position(startX, startY, this_rotation, this_distance, this_axis):
	if this_axis == "x":
		if this_rotation > 180:
			return startX - this_distance * sin(deg_to_rad(this_rotation))
		else:
			return startX + this_distance * sin(deg_to_rad(this_rotation))
	elif this_axis == "y":
		if this_rotation > 180:
			return startY + this_distance * cos(deg_to_rad(this_rotation))
		else:
			return startY - this_distance * cos(deg_to_rad(this_rotation))

static func get_distance(mc_1, mc_2):
	point_this.x = mc_1.position.x
	point_this.y = mc_1.position.y
	point_target.x = mc_2.position.x
	point_target.y = mc_2.position.y
	this_distance = point_this.distance_to(point_target)
	return this_distance

static func get_distance2(mc_1_x, mc_1_y, mc_2_x, mc_2_y):
	point_this.x = mc_1_x
	point_this.y = mc_1_y
	point_target.x = mc_2_x
	point_target.y = mc_2_y
	this_distance = point_this.distance_to(point_target)
	return this_distance

static func NumeroRandom(min: int, max: int):
	return randi() % (max - min + 1) + min

static func NumeroRandom2(min: float, max: float):
	return min + (max - min) * randf()

static func getAxisDistance(inStart, inEnd):
	var result = inStart - inEnd
	if inStart < inEnd:
		result *= -1
	return result

static func getRotDistance(inRot1, inRot2):
	var result = 0
	if inRot1 < inRot2 - 180:
		inRot1 += 360
	if inRot1 > inRot2 + 180:
		inRot1 -= 360
	result = inRot1 - inRot2
	if result < 0:
		result *= -1
	return result

static func mezclarArray(enArray):
	var Arraymezclado: Array = []
	var Arrayoriginal = enArray.duplicate()
	while Arrayoriginal.size() > 0:
		var index = NumeroRandom(0, Arrayoriginal.size() - 1)
		Arraymezclado.append(Arrayoriginal[index])
		Arrayoriginal.remove_at(index)
	return Arraymezclado

static func ElementoRandom(inArray):
	return inArray[NumeroRandom(0, inArray.size() - 1)]

static func removeElement(inElement, inArray):
	var index = inArray.find(inElement)
	if index != -1:
		inArray.remove(index)

static func DevolverElNumeroConComas(Num):
	var strNum = str(Num)
	var resultado: String = ""
	var cuenta: int = 0
	var largo = len(strNum)
	while cuenta <= largo:
		if largo <= 3:
			resultado = strNum + resultado
			break
		resultado = "," + strNum.substr(largo - 3, 3) + resultado
		strNum = strNum.substr(0, largo - 3)
		largo -= 3
	return resultado

static func CalcularProbabilidad(Probabilidad):
	if NumeroRandom2(0.0, 100.0) >= Probabilidad:
		return true
	else:
		return false
