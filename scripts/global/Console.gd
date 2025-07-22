extends Node

const GENERAL_PROMPT = "You are an AI assistant. You follow the user's instructions exactly as given. Do not add, change, explain, summarize, or include anything extra beyond what the user explicitly requests."
const EN_JP_TRANSLATOR_PROMPT = "You are a strict translator. If the input is in English, translate it *directly* into natural Japanese with no explanation, no formatting, no preamble, and no label. If the input is already in Japanese, return it exactly as is. Output only the result — no comments, no headings, no extra text."

var current_debug_console: RichTextLabel = null
var current_error_console: RichTextLabel = null


func register_debug_console(node: RichTextLabel):
	current_debug_console = node


func register_error_console(node: RichTextLabel):
	current_error_console = node
	
func clear_consoles():
	current_debug_console = null
	current_error_console = null

func show_error(err: String):
	push_error(err)
	if current_error_console == null:
		return
	
	current_error_console.clear()
	current_error_console.bbcode_enabled = true
	var formatted_message = "[center][color=red][font_size=24]" + err + "[/font_size][/color][/center]"
	current_error_console.append_text(formatted_message)


func show_debug(debug_message: String):
	print(debug_message)
	if current_debug_console == null:
		return
	
	current_debug_console.clear()
	current_debug_console.bbcode_enabled = true
	var formatted_message = "[center][color=blue][font_size=24]" + debug_message + "[/font_size][/color][/center]"
	current_debug_console.append_text(formatted_message)

	
func show_message(message: String):
	var console = get_node("/root/Main/UI/Panel/Console")
	console.clear()
	console.bbcode_enabled = true
	var formatted_message = "[center][color=green][font_size=24]" + message + "[/font_size][/color][/center]"
	console.append_text(formatted_message)
	
