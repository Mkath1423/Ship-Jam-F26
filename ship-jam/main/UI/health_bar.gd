extends Node2D

@export var resourceManager : Resource

var original_scale_x

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Change BarColour to orange
	original_scale_x = get_node("HealthBar_1").get_node("BarColourFill").scale.x

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var fractional_health : float = float(resourceManager.playerHealth) / float(resourceManager.maxPlayerHealth)
	print(resourceManager.playerHealth)
	print(resourceManager.maxPlayerHealth)
	print(fractional_health)
	print()
	
	# Update the bar
	get_node("HealthBar_1").get_node("BarColourFill").scale.x = original_scale_x * fractional_health
