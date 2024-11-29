extends Control


func _ready() -> void:
	Preferences.initialise_prefs()
	Globals.downloads = Downloads.new()
	Globals.installations = Installations.new()
	Globals.projects = Projects.new()
	OS.low_processor_usage_mode = true
	get_tree().call_deferred("change_scene_to_file", "./src/main.tscn")
