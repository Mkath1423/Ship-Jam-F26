extends CharacterBody2D

@export var boost_acceleration : float
@export var nudge_acceleration : float

@export var max_speed : float = -1
@export var max_speed_decay : float = 0.5

@export var break_speed_decay : float = 0.5

@export var bullet_manager : Node
var gun_on_cooldown : bool = false

var look_at = Vector2.LEFT

func _physics_process(delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	
	$Sprite2D.rotation = global_position.angle_to_point(mouse_pos) + deg_to_rad(90)
	look_at = (mouse_pos - global_position).normalized()
	
	
	var nudge = Vector2(
		Input.get_axis("left", "right"),
		Input.get_axis("forward", "back")
	)
	
	velocity += nudge * delta * nudge_acceleration
	
	if Input.is_action_pressed("break"):
		velocity *= (1 - break_speed_decay * delta)
	
	elif Input.is_action_pressed("boost"):
		velocity += look_at * delta * boost_acceleration
	var speed = velocity.length()
	if max_speed > 0 and speed > max_speed:
		var decay = max_speed_decay * delta
		velocity *= (decay * speed + (1 - decay) * max_speed) / speed
	
	
	var v_before = velocity
	move_and_slide()
	
	if Input.is_action_pressed("shoot") and not gun_on_cooldown:
		bullet_manager.spawn_bullet(position, 3000, $Sprite2D.rotation)
		$ShotTimer.start()
		gun_on_cooldown = true
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is RigidBody2D:
			collider.apply_impulse(-velocity + v_before, collider.position)
		
		else:
			print("unhandled collision with ", collision.get_collider().name)


func _on_shot_timer_timeout() -> void:
	gun_on_cooldown = false
