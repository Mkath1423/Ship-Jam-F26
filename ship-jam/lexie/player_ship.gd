extends CharacterBody2D

var look_at = Vector2.LEFT

func _physics_process(delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	
	$Sprite2D.rotation = global_position.angle_to_point(mouse_pos) + 90
	look_at = (mouse_pos - global_position).normalized()
	
	if Input.is_action_pressed("forward"):
		velocity += look_at * delta * 1000
	
	move_and_slide()
