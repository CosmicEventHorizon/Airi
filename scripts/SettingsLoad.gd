extends Node

const SETTINGS_LOCATION = "user://settings.cfg"

var settings = {
	"api_key" = "",
	"system_prompt" = "",
	"ollama_ip_address" = "",
	"ollama_model" = "",
	"option" = 0
}


func _ready():
	load_settings()


func load_settings():
	var config = ConfigFile.new()
	var err = config.load(SETTINGS_LOCATION)
	if err != OK:
		Globals.show_debug("No saved settings fallbacking to default")
		return
	for key in settings.keys():
		settings[key] = config.get_value("SETTINGS", key, settings[key])
