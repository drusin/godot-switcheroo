@tool

class_name CenteredCursiveLabel
extends VBoxContainer

@export var text := "text":
	set(new_val):
		text = new_val
		_set_text()

@onready var Text: RichTextLabel = find_child("Text", true)


func _ready() -> void:
	_set_text()


func _set_text() -> void:
	if Text:
		Text.text = "[i]" + text + "[/i]"


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		_set_text()
