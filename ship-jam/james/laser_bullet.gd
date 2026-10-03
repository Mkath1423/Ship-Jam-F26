extends Area2D

var speed : float = 0

const bullet_types = preload("res://main/bullets/bullet_types.gd")

var bullet_type : bullet_types.bullet_types

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += Vector2(sin(rotation), -cos(rotation)) * speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("hit_by_bullet"):
		body.hit_by_bullet(self)
