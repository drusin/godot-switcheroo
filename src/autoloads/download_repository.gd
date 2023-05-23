extends Node

const JSON_URL := "https://drusin.github.io/gd-dl-json-wrapper/json/output.json"

var _data: Dictionary


func _ready() -> void:
	await _fetch_available_versions()
	#print(await download("4.0.3"))


func _fetch_available_versions() -> void:
	var result_string := (await _request(JSON_URL)).body.get_string_from_utf8()
	_data = JSON.parse_string(result_string)


func available_versions() -> Array[String]:
	var return_val: Array[String] = []
	return_val.append_array(_data.keys())
	return return_val


func download(version: String) -> String:
	### Fixme!!!!!!!!!!!!!!!!
	var os_name := "win"
	push_error("os name detection is broken!")
	var arch := "64" if OS.has_feature("64") else "32"
	var link: String = _data[version].filter( \
			func (line: String):
				return line.contains(os_name) and (line.contains(arch) or line.contains("universal")) \
			)[0]
	var file_name := link.split("/")[-1]
	var bytes := (await _request(link)).body
	var temp_dir = PREFERENCES.read(Prefs.Keys.TEMP_DIR)
	DirAccess.make_dir_absolute(temp_dir)
	var zip_file_path: String = temp_dir + "/" + file_name
	var file := FileAccess.open(zip_file_path, FileAccess.WRITE)
	file.store_buffer(bytes)
	file.close()
	var zip := ZIPReader.new()
	zip.open(zip_file_path)
	var unpacked_file_name := zip.get_files()[0]
	var unpacked_file := zip.read_file(unpacked_file_name)
	zip.close()
	var managed_path = PREFERENCES.read(Prefs.Keys.MANAGED_INSTALLATIONS_DIR) + "/" + version
	DirAccess.make_dir_recursive_absolute(managed_path)
	var installation_path: String = managed_path + "/" + unpacked_file_name
	file = FileAccess.open(installation_path, FileAccess.WRITE)
	file.store_buffer(unpacked_file)
	file.close()
	DirAccess.remove_absolute(zip_file_path)
	return installation_path


func _get_os_labels() -> Array[String]:
	match OS.get_name():
		"Windows", "UWP":
			return ["win"]
		"macOS":
			# Don't know enough about apple stuff for support...
			return []
		"Linux", "FreeBSD", "NetBSD", "OpenBSD", "BSD":
			# Support coming, but need to look into it... pre 4.0 stuff is wonky...
			return []
	return []


func _request(url: String) -> ReqResult:
	var req = HTTPRequest.new()
	get_tree().get_root().add_child.call_deferred(req)
	await req.tree_entered
	req.request(url)
	var results: Array = await req.request_completed
	req.queue_free()
	return ReqResult.new(results)


class ReqResult extends RefCounted:
	var result: int
	var status_code: int
	var headers: PackedStringArray
	var body: PackedByteArray
	
	func _init(from: Array) -> void:
		result = from[0]
		status_code = from[1]
		headers = from[2]
		body = from[3]
