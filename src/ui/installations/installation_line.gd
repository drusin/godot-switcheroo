class_name InstallationLine
extends ListItem

var godot_version: GodotVersion

func _ready():
	icon_text = godot_version.version.substr(0, 3)
	super()
	_setup.call_deferred()
	

func _setup() -> void:
	bottom_secondary_text = ""
	if godot_version.is_custom:
		top_main_text = godot_version.custom_name
		top_secondary_text = godot_version.version
		bottom_main_text = godot_version.installation_path
	else:
		top_main_text = godot_version.version
		bottom_secondary_text = ""
		bottom_main_text = "managed"
	if godot_version.installation_path == CONSTANTS.DOWNLOADING:
		bottom_secondary_text = "downloading"
