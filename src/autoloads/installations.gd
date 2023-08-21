extends Node

signal versions_loaded
signal installations_changed()

const ABOUT_FILE := "Custom installations dictionairy for https://github.com/drusin/godot-switcheroo"
const VERSION_CACHE_FILE := "user://.installations.godot-switcheroo"
const VERSION_CACHE_FILE_VERSION := 1

var _local_installations := {}
var _remote_versions := {}


func _ready() -> void:
	DOWNLOADS.version_downloaded.connect(_on_version_downloaded)
	_load_cache()
	_persist_cache()


func add_custom(custom: GodotVersion) -> void:
	_local_installations[custom.id()] = custom
	_persist_cache()
	installations_changed.emit()


func add_managed(installations: Array) -> void:
	for installation in installations:
		_local_installations[installation.id()] = installation
	_persist_cache()
	installations_changed.emit()


func version(id: String) -> GodotVersion:
	return _local_installations[id] if _local_installations.has(id) else null


func all_versions() -> Array[GodotVersion]:
	await _add_remote_versions()
	var returnVal: Array[GodotVersion] = []
	returnVal.append_array(_remote_versions.values())
	returnVal.append_array(_local_installations.values())
	return returnVal


func local_versions() -> Array[GodotVersion]:
	var returnVal: Array[GodotVersion] = []
	returnVal.append_array(_local_installations.values())
	return returnVal


func remove(ids: Array):
	for id in ids:
		_remove(id)
		_persist_cache()
	installations_changed.emit()


func _remove(id: String) -> void:
	var to_remove := version(id)
	if not to_remove.is_custom and to_remove.installation_path != "":
		DirAccess.remove_absolute(to_remove.installation_path)
		DirAccess.remove_absolute(to_remove.folder_path())
		to_remove.installation_path = ""
	else:
		_local_installations.erase(id)


func _on_version_downloaded(downloaded: GodotVersion) -> void:
	add_managed([downloaded])


func _add_remote_versions():
	_remote_versions = {}
	for version_str in await DOWNLOADS.available_versions():
		var godot_version = GodotVersion.new()
		godot_version.version = version_str
		if not _local_installations.has(godot_version.id()):
			_remote_versions[godot_version.id()] = godot_version


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
		_local_installations[installation.id()] = installation
	versions_loaded.emit()
