extends Node

var rounds_cleared : int = 0
var current_wave : int = 0
var count_down : int = 0
var playing = true
var current_round_type : RoundType = RoundType.IDLE

enum RoundType { IDLE, SURVIVE }

@export var enemy_controller : EnemyController 
@export var chunk_manager : ChunkManager
@export var player : Node2D 
@export var resourceManager : Resource

@onready var round_timer : Timer = $RoundTimer
@onready var wave_timer : Timer = $WaveTimer
@onready var count_down_timer : Timer = $CountDownTimer

@export var banner : Label 
@export var objective : Label 


func _ready() -> void:
	round_timer.timeout.connect(round_over)
	wave_timer.timeout.connect(_wave_timer_timeout)
	count_down_timer.timeout.connect(_on_survival_countdown_tick)

func _hide_ui():
	banner.hide()
	objective.hide()

func reset():
	rounds_cleared = 0
	current_wave = 0
	playing = false
	_hide_ui()
	_stop_timers()

func _on_main_restart() -> void:
	reset()
	playing = true
	play_next_round()

func _on_main_end() -> void:
	playing = false
	_stop_timers()

func _stop_timers():
	round_timer.stop()
	wave_timer.stop()
	count_down_timer.stop()
	

func _pre_round_animation():
	_hide_ui()
	await get_tree().create_timer(0.5).timeout
	banner.visible_ratio = 0
	banner.text = "HOSTILES INCOMING..."
	banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	banner.show()
	
	var tween = create_tween()
	tween.tween_property(banner, "visible_ratio", 1, 1.5)
	await tween.finished
	
	await get_tree().create_timer(1).timeout
	
	banner.text = ""
	await get_tree().create_timer(1).timeout
	
	banner.visible_ratio = 1
	banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	for i in range(3, 0, -1):
		banner.text = str(i)
		await get_tree().create_timer(1).timeout
	banner.hide()

func _post_round_animation():
	_hide_ui()
	await get_tree().create_timer(0.5).timeout
	banner.visible_ratio = 0
	banner.text = "WAVE " + str(rounds_cleared) + " DEFEATED" 
	banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner.show()
	
	var tween = create_tween()
	tween.tween_property(banner, "visible_ratio", 1, 1.5)
	await tween.finished
	
	await get_tree().create_timer(1).timeout
	_hide_ui()
	await get_tree().create_timer(3).timeout
	


func play_next_round():
	await _pre_round_animation()
	if not playing:
		return
	
	# choose the type of round duration difficulty etc
	_start_survival_round()


func _initialize_survival_objective():
	_hide_ui()
	await get_tree().create_timer(0.5).timeout
	objective.text = "SURVIVE: " + str(count_down)
	objective.visible_ratio = 0
	objective.show()
	
	var tween = create_tween()
	tween.tween_property(objective, "visible_ratio", 1, 0.5)
	await tween.finished
	await get_tree().create_timer(0.5).timeout


func _start_survival_round():
	current_round_type = RoundType.SURVIVE
	count_down = 30
	resourceManager.attempt_add_health(20);
	await _initialize_survival_objective()
	_wave_timer_timeout()
	count_down_timer.start(1)
	#round_timer.start(count_down)

func _on_survival_countdown_tick():
	if not playing or current_round_type != RoundType.SURVIVE:
		print("ignoring bad tick request")
		return 
	
	count_down -= 1
	
	if count_down == 0:
		round_over()
		
	else:
		objective.text = "SURVIVE: " + str(count_down)
		count_down_timer.start(1)

func _wave_timer_timeout():
	if not playing or current_round_type != RoundType.SURVIVE:
		print("ignoring bad wave request")
		return 
	
	_spawn_chasers_near_player(3 + rounds_cleared  * 3)
	
	wave_timer.start(5)
	
func _spawn_chasers_near_player(max_count : int):
	
	var dir = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	if dir == Vector2.ZERO:
		dir = Vector2.LEFT
	
	var start_pos = player.global_position + dir * 2500
	
	
	var flock : EnemyController.FlockInfo = enemy_controller._awaken_flock(
		enemy_controller._spawn_points_in_rect(Rect2(start_pos.x, start_pos.y, 100, 100), 
			ceili(sqrt(max_count))+ 2, ceili(sqrt(max_count)) + 2, max_count),
		enemy_controller._awaken_enemy)
		
	flock.state = EnemyController.FlockState.IDLE
	flock.behavior = EnemyController.BehaviorType.CHASER
	
	enemy_controller.live_flocks.push_back(flock)
	print("spawned wave of...", flock.ships.size())


func round_over():
	_stop_timers()
	current_round_type = RoundType.IDLE
	
	rounds_cleared += 1
	
	await _post_round_animation()
	
	call_deferred("play_next_round")
	current_wave = 0
	
	


	
