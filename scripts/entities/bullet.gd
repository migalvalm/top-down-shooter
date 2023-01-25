extends RigidBody2D

func on_body_entered(body: Node) -> void:
	queue_free()
