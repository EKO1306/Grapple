extends CharacterBody2D


var moveSpeed = 7.0
var groundFriction = 0.95
var airFriction = 0.99

var jumpHeight = 130.0
var jumpTimer = 100.0

var gravity = 300.0
var visual_wheelSpinSpeed = 0.0
var visual_blinkTimer = 0.0

@onready var node_headBG = $Sprite/HeadBG
@onready var node_head = $Sprite/HeadBG/Head
@onready var node_eyes = $Sprite/HeadBG/Head/ScreenBG/Eyes
@onready var node_scanlines = $Sprite/HeadBG/Head/ScreenBG/Scanlines

@onready var node_bodyBG = $Sprite/BodyBG
@onready var node_body = $Sprite/BodyBG/Body
@onready var node_leg = $Sprite/Leg
@onready var node_wheel = $Sprite/Leg/Wheel

func _process(delta: float) -> void:
	var mousePos = get_global_mouse_position() - get_viewport().get_camera_2d().global_position
	var mousePosX = sigmoid(mousePos.x, 1.0, 0.03)
	var mousePosY = sigmoid(mousePos.y, 1.0, 0.05)
	node_headBG.position = Vector2((mousePosX * 0.5) - 0.5, (mousePosY * 0.25) - 20.25)
	node_head.position = Vector2(mousePosX - 1.0, mousePosY)
	node_eyes.position = Vector2((mousePosX * 4.0) - 2.0, (mousePosY * 2.0) - 1.0)
	
	node_body.position = Vector2((mousePosX) - 1.0, mousePosY - 0.5)
	node_leg.position.y = sigmoid(-velocity.y, 4.0, 0.03) - 4
	$Sprite.rotation_degrees = sigmoid(-velocity.x, 20.0, 0.01) - 10.0
	
	if is_on_floor():
		visual_wheelSpinSpeed = velocity.x / 12.0
	else:
		visual_wheelSpinSpeed *= airFriction
	node_wheel.rotation_degrees += visual_wheelSpinSpeed
	
	visual_blinkTimer += delta
	if visual_blinkTimer > 2.45:
		visual_blinkTimer -= 2.45
		node_eyes.play("Blink")
	
	node_scanlines.position.x -= delta
	if node_scanlines.position.x < -2:
		node_scanlines.position.x += 2
	print(node_scanlines.position.x)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	jumpTimer += delta
	if is_on_floor():
		jumpTimer = 0
	if Input.is_action_just_pressed("actionJump") and jumpTimer <= 0.1:
		velocity.y = -jumpHeight
		jumpTimer = 100

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("actionMoveLeft", "actionMoveRight")
	if direction:
		if is_on_floor():
			velocity.x += direction * moveSpeed
		else:
			velocity.x += direction * moveSpeed * 0.25
	if is_on_floor():
		velocity.x *= groundFriction
	else:
		velocity.x *= airFriction

	move_and_slide()

func sigmoid(x, height = 1.0, steepness = 1.0):
	return height / (1 + 2.71828 ** (-steepness * x))
