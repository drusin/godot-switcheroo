extends Node
class_name Prefs

const ABOUT_FILE := "Preferences for https://github.com/drusin/godot-switcheroo"
const PREFS_FILE := "user://.prefs.godot-switcheroo"
const FILE_VERSION := 1

enum Keys {
	SCAN_DIR,
	LAST_CUSTOM_INSTALLATION_DIR,
	MANAGED_INSTALLATIONS_DIR,
	TEMP_DIR,
}

var _values := {}


func _ready() -> void:
	_set_pref(Keys.SCAN_DIR, "")
	_set_pref(Keys.LAST_CUSTOM_INSTALLATION_DIR, "")
	_set_pref(Keys.MANAGED_INSTALLATIONS_DIR, "user://.managed")
	_set_pref(Keys.TEMP_DIR, "user://.temp")
	load_prefs()
	_persist_prefs()


func read(key: Keys):
	return _values[Keys.keys()[key]]


func write(key: Keys, value) -> void:
	_set_pref(key, value)
	_persist_prefs()


func _set_pref(key: Keys, value) ->  void:
	_values[Keys.keys()[key]] = value


func _persist_prefs() -> void:
	var stringified := JSON.stringify(_create_prefs_file_dict(), "    ")
	var file := FileAccess.open(PREFS_FILE, FileAccess.WRITE)
	if file == null:
		push_error("cannot read prefs file")
		return
	file.store_string(stringified)


func _create_prefs_file_dict() -> Dictionary:
	return {
		_about = ABOUT_FILE,
		file_version = FILE_VERSION,
		values = _values,
	}


func load_prefs() -> void:
	if not FileAccess.file_exists(PREFS_FILE):
		return
	var file := FileAccess.open(PREFS_FILE, FileAccess.READ)
	var stringified := file.get_as_text()
	var read_values = JSON.parse_string(stringified)
	if read_values.file_version != FILE_VERSION:
		push_error("Wrong prefs file version!")
		return
	for key in read_values.values.keys():
		_values[key] = read_values.values[key]
