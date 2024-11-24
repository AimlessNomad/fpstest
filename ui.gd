extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	$CenterContainer.size = get_node("..").get_tree().root.get_visible_rect().size
