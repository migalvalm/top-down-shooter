extends KinematicBody2D
class_name Player

enum states {
	WALK,
	AIM,
	RUN
}

onready var step_player: AudioStreamPlayer2D = get_node("Movement/StepPlayer")
onready var animation: AnimationPlayer = get_node("Animation")
onready var walk_timer: Timer = get_node("Movement/WalkTimer")
onready var flashlight_light: Light2D = get_node("Flashlight/Light")
onready var flashlight_area: Area2D = get_node("Flashlight/Area")

export var movespeed: int = 80
export var runspeed: int = 130
export var aim_movespeed: int = 20
export var cameraspeed: float = 0.8
export var footstep_file_base: String = "res://assets/sounds/steps/FootstepsConcrete"

onready var weapons: Array = get_node("Weapons").get_children()

var footstep_rng = RandomNumberGenerator.new()

### State Variables
var state: int = states.WALK
var weapon_inventory: Array = []
var selected_weapon: Node2D = null
var aiming: bool = false
var speed: int = movespeed
var speed_velocity: Vector2 = Vector2.ZERO

### Engine Functions
func _ready() -> void:
	footstep_rng.randomize()
	Input.set_default_cursor_shape(3)
	
	equip_weapon(weapons[0])

func _physics_process(delta: float) -> void:
	process_movement()
	process_actions()

### Movement Handler
func process_movement():
	var velocity: Vector2 = calculate_velocity()

	if velocity.length() == 0:
		animation.play("idle")
		step_player.stop()
		
	if velocity.length() != 0:
		match state:
			states.RUN:
				speed = runspeed
				step(0.25, "run")
			states.WALK:
				speed = movespeed
				step(0.4, "walk")
			states.AIM:
				speed = aim_movespeed
				step(0.9)
				
	process_mouse_input()
	
	speed_velocity = move_and_slide(velocity.normalized() * speed)

### Action Management
func process_actions() -> void:
	process_equip()
	process_aim()
	process_fire()
	process_flashlight()
	if !is_aiming(): process_run()

### Input Validators - PlayerInput node
func process_mouse_input() -> void:
	var mousePos = get_global_mouse_position()
	var space = get_world_2d().direct_space_state

	if space.intersect_point(mousePos, 1):
		if "Player" in space.intersect_point(mousePos, 1).pop_front().collider.name:
			speed = 20
		if "WallMap" in space.intersect_point(mousePos, 1).pop_front().collider.name:
			flashlight_light
			
	look_at(mousePos)
	
func process_aim() -> void:
	if Input.is_action_pressed("aim"):
		selected_weapon.aim(animation)
			
		state = states.AIM
	
	if Input.is_action_just_released("aim"):
		state = states.WALK

func process_fire() -> void:
	if Input.is_action_just_pressed("fire") and is_aiming():
		shoot(selected_weapon)

func process_flashlight() -> void:	
	if Input.is_action_just_pressed("toggle_flashlight"):
		flashlight_light.enabled = !flashlight_light.enabled 
		flashlight_area.monitoring = flashlight_light.enabled

func process_run() -> void:
	if Input.is_action_pressed("run") and !is_running() and is_walking():
		state = states.RUN
		
	elif !Input.is_action_pressed("run") and is_running():
		state = states.WALK

# Move this input validator function to WeaponInventoryController
func process_equip() -> void:
	if Input.is_action_just_pressed("weapon_1"):
		selected_weapon = weapons[0]
	elif Input.is_action_just_pressed("weapon_2"):
		selected_weapon = weapons[1]
	elif Input.is_action_just_pressed("weapon_3"):
		selected_weapon = weapons[2]
		
		
### Action Functions - PlayerAction node
func step(step_time: float, step_animation = "") -> void:
	if !step_animation.empty():
		animation.play(step_animation) 
		
	if walk_timer.is_stopped() and !step_player.playing:
		step_player.pitch_scale = rand_range(0.3, 0.4)
		step_player.stream = SoundPlayer.get_random_soundfile(footstep_rng, [1,3], footstep_file_base)
		step_player.play()
		walk_timer.start(step_time)

func shoot(gun: BaseWeapon) -> void:
	gun.fire()

func reload(gun: BaseWeapon) -> void:
	gun.reload()
	
func equip_weapon(gun) -> void:
	selected_weapon = gun
	selected_weapon.connect("no_ammo", self, "on_no_ammo")
	
func kill():
	get_tree().reload_current_scene()

### Helpers Functions - HelperClass
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

### Helpers State - PlayerState node
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
	step_player.stop()

func on_no_ammo() -> void:
	reload(selected_weapon)
