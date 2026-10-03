class_name _EnemyController extends Node

@export var basic_enemy_scene : PackedScene
@export var world : Node2D
@export var player : Node2D

@export var target_factor : float
@export var seperation_factor : float
@export var alignment_factor : float
@export var cohesion_factor : float

@export var update_targeting_interval : float = 0.1

class EnemyInfo:
	var node : EnemyShip
	var is_dying : bool
	var target_velocity : Vector2
	var update_target_vel : float

var live_enemies : Array[EnemyInfo]


func _kill_one(info: EnemyInfo):
	info.node.queue_free()
	
	

func _awaken_enemy(position : Vector2):
	var info = EnemyInfo.new()
	
	var node : EnemyShip = basic_enemy_scene.instantiate()
	
	node.global_position = position
	world.add_child(node)
	
	info.node = node
	info.is_dying = false
	
	return info



func _awaken_in_rect(spawning_boundry : Rect2, width : int, height : int, max : int):
	var query = PhysicsShapeQueryParameters2D.new()
	
	var spawn_rect = RectangleShape2D.new() 
	spawn_rect.size = Vector2(
		spawning_boundry.size.x * width,
		spawning_boundry.size.y * height,
	)
	query.shape = spawn_rect
	query.collision_mask = 1
	query.transform.origin = spawning_boundry.position
	query.collide_with_bodies = true
	query.collide_with_areas = false
	var space_state = world.get_world_2d().direct_space_state
	var results = space_state.intersect_shape(query)
	
	var bounding_boxes : Array[Rect2] = []
	for res in results:
		var collider : PhysicsBody2D = res["collider"] 
		var owner = collider.shape_find_owner(res["shape"])
		var shape = collider.shape_owner_get_shape(owner, res["shape"]) as Shape2D
		var rect = shape.get_rect()
		rect.position -= spawning_boundry.size
		rect.size += 2 * spawning_boundry.size
		bounding_boxes.append(rect)
	
	var out = []
	
	for x in range(width):
		for y in range(height):
			var pos = Vector2(
				spawning_boundry.size.x * x,
				spawning_boundry.size.y * y,
			) + spawning_boundry.position
			
			var good = true
			for aabb in bounding_boxes:
				if aabb.has_point(pos):
					good = false
					break
			
			if good:
				var info = _awaken_enemy(pos)
				live_enemies.push_back(info)
				out.push_back(info)
				
			if out.size() >= max:
				return out
	
	return out

func _ready() -> void:
	await get_tree().create_timer(3).timeout
	_awaken_in_rect(Rect2(-200, -200, 100, 100), 6, 6, 50)
	pass
	

func _process(delta: float) -> void:
	
	var center = Vector2.ZERO 
	var alignment_direction = Vector2.ZERO
	
	# filter out dead enemies
	for i in range(live_enemies.size() - 1, -1, -1):
		var info = live_enemies[i]
		
		if info.is_dying:
			live_enemies.remove_at(i)
			_kill_one(info)
			
		else:
			center += info.node.global_position
			alignment_direction += info.node.velocity
	
	center /= live_enemies.size()
	alignment_direction /= live_enemies.size()
	# update desired velocities
	for info in live_enemies:
		
		if info.update_target_vel > 0:
			info.update_target_vel -= delta
			continue
		else:
			info.update_target_vel = update_targeting_interval
		
		var seperation = Vector2.ZERO
		var near = 0
		for other in live_enemies:
			var dx = (info.node.global_position - other.node.global_position)
			if other != info and dx.length() < 100:
				seperation += dx.normalized()
				near += 1
		
		
		# move towards player
		var to_player = (player.position - info.node.position).normalized()
		
		var desired_velocity = to_player * target_factor
		if near != 0:
			desired_velocity += (seperation / near) * seperation_factor
			
		desired_velocity += (alignment_direction - info.node.velocity).normalized() * alignment_factor 
		desired_velocity += (center - info.node.position).normalized() * cohesion_factor
		
		desired_velocity = desired_velocity.normalized() * (info.node.max_speed)
		info.target_velocity = desired_velocity
		
		
	for info in live_enemies:
		var desired_velocity = info.target_velocity
		
		var accel = (desired_velocity - info.node.velocity).limit_length(info.node.max_acceleration)
		info.node.velocity += accel * delta
		#info.node.move_and_slide()
		info.node.velocity.limit_length(info.node.max_speed)
	
		var collision = info.node.move_and_collide(info.node.velocity * delta)
		#
		if collision:
			#info.node.velocity = info.node.velocity.bounce(collision.get_normal())
			var collider = collision.get_collider()
			var v_before = info.node.velocity
			if collider is RigidBody2D:
				info.node.velocity *= 0.1
				collider.apply_central_force(v_before - info.node.velocity)
			
			elif collider is EnemyShip:
				var k = collision.get_normal()
				var impulse = k.dot(collider.velocity - info.node.velocity) 
				collider.velocity -= impulse * k
				info.node.velocity += impulse * k
			
			#if collision.get_collider().has_method("hit"):
				#collision.get_collider().hit()
		
		#for i in info.node.get_slide_collision_count():
			#var collision =  info.node.get_slide_collision(i)
			#print("unhandled collision with ", collision.get_collider().name)
			
	#
	# 
	#
	#
	#
	#
	#
	#
	
