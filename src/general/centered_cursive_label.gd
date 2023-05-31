class_name CenteredCursiveLabel
extends VBoxContainer

@export var text := "text":
	set(new_val):
		text = new_val
		if Text: Text.text = "[i]" + new_val + "[/i]"

@onready var Text: RichTextLabel = find_child("Text", true)
