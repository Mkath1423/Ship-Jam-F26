class_name _EnemyController extends Node

@export var basic_enemy_scene : PackedScene
@export var world : Node2D
@export var player : Node2D

@export var target_factor : float
@export var seperation_factor : float
@export var alignment_factor : float
@export var cohesion_factor : float

class EnemyInfo:
	var node : EnemyShip
	var is_dying : bool

var total_enemies : int = 10

var dead_basic_enemy_nodes : Array[EnemyInfo]
var live_enemies : Array[EnemyInfo]


func _spawn_one(scene):
	var node : EnemyShip = scene.instantiate()
	world.add_child(node)
	return node

func _kill_one(info: EnemyInfo):
	info.node.visible = false
	info.node.process_mode = Node.PROCESS_MODE_DISABLED

func _spawn_basic_enemy():
	var info = EnemyInfo.new()
	info.node = _spawn_one(basic_enemy_scene)
	_kill_one(info)
	dead_basic_enemy_nodes.append(info)

func _awaken_enemy(position : Vector2):
	if dead_basic_enemy_nodes.size() == 0:
		_spawn_basic_enemy()
	var info = dead_basic_enemy_nodes.pop_back()
	live_enemies.push_back(info)
	
	info.node.global_position = position
	info.node.process_mode = Node.PROCESS_MODE_INHERIT
	info.node.visible = true
	info.is_dying = false


func _ready() -> void:
	for i in range(total_enemies):
		_awaken_enemy(Vector2.ONE * i * 100)
		

func _process(delta: float) -> void:
	
	var center = Vector2.ZERO 
	var alignment_direction = Vector2.ZERO
	
	# filter out dead enemies
	for i in range(live_enemies.size() - 1, -1, -1):
		var info = live_enemies[i]
		
		if info.is_dying:
			live_enemies.remove_at(i)
			_kill_one(info)
			dead_basic_enemy_nodes.push_back(info)
			
		else:
			center += info.node.global_position
			alignment_direction += info.node.velocity
	
	center /= live_enemies.size()
	alignment_direction /= live_enemies.size()
	# update desired velocities
	for info in live_enemies:
		
		
		var seperation = Vector2.ZERO
		var near = 0
		for other in live_enemies:
			var dx = (info.node.global_position - other.node.global_position)
			if other != info and dx.length() < 100:
				seperation += dx
				near += 1
		
		
		# move towards player
		var to_player = player.position - info.node.position
		
		var desired_velocity = to_player * target_factor
		if near != 0:
			desired_velocity += (seperation / near) * seperation_factor
			
		desired_velocity += (alignment_direction - info.node.velocity) * alignment_factor 
		desired_velocity += (center - info.node.position) * cohesion_factor
		
		desired_velocity.limit_length(info.node.max_speed)
		
		var accel = (desired_velocity - info.node.velocity).limit_length(info.node.max_acceleration)
		info.node.velocity += accel * delta
	
		var collision = info.node.move_and_collide(info.node.velocity * delta)
		#
		#if collision:
			#info.node.velocity = info.node.velocity.bounce(collision.get_normal())
			#info.node.velocity *= 0.1
			#if collision.get_collider().has_method("hit"):
				#collision.get_collider().hit()
		#
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
	
