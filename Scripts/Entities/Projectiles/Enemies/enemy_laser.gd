extends Area2D

var velocity = Vector2(1,0)
var maxLifespan = 10.0
var lifespan = maxLifespan

func _physics_process(delta: float) -> void:
	lifespan -= delta
	if lifespan <= 0:
		queue_free()
		
	for i in get_overlapping_bodies():
		if i.is_in_group("Solid"):
			queue_free()
		
	global_position += velocity * delta
	look_at(global_position + velocity)
	
