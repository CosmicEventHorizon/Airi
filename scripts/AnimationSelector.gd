extends Node

#scripts
@onready var nlp_client = get_node("/root/Main/NLPClient")

#nodes
@onready var anim_player = get_node("/root/Main/Avatar/Airi/AvatarSample_E/AnimationPlayer")


func choose_animation(prompt: String) -> void:
	var animations = anim_player.get_animation_list()

	var animation_list_str = ", ".join(animations)
	
	var query = "You are an animation director. Based on this text: \"{text}\", choose the most appropriate animation from the following list: [{list}]. Only respond with the animation name.".format({
		"text": prompt,
		"list": animation_list_str
	})
	var raw_response: String = await nlp_client.get_response(query, Globals.GENERAL_PROMPT)
	var chosen_animation = raw_response.strip_edges()

	if animations.has(chosen_animation):
		Globals.show_debug("Animation name returned: " + chosen_animation)
		play_temp_animation(chosen_animation)
	else:
		Globals.show_debug("Invalid animation name returned: " + chosen_animation)

func play_temp_animation(anim_name: String) -> void:
	anim_player.play(anim_name)


func on_animation_finished(anim_name: StringName) -> void:
	anim_player.play("idle")
	anim_player.get_animation("idle").loop = true
