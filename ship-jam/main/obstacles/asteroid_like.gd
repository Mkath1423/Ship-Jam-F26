extends Node2D

@export var health = 4
@onready var hit_particles = preload("res://main/obstacles/hit.tscn")
@onready var death = preload("res://main/obstacles/death.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if health <= 0:
		self.queue_free()

func animate_hit(pos):
	var node : CPUParticles2D = hit_particles.instantiate()
	add_child(node)
	node.position = Vector2.ZERO
	node.rotation = (pos - global_position).angle()
	node.emitting = true
	node.finished.connect(func(): node.queue_free())

func hit_by_bullet(bullet):
	health -= 1
	animate_hit(bullet.global_position)
	print("hit asteroid")
