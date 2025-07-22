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
	{"name" = "airi", "path" = "res://assets/models/airi/airi.glb"},
	{"name" = "viona", "path" = "res://assets/models/viona/viona.glb"}
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



	ModelRegistry.face = placeholder.get_node("Root/Model/Armature/Skeleton3D/Face")
	ModelRegistry.camera = placeholder.get_parent().get_node("Camera3D")
	var face_position = ModelRegistry.face.global_transform.origin
	ModelRegistry.camera.look_at(face_position, Vector3.UP)
	var target = ModelRegistry.face.global_transform.origin

	var vertical_offset = 0.6
	var backward_offset = 0.4

	var dir_to_face = (ModelRegistry.camera.global_transform.origin - target).normalized()
	ModelRegistry.camera.global_transform.origin = target + dir_to_face * backward_offset + Vector3.UP * vertical_offset
	ModelRegistry.camera.look_at(target, Vector3.ZERO)
	ModelRegistry.camera.rotation_degrees = Vector3(0, 0, 0)

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
