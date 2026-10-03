class_name EnemyShip extends CharacterBody2D

@export var max_acceleration : float = 500
@export var max_speed : float = 1000

func set_state(rotation):
	$Sprite2D.rotation_degrees = rotation
