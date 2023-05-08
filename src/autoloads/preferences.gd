extends Node
class_name Prefs

const ABOUT_FILE := "Preferences for https://github.com/drusin/godot-switcheroo"
const PREFS_FILE := "user://.prefs.godot-switcheroo"
const FILE_VERSION := 1

enum Keys {
	SCAN_DIR,
	LAST_CUSTOM_INSTALLATION_DIR,
}

var _values := {}
var _file_dict := {
	_about = ABOUT_FILE,
	file_version = FILE_VERSION,
	values = _values,
}

func _ready() -> void:
	write(Keys.SCAN_DIR, "")
	write(Keys.LAST_CUSTOM_INSTALLATION_DIR, "")
	load_prefs()


func read(key: Keys):
	return _values[Keys.keys()[key]]


func write(key: Keys, value) -> void:
	_values[Keys.keys()[key]] = value
	_persist_prefs()


func _persist_prefs() -> void:
	var stringified := JSON.stringify(_file_dict, "    ")
	var file := FileAccess.open(PREFS_FILE, FileAccess.WRITE)
	if file == null:
		push_error("cannot read prefs file")
		return
	file.store_string(stringified)


func load_prefs() -> void:
	if not FileAccess.file_exists(PREFS_FILE):
		return
	var file := FileAccess.open(PREFS_FILE, FileAccess.READ)
	var stringified := file.get_as_text()
	var read_values = JSON.parse_string(stringified)
	if read_values.file_version != FILE_VERSION:
		push_error("Wrong prefs file version!")
		return
	_values = read_values.values
