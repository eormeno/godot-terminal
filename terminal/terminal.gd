class_name Terminal extends PanelContainer

@onready var history = $MarginContainer/ScrollContainer/PanelContainer/RichTextLabel
@onready var input = $MarginContainer/ScrollContainer/PanelContainer/HBoxContainer/LineEdit
@onready var prompt = $MarginContainer/ScrollContainer/PanelContainer/HBoxContainer/prompt
@onready var scroll : ScrollContainer = $MarginContainer/ScrollContainer
@onready var prompt_container : HBoxContainer = $MarginContainer/ScrollContainer/PanelContainer/HBoxContainer

signal command_entered(command : String, callback : Callable)

var max_scroll
var v_scroll_bar
var commands_history : Array[String] = []
var current_history_shown : int = 0
var last_command_entered : String
var command_timeout : float = 2.0
var timeout_counter : float
var timeout_running : bool
var default_prompt : String = "$:  "

func _ready():
	prompt.text = default_prompt
	input.grab_focus()
	v_scroll_bar = scroll.get_v_scroll_bar()
	v_scroll_bar.connect("changed", scroll_to_bottom)
	
func set_prompt(directory : String):
	var dir = directory.lstrip(' ').rstrip(' ')
	default_prompt = dir + " " + default_prompt
	prompt.text = default_prompt
	
func _process(delta):
	if timeout_running:
		timeout_counter += delta
		if timeout_counter > command_timeout:
			timeout_running = false
			timeout_counter = 0
			_on_command_execution_result("timeout")
		
	if commands_history.is_empty():
		return
	if Input.is_action_just_pressed("ui_up"):
		current_history_shown -= 1
		if current_history_shown < 0:
			current_history_shown = 0
		input.text = commands_history[current_history_shown]
	if Input.is_action_just_pressed("ui_down"):
		current_history_shown += 1
		if current_history_shown >= commands_history.size():
			current_history_shown = commands_history.size()
			input.text = ""
		else:
			input.text = commands_history[current_history_shown]

func _on_line_edit_text_submitted(new_text : String):
	if new_text.lstrip(' ').rstrip(' ').is_empty():
		return
	commands_history.append(new_text)
	current_history_shown = commands_history.size()
	if new_text == "clear":
		history.text = ""
		input.clear()
	else:
		last_command_entered = new_text
		input.editable = false
		timeout_running = true
		emit_signal("command_entered", new_text, _on_command_execution_result)
	
func _on_command_execution_result(message: String):
	history.append_text(prompt.text)
	history.append_text(last_command_entered)
	history.append_text("\n")
	if not message.is_empty():
		var space:String = "".lpad(prompt.text.length())
		history.append_text(space)
		history.push_bgcolor(Color.DARK_RED)
		history.push_color(Color.WHITE_SMOKE)
		history.append_text("command '")
		history.push_bold_italics()
		history.append_text(last_command_entered)
		history.pop()
		history.append_text("' exception: ")
		history.append_text(message + "\n")
		history.pop()
		history.pop()
	input.clear()
	input.editable = true

func scroll_to_bottom():
	if max_scroll != v_scroll_bar.max_value:
		max_scroll = v_scroll_bar.max_value
		scroll.scroll_vertical = v_scroll_bar.max_value
