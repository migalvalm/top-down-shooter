extends KinematicBody2D
class_name Enemy

onready var wander_controller = $WanderController
var motion: Vector2 = Vector2()
var speed: int = 100
var rotation_speed: float = 8.0

signal kill

enum states {
	IDLE,
	EAT,
	WALK,
	PATROL,
	CHASE,
	ALERT,
	DIE
}

var state: int = states.IDLE
var state_rng = RandomNumberGenerator.new()

var player_ref

func _physics_process(delta: float) -> void:
	match state:
		states.IDLE:
			pick_random_state([states.IDLE])
		states.ALERT:
			state = states.CHASE
		states.CHASE:
			look_at(player_ref.global_position)
			motion = global_position.direction_to(player_ref.global_position) * speed * delta
			move_and_collide(motion)
		states.WALK:
			pass
		states.DIE:
			emit_signal("kill")
			queue_free()

func rotate_to_target(target_position, delta):
	var direction = (target_position - global_position)
	var angle_to = transform.x.angle_to(direction)
	rotate(sign(angle_to) * min(delta * rotation_speed, abs(angle_to)))

func pick_random_state(states: Array) -> void:
	state_rng.randomize()
	states.shuffle()
	
	state = states[state_rng.randi_range(0,0)]
	
# Change signal name to hitbox_body
func on_body_entered(body: Node) -> void:
	if "Bullet" in body.name:
			state = states.DIE

func on_DetectionArea_body_entered(body: Node) -> void:
	match body.name:
		"Player":
			if !player_ref:
				player_ref = body

				state = states.ALERT
		
func _on_DetectionArea_body_exited(body: Node) -> void:
	match body.name:
		"Player":
			player_ref = null
			state = states.IDLE
