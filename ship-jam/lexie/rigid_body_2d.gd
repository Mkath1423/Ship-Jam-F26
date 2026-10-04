extends RigidBody2D

var teleport_requested : bool = false
var teleport_offset : Vector2 

func _on_body_entered(body: Node) -> void:
	print("ROCK HIT A ", body.name)

func teleport_by(offset : Vector2):
	teleport_requested = false
	teleport_offset = offset

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if teleport_requested:
		print("processed tele")
		state.linear_velocity = Vector2.ZERO
		state.angular_velocity = 0
		teleport_requested = false
	else:
		# Fall back to Godot's default force integration
		state.integrate_forces()
