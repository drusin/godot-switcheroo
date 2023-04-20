extends Control

@export var index := 1

@onready var ImportDialog: FileDialog = $ImportDialog


func _on_import_pressed() -> void:
	ImportDialog.popup()
