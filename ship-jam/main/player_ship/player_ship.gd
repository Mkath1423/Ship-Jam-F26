class_name PlayerShip extends CharacterBody2D

@export var boost_acceleration : float
@export var nudge_acceleration : float

@export var max_speed : float = -1
@export var max_speed_decay : float = 0.5
var prev_velocity : Vector2
var acceleration : Vector2

@export var break_speed_decay : float = 0.5

@export var resourceManager : Resource
var energy_gain_rate : float = 0
var energy_gain_factor : float = 1
# We need to disable energy gain right when the railgun fires, since that makes
# the acceleration go through the roof, which energy gain rate is based on.
var energy_gain_enabled : bool = true

@export var bullet_manager : Node
var gun_on_cooldown : bool = false

const teams = preload("res://main/teams.gd")
var team : teams.team = teams.team.Player

var charging_railgun : bool = false
var pre_charge_velocity : Vector2

var has_hit_player : bool = false

var look_at = Vector2.LEFT

@onready var nudge_root = $nudge_root
@onready var nudge_particles = $nudge_root/nudge_particles
@onready var boost_particles = $Sprite2D/boost_particles
@onready var break_particles = $nudge_root/break_particles
@onready var bullet_spawn_point = $Sprite2D/bullet_spawn_point

func emit_nudge_particles(nudge_dir: Vector2):
	if boost_particles.emitting == true:
		return 
	nudge_root.rotation = nudge_dir.angle() + deg_to_rad(90)
	if not nudge_particles.emitting:
		nudge_particles.emitting = true

func emit_break_particles():
	nudge_root.rotation = (-velocity).angle() + deg_to_rad(90)
	break_particles.emitting = true

func _physics_process(delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	
	$Sprite2D.rotation = global_position.angle_to_point(mouse_pos) + deg_to_rad(90)
	look_at = (mouse_pos - global_position).normalized()
	
	
	var nudge = Vector2(
		Input.get_axis("left", "right"),
		Input.get_axis("forward", "back")
	)
	
	if Input.is_action_just_pressed("left") or \
		Input.is_action_just_pressed("right") or \
		Input.is_action_just_pressed("forward") or \
		Input.is_action_just_pressed("back"):
		emit_nudge_particles(nudge.normalized())
	
	
	velocity += nudge * delta * nudge_acceleration
	
	if Input.is_action_pressed("break"):
		velocity *= (1 - break_speed_decay * delta)
		emit_break_particles()
	
	elif Input.is_action_pressed("boost"):
		velocity += look_at * delta * boost_acceleration
		boost_particles.emitting = true
		#if Input.is_action_just_pressed("boost"):
		#	$Jets.play()
		#elif Input.is_action_just_released("boost"):
		#	$Jets.stop()
	else:
		boost_particles.emitting = false
		break_particles.emitting = false
	var speed = velocity.length()
	if max_speed > 0 and speed > max_speed:
		var decay = max_speed_decay * delta
		velocity *= (decay * speed + (1 - decay) * max_speed) / speed
	
	if Input.is_action_just_pressed("alt_shoot"):
		if (resourceManager.attempt_spend_energy(20)):
			pre_charge_velocity = velocity
			charging_railgun = true
			$RailgunCharge.play()
	
	if charging_railgun and Input.is_action_just_released("alt_shoot"):
		bullet_manager.spawn_railgun_beam(teams.team.Player, position, 5000, $Sprite2D.rotation)
		var dir_opp_facing = -Vector2(sin($Sprite2D.rotation), -cos($Sprite2D.rotation)).normalized()
		# This formula is VERY much still up in the air.
		velocity = dir_opp_facing * (pre_charge_velocity.length() * 2 + 2000)
		charging_railgun = false
		energy_gain_enabled = false
		$RailgunCharge.stop()
		$RailgunShot.play()
		$NoEnergyGainTimer.start()
	
	if charging_railgun:
		# TODO: Adapt this to be slowdown, or whatever else it needs to be
		velocity *= 0.8 * delta
	
	acceleration = (velocity - prev_velocity) * delta
	var theta = sin(velocity.angle_to(acceleration))
	var acceleration_for_energy = min(acceleration.length(), 0.4)
	energy_gain_rate = theta * theta * acceleration_for_energy * energy_gain_factor
	if energy_gain_enabled:
		resourceManager.attempt_add_energy(energy_gain_rate)
	
	prev_velocity = velocity
	var v_before = velocity
	move_and_slide()
	
	if Input.is_action_pressed("shoot") and not gun_on_cooldown:
		gun_on_cooldown = true
		bullet_manager.spawn_bullet(teams.team.Player, bullet_spawn_point.global_position, 3000, $Sprite2D.rotation)
		$LaserShot1.play()
		await get_tree().create_timer(0.05).timeout
		bullet_manager.spawn_bullet(teams.team.Player, bullet_spawn_point.global_position, 3000, $Sprite2D.rotation+0.01*PI)
		$LaserShot1.play()
		await get_tree().create_timer(0.05).timeout
		bullet_manager.spawn_bullet(teams.team.Player, bullet_spawn_point.global_position, 3000, $Sprite2D.rotation+0.01*PI)
		$LaserShot1.play()
		$ShotTimer.start()
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is RigidBody2D:
			collider.apply_impulse(-velocity + v_before, collider.position)
	

func _on_shot_timer_timeout() -> void:
	gun_on_cooldown = false

func hit_by_bullet(bullet):
	if bullet.team == teams.team.Enemy:
		resourceManager.playerHealth -= 10

func _on_no_energy_gain_timer_timeout() -> void:
	energy_gain_enabled = true


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body is EnemyShip:
		resourceManager.playerHealth -= 10
		body.is_dying = true
		print(resourceManager.playerHealth)
