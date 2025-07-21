extends Node

#script
@onready var tts = get_node("/root/Main/TTSManager")

#nodes
@onready var mesh = get_node("/root/Main/Avatar/Airi/AvatarSample_E/Armature/Skeleton3D/Face")

var shape_map = {
	"A": "target_26",
	"U": "target_31",
	"E": "target_32",
	"O": "target_27",
	"I": "target_30"
}
var is_speaking = false
var fake_phonemes = ["A", "I", "U", "E", "O"]
var looping_phoneme_task = false


func on_tts_phoneme_data(duration: float, silent_ranges: Array) -> void:
	if looping_phoneme_task:
		looping_phoneme_task = false
		reset_blend_shapes()

	var talking_segments = []
	var last_time = 0.0

	for silence in silent_ranges:
		var start = silence[0]
		if start > last_time:
			talking_segments.append([last_time, start])
		last_time = silence[1]
	if last_time < duration:
		talking_segments.append([last_time, duration])

	looping_phoneme_task = true
	await play_fake_phonemes_timeline(talking_segments)
	

func play_fake_phonemes_timeline(talk_segments: Array) -> void:
	await get_tree().process_frame

	var start_time = Time.get_ticks_msec() / 1000.0
	var current_segment = 0
	var i = 0

	while current_segment < talk_segments.size():
		var now = Time.get_ticks_msec() / 1000.0 - start_time
		var segment = talk_segments[current_segment]
		var seg_start = segment[0]
		var seg_end = segment[1]

		if now < seg_start:
			var wait_time = seg_start - now
			await get_tree().create_timer(wait_time).timeout
			continue

		if now >= seg_start and now < seg_end:
			var phoneme = fake_phonemes[i % fake_phonemes.size()]
			var blend = shape_map.get(phoneme, null)
			if blend:
				mesh.set("blend_shapes/%s" % blend, 0.5)
				await get_tree().create_timer(0.1).timeout
				mesh.set("blend_shapes/%s" % blend, 0.0)
			await get_tree().create_timer(0.05).timeout
			i += 1
		elif now >= seg_end:
			current_segment += 1

	reset_blend_shapes()

func reset_blend_shapes():
	for shape in shape_map.values():
		mesh.set("blend_shapes/%s" % shape, 0.0)
