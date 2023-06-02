extends Node

signal versions_loaded(versions: Array[GodotVersion])
signal installations_changed()

const ABOUT_FILE := "Custom installations dictionairy for https://github.com/drusin/godot-switcheroo"
const VERSION_CACHE_FILE := "user://.installations.godot-switcheroo"
const VERSION_CACHE_FILE_VERSION := 1

var _installations := {}


func _ready() -> void:
	DOWNLOAD_REPOSITORY.available_versions_ready.connect(_add_remote_versions)
	DOWNLOAD_REPOSITORY.version_downloaded.connect(add_managed)
	_load_cache()
	_persist_cache()


func add_custom(custom: GodotVersion) -> void:
	_installations[custom.id()] = custom
	_persist_cache()
	PREFERENCES.write(Prefs.Keys.LAST_CUSTOM_INSTALLATION_DIR, custom.folder_path())
	emit_signal("installations_changed")


func add_managed(managed: GodotVersion) -> void:
	_installations[managed.id()] = managed
	_persist_cache()
	emit_signal("installations_changed")


func version(id: String) -> GodotVersion:
	return _installations[id] if _installations.has(id) else null


func all_versions() -> Array[GodotVersion]:
	var returnVal: Array[GodotVersion] = []
	returnVal.append_array(_installations.values())
	return returnVal


func local_versions() -> Array[GodotVersion]:
	return all_versions().filter(func (ver: GodotVersion): return ver.installation_path != "")


func remove(id: String):
	var to_remove := version(id)
	if not to_remove.is_custom and to_remove.installation_path != "":
		DirAccess.remove_absolute(to_remove.installation_path)
		DirAccess.remove_absolute(to_remove.folder_path())
		to_remove.installation_path = ""
	else:
		_installations.erase(id)
	_persist_cache()
	emit_signal("installations_changed")


func _add_remote_versions():
	for version_str in DOWNLOAD_REPOSITORY.available_versions():
		var godot_version = GodotVersion.new()
		godot_version.version = version_str
		if not _installations.has(godot_version.id()):
			_installations[godot_version.id()] = godot_version


func _persist_cache() -> void:
	var installation_dicts := []
	for installation in local_versions():
		installation_dicts.append(inst_to_dict(installation))
	var version_cache := {
		_about = ABOUT_FILE,
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
