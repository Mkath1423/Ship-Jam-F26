class_name PlayerShip extends CharacterBody2D

@export var boost_acceleration : float
@export var nudge_acceleration : float

@export var max_speed : float = -1
@export var max_speed_decay : float = 0.5
var prev_velocity : Vector2

@export var break_speed_decay : float = 0.5

@export var resourceManager : Resource
var energy_gain_rate : float = 0
var energy_gain_factor : float = 0.2
# We need to disable energy gain right when the railgun fires, since that makes
# the acceleration go through the roof, which energy gain rate is based on.
var energy_gain_enabled : bool = true

@export var bullet_manager : Node
var gun_on_cooldown : bool = false

const teams = preload("res://main/teams.gd")
var team : teams.team = teams.team.Player

var charging_railgun : bool = false
var pre_charge_velocity : Vector2

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
	
	if Input.is_action_just_pressed("alt_shoot"):
		if (resourceManager.attempt_spend_energy(20)):
			pre_charge_velocity = velocity
			charging_railgun = true
	
	if charging_railgun and Input.is_action_just_released("alt_shoot"):
		bullet_manager.spawn_railgun_beam(teams.team.Player, position, 5000, $Sprite2D.rotation)
		var dir_opp_facing = -Vector2(sin($Sprite2D.rotation), -cos($Sprite2D.rotation)).normalized()
		# This formula is VERY much still up in the air.
		velocity = dir_opp_facing * (pre_charge_velocity.length() * 2 + 2000)
		charging_railgun = false
		energy_gain_enabled = false
		$NoEnergyGainTimer.start()
	
	if charging_railgun:
		# TODO: Adapt this to be slowdown, or whatever else it needs to be
		velocity = Vector2(0, 0)
	
	var acceleration = (velocity - prev_velocity) * delta
	energy_gain_rate = abs(velocity.angle_to(acceleration)) * acceleration.length() * energy_gain_factor
	if energy_gain_enabled:
		resourceManager.attempt_add_energy(energy_gain_rate)
	
	prev_velocity = velocity
	var v_before = velocity
	move_and_slide()
	
	if Input.is_action_pressed("shoot") and not gun_on_cooldown:
		bullet_manager.spawn_bullet(teams.team.Player, position, 3000, $Sprite2D.rotation)
		$ShotTimer.start()
		gun_on_cooldown = true
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is RigidBody2D:
			collider.apply_impulse(-velocity + v_before, collider.position)
		
		elif collider is EnemyShip:
			resourceManager.playerHealth -= 10
			print(resourceManager.playerHealth)

func _on_shot_timer_timeout() -> void:
	gun_on_cooldown = false

func hit_by_bullet(bullet):
	if bullet.team == teams.team.Enemy:
		resourceManager.playerHealth -= 10




func _on_no_energy_gain_timer_timeout() -> void:
	energy_gain_enabled = true
