class_name GodotVersion 
extends RefCounted

var version: String
var is_custom := false
var custom_name := ""
var installation_path := ""


func id() ->  String:
	return version + ";" + str(is_custom) + ";" + custom_name


func folder_path() -> String:
	var path_fragments := installation_path.split("/")
	return installation_path \
		.substr(0, installation_path.length() - path_fragments[-1].length())


func is_run_supported() -> bool:
	var main_ver_str := version.split(".")[0]
	if not main_ver_str.is_valid_int():
		return true
	return int(main_ver_str) > 2


static func from_id(id_str: String) -> GodotVersion:
	var id_split := id_str.split(";")
	var return_val = GodotVersion.new()
	return_val.version = id_split[0]
	return_val.is_custom = id_split[1] == "true"
	return_val.custom_name = id_split[2]
	return return_val
	
