extends Node2D

signal restart
signal end

var playing = false

func _ready() -> void:
	restart.emit()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if playing:
			end.emit()
		else:
			restart.emit()
		playing = not playing
