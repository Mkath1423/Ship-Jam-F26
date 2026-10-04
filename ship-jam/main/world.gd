extends Node2D

signal restart
signal end

signal swtch_to_game_over

var playing = false
@export var resourceManager : ResourceManager

func start():
	playing = true
	restart.emit()

func _process(delta: float) -> void:
	if playing:
		if (resourceManager.playerHealth <= 0):
			end.emit()
			playing = false
			swtch_to_game_over.emit.call_deferred()
