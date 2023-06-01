extends Node

signal available_versions_ready()
signal version_downloaded(version: GodotVersion)

const JSON_URL := "https://drusin.github.io/gd-dl-json-wrapper/json/output.json"

@onready var temp_dir = PREFERENCES.read(Prefs.Keys.TEMP_DIR)

var _data: Dictionary


func _ready() -> void:
	DirAccess.make_dir_absolute(temp_dir)
	_fetch_available_versions()


func _fetch_available_versions() -> void:
	var result_string := (await _request(JSON_URL)).body.get_string_from_utf8()
	_data = JSON.parse_string(result_string)
	emit_signal("available_versions_ready")


func available_versions() -> Array[String]:
	var return_val: Array[String] = []
	return_val.append_array(_data.keys())
	return return_val


func download(version: String) -> GodotVersion:
	var link := _find_link(version)
	if link == "":
		push_error("Could not determine download link")
		return null
	var file_name := link.split("/")[-1]
	var dl_result := await _download_and_unzip(link, file_name)
	var unpacked_file: PackedByteArray = dl_result[0]
	var unpacked_file_name: String = dl_result[1]
	var installation_path = _move_to_managed_path(unpacked_file, unpacked_file_name, version)
	var godot_version = GodotVersion.new()
	godot_version.version = version
	godot_version.installation_path = FileAccess.open(installation_path, FileAccess.READ).get_path_absolute()
	emit_signal("version_downloaded", godot_version)
	return godot_version


func _find_link(version: String) -> String:
	var os_label = _get_os_label(version)
	var arch := "64" if OS.has_feature("64") else "32"
	var found_links: Array = _data[version].filter( \
			func (line: String):
				return line.contains(os_label) and (line.contains(arch) or line.contains("universal")) \
			)
	return "" if found_links.size() == 0 else found_links[0]


func _get_os_label(version: String) -> String:
	var detected_name = OS.get_name()
	match detected_name:
		"Windows":
			return "win"
		"Linux", "FreeBSD", "NetBSD", "OpenBSD", "BSD":
			return "linux" if version.begins_with("4") else "x11"
	push_error("unsupported os: " + detected_name)
	return ""


func _download_and_unzip(link: String, file_name: String) -> Array:
	var bytes := (await _request(link)).body
	var zip_file_path: String = temp_dir + "/" + file_name
	var file := FileAccess.open(zip_file_path, FileAccess.WRITE)
	file.store_buffer(bytes)
	file.close()
	var zip := ZIPReader.new()
	zip.open(zip_file_path)
	var unpacked_file_name := zip.get_files()[0]
	var unpacked_file := zip.read_file(unpacked_file_name)
	zip.close()
	DirAccess.remove_absolute(zip_file_path)
	return [unpacked_file, unpacked_file_name]


func _move_to_managed_path(unpacked_file: PackedByteArray, unpacked_file_name: String, version: String) -> String:
	var managed_path = PREFERENCES.read(Prefs.Keys.MANAGED_INSTALLATIONS_DIR) + "/" + version
	DirAccess.make_dir_recursive_absolute(managed_path)
	var installation_path: String = managed_path + "/" + unpacked_file_name
	var file = FileAccess.open(installation_path, FileAccess.WRITE)
	file.store_buffer(unpacked_file)
	file.close()
	return installation_path


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
