extends Control

@export var index := 1

@onready var ImportDialog: FileDialog = $ImportDialog


func _on_import_pressed() -> void:
	ImportDialog.popup()


func _on_import_dialog_file_selected(path):
	pass # Replace with function body.
