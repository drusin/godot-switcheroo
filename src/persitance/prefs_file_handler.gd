class_name  PrefsFileHandler
extends RefCounted

static var _file_path := "user://.prefs.godot-switcheroo"
static var _about := "Preferences for https://github.com/drusin/godot-switcheroo"
static var _file_version := 1


static func load_prefs() -> Dictionary:
	if not FileAccess.file_exists(_file_path):
		return {}
	
	var file := FileAccess.open(_file_path, FileAccess.READ)
	var stringified := file.get_as_text()
	var read_values = JSON.parse_string(stringified)
	if read_values.file_version != _file_version:
		push_error("Wrong prefs file version!")
		return {}
	
	var values := {}
	for key in read_values.values.keys():
		values[key] = read_values.values[key]
	return values


static func persist_prefs(values: Dictionary) -> void:
	var stringified := JSON.stringify(_create_prefs_file_dict(values), "    ")
	var file := FileAccess.open(_file_path, FileAccess.WRITE)
	if file == null:
		push_error("cannot read prefs file")
		return
	file.store_string(stringified)


static func _create_prefs_file_dict(values: Dictionary) -> Dictionary:
	return {
		"_about" = _about,
		"file_version" = _file_version,
		"values" = values,
	}
