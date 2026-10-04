class_name EnemyShip extends CharacterBody2D

@export var max_acceleration : float = 500
@export var max_speed : float = 1000

var is_dying : bool = false
var player_killed : bool = false

const teams = preload("res://main/teams.gd")
var team : teams.team = teams.team.Enemy

var teleport_requested : bool = false

func hit_by_bullet(bullet):
	if bullet.team == teams.team.Player:
		is_dying = true
		player_killed = true


func set_direction(rotation):
	$Sprite2D.rotation = rotation

func set_collidable(value):
	# TODO: fuck with the collision layers 
	$CollisionShape2D.disabled = not value
	

func teleport(offset : Vector2):
	teleport_requested = false
	global_position = offset

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if teleport_requested:
		print("processed tele")
		state.linear_velocity = Vector2.ZERO
		state.angular_velocity = 0
		teleport_requested = false
	else:
		# Fall back to Godot's default force integration
		state.integrate_forces()
