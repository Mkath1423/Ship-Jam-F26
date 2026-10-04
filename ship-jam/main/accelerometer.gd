extends Node2D

@export var player : PlayerShip

var original_rotation
var max_acceleration
var max_rotation = 1.5 * PI

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Change BarColour to orange
	max_acceleration = 0.5
	original_rotation = get_node("Accelerometer_1").get_node("Dial").rotation

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var fractional_rotation = player.acceleration.length() / max_acceleration
		
	var new_additional_rotation = (2 * PI * fractional_rotation)
	
	if new_additional_rotation >= 1.5 * PI:
		new_additional_rotation = 1.5 * PI
	
	var new_rotation = new_additional_rotation + original_rotation
	# Update the bar
	get_node("Accelerometer_1").get_node("Dial").rotation = new_rotation
