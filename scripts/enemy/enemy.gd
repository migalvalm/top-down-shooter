extends KinematicBody2D
class_name Enemy

onready var wander_controller = $WanderController
var motion: Vector2 = Vector2()
var speed: int = 200
var rotation_speed: float = 8.0

enum states {
	IDLE,
	EAT,
	WALK,
	PATROL,
	CHASE,
	DIE
}

var state: int = states.IDLE
var state_rng = RandomNumberGenerator.new()

var player_ref
	
func _physics_process(delta: float) -> void:
	match state:
		states.IDLE:
			pick_random_state([states.IDLE, states.WALK])

		states.CHASE:
			position += (player_ref.position - position)/80
			rotate_to_target(player_ref.global_position, delta)
		
			move_and_collide(motion)
		states.WALK:
			if wander_controller.get_time_left() == 0:
				wander_controller.start_wander_timer(rand_range(10, 20))
			
				rotate_to_target(wander_controller.target_position, delta)
				
				motion = position.direction_to(wander_controller.target_position) * speed * delta
				
				move_and_collide(motion)
			
				if global_position.distance_to(wander_controller.target_position) <= 4:
					state = states.IDLE
					wander_controller.start_wander_timer(rand_range(1, 3))

		states.DIE:
			queue_free()

func rotate_to_target(target_position, delta):
	var direction = (target_position - global_position)
	var angle_to = transform.x.angle_to(direction)
	rotate(sign(angle_to) * min(delta * rotation_speed, abs(angle_to)))

func pick_random_state(states: Array) -> void:
	state_rng.randomize()
	states.shuffle()
	
	state = states[state_rng.randi_range(0,1)]
	
# Change signal name to hitbox_body
func on_body_entered(body: Node) -> void:
	if "Bullet" in body.name:
			state = states.DIE

func on_DetectionArea_body_entered(body: Node) -> void:
	match body.name:
		"Player":
			player_ref = body
			state = states.CHASE
		
func on_area_shape_entered(_area_rid: RID, area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	match area.get_parent().name:
		"Flashlight":
			#Feels like shit way to get player ref :shrug:
			player_ref = area.get_parent().get_parent()
			state = states.CHASE

func _on_DetectionArea_body_exited(body: Node) -> void:
	match body.name:
		"Player":
			player_ref = null
			state = states.IDLE
