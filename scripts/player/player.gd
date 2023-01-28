extends KinematicBody2D
class_name Player

enum states {
	WALK,
	AIM,
	RUN
}

onready var audio_player: AudioStreamPlayer2D = get_node("AudioPlayer")
onready var animation: AnimationPlayer = get_node("Animation")
onready var walk_timer: Timer = get_node("WalkTimer")
onready var flashlight_light: Light2D = get_node("Flashlight/Light")
onready var flashlight_area: Area2D = get_node("Flashlight/Area")
onready var bullet_spawn_point: Position2D = get_node("BulletSpawnPoint")

export var movespeed: int = 80
export var runspeed: int = 130
export var aim_movespeed: int = 20
export var cameraspeed: float = 0.8
export var bullet_speed: int = 2000
export var footstep_file_base: String = "res://assets/sounds/steps/FootstepsConcrete"

var bullet: Resource  = preload('res://scenes/entities/bullet.tscn')
var footstep_rng = RandomNumberGenerator.new()

### State Variables
var state: int = states.WALK
var aiming: bool = false
var speed: int = movespeed

func _ready() -> void:
	footstep_rng.randomize()
	Input.set_default_cursor_shape(3)

func get_mouse_input() -> void:
	var mousePos = get_global_mouse_position()
	var space = get_world_2d().direct_space_state

	if space.intersect_point(mousePos, 1):
		if "Player" in space.intersect_point(mousePos, 1).pop_front().collider.name:
			speed = 0
		if "WallMap" in space.intersect_point(mousePos, 1).pop_front().collider.name:
			flashlight_light
			
	look_at(mousePos)

func _physics_process(delta: float) -> void:
	process_movement()
	process_actions()

### Movement Handler
func process_movement():
	var velocity: Vector2 = calculate_velocity()

	if velocity.length() == 0:
		animation.play("idle")
		audio_player.stop()
		
	if velocity.length() != 0:
		match state:
			states.RUN:
				speed = runspeed
				step(0.35)
			states.WALK:
				speed = movespeed
				step(0.4)
			states.AIM:
				speed = aim_movespeed
				step(0.9)
				
	get_mouse_input()
	
	move_and_slide(velocity.normalized() * speed)

### Action Management
func process_actions() -> void:
	process_aim()
	process_fire()
	process_flashlight()
	if !is_aiming(): process_run()

### Input Validators
func process_aim() -> void:
	if Input.is_action_pressed("aim"):
		animation.play("aim")
		state = states.AIM
	
	if Input.is_action_just_released("aim"):
		state = states.WALK

func process_fire() -> void:
	if Input.is_action_just_pressed("fire") and is_aiming():
		var bullet_instance: RigidBody2D = bullet.instance()
		bullet_instance.position = bullet_spawn_point.global_position
		bullet_instance.rotation_degrees = rotation_degrees
		bullet_instance.apply_impulse(Vector2(), Vector2(bullet_speed, 1).rotated(rotation))
		
		get_tree().get_root().call_deferred("add_child", bullet_instance)

func process_flashlight() -> void:	
	if Input.is_action_just_pressed("toggle_flashlight"):
		flashlight_light.enabled = !flashlight_light.enabled 
		flashlight_area.monitoring = flashlight_light.enabled

func process_run() -> void:
	if Input.is_action_pressed("run") and !is_running() and is_walking():
		state = states.RUN
		
	elif !Input.is_action_pressed("run") and is_running():
		state = states.WALK

### Behavior Functions
func step(step_time: float) -> void:
	animation.play("walk")
	if walk_timer.is_stopped() and !audio_player.playing:
		audio_player.pitch_scale = rand_range(0.3, 0.4)
		var filename_number = [1,3][RandomNumberGenerator.new().randi_range(0,1)]
		audio_player.stream = SoundPlayer.load_audio_file(footstep_file_base + str(filename_number) + ".wav", false)
		audio_player.play()
		walk_timer.start(step_time)

func kill():
	get_tree().reload_current_scene()

### Helpers Functions
func calculate_velocity() -> Vector2:
	var velocity = Vector2()
	var vel_x = Input.get_action_strength("right") - Input.get_action_strength("left")
	var vel_y = Input.get_action_strength("down") - Input.get_action_strength("up")
	
	if vel_x > 0:
		#right
		pass
	elif vel_x < 0:
		#left
		pass
	elif vel_y > 0:
		#down
		pass
	elif vel_y < 0:
		#up
		pass
		
	velocity = Vector2(vel_x, vel_y)
	
	return velocity

### Helpers State
func is_aiming() -> bool:
	return state == states.AIM

func is_walking() -> bool:
	return state == states.WALK

func is_running() -> bool:
	return state == states.RUN

### Signals functions
func on_body_entered(body: Node) -> void:
	if "Enemy" in body.name:
			kill()

func on_timer_timeout() -> void:
	audio_player.stop()
