extends Node2D

@onready var node_bodyBG = $BodyBG
@onready var node_propellors = $BodyBG/PropellorsBack
@onready var node_body = $BodyBG/Body
@onready var node_gunMountBG = $BodyBG/GunMountBG
@onready var node_gun = $BodyBG/GunMountBG/Gun
@onready var node_gunBG = $BodyBG/GunMountBG/Gun/GunBG

func visual_tick(facingPos, attackPos):
	var relativeFace = facingPos - global_position
	var mousePosX = sigmoid(relativeFace.x, 1.0, 0.03)
	var mousePosY = sigmoid(relativeFace.y, 1.0, 0.05)
	
	node_body.position = Vector2((mousePosX * 4.0) - 2.0, (mousePosY * 3.0) - 1.5)
	node_propellors.position = Vector2((mousePosX * -2.0) + 1.0, (mousePosY * -2.0) + 1.0)
	node_gunMountBG.position = (-global_position.direction_to(attackPos)) + Vector2(0,4)
	node_gun.look_at(attackPos)
	node_gun.position = global_position.direction_to(attackPos)
	node_gunBG.position.y = global_position.direction_to(attackPos).x
	
func sigmoid(x, height = 1.0, steepness = 1.0):
	return height / (1 + 2.71828 ** (-steepness * x))
