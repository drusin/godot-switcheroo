extends Control

@export var main_scene: PackedScene


func _ready() -> void:
	Preferences.initialise_prefs()
	Globals.downloads = Downloads.new()
	Globals.installations = Installations.new()
	Globals.projects = Projects.new()
	Globals.root = get_tree().get_root()
	get_tree().call_deferred("change_scene_to_packed", main_scene)
