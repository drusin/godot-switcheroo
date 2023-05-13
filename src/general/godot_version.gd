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
