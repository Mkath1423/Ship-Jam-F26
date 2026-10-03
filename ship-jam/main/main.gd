extends Node2D

@export var resourceManager : Resource

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (resourceManager.playerHealth <= 0):
		game_over()

func game_over():
	pass
	#print("That's a wrap, folks!")
