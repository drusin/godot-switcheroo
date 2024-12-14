extends Control

@export var main_scene: PackedScene


func _ready() -> void:
	Preferences.initialise_prefs()
	Globals.root = get_tree().get_root()
	Globals.downloads = Downloads.new()
	Globals.installations = Installations.new()
	Globals.projects = Projects.new()
	get_tree().call_deferred("change_scene_to_packed", main_scene)
