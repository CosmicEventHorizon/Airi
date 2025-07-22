extends Control

signal prompt_submitted(prompt: String)

@onready var prompt_te = get_node("/root/Main/UI/Panel/TextEdit")
@onready var prompt_btn = get_node("/root/Main/UI/Panel/Button")


func _ready():
	prompt_btn.pressed.connect(on_prompt_btn_pressed)


func _process(_delta: float) -> void:
	if OS.get_name() not in ["Android", "iOS"]:
		return
	var keyboard_height := DisplayServer.virtual_keyboard_get_height()
	self.size.y = get_viewport_rect().size.y - (keyboard_height / get_viewport_transform().get_scale().y)

func on_prompt_btn_pressed():
	var prompt = prompt_te.text.strip_edges()
	if prompt != "":
		emit_signal("prompt_submitted", prompt)
		prompt_te.clear() 
