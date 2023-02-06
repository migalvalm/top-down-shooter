extends Node2D
class_name BaseWeapon

onready var reload_timer = get_node("ReloadTimer")

#Preloads
var bullet_rng = RandomNumberGenerator.new()
var bullet = preload("res://scenes/entities/bullet.tscn")

export var weapon_ammo = 7
export var bullet_damage = 10
export var impact_vector: Vector2 = Vector2(0,30)
export var reload_time: float = 0.5
export var bullet_speed: int = 2000
export var bullet_file_base: String = "res://assets/sounds/bang-sfx/bang_"
export(Array) var bullet_soundfile_numbers: Array = ["07"]

#State Variables
var current_ammo = weapon_ammo
var reloading = false

signal no_ammo

func _ready() -> void:
	bullet_rng.randomize()	
	
func fire():
	can_shoot()

func can_shoot():
	print("Weapon Current Ammo: ", current_ammo)
	print("Weapon Reloading: ", reloading)
	if current_ammo <= 0 and !reloading: emit_signal("no_ammo")
	elif reloading: pass
	else: shoot()
	
func shoot():	
	var bullet_instances: Array = []
	var spawn_positions: Node2D = get_node("SpawnPoints")
	
	for position in spawn_positions.get_children():
		if position.name.match("SpawnPoint?"):
			var bullet_instance = bullet.instance()
			
			print("bullet: ", position.global_position)
			bullet_instance.position = position.global_position
			
			bullet_instances.push_back(bullet_instance)
			
	
	for bullet_instance in bullet_instances:
		#Generate and play sound
		SoundPlayer.play_sound(
			SoundPlayer.get_random_soundfile(
				bullet_rng, 
				bullet_soundfile_numbers,
				bullet_file_base,
				".ogg"
			),
			-4,
		rand_range(0.8, 0.95)
		)
			
		#Apply rotation and impluse
		bullet_instance.apply_impulse(Vector2(), Vector2(bullet_speed, 1).rotated(get_player().rotation))
	
	
		get_tree().get_root().call_deferred("add_child", bullet_instance)
	
	current_ammo -= bullet_instances.size()
	
	#Impact
	get_player().move_and_slide(
		(Vector2(global_position.x, global_position.y).normalized() + 
		impact_vector
	) * 100)

func reload():
	reloading = true
	reload_timer.start(0.5)

func aim(animation_player: AnimationPlayer):
	pass

func is_reloading():
	return reloading
	
func get_player():
	return get_parent().get_parent()


func on_reload_timer_timeout() -> void:
	reloading = false
	current_ammo = weapon_ammo
