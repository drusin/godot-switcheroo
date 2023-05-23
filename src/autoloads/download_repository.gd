extends Node

const JSON_URL := "https://drusin.github.io/gd-dl-json-wrapper/json/output.json"

var _data: Dictionary


func _ready() -> void:
	await _fetch_available_versions()
	#await download("4.0.3")


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


func download(version: String):
	### Fixme!!!!!!!!!!!!!!!!
	var os_name = "win"
	push_error("os name detection is broken!")
	var arch := "64" if OS.has_feature("64") else "32"
	var link: String = _data[version].filter( \
			func (line: String):
				return line.contains(os_name) and (line.contains(arch) or line.contains("universal")) \
			)[0]
	var file_name := link.split("/")[-1]
	var request = await _request()
	request.request(link)
	var bytes: PackedByteArray = (await request.request_completed)[-1]
	request.queue_free()
	if not DirAccess.dir_exists_absolute(PREFERENCES.read(Prefs.Keys.MANAGED_INSTALLATIONS_DIR)):
		DirAccess.make_dir_absolute(PREFERENCES.read(Prefs.Keys.MANAGED_INSTALLATIONS_DIR))
	var file = FileAccess.open(PREFERENCES.read(Prefs.Keys.MANAGED_INSTALLATIONS_DIR) + "/" + file_name, FileAccess.WRITE)
	file.store_buffer(bytes)
	print("done!")


func _request() -> HTTPRequest:
	var req = HTTPRequest.new()
	get_tree().get_root().add_child.call_deferred(req)
	await req.tree_entered
	return req
