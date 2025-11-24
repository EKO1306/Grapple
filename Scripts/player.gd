extends CharacterBody2D


var stat_moveSpeed = 7.0
var stat_groundFriction = 2.0
var stat_airFriction = 0.5
var stat_jumpHeight = 130.0
var stat_grappleAcceleration = 300.0

var jumpTimer = 100.0

var gravity = 300.0
var visual_wheelSpinSpeed = 0.0
var visual_blinkTimer = 0.0

var isGrappling = false
var grappleAnchor

@onready var node_headBG = $Sprite/HeadBG
@onready var node_head = $Sprite/HeadBG/Head
@onready var node_eyes = $Sprite/HeadBG/Head/ScreenBG/Eyes
@onready var node_scanlines = $Sprite/HeadBG/Head/ScreenBG/Scanlines

@onready var node_bodyBG = $Sprite/BodyBG
@onready var node_body = $Sprite/BodyBG/Body
@onready var node_leg = $Sprite/Leg
@onready var node_dustParticles = $Sprite/Leg/GPUParticles2D
@onready var node_wheel = $Sprite/Leg/Wheel

@onready var node_grappleLine = $Sprite/BodyBG/Body/BodyGlow/GrappleLine
@onready var node_grappleCheckArea = $GrappleCheckArea
@onready var node_grappleRaycast = $GrappleCheckArea/GrappleRaycast

func _process(delta: float) -> void:
	var mousePos = get_global_mouse_position() - global_position
	var mousePosX = sigmoid(mousePos.x, 1.0, 0.03)
	var mousePosY = sigmoid(mousePos.y, 1.0, 0.05)
	node_headBG.position = Vector2((mousePosX * 0.5) - 0.5, (mousePosY * 0.25) - 20.25)
	node_head.position = Vector2(mousePosX - 1.0, mousePosY)
	node_eyes.position = Vector2((mousePosX * 6.0) - 3.0, (mousePosY * 4.0) - 2.0)
	
	node_body.position = Vector2((mousePosX) - 1.0, mousePosY - 0.5)
	node_leg.position.y = sigmoid(-velocity.y, 4.0, 0.03) - 4
	$Sprite.rotation_degrees = sigmoid(-velocity.x, 20.0, 0.01) - 10.0
	
	if is_on_floor():
		visual_wheelSpinSpeed = velocity.x / 12.0
		node_dustParticles.amount_ratio = abs(sigmoid(velocity.x, 2.0, 0.03) - 1.0)
	else:
		visual_wheelSpinSpeed *= 1 - (stat_airFriction * delta)
		node_dustParticles.amount_ratio = 0
	node_wheel.rotation_degrees += visual_wheelSpinSpeed
	
	visual_blinkTimer += delta
	if visual_blinkTimer > 2.45:
		visual_blinkTimer -= 2.45
		node_eyes.play("Blink")
	
	node_scanlines.position.x -= delta
	if node_scanlines.position.x < -2:
		node_scanlines.position.x += 2
	
	if grappleAnchor != null:
		node_grappleLine.points[1] = grappleAnchor - node_grappleLine.global_position
		node_grappleLine.global_rotation = 0
	

func _physics_process(delta: float) -> void:
	
	var validGrapple = checkIfValidGrapple()
	
	if Input.is_action_just_pressed("actionGrapple"):
		if not isGrappling:
			createGrapple()
	
	if isGrappling:
		calcGrapple(delta)
	
	if not is_on_floor():
		if not isGrappling:
			velocity.y += gravity * delta

	jumpTimer += delta
	if is_on_floor():
		jumpTimer = 0
	if Input.is_action_just_pressed("actionJump") and jumpTimer <= 0.15:
		velocity.y = -stat_jumpHeight
		jumpTimer = 100

	var direction := Input.get_axis("actionMoveLeft", "actionMoveRight")
	if direction:
		if is_on_floor():
			velocity.x += direction * stat_moveSpeed
		else:
			velocity.x += direction * stat_moveSpeed * 0.25
	if is_on_floor():
		velocity.x *= 1 - (stat_groundFriction * delta)
	else:
		velocity.x *= 1 - (stat_airFriction * delta)
	
	move_and_slide()
	
	node_grappleCheckArea.global_position = get_global_mouse_position()

func calcGrapple(delta):
	if not Input.is_action_pressed("actionGrapple"):
		removeGrapple()
		return
	
	if not checkIfValidGrapple():
		removeGrapple()
		return
	
	velocity += global_position.direction_to(grappleAnchor) * delta * stat_grappleAcceleration
	
func checkIfValidGrapple():
	var targetPosition
	if isGrappling:
		targetPosition = grappleAnchor
	else:
		for i in node_grappleCheckArea.get_overlapping_areas():
			if targetPosition == null:
				targetPosition = i.global_position
				continue
			
			if node_grappleCheckArea.global_position.distance_to(i.global_position) < targetPosition:
				targetPosition = i.global_position
				continue
		if targetPosition == null:
			return false
	
	node_grappleRaycast.global_position = targetPosition
	node_grappleRaycast.target_position = global_position - node_grappleRaycast.global_position
	node_grappleRaycast.force_raycast_update()
	if node_grappleRaycast.is_colliding():
		return false
	if isGrappling:
		return true
	else:
		return targetPosition

func createGrapple():
	var targetPosition = checkIfValidGrapple()
	if not targetPosition:
		return
	grappleAnchor = targetPosition
	isGrappling = true
	node_grappleLine.clear_points()
	node_grappleLine.add_point(Vector2.ZERO)
	node_grappleLine.add_point(grappleAnchor - node_grappleLine.global_position)

func removeGrapple():
	grappleAnchor = null
	isGrappling = false
	node_grappleLine.clear_points()

func sigmoid(x, height = 1.0, steepness = 1.0):
	return height / (1 + 2.71828 ** (-steepness * x))
