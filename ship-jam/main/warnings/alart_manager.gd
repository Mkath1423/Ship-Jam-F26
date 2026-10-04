extends Node2D
class_name AlertManager

var alert = preload("res://main/warnings/alert.tscn")

@export var player : Node2D
@export var camera : Camera2D

var alert_entities : Array[Node2D] = []

@export var alert_distance = 300
 
var time_to = 0

func update_alerts():
	for i in range(alert_entities.size() - 1, -1, -1):
		if not is_instance_valid(alert_entities[i]):
			alert_entities.remove_at(i)
	
	for c in get_children():
		c.queue_free()
	
	for e in alert_entities:
		if not get_viewport_rect().has_point(e.global_position):
			var to = (e.global_position - camera.get_screen_center_position()).normalized()
			var a : Node2D = alert.instantiate()
			a.global_position = alert_distance * to
			add_child(a)
	
func _process(delta: float) -> void:
	time_to -= delta
	if time_to <= 0:
		time_to += 0.1
		update_alerts()
	
