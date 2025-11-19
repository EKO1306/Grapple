extends Area2D

@export var cameraLockBounds = Vector4.ZERO
var isLocking = false

@onready var playerCamera = get_tree().current_scene.get_node("Player/Camera2D")

func _physics_process(_delta: float) -> void:
	print(playerCamera.global_position)
	if isLocking:
		playerCamera.global_position = Vector2(0.0,-48.0)
	isLocking = false
	for i in get_overlapping_bodies():
		if i.is_in_group("Player"):
			isLocking = true
	
	if isLocking:
		playerCamera.global_position.x = clamp(playerCamera.global_position.x, cameraLockBounds.x, cameraLockBounds.z)
		playerCamera.global_position.y = clamp(playerCamera.global_position.y, cameraLockBounds.y, cameraLockBounds.w)
