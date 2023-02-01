extends Node

export(Texture) var road_texture;
export var camera_velocity: Vector2 = Vector2(0,0)

onready var road_parallax = $RoadParallax
onready var wall_area = $WallArea


func _ready():
	road_parallax.load_texture(road_texture)
	
func _physics_process(delta: float) -> void:
	for children in get_parent().get_children():
		if children.name == "Player":
			# Because Y Axis here is inverted, so top is -1, and bottom 1
			# So the -, is there to make the value correspond to godot axis
			# If y > 0, -(y) = -y
			# If y < 0, -(-y) = y
			camera_velocity = Vector2(0, children.position.y)
			wall_area.position = Vector2(0, children.position.y)
				
	var new_offset: Vector2 = road_parallax.get_scroll_offset() + camera_velocity * delta

	road_parallax.set_scroll_offset(new_offset)

