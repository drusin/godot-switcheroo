extends Node

const PREFS_FILE := "user://.prefs.godot-switcheroo"
const FILE_VERSION := 1

var values := {
	file_version = FILE_VERSION,
	scan_dir = "",
	last_custom_installation_dir = "",
}


func _ready() -> void:
	load_prefs()


func persist_prefs() -> void:
	var stringified := JSON.stringify(values, "    ")
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
	values = read_values
