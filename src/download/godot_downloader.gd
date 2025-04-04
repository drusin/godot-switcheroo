class_name GodotDownloader
extends RefCounted

signal update(count: int, percentage: int)
signal downloaded(id: String)

var api_gateway := ApiGateway.new()
var _downloads := {}


func download_and_unzip(id: String, metadata: GodotDownloadMetadata, path: String) -> void:
	var request := api_gateway.download_godot(metadata.browser_download_url)
	request.update.connect(_create_update_listener(id, metadata.size))
	_downloads[id] = 0

	var result := await request.request()
	var bytes := result.body

	var zip_file_path: String = path + "/" + metadata.name
	var zip_file := FileAccess.open(zip_file_path, FileAccess.WRITE)
	zip_file.store_buffer(bytes)
	zip_file.close()

	var zip := ZIPReader.new()
	zip.open(zip_file_path)
	var unpacked_file_name := zip.get_files()[0]
	var unpacked_bytes := zip.read_file(unpacked_file_name)
	zip.close()
	DirAccess.remove_absolute(zip_file_path)

	var unpacked_file := FileAccess.open(path + "/" + unpacked_file_name, FileAccess.WRITE)
	unpacked_file.store_buffer(unpacked_bytes)
	unpacked_file.close()
	_downloads.erase(id)
	downloaded.emit(id)


func _create_update_listener(id: String, size: int) -> Callable:
	return func (bytes: int) -> void:
		@warning_ignore("integer_division")
		var percentage: int = round(100 * bytes / size)
		_downloads[id] = percentage
		var accumulated_percentages = _downloads.values().reduce(func (left: int, right: int): return left + right) / _downloads.size()
		update.emit(_downloads.size(), accumulated_percentages)
