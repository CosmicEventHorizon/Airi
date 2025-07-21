extends Node

const OPENAI_URL := "https://api.openai.com/v1/responses"
const MODEL_NAME := "gpt-4.1"


func get_response(prompt: String, system_prompt: String):
	var api_endpoint_choice = Load.settings["option"]
	
	match api_endpoint_choice:
		0:
			return await ollama_completion(prompt, system_prompt)
		1:
			return await openai_completion(prompt, system_prompt)


func ollama_completion(prompt: String, system_prompt: String):
	var model = Load.settings["ollama_model"]
	var ip_address = Load.settings["ollama_ip_address"] 
	if not ip_address.begins_with("http://") and not ip_address.begins_with("https://"):
		ip_address = "http://" + ip_address
	var url = ip_address + "/api/generate"

	
	var headers = [
		"Content-Type: application/json"
	]

	var body = {
		"model": model,
		"prompt": prompt,
		"system": system_prompt, 
		"stream": false,
		"think": false
	}

	var http := HTTPRequest.new()
	add_child(http)

	var err = http.request(
		url,
		headers,
		HTTPClient.METHOD_POST,
		JSON.stringify(body)
	)
	if err != OK:
		Globals.show_error("[NLP] Request failed to start: " + str(err))
		return null

	Globals.show_debug("[NLP] Awaiting Ollama response...")
	var result = await http.request_completed
	var response_code = result[1]
	var raw_body = result[3]
	Globals.show_debug("[NLP] Raw Response Code: " + str(response_code))
	if response_code != 200:
		Globals.show_error("[NLP] Non-200 response: " + str(response_code))
		return null

	var parsed = JSON.parse_string(raw_body.get_string_from_utf8())
	if typeof(parsed) != TYPE_DICTIONARY:
		Globals.show_error("[NLP] Failed to parse response JSON.")
		return null

	var content = parsed.get("response", null)
	if content == null:
		Globals.show_error("[NLP] Failed to get response content.")
		return null
	
	var think_pattern = RegEx.new()
	think_pattern.compile("(?s)<think>.*?</think>")
	content = think_pattern.sub(content, "", true)
	print("[NLP] Response: " + content)
	
	return content

func openai_completion(prompt:String, system_prompt:String):
	var api_key = Load.settings["api_key"]
	var headers = [
		"Content-Type: application/json",
		"Authorization: Bearer %s" % api_key
	]
	var body = {
		"model": MODEL_NAME,
		"instructions":system_prompt,
		"input": prompt
	}
	var http := HTTPRequest.new()
	add_child(http)
	
	var err = http.request(
		OPENAI_URL,
		headers,
		HTTPClient.METHOD_POST,
		JSON.stringify(body)
	)
	if err != OK:
		Globals.show_error("[NLP] Request failed to start: " + str(err))
		return null

	Globals.show_debug("[NLP] Awaiting OpenAI response...")
	var result = await http.request_completed
	var response_code = result[1]
	var raw_body = result[3]
	Globals.show_debug("[NLP] Raw Response Code: " + str(response_code))
	if response_code != 200:
		Globals.show_error("[NLP] Non-200 response: " + str(response_code))
		return null

	var parsed = JSON.parse_string(raw_body.get_string_from_utf8())
	if typeof(parsed) != TYPE_DICTIONARY:
		Globals.show_error("[NLP] Failed to parse response JSON.")
		return null
	var output = parsed.get("output", null)
	if output == null:
		Globals.show_error("[NLP] Failed to get response content.")
		return null
	var content = output[0]["content"]
	return content[0]["text"]
