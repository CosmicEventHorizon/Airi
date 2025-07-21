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
	{"name" = "airi", "path" = "user://models/airi.glb"}
]


func _ready():
	load_settings()


func load_settings():
	var config = ConfigFile.new()
	var err = config.load(SETTINGS_LOCATION)
	if err != OK:
		Globals.show_debug("No saved settings falling back to default")
		return
	for key in settings.keys():
		settings[key] = config.get_value("SETTINGS", key, settings[key])

func load_models():
	var config = ConfigFile.new()
	var err = config.load(MODELS_LOCATION)
	if err != OK:
		Globals.show_debug("No saved models falling back to default")
		return
	var keys: PackedStringArray = config.get_section_keys("MODELS")
	for key in keys:
		var path = config.get_value("MODELS", key, "")
		models.append({"name" = key, "path" = path })
