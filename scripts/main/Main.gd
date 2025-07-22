extends Node3D

#scripts
@onready var ui = get_node("/root/Main/UI")
@onready var nlp = get_node("/root/Main/NLPClient")
@onready var tts = get_node("/root/Main/TTSManager")
@onready var avatar = get_node("/root/Main/Avatar/AvatarController")
@onready var anim_selector = get_node("/root/Main/LogicManager/AnimationSelector")

#nodes
@onready var settings_btn = get_node("/root/Main/UI/MenuPanel/SettingsSceneButton")
@onready var avatar_select_btn = get_node("/root/Main/UI/MenuPanel/AvatarSelectSceneButton")
@onready var console = get_node("/root/Main/UI/Panel/Console") 
@onready var placeholder = get_node("/root/Main/Avatar/ModelPlaceholder")


func _ready():
	Load.load_models()
	var selected_model = Load.models[Load.selected_model_idx]
	Load.load_glb(selected_model["path"], placeholder)
	print("[Main] Ready")
	
	#load model nodes
	ModelRegistry.anim_player = get_node("/root/Main/Avatar/ModelPlaceholder/Root/AnimationPlayer")
	ModelRegistry.model_mth = get_node("/root/Main/Avatar/ModelPlaceholder/Root/Model/Armature/Skeleton3D/Face")
	
	#conenct signals
	ui.prompt_submitted.connect(on_prompt_submitted)
	settings_btn.pressed.connect(on_settings_btn_pressed)
	avatar_select_btn.pressed.connect(on_avatar_select_btn_pressed)
	
	#loop idle animation
	ModelRegistry.anim_player.play("idle")
	ModelRegistry.anim_player.get_animation("idle").loop = true


func on_settings_btn_pressed():
	get_tree().root.add_child(load("res://scenes/Settings.tscn").instantiate())

func on_avatar_select_btn_pressed():
	var avatar_select_scene = load("res://scenes/AvatarSelect.tscn")
	get_tree().change_scene_to_packed(avatar_select_scene)

func on_prompt_submitted(prompt: String) -> void:
	Console.register_debug_console(console)
	Console.register_error_console(console)
	Console.show_debug("[Main] User prompt received: " + prompt)

	Console.show_debug("[Main] Sending prompt to NLP...")
	Load.load_settings()
	var response = await nlp.get_response(prompt,Load.settings["system_prompt"])
	
	if response == null:
		Console.show_error("[Main] Failed to recieve a response from the API")
		return
	
	Console.show_debug("[Main] Translating response to JP...")
	var response_jp = await nlp.get_response(response, Console.EN_JP_TRANSLATOR_PROMPT)

	if response_jp == null:
		Console.show_error("[Main] Failed to recieve a response from the API")
		return

	Console.show_debug("[Main] Sending response to TTS...")
	var result = await tts.speak(prompt, response, response_jp)
	if result == null:
		Console.show_error("[Main] Failed to play TTS data.")
