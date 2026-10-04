extends Node

var rounds_cleared : int = 0
var current_wave : int = 0
var playing = true

@onready var enemy_controller : EnemyController = $"../EnemyController"
@onready var round_timer : Timer = $RoundTimer
@onready var wave_timer : Timer = $WaveTimer

func _ready() -> void:
	$RoundTimer.timeout.connect(round_over)

func reset():
	rounds_cleared = 0
	current_wave = 0
	playing = false
	_stop_timers()

func _for() -> void:
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
	
	while playing:
		
		$Timer.start(3)
		await $Timer.timeout

func _start_survival_round():
	pass
	
func _next_survial_wave():
	
	wave_timer.connect(_next_survial_wave, CONNECT_ONE_SHOT )
	
func _spawn_chasers_near_player(max : int):
	var flock : EnemyController.FlockInfo = enemy_controller._awaken_flock(
		enemy_controller._spawn_points_in_rect(Rect2(-200, -200, 100, 100), 6, 6, max),
		enemy_controller._awaken_enemy)
		
	flock.state = EnemyController.FlockState.IDLE
	flock.behavior = EnemyController.BehaviorType.CHASER
	
	enemy_controller.live_flocks.push_back(flock)


func round_over():
	_stop_timers()
	
	# todo: check if its a win?
	rounds_cleared += 1
	
	


	
