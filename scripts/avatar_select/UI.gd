extends Control

#nodes
@onready var model_rtl = get_node("/root/AvatarSelect/UI/Panel/CenterPanel/ModelRichTextLabel/") as RichTextLabel
@onready var left_btn = get_node("/root/AvatarSelect/UI/Panel/LeftPanel/LeftButton")
@onready var right_btn = get_node("/root/AvatarSelect/UI/Panel/RightPanel/RightButton")
@onready var preview_btn = get_node("/root/AvatarSelect/UI/Panel/CenterPanel/PreviewButton")
@onready var upload_btn = get_node("/root/AvatarSelect/UI/Panel/LeftPanel/UploadButton")
@onready var choose_btn = get_node("/root/AvatarSelect/UI/Panel/RightPanel/ChooseButton")


func _ready():
	update_ui("airi")
	#connect singals
	left_btn.pressed.connect(on_left_btn_pressed)
	right_btn.pressed.connect(on_right_btn_pressed)
	preview_btn.pressed.connect(on_preview_btn_pressed)
	upload_btn.pressed.connect(on_upload_btn_pressed)
	choose_btn.pressed.connect(on_choose_btn_pressed)



func on_left_btn_pressed():
	pass
func on_right_btn_pressed():
	pass
func on_preview_btn_pressed():
	pass
func on_upload_btn_pressed():
	var dialog = FileDialog.new()
	dialog.access=FileDialog.ACCESS_FILESYSTEM
	dialog.filters = ["*.glb"]
	dialog.file_selected.connect(save_model)
	
func save_model(path: String):
	var name = path.get_file().get_basename()
	var config  = ConfigFile.new()
	config.set_value("MODELS", name, path)
	


func update_ui(model: String):
	model_rtl.clear()
	model_rtl.bbcode_enabled = true
	var formatted_message = "[center][color=red][font_size=20]" + model + "[/font_size][/color][/center]"
	model_rtl.append_text(formatted_message)


func on_choose_btn_pressed():
	pass
