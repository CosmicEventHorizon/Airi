extends Node3D

#scripts
@onready var ui = get_node("/root/Main/UI")
@onready var nlp = get_node("/root/Main/NLPClient")
@onready var tts = get_node("/root/Main/TTSManager")
@onready var avatar = get_node("/root/Main/Avatar/AvatarController")
@onready var anim_selector = get_node("/root/Main/LogicManager/AnimationSelector")

#nodes
@onready var anim_player = get_node("/root/Main/Avatar/Airi/AvatarSample_E/AnimationPlayer")
@onready var settings_btn = get_node("/root/Main/UI/SettingsSceneButton")
@onready var console = get_node("/root/Main/UI/Panel/Console") 


func _ready():
	print("[Main] Ready")
	
	#conenct signals
	ui.prompt_submitted.connect(on_prompt_submitted)
	settings_btn.pressed.connect(on_settings_btn_pressed)
	
	#loop idle animation
	anim_player.play("idle")
	anim_player.get_animation("idle").loop = true


func on_settings_btn_pressed():
	get_tree().root.add_child(load("res://scenes/Settings.tscn").instantiate())


func on_prompt_submitted(prompt: String) -> void:
	Globals.register_debug_console(console)
	Globals.register_error_console(console)
	Globals.show_debug("[Main] User prompt received: " + prompt)

	Globals.show_debug("[Main] Sending prompt to NLP...")
	SettingsLoad.load_settings()
	var response = await nlp.get_response(prompt,SettingsLoad.settings["system_prompt"])
	
	if response == null:
		Globals.show_error("[Main] Failed to recieve a response from the API")
		return
	
	Globals.show_debug("[Main] Translating response to JP...")
	var response_jp = await nlp.get_response(response, Globals.EN_JP_TRANSLATOR_PROMPT)

	if response_jp == null:
		Globals.show_error("[Main] Failed to recieve a response from the API")
		return

	Globals.show_debug("[Main] Sending response to TTS...")
	var result = await tts.speak(prompt, response, response_jp)
	if result == null:
		Globals.show_error("[Main] Failed to play TTS data.")
