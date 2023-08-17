extends Node

signal available_versions_ready()
signal version_downloaded(version: GodotVersion)
signal single_update(version: String, percent: int)
signal all_update(downloads: int, percent: int)

const MAIN_JSON_URL := "https://drusin.github.io/gd-dl-json-wrapper/json/main.json"

@onready var _temp_dir: String = PREFERENCES.read(Prefs.Keys.TEMP_DIR)
@onready var _managed_folder: String = PREFERENCES.read(Prefs.Keys.MANAGED_INSTALLATIONS_DIR)

var _available_versions := {}
var _current_downloads := {}
var _update_timer := Timer.new()


func _ready() -> void:
	DirAccess.make_dir_absolute(_temp_dir)
	_fetch_available_versions()
	_update_timer.timeout.connect(_send_updates)
	_update_timer.wait_time = CONSTANTS.DOWNLOAD_TIMER_UPDATE
	_update_timer.autostart = true
	add_child(_update_timer)


func _fetch_available_versions() -> void:
	var result_string := (await _request(MAIN_JSON_URL)).body.get_string_from_utf8()
	var parsed_versions: Dictionary = JSON.parse_string(result_string)
	var filtered_names = parsed_versions.keys() \
			.filter(func (key: String): return !key.begins_with("1") and !key.begins_with("2"))
	for filtered in filtered_names:
		_available_versions[filtered] = parsed_versions[filtered]
	available_versions_ready.emit()


func available_versions() -> Array[String]:
	var return_val: Array[String] = []
	return_val.append_array(_available_versions.keys())
	return return_val


func download(version: String) -> void:
	var all_version_metadata := await _fetch_version_specific_data(_available_versions[version])
	var relevant_metadata := _find_needed_data(version, all_version_metadata)
	if relevant_metadata.is_empty():
		push_error("Could not determine download link")
		return
	relevant_metadata["version"] = version
	var dl_result := await _download_and_unzip(relevant_metadata)
	var unpacked_file: PackedByteArray = dl_result[0]
	var unpacked_file_name: String = dl_result[1]
	var installation_path = _move_to_managed_path(unpacked_file, unpacked_file_name, version)
	var godot_version = GodotVersion.new()
	godot_version.version = version
	godot_version.installation_path = FileAccess.open(installation_path, FileAccess.READ).get_path_absolute()
	version_downloaded.emit(godot_version)


func _fetch_version_specific_data(url: String) -> Array[Dictionary]:
	var result_string := (await _request(url)).body.get_string_from_utf8()
	var parsed_versions: Array = JSON.parse_string(result_string)
	var return_val: Array[Dictionary] = []
	return_val.append_array(parsed_versions)
	return return_val


func _find_needed_data(version: String, metadatas: Array[Dictionary]) -> Dictionary:
	var os_label = _get_os_label(version)
	var arch := "64" if OS.has_feature("64") else "32"
	for data in metadatas:
		if data["name"].contains(os_label) and (data["name"].contains(arch) or data["name"].contains("universal")):
			return data
	return {}


func _get_os_label(version: String) -> String:
	var detected_name = OS.get_name()
	match detected_name:
		"Windows":
			return "win"
		"Linux", "FreeBSD", "NetBSD", "OpenBSD", "BSD":
			return "linux" if version.begins_with("4") else "x11"
	push_error("unsupported os: " + detected_name)
	return ""


func _download_and_unzip(metadata: Dictionary) -> Array:
	var bytes := (await _request("", metadata)).body
	var zip_file_path: String = _temp_dir + "/" + metadata["name"]
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
	var managed_path := _managed_folder + "/" + version
	DirAccess.make_dir_recursive_absolute(managed_path)
	var installation_path := managed_path + "/" + unpacked_file_name
	var file := FileAccess.open(installation_path, FileAccess.WRITE)
	file.store_buffer(unpacked_file)
	file.close()
	return installation_path


func _send_updates():
	var keys := _current_downloads.keys()
	var summed_percentage := 0
	for version in keys:
		var metadata: Dictionary = _current_downloads[version]
		var percentage := _calc_percentage(metadata)
		summed_percentage += percentage
		single_update.emit(version, percentage)
	@warning_ignore("integer_division")
	var all_percentage := 0 if summed_percentage == 0 else summed_percentage / keys.size()
	all_update.emit(keys.size(), all_percentage)


func _calc_percentage(metadata: Dictionary) -> int:
	return int(100 * metadata["req"].get_downloaded_bytes() / metadata["size_in_bytes"])


func _request(url := "", metadata := {}) -> ReqResult:
	var req = HTTPRequest.new()
	get_tree().get_root().add_child.call_deferred(req)
	await req.tree_entered
	req.request(url if not url == "" else metadata["url"])
	if not metadata.is_empty():
		metadata["size_in_bytes"] = _mb_to_byte(metadata["size"])
		metadata["req"] = req
		_current_downloads[metadata["version"]] = metadata
	var results: Array = await req.request_completed
	req.queue_free()
	if not metadata.is_empty():
		_current_downloads.erase(metadata["version"])
	return ReqResult.new(results)


func _mb_to_byte(mb: String) -> int:
	return int(mb.rstrip("M").to_float() * 1_000_000)


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
