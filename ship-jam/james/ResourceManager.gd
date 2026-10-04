# NOTE: Currently, there's no mechanism for resetting the signal stuff.
# Idk how we are going to do that, later us problem.

extends Resource 
class_name ResourceManager

@export var maxPlayerHealth : int = 100
@export var maxPlayerEnergy : int = 100

@export var playerHealth : int = maxPlayerHealth
@export var playerEnergy : float = 0

func restart():
	playerHealth = maxPlayerHealth
	playerEnergy = 0
	
func attempt_add_energy(energy_to_add : float):
	if playerEnergy + energy_to_add > maxPlayerEnergy:
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
