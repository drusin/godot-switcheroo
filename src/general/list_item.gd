extends Control
class_name ListItem

signal selected_changed(selected: bool)

@export var is_selected := false:
	set(newVal):
		is_selected = newVal
		if SelectButton:
			SelectButton.button_pressed = newVal

@export_node_path("Button") var select_button_path:
	set(newVal):
		select_button_path = newVal
		SelectButton = get_node_or_null(newVal)
		if SelectButton:
			SelectButton.pressed.connect(_on_select_button_pressed)

var SelectButton: Button


func _ready() -> void:
	SelectButton = get_node(select_button_path)


func _on_select_button_pressed() -> void:
	is_selected = SelectButton.button_pressed
	emit_signal("selected_changed", is_selected)
