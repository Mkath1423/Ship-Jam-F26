# NOTE: Currently, there's no mechanism for resetting the signal stuff.
# Idk how we are going to do that, later us problem.

extends Resource

@export var playerHealth : int = 0
@export var playerEnergy : float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	

func attempt_add_energy(energy_to_add : float):
	if playerEnergy + energy_to_add > 100:
		playerEnergy = 100
	else:
		playerEnergy += energy_to_add

# Attempts to spend x energy, if there is enough.
# If there is, removes that much energy and returns true
# If there is not, returns false.
func attempt_spend_energy(energy_to_spend : float) -> bool:
	if (playerEnergy >= energy_to_spend):
		playerEnergy -= energy_to_spend
		return true
	else:
		return false
