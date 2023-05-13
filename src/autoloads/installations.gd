extends Node

signal versions_loaded(versions: Array[GodotVersion])

const VERSION_CACHE_FILE := "user://.installations.godot-switcheroo"
const VERSION_CACHE_FILE_VERSION := 1

var _installations := {}


func _ready() -> void:
	_load_cache()


func add_custom(custom: GodotVersion) -> void:
	_installations[custom.id()] = custom
	_persist_cache()
	PREFERENCES.write(Prefs.Keys.LAST_CUSTOM_INSTALLATION_DIR, custom.folder_path())


func version(id: String) -> GodotVersion:
	return _installations[id] if _installations.has(id) else null


func all_versions() -> Array[GodotVersion]:
	var returnVal: Array[GodotVersion] = []
	returnVal.append_array(_installations.values())
	return returnVal


func remove(id: String):
	_installations.erase(id)
	_persist_cache()


func _persist_cache() -> void:
	var installation_dicts := []
	for installation in _installations.values():
		installation_dicts.append(inst_to_dict(installation))
	var version_cache := {
		file_version = VERSION_CACHE_FILE_VERSION,
		installations = installation_dicts
	}
	var file = FileAccess.open(VERSION_CACHE_FILE, FileAccess.WRITE)
	if file == null:
		push_error("cannot open installations cache file")
		return
	file.store_string(JSON.stringify(version_cache, "    "))


func _load_cache() -> void:
	if not FileAccess.file_exists(VERSION_CACHE_FILE):
		return
	var file = FileAccess.open(VERSION_CACHE_FILE, FileAccess.READ)
	if file == null:
		push_error("cannot open installations cache file")
		return
	var version_cache: Dictionary = JSON.parse_string(file.get_as_text())
	if version_cache.file_version != VERSION_CACHE_FILE_VERSION:
		push_error("Wrong installations cache file version!")
		return
	for installation_dict in version_cache.installations:
		var installation: GodotVersion = dict_to_inst(installation_dict)
		_installations[installation.id()] = installation
	emit_signal("versions_loaded", all_versions())
