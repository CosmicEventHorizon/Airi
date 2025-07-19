extends Node

#scripts
@onready var avatar_controller = get_node("/root/Main/Avatar/AvatarController")
@onready var nlp = get_node("/root/Main/NLPClient")

#nodes
@onready var audio_player: AudioStreamPlayer = get_node("/root/Main/AudioStreamPlayer")
@onready var anim_selector = get_node("/root/Main/LogicManager/AnimationSelector")

const TTS_URL := "https://cosmiceventhorizon-moe-tts.hf.space/call/tts_fn"


func speak(prompt: String, message: String, message_jp: String, speaker: String = "綾地寧々", speed: float = 1.0, symbol_input := false):
	var http = HTTPRequest.new()
	add_child(http)
	
	#recieve the event_id
	var payload = {
		"data": [message_jp, speaker, speed, symbol_input]
	}
	var headers = ["Content-Type: application/json"]
	var err = http.request(TTS_URL, headers, HTTPClient.METHOD_POST, JSON.stringify(payload))
	if err != OK:
		Globals.show_error("[TTS] Request failed: " + err)
		return null
	var result = await http.request_completed
	var response_code = result[1]
	var raw_body = result[3]
	if response_code != 200:
		Globals.show_error("[TTS] Non-200 status code.")
		return null
	var parsed = JSON.parse_string(raw_body.get_string_from_utf8())
	if typeof(parsed) != TYPE_DICTIONARY:
		Globals.show_error("[TTS] Failed to parse JSON.")
		return null
	var event_id: String = parsed["event_id"]
	Globals.show_debug("[TTS] Recieved the event ID " + event_id)

	#receive wav url
	var url = TTS_URL + "/" + event_id
	err = http.request(url)
	if err != OK:
		Globals.show_error("[TTS] Failed to send request: " + err)
		return null
	result = await http.request_completed
	response_code = result[1]
	if response_code != 200:
		Globals.show_error("[TTS] Audio url request failed with code " + response_code)
		return null
	raw_body = result[3].get_string_from_utf8()
	var wav_url = null
	var lines = raw_body.split("\n")
	for line in lines:
		if line.begins_with("data: ["):
			var data_line = line.substr(6)
			var parsed_url = JSON.parse_string(data_line)
			if parsed_url[1] == null:
				Globals.show_error("[TTS] Failed to recieve audio url " + data_line)
				return null
			else:
				wav_url = parsed_url[1]["url"]
	if wav_url == null:
		Globals.show_error("[TTS] Failed to parse audio url.")
		return null

	#recieve wav data
	err = http.request(wav_url)
	if err != OK:
		Globals.show_error("[TTS] Failed to start audio download.")
		return null
	result = await http.request_completed
	response_code = result[1]
	raw_body = result[3]
	if response_code != 200:
		Globals.show_error("[TTS] Audio download failed with code %s " + response_code)
		return null

	#create audio stream
	var audio_stream := AudioStreamWAV.new()
	audio_stream.format = AudioStreamWAV.FORMAT_16_BITS
	audio_stream.mix_rate = 24000
	audio_stream.stereo = false
	audio_stream.data = raw_body

	#analyze volume timing
	var analysis_result = analyze_audio(audio_stream)
	var duration = analysis_result[0]
	var silent_ranges = analysis_result[1]
	
	#choose animation to play based on prompt
	await anim_selector.choose_animation(prompt)

	#send volume timing to avatar controller
	avatar_controller.on_tts_phoneme_data(duration, silent_ranges)
	
	#play audio
	audio_player.stream = audio_stream
	audio_player.play()
	Globals.show_debug("[TTS] Playing audio...")
	
	#show subtitle
	Globals.show_message(message)
	return 0

func analyze_audio(audio_stream: AudioStreamWAV) -> Array:
	var sample_rate = audio_stream.mix_rate
	var samples = audio_stream.data
	var step = 0.1 
	var window_size = int(step * sample_rate)
	var bytes_per_sample = 2

	var duration = float(samples.size()) / (sample_rate * bytes_per_sample)
	var silent_ranges: Array = []

	var i = 0
	var last_state = true
	var silence_start = -1.0

	while i < samples.size():
		var sum = 0
		var count = 0
		for j in range(i, min(i + window_size * bytes_per_sample, samples.size()), bytes_per_sample):
			var sample = samples.decode_s16(j)
			sum += abs(sample)
			count += 1

		var avg = float(sum) / max(1, count)
		var is_talking = avg > 1000  

		var time_sec = float(i) / (sample_rate * bytes_per_sample)

		if not is_talking and last_state:
			silence_start = time_sec
		elif is_talking and not last_state and silence_start >= 0:
			silent_ranges.append([silence_start, time_sec])
			silence_start = -1.0

		last_state = is_talking
		i += window_size * bytes_per_sample

	if not last_state and silence_start >= 0:
		silent_ranges.append([silence_start, duration])

	return [duration, silent_ranges]
