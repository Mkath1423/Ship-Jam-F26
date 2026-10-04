extends Node

var rounds_cleared : int = 0
var current_wave : int = 0
var playing = true
var current_round_type : RoundType = RoundType.IDLE

enum RoundType { IDLE, SURVIVE }

@export var enemy_controller : EnemyController 
@onready var round_timer : Timer = $RoundTimer
@onready var wave_timer : Timer = $WaveTimer

func _ready() -> void:
	round_timer.timeout.connect(round_over)
	wave_timer.timeout.connect(_wave_timer_timeout)

func reset():
	rounds_cleared = 0
	current_wave = 0
	playing = false
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
	
	
func play_next_round():
	# todo : do some nice animations
	print("starting round")
	
	if not playing:
		return
	
	# choose the type of round duration difficulty etc
	_start_survival_round()

func _start_survival_round():
	current_round_type = RoundType.SURVIVE
	_wave_timer_timeout()
	round_timer.start(30)
	
func _wave_timer_timeout():
	if not playing or current_round_type != RoundType.SURVIVE:
		print("ignoring bad wave request")
		return 
	
	_spawn_chasers_near_player(2)
	
	wave_timer.start(10)
	
func _spawn_chasers_near_player(max_count : int):
	var flock : EnemyController.FlockInfo = enemy_controller._awaken_flock(
		enemy_controller._spawn_points_in_rect(Rect2(-200, -200, 100, 100), 6, 6, max_count),
		enemy_controller._awaken_enemy)
		
	flock.state = EnemyController.FlockState.IDLE
	flock.behavior = EnemyController.BehaviorType.CHASER
	
	enemy_controller.live_flocks.push_back(flock)
	print("spawned wave of...", flock.ships.size())


func round_over():
	_stop_timers()
	current_round_type = RoundType.IDLE
	
	rounds_cleared += 1
	
	play_next_round()
	current_wave = 0
	
	


	
