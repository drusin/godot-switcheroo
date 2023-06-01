extends Node

signal projects_loaded(projects: Array[ProjectData])

const CACHE_FILE_NAME := "user://.projects.godot-switcheroo"
const ABOUT_CACHE_FILE := "Projects cache file for https://github.com/drusin/godot-switcheroo"
const CACHE_FILE_VERSION := 1

const VERSION_FILE_NAME := ".godot-switcheroo"
const ABOUT_VERSION_FILE := "Used by https://github.com/drusin/godot-switcheroo to determine which godot version was set for this project"
const VERSION_FILE_VERSION := 1

var _projects := {}


func _ready() -> void:
	await INSTALLATIONS.versions_loaded
	_load_cache()


func reload_projects() -> void:
	_load_cache()


func add(dir: DirAccess) -> ProjectData:
	if _projects.has(dir.get_current_dir(true)) or \
			(not dir.file_exists("project.godot") and \
			not dir.file_exists("engine.cfg")):
		return null
	var project_cache_data = ProjectCacheData.new()
	var project_file_name := "project.godot" if dir.file_exists("project.godot") else "engine.cfg"
	project_cache_data.path = dir.get_current_dir(true) + "/" + project_file_name
	var project_data = _project_data_from_cache(project_cache_data)
	_projects[project_cache_data.path] = project_data
	_persist_cache()
	return project_data


func remove(path: String) -> void:
	_projects.erase(path)
	_persist_cache()


func get_by_path(path: String) -> ProjectData:
	return _projects[path]


func all_projects() -> Array[ProjectData]:
	var return_val: Array[ProjectData] = []
	return_val.append_array(_projects.values())
	return return_val


func set_godot_version(project_path: String, version: GodotVersion) -> void:
	var project := get_by_path(project_path)
	project.godot_version = version
	var file_dict = _create_version_file_dict(version)
	var file = FileAccess.open(project.general.version_file_path(), FileAccess.WRITE)
	if not file:
		push_error("Cannot write version file")
		return
	file.store_string(JSON.stringify(file_dict, "    "))


func update_last_opened(project_path: String) -> void:
	var project := get_by_path(project_path)
	project.general.last_opened = Time.get_datetime_string_from_system(true)
	_persist_cache()


func _create_version_file_dict(version: GodotVersion) -> Dictionary:
	return {
		_about = ABOUT_VERSION_FILE,
		file_version = VERSION_FILE_VERSION,
		godot_versions = [version.id()],
	}


func _project_data_from_cache(cache: ProjectCacheData) ->  ProjectData:
	var project_data := ProjectData.new()
	var config := ConfigFile.new()
	var before_3 := !cache.path.ends_with("project.godot")
	config.load(cache.path)
	project_data.project_name = config.get_value("application", "name" if before_3 else "config/name")
	project_data.icon_path = cache.folder_path() + \
			config.get_value("application", "icon" if before_3 else "config/icon").trim_prefix("res://")
	project_data.general = cache
	project_data.godot_version = _read_godot_version(cache)
	return project_data


func _read_godot_version(cache: ProjectCacheData) -> GodotVersion:
	if not FileAccess.file_exists(cache.version_file_path()):
		return null
	var file := FileAccess.open(cache.version_file_path(), FileAccess.READ)
	if not file:
		push_error("Cannot open version file")
		return null
	var file_dict: Dictionary = JSON.parse_string(file.get_as_text())
	if file_dict.file_version != VERSION_FILE_VERSION:
		push_error("Wrong version file version!")
		return null
	var return_val := INSTALLATIONS.version(file_dict.godot_versions[0])
	if not return_val:
		return_val = GodotVersion.from_id(file_dict.godot_versions[0])
	return return_val


func _load_cache() -> void:
	_projects.clear()
	if not FileAccess.file_exists(CACHE_FILE_NAME):
		return
	var file := FileAccess.open(CACHE_FILE_NAME, FileAccess.READ)
	if file == null:
		push_error("Cannot open projects cache file")
		return
	var dict = JSON.parse_string(file.get_as_text())
	if dict.file_version != CACHE_FILE_VERSION:
		push_error("Wrong version of project cache file!")
		return
	for project in dict.values:
		var parsed := dict_to_inst(project) as ProjectCacheData
		_projects[parsed.path] = _project_data_from_cache(parsed)
	emit_signal("projects_loaded", all_projects())


func _persist_cache() -> void:
	var file := FileAccess.open(CACHE_FILE_NAME, FileAccess.WRITE)
	if file == null:
		push_error("Cannot open projects cache file")
		return
	var dict = _create_cache_file_dict()
	for project in _projects.values():
		dict.values.append(inst_to_dict(project.general))
	var stringified = JSON.stringify(dict, "    ")
	file.store_string(stringified)


func _create_cache_file_dict() ->  Dictionary:
	return {
		_about = ABOUT_CACHE_FILE,
		file_version = CACHE_FILE_VERSION,
		values = [],
	}


class ProjectCacheData extends RefCounted:
	var path: String
	var is_favourite: bool
	var last_opened := "0"

	func folder_path() -> String:
		var path_fragments := path.split("/")
		return path \
			.substr(0, path.length() - path_fragments[-1].length())

	func version_file_path() -> String:
		return folder_path() + "/" + VERSION_FILE_NAME
