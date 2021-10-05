extends Camera

export(NodePath) var cam_path
onready var cam = get_node(cam_path)

func _process(delta):
	global_transform = cam.global_transform
