extends Control

signal prompt_submitted(prompt: String)

@onready var prompt_te = get_node("/root/Main/UI/Panel/TextEdit")
@onready var prompt_btn = get_node("/root/Main/UI/Panel/Button")

func _ready():
	prompt_btn.pressed.connect(on_prompt_btn_pressed)


func on_prompt_btn_pressed():
	var prompt = prompt_te.text.strip_edges()
	if prompt != "":
		emit_signal("prompt_submitted", prompt)
		prompt_te.clear() 
