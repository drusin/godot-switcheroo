extends Control

@export var index := 1

@onready var CustomVersionDialog: CustomVersionDialog = $CustomVersionDialog


func _on_import_pressed() -> void:
	CustomVersionDialog.custom_popup()


func _on_custom_version_dialog_version_created(version: INSTALLATIONS.GodotVersion) -> void:
	pass # Replace with function body.
