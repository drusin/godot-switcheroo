class_name Persistence extends Object


const PROJECTS_FILE := "user://.projects.godot-switcheroo"
const FILE_VERSION := 1


static func persist_projects(projects: Array) -> void:
	var projects_dict := {
		file_version = FILE_VERSION,
		projects = projects
	}
	var stringified := JSON.stringify(projects_dict, "    ")
	var file := FileAccess.open(PROJECTS_FILE, FileAccess.WRITE)
	if file == null:
		push_error("cannot open projects persistence file")
		return
	file.store_string(stringified)


static func load_persisted_projects() -> Array[String]:
	if not FileAccess.file_exists(PROJECTS_FILE):
		return []

	var file := FileAccess.open(PROJECTS_FILE, FileAccess.READ)
	if file == null:
		push_error("cannot open projects persistence file")
		return []
	var stringified := file.get_as_text()
	var projects_dict = JSON.parse_string(stringified)
	if projects_dict.file_version != FILE_VERSION:
		push_error("wrong projects file version!")
		return []
	var returnVal: Array[String] = []
	returnVal.append_array(projects_dict.projects)
	return returnVal


class ProjectData extends RefCounted:
	var name: String
	var path: String
	var is_favourite: bool
	var icon_path: String
	var godot_version: GodotVersion

	func serialize() -> Dictionary:
		return {
			"name": name,
			"path": path,
			"is_favourite": is_favourite,
			"icon_path": icon_path,
			"godot_version": inst_to_dict(godot_version),
		}

	static func deserialize(dict: Dictionary) -> ProjectData:
		var returnVal := ProjectData.new()
		returnVal.name = dict.name
		returnVal.path = dict.path
		returnVal.is_favourite = dict.is_favourite
		returnVal.icon_path = dict.icon_path
		returnVal.godot_version = dict_to_inst(dict.godot_version)
		return returnVal


class GodotVersion extends RefCounted:
	var version: String
	var is_custom: bool
	var custom_name: String
