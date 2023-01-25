extends KinematicBody2D
class_name Enemy

var motion: Vector2 = Vector2()

enum states {
	EAT
	WALK,
	PATROL,
	CHASE,
	DIE
}

var state: int = states.WALK

var player_ref
	
func _physics_process(delta: float) -> void:
	match state:
		states.CHASE:
			position += (player_ref.position - position)/75
		
			look_at(player_ref.position)
		
			move_and_collide(motion)
		states.DIE:
			queue_free()

# Change signal name to hitbox_body
func on_body_entered(body: Node) -> void:
	if "Bullet" in body.name:
			state = states.DIE

func on_DetectionArea_body_entered(body: Node) -> void:
	match body.name:
		"Player":
			player_ref = body
			state = states.CHASE

func on_DetectionArea_body_exited(body: Node) -> void:
	match body.name:
		"Player":
			player_ref = null

func on_area_shape_entered(_area_rid: RID, area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	match area.get_parent().name:
		"Flashlight":
			#Feels like shit way to get player ref :shrug:
			player_ref = area.get_parent().get_parent()
			state = states.CHASE
