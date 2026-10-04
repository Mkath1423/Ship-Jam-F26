extends Node2D
class_name AlertManager

var alert = preload("res://main/warnings/alert.tscn")

@export var player = Node2D

var alert_entities : Array[Node2D] = []


func _process(delta: float) -> void:
	for i in range(alert_entities.size() - 1, -1, -1):
		if not is_instance_valid(alert_entities[i]):
			alert_entities.remove_at(i)
	
	
