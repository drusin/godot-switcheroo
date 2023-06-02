class_name ListItem
extends Control

signal selected_changed(selected: bool)

@export var is_selected := false:
	set(new_val):
		is_selected = new_val
		if SelectButton:
			SelectButton.button_pressed = new_val

@export var SelectButton: Button:
	set(new_val):
		SelectButton = new_val
		SelectButton.pressed.connect(_on_select_button_pressed)


func _ready() -> void:
	if not SelectButton:
		SelectButton = $SelectButton


func _on_select_button_pressed() -> void:
	is_selected = SelectButton.button_pressed
	emit_signal("selected_changed", is_selected)
