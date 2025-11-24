extends CharacterBody2D

@onready var node_raycastClearance = $PlayerClearanceRaycast
@onready var node_raycastSight = $PlayerSightRaycast
@onready var node_navAgent = $NavigationAgent2D
var navTargetUpdateTimer = 0.0

@export var stat_moveSpeed = 40.0
var stat_airFriction = 0.5
var stat_gravity = 20.0
var stat_fireRate = 3.0
var attackTimer = stat_fireRate

@export var node_attack_origin = Node2D
@export var node_attack_indicator = Node2D
@export var node_attack_indicator2 = Node2D

@onready var node_player = get_tree().current_scene.get_node("Player")

func _ready() -> void:
	node_raycastClearance.add_exception(node_player)

func _process(_delta: float) -> void:
	var directionPos = (velocity * 4) + (node_player.global_position - global_position)
	var attackPos = node_player.global_position
	attackPos.y = max(attackPos.y,global_position.y + 5.0)
	$Sprite.visual_tick(directionPos, attackPos)
	
func _physics_process(delta: float) -> void:
	navTargetUpdateTimer -= delta
	if navTargetUpdateTimer <= 0.0 or node_navAgent.target_position == null:
		node_raycastClearance.global_position = node_player.global_position
		node_raycastClearance.target_position = Vector2(0,-80)
		node_raycastClearance.force_raycast_update()
		
		if node_raycastClearance.is_colliding():
			node_navAgent.target_position = node_raycastClearance.get_collision_point() - Vector2(0,16)
		else:
			node_navAgent.target_position = node_player.global_position + Vector2(0,-64)
		navTargetUpdateTimer += 1.0
	
	node_raycastSight.global_position = node_attack_origin.global_position
	node_raycastSight.target_position = node_player.global_position - node_raycastSight.global_position
	node_raycastSight.force_raycast_update()
	
	var targetPos = node_navAgent.get_next_path_position()
	velocity += global_position.direction_to(targetPos) * stat_moveSpeed * delta
	velocity.y += stat_gravity * delta
	velocity *= 1 - (stat_airFriction * delta)
	
	if node_raycastSight.is_colliding() or node_raycastSight.global_position.y >= node_player.global_position.y:
		attackTimer = min(attackTimer + (delta / 2.0), stat_fireRate)
	else:
		attackTimer -= delta
		if attackTimer <= 0:
			attackTimer = stat_fireRate
			var node_laserProjectile = preload("res://Nodes/Entities/Projectiles/Enemies/enemy_laser.tscn").instantiate()
			node_laserProjectile.global_position = node_attack_origin.global_position
			node_laserProjectile.velocity = node_laserProjectile.global_position.direction_to(node_player.global_position) * 100
			get_tree().current_scene.add_child(node_laserProjectile)
	node_attack_indicator.modulate.a = 1 - (attackTimer / stat_fireRate)
	node_attack_indicator2.modulate.a = 1 - (attackTimer / stat_fireRate)
	
	move_and_slide()
