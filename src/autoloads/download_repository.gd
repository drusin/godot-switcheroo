extends Node

const JSON_URL := "https://drusin.github.io/gd-dl-json-wrapper/json/output.json"

var _data: Dictionary


func _ready() -> void:
	await _fetch_available_versions()
	#print(await download("4.0.3"))


func _fetch_available_versions() -> void:
	var request = await _request()
	request.request(JSON_URL)
	var result_string := ((await request.request_completed)[-1] as PackedByteArray).get_string_from_utf8()
	_data = JSON.parse_string(result_string)
	request.queue_free()


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
	var request := await _request()
	request.request(link)
	var bytes: PackedByteArray = (await request.request_completed)[-1]
	request.queue_free()
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


func _request() -> HTTPRequest:
	var req = HTTPRequest.new()
	get_tree().get_root().add_child.call_deferred(req)
	await req.tree_entered
	return req
