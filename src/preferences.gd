extends Node

const PREFS_FILE := "user://.prefs.godot-switcheroo"

var values := {
	scan_dir = "",
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
	values = JSON.parse_string(stringified)
