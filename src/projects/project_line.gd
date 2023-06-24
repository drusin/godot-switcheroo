class_name ProjectLine
extends ListItem

var project: ProjectData


func _ready() -> void:
	icon_type = IconType.TEXTURE
	icon_texture_path = project.icon_path
	super()
	_setup.call_deferred()


func _setup() -> void:
	top_main_text = project.project_name
	top_secondary_text = project.general.path
	if project.godot_version_id == "":
		bottom_main_text = ""
		bottom_secondary_text = "No Godot version selected"
		return
	var godot_version := INSTALLATIONS.version(project.godot_version_id)
	if not godot_version:
		godot_version = GodotVersion.from_id(project.godot_version_id)
		INSTALLATIONS.add_managed([godot_version])
	if godot_version.is_custom:
		bottom_main_text = godot_version.custom_name
		bottom_secondary_text = godot_version.version
	else:
		bottom_main_text = godot_version.version
		bottom_secondary_text = "managed"
