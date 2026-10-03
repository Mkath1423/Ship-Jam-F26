extends Camera2D


@export var lower_bound_margin : float
@export var upper_bound_margin : float 

@export var lower_bound_speed : float
@export var upper_bound_speed : float


@export var gamma : float

@onready var player : CharacterBody2D = $".."

func compute_liner_weight(value):
	return 
func compute_margin(value):
	var weight = (value - lower_bound_speed) / (upper_bound_speed - lower_bound_speed)
	weight = clampf(weight, 0.0, 1.0)
	weight = pow(weight, gamma)
	
	return lerpf(lower_bound_margin, upper_bound_margin, weight)


func _process(delta: float) -> void:
	drag_bottom_margin = compute_margin(player.velocity.y)
	drag_top_margin = compute_margin(-player.velocity.y)
	drag_right_margin = compute_margin(player.velocity.x)
	drag_left_margin = compute_margin(-player.velocity.x)
