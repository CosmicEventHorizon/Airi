extends Node3D

#
@onready var placeholder = get_node("/root/AvatarSelect/Preview/ModelPlaceholder")

func _ready():
	ModelRegistry.placeholder = placeholder
	var load_scene = Load.load_glb(Load.models[Load.selected_model_idx]["path"], ModelRegistry.placeholder)
	
