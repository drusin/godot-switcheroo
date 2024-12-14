class_name GodotVersion
extends RefCounted

var version: String
var is_custom := false
var custom_name := ""
var installation_path := ""


static func simple(version_to_set: String) -> GodotVersion:
	var return_val := GodotVersion.new()
	return_val.version = version_to_set
	return return_val


static func from_id(id_str: String) -> GodotVersion:
	var id_split := id_str.split(";")
	var return_val = GodotVersion.new()
	return_val.version = id_split[0]
	return_val.is_custom = id_split[1] == "true"
	return_val.custom_name = id_split[2]
	return return_val


func id() -> String:
	return version + ";" + str(is_custom) + ";" + custom_name


func folder_path() -> String:
	var path_fragments := installation_path.split("/")
	return installation_path \
		.substr(0, installation_path.length() - path_fragments[-1].length())


func ready_to_run() -> bool:
	return installation_path != ""


func downloadable() -> bool:
	return not is_custom
