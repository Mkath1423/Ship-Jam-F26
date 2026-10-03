class_name EnemyShip extends CharacterBody2D

@export var max_acceleration : float = 500
@export var max_speed : float = 1000

var is_dying : bool = false

const teams = preload("res://main/teams.gd")
var team : teams.team = teams.team.Enemy

func set_state(rotation):
	$Sprite2D.rotation_degrees = rotation

func hit_by_bullet(bullet):
	if bullet.team == teams.team.Player:
		is_dying = true
		print(true)
