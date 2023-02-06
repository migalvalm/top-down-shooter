extends Node2D

onready var timer = $Timer
export(int) var wander_range = 32

onready var start_position = position
onready var target_position;

var last_position = position

func _ready() -> void:
	update_target_position()

func update_target_position():
	var target_vector = Vector2(0, rand_range(-wander_range, wander_range))
	target_position = start_position + target_vector

func reach_target_position():
	return position.distance_to(target_position) <= 0.5

func get_timeleft():
	return timer.time_left
	
func start_wait_time(duration):
	timer.start(duration)
	
func _on_timer_timeout() -> void:
	start_position = target_position
	update_target_position()
