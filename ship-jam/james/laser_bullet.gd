extends Area2D

var speed : float = 0

const teams = preload("res://main/teams.gd")
var team : teams.team

var distance_before_despawn : float = 100000
var original_position : Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	original_position = position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += Vector2(sin(rotation), -cos(rotation)) * speed * delta
	
	# NOTE: DESPAWNING NOT THOUROUGHLY TESTED. IF LAG, CHECK HERE.
	var dist_from_spawnpoint = (original_position - position).length()
	if dist_from_spawnpoint >= distance_before_despawn:
		self.queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("hit_by_bullet"):
		body.hit_by_bullet(self)
		if "team" not in body or self.team != body.team:
			self.queue_free()
