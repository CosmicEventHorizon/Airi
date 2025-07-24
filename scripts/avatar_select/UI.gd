extends Control

#nodes
@onready var model_rtl = get_node("/root/AvatarSelect/UI/Panel/CenterPanel/ModelRichTextLabel/") as RichTextLabel
@onready var left_btn = get_node("/root/AvatarSelect/UI/Panel/LeftPanel/LeftButton")
@onready var right_btn = get_node("/root/AvatarSelect/UI/Panel/RightPanel/RightButton")
@onready var back_btn = get_node("/root/AvatarSelect/UI/Panel/LeftPanel/BackButton")
@onready var upload_btn = get_node("/root/AvatarSelect/UI/Panel/CenterPanel/UploadButton")
@onready var choose_btn = get_node("/root/AvatarSelect/UI/Panel/RightPanel/ChooseButton")

var current_idx = 0

func _ready():
	current_idx = Load.selected_model_idx
	update_ui(Load.models[Load.selected_model_idx]["name"])
	#connect singals
	left_btn.pressed.connect(on_left_btn_pressed)
	right_btn.pressed.connect(on_right_btn_pressed)
	back_btn.pressed.connect(on_back_btn_pressed)
	upload_btn.pressed.connect(on_upload_btn_pressed)
	choose_btn.pressed.connect(on_choose_btn_pressed)


func on_left_btn_pressed():
	current_idx -= 1
	if current_idx < 0:
		current_idx = Load.models.size() - 1
	var load_scene = Load.load_glb(Load.models[current_idx]["path"], ModelRegistry.placeholder)
	update_ui(Load.models[current_idx]["name"])


func on_right_btn_pressed():
	current_idx = (current_idx + 1) % Load.models.size()
	var load_scene = Load.load_glb(Load.models[current_idx]["path"], ModelRegistry.placeholder)
	update_ui(Load.models[current_idx]["name"])

func on_back_btn_pressed():
	var main_scene = load("res://scenes/Main.tscn")
	get_tree().change_scene_to_packed(main_scene)


func on_upload_btn_pressed():
	var dialog = FileDialog.new()
	dialog.access=FileDialog.ACCESS_FILESYSTEM
	dialog.filters = ["*.glb"]
	dialog.file_selected.connect(save_model)
	add_child(dialog)
	dialog.popup_centered()

	
	
func save_model(path: String):
	var filename = path.get_file().get_basename()
	var config  = ConfigFile.new()
	config.set_value("MODELS", filename, path)
	var err = config.save(Load.MODELS_LOCATION)
	if err != OK:
		Console.show_error("[AvatarSelect/UI] failed to write to file")


func update_ui(model: String):
	model_rtl.clear()
	model_rtl.bbcode_enabled = true
	var formatted_message = "[center][color=red][font_size=20]" + model + "[/font_size][/color][/center]"
	model_rtl.append_text(formatted_message)


func on_choose_btn_pressed():
	var config  = ConfigFile.new()
	var load_err = config.load(Load.MODELS_LOCATION)
	if load_err != OK:
		Console.show_debug("[AvatarSelect/UI] models.cfg not found, creating one")
	config.set_value("MODEL_CHOICE", "selected_model_idx", current_idx)
	var save_err = config.save(Load.MODELS_LOCATION)
	if save_err != OK:
		Console.show_error("[AvatarSelect/UI] failed to write to file")
	else:
		Console.show_debug("[AvatarSelect/UI] saved configuration")
	on_back_btn_pressed()
