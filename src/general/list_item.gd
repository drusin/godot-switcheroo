extends Control
class_name ListItem

signal selected_changed(selected: bool)

@export var is_selected := false:
	set(newVal):
		is_selected = newVal
		if SelectButton:
			SelectButton.button_pressed = newVal

@onready var SelectButton: Button = $SelectButton


func _on_button_pressed() -> void:
	is_selected = SelectButton.button_pressed
	emit_signal("selected_changed", is_selected)
