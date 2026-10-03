extends Node

@export var bullet : PackedScene
@export var world : Node2D

func spawn_bullet(position, speed, rotation):
	var node = bullet.instantiate()
	node.position = position
	node.speed = speed
	node.rotation = rotation
	world.add_child(node)
	return node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
