extends PanelContainer

@onready var history = $MarginContainer/ScrollContainer/PanelContainer/RichTextLabel
@onready var input = $MarginContainer/ScrollContainer/PanelContainer/HBoxContainer/LineEdit
@onready var prompt = $MarginContainer/ScrollContainer/PanelContainer/HBoxContainer/prompt
@onready var scroll = $MarginContainer/ScrollContainer

func _ready():
	input.grab_focus()

func _on_line_edit_text_submitted(new_text):
	history.text += prompt.text + " " + new_text + "\n"
	if new_text == "clear":
		history.text = ""
		input.clear()
#	input.clear()
