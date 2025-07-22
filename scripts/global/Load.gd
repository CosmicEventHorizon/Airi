extends Node

const SETTINGS_LOCATION = "user://settings.cfg"
const MODELS_LOCATION = "user://models.cfg"

var settings = {
	"api_key" = "",
	"system_prompt" = "",
	"ollama_ip_address" = "",
	"ollama_model" = "",
	"option" = 0
}

var models = [
	{"name" = "airi", "path" = "res://assets/models/airi/airi.mdl"},
	{"name" = "viona", "path" = "res://assets/models/viona/viona.mdl"}
]

var selected_model_idx = 1


func _ready():
	load_settings()


func load_settings():
	var config = ConfigFile.new()
	var err = config.load(SETTINGS_LOCATION)
	if err != OK:
		Console.show_debug("No saved settings falling back to default")
		return
	for key in settings.keys():
		settings[key] = config.get_value("SETTINGS", key, settings[key])

func load_models():
	var config = ConfigFile.new()
	var err = config.load(MODELS_LOCATION)
	if err != OK:
		Console.show_debug("No saved models falling back to default")
		return
	selected_model_idx = config.get_value("MODEL_CHOICE", "selected_model_idx", 1)
	if !config.has_section("MODELS"):
		Console.show_debug("No saved models falling back to default")
		return
	var keys: PackedStringArray = config.get_section_keys("MODELS")
	for key in keys:
		var path = config.get_value("MODELS", key, "")
		if FileAccess.file_exists(path):
			models.append({"name" = key, "path" = path })
		else:
			config.erase_section_key("MODELS", key)


func load_glb(glb_path: String, placeholder: Node):
	var file = FileAccess.open(glb_path, FileAccess.READ)
	if not file:
		Console.show_error("Failed to open GLB at " + glb_path)
		return

	var gltf = GLTFDocument.new()
	var state = GLTFState.new()
	
	var err = gltf.append_from_buffer(file.get_buffer(file.get_length()), "", state)
	if err != OK:
		Console.show_error("GLTF parse error.")
		return

	var model_scene = gltf.generate_scene(state)
	if not model_scene:
		Console.show_error("Failed to generate scene from GLB.")
		return

	while placeholder.get_child_count() > 0:
		var child = placeholder.get_child(0)
		placeholder.remove_child(child)
		child.queue_free()

	placeholder.add_child(model_scene)
	print(placeholder.get_child(0).name)
	if placeholder.get_child(0).name != "Root":
		placeholder.get_child(0).name = "Root"

	ModelRegistry.skeleton = placeholder.get_node("Root/Model/Armature/Skeleton3D")
	ModelRegistry.camera = placeholder.get_parent().get_node("Camera3D")
	var skeleton = ModelRegistry.skeleton
	var model = ModelRegistry.skeleton.get_parent().get_parent()  

	var bone_name = ""
	var pattern = RegEx.new()
	pattern.compile("(?i)(face)")  

	for i in range(skeleton.get_bone_count()):
		var name = skeleton.get_bone_name(i)
		if pattern.search(name) != null:
			bone_name = name
			break

	if bone_name != "":
		var bone_index = skeleton.find_bone(bone_name)
		var face_position = skeleton.get_bone_global_pose(bone_index).origin

		var model_forward = -model.global_transform.basis.z.normalized()

		var backward_offset = 0.6
		var camera_position = face_position - model_forward * backward_offset
		camera_position.y = face_position.y 

		ModelRegistry.camera.global_transform.origin = camera_position
		ModelRegistry.camera.look_at(face_position, Vector3.UP)
	else:
		print("No bone with 'face' found.")

	ModelRegistry.anim_player = placeholder.get_node("Root/AnimationPlayer")
	ModelRegistry.anim_player.play("idle")
	ModelRegistry.anim_player.get_animation("idle").loop = true


	print_node_tree(placeholder)
	return model_scene

func print_node_tree(node: Node, indent: int = 0):
	print("  ".repeat(indent) + node.name + " (" + node.get_class() + ")")
	for child in node.get_children():
		if child is Node:
			print_node_tree(child, indent + 1)
