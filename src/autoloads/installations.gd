class_name Installations
extends Node

signal versions_loaded
signal installations_changed

const ABOUT_FILE := "Custom installations dictionairy for https://github.com/drusin/godot-switcheroo"
const VERSION_CACHE_FILE := "user://.installations.godot-switcheroo"
const VERSION_CACHE_FILE_VERSION := 1

var _installations := {}


func _ready() -> void:
	Globals.downloads.available_versions_ready.connect(_add_remote_versions)
	Globals.downloads.version_downloaded.connect(_on_version_downloaded)
	_load_cache()
	_persist_cache()


func add_custom(custom: GodotVersion) -> void:
	_installations[custom.id()] = custom
	_persist_cache()
	installations_changed.emit()


func add_managed(installations: Array) -> void:
	for installation in installations:
		_installations[installation.id()] = installation
	_persist_cache()
	installations_changed.emit()


func version(id: String) -> GodotVersion:
	return _installations[id] if _installations.has(id) else null


func all_versions() -> Array[GodotVersion]:
	var returnVal: Array[GodotVersion] = []
	returnVal.append_array(_installations.values())
	return returnVal


func local_versions() -> Array[GodotVersion]:
	return all_versions().filter(func (ver: GodotVersion): return ver.installation_path != "")


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
		_installations.erase(id)


func _on_version_downloaded(downloaded: GodotVersion) -> void:
	add_managed([downloaded])


func _add_remote_versions():
	for version_str in Globals.downloads.available_versions():
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
	versions_loaded.emit()
