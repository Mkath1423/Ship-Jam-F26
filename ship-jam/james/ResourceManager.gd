# NOTE: Currently, there's no mechanism for resetting the signal stuff.
# Idk how we are going to do that, later us problem.

extends Resource

@export var playerHealth : int = 0
@export var playerEnergy : int = 0

signal playerDied
var playerDiedEmitted : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (not playerDiedEmitted and playerHealth <= 0):
		playerDied.emit()
		playerDiedEmitted = true
	
