class_name EnemyController extends Node

signal player_killed_enemy(type : BehaviorType)

@export var basic_enemy_scene : PackedScene
@export var world : Node2D
@export var player : Node2D

@export var target_factor : float
@export var seperation_factor : float
@export var alignment_factor : float
@export var cohesion_factor : float

@export var update_targeting_interval : float = 0.1

enum BehaviorType { CHASER, GUNNER, BLOCKER, TURRET };
enum FlockState { IDLE, AGGRESSIVE, FLEE };

class EnemyInfo:
	var node : EnemyShip
	var target_velocity : Vector2
	var update_target_vel : float

class FlockInfo:
	var ships : Array[EnemyInfo]
	var center = Vector2.ZERO 
	var alignment_direction  : Vector2
	var goal_position : Vector2
	var update_targets : float
	var behavior : BehaviorType
	var state : FlockState

var spawning_flock : bool = false
var live_flocks : Array[FlockInfo]

func _kill_one(info: EnemyInfo):
	info.node.queue_free()
	
func _awaken_enemy(position : Vector2):
	var info = EnemyInfo.new()
	var node : EnemyShip = basic_enemy_scene.instantiate()
	node.global_position = position
	world.add_child(node)
	info.node = node
	info.node.is_dying = false
	return info


func _spawn_points_in_rect(spawning_boundry : Rect2, width : int, height : int, max_count : int):
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
		var o = collider.shape_find_owner(res["shape"])
		var shape = collider.shape_owner_get_shape(o, res["shape"]) as Shape2D
		var rect = shape.get_rect()
		rect.position -= spawning_boundry.size
		rect.size += 2 * spawning_boundry.size
		bounding_boxes.append(rect)
	
	var out : Array[Vector2] = []
	
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
				out.push_back(pos)
				
			if out.size() >= max_count:
				return out
	
	return out

func _awaken_flock(spawn_points : Array[Vector2], spawn_func : Callable):
	var flock = FlockInfo.new()
	for pos in spawn_points:
		flock.ships.push_back(spawn_func.call(pos))
	
	flock.update_targets = -1
	return flock


func _on_main_end() -> void:
	for flock in live_flocks:
		for ship in flock.ships:
			_kill_one(ship)
	live_flocks.clear()


func _physics_process(delta: float) -> void:
	# first pass to filter and update flock targets
	for f in range(live_flocks.size() - 1, -1, -1):
		var flock = live_flocks[f]
		_update_flock_targets(flock, delta)
		
		# remove dead flocks
		if flock.ships.size() == 0:
			live_flocks.remove_at(f)
	
	# update desired velocities
	for flock in live_flocks:
		_update_ship_targets(flock, delta)
		
	# move the boids!
	for flock in live_flocks:
		for ship in flock.ships:
			_move_ship(ship, delta)


func _update_flock_targets(flock : FlockInfo, _delta : float):
# clear dead enemies
	for i in range(flock.ships.size() - 1, -1, -1):
		var info = flock.ships[i]
		if info.node == null or info.node.is_dying:
			
			if info.node.player_killed:
				player_killed_enemy.emit(flock.behavior)
			
			flock.ships.erase(info)
			_kill_one(info)
	
	# recompute targets
	flock.center = Vector2.ZERO
	flock.alignment_direction = Vector2.ZERO
	for info in flock.ships: 
		flock.center += info.node.global_position
		flock.alignment_direction += info.node.velocity
		
	flock.center /= flock.ships.size()
	flock.alignment_direction /= flock.ships.size()
	flock.goal_position = player.global_position

func _update_ship_targets(flock : FlockInfo, delta : float):
	for info in flock.ships:
		if info.update_target_vel > 0:
			info.update_target_vel -= delta
			continue
		else:
			info.update_target_vel = update_targeting_interval
		
		var seperation = Vector2.ZERO
		var near = 0
		for other in flock.ships:
			var dx = (info.node.global_position - other.node.global_position)
			if other != info and dx.length() < 100:
				seperation += dx.normalized()
				near += 1
		
		# move towards player
		var to_player = (player.position - info.node.position).normalized()
		
		var v = to_player * target_factor
		if near != 0:
			v += (seperation / near) * seperation_factor
		
		if info.node.velocity.length() > 100:
			v += (flock.alignment_direction - info.node.velocity).normalized() * alignment_factor 
		
		v += (flock.center - info.node.position).normalized() * cohesion_factor
		
		v = v.normalized() * (info.node.max_speed)
		info.target_velocity = v

func _move_ship(info : EnemyInfo, delta : float):
	var desired_velocity = info.target_velocity
	
	var accel = (desired_velocity - info.node.velocity).limit_length(info.node.max_acceleration)
	info.node.velocity += accel * delta
	#info.node.move_and_slide()
	info.node.velocity.limit_length(info.node.max_speed)

	var collision = info.node.move_and_collide(info.node.velocity * delta)

	if collision == null:
		return
		
	var collider = collision.get_collider()
	var v_before = info.node.velocity
	
	if collider is RigidBody2D:
		info.node.velocity = info.node.velocity.slide(collision.get_normal())
		collider.apply_central_force(v_before - info.node.velocity)
	
	elif collider is EnemyShip:
		var k = collision.get_normal()
		var impulse = k.dot(collider.velocity - info.node.velocity) 
		collider.velocity -= impulse * k
		info.node.velocity += impulse * k
			
