extends ParallaxBackground


onready var road_sprite = get_node("RoadLayer/Sprite") as Sprite

func load_texture(road_texture: Texture) -> void:
	road_sprite.texture = road_texture
