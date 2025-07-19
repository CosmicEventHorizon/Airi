extends Control

#scripts
@onready var nlp = get_node("/root/Main/NLPClient")

#nodes
@onready var field_nodes = {
	"api_key" = get_node("/root/Settings/SettingsUI/ColorRect/APIPanel/TextEdit"),
	"system_prompt" = get_node("/root/Settings/SettingsUI/ColorRect/SystemPromptPanel/TextEdit"),
	"ollama_ip_address" = get_node("/root/Settings/SettingsUI/ColorRect/IPAddressPanel/TextEdit"),
	"ollama_model" = get_node("/root/Settings/SettingsUI/ColorRect/ModelPanel/TextEdit"),
	"option" = get_node("/root/Settings/SettingsUI/ColorRect/OptionsPanel/OptionsButton")	
}
@onready var console = get_node("/root/Settings/SettingsUI/ColorRect/ButtonsPanel/Console") as RichTextLabel
@onready var save_btn = get_node("/root/Settings/SettingsUI/ColorRect/ButtonsPanel/SaveButton")
@onready var back_btn = get_node("/root/Settings/SettingsUI/ColorRect/ButtonsPanel/BackButton")

var api_endpoints = ["Ollama", "OpenAI"]

func _ready():
	Globals.register_debug_console(console)
	Globals.register_error_console(console)
	
	update_fields()
	
	#connect signals
	save_btn.pressed.connect(on_save_btn_pressed)
	back_btn.pressed.connect(on_back_btn_pressed)


func update_fields():
	for item in api_endpoints:
		field_nodes["option"].add_item(item)
	SettingsLoad.load_settings()
	var settings = SettingsLoad.settings
	for key in settings.keys():
		var node = field_nodes.get(key)
		if node is TextEdit:
			node.text = str(settings[key])
		elif node is OptionButton:
			node.selected = settings[key]



func on_save_btn_pressed():
	var settings = SettingsLoad.settings

	for key in settings.keys():
		var node = field_nodes.get(key)
		if node is TextEdit:
			settings[key] = field_nodes[key].text.strip_edges()
		elif node is OptionButton:
			settings[key] = field_nodes[key].selected
			
	var config = ConfigFile.new()
	for key in settings.keys():
		config.set_value("SETTINGS", key, settings[key])
	config.save(SettingsLoad.SETTINGS_LOCATION)
	Globals.show_debug("[SettingsSave] User settings saved.")


func on_back_btn_pressed():
	Globals.clear_consoles()
	get_node("/root/Settings").queue_free()
