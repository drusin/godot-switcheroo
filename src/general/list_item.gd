class_name ListItem
extends Control

signal selected_changed(selected: bool)

@export var is_selected := false:
	set(new_val):
		is_selected = new_val
		if SelectButton and SelectButton.button_pressed != new_val:
			SelectButton.button_pressed = new_val

@onready var SelectButton: Button = find_child("SelectButton", true)


func _on_select_button_pressed() -> void:
	is_selected = SelectButton.button_pressed
	emit_signal("selected_changed", is_selected)
