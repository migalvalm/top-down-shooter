extends Node2D

# Starting range of possible offsets using random values
export var RANDOM_SHAKE_STRENGTH: float = 30.0
# Multiplier for lerping the shake strength to zero
export var SHAKE_DECAY_RATE: float = 5.0
# How quickly to move through the noise
export var NOISE_SHAKE_SPEED: float = 30.0
# Noise returns values in range [-1, 1]
# So this is how much to multiply the returned value by
export var NOISE_SHAKE_STRENGTH: float = 60.0

export(NodePath) onready var camera = get_node(camera) as Camera2D
onready var rand = RandomNumberGenerator.new()
onready var noise = OpenSimplexNoise.new()


var noise_l: float = 0.0
var shake_strength: float = 0.0

func _ready() -> void:
	rand.randomize()
	
	noise.seed = rand.randi()
	noise.period = 2
	
func apply_shake(strength: float) -> void:
	shake_strength = strength

func _process(delta: float) -> void:
	# Fade out the intensity over time
	shake_strength = lerp(shake_strength, 0, SHAKE_DECAY_RATE * delta) 
	
	# Shake by adjusting camera_offset so we can move the camera around
	# via its position property
	camera.offset = get_noise_offset(delta)

func get_noise_offset(delta: float) -> Vector2:
	noise_l += delta * NOISE_SHAKE_SPEED
	
	# Set the x values of each call to 'get_noise_2d' to a different value
	# So that our x and y vectors will be reading the unrelated areas of noise
	return Vector2(
		noise.get_noise_2d(1, noise_l) * shake_strength,
		noise.get_noise_2d(100, noise_l) * shake_strength
	)
