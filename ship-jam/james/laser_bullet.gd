extends Area2D

var speed : float = 0

const teams = preload("res://main/teams.gd")
var team : teams.team

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += Vector2(sin(rotation), -cos(rotation)) * speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("hit_by_bullet"):
		body.hit_by_bullet(self)
		if "team" not in body or self.team != body.team:
			self.queue_free()
