class_name GodotDownloader
extends RefCounted

signal update(id: String, percentage: int)
signal downloaded(id: String)


func download(id: String, metadata: GodotDownloadMetadata, path: String) -> void:
    var request := DownloadRequest.new()
    request.update.connect(_create_update_listener(id, metadata.size))

    var result := await request.request(metadata.browser_download_url)
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
    downloaded.emit(id)


func _create_update_listener(id: String, size: int) -> Callable:
    return func (bytes: int) -> void:
        @warning_ignore("integer_division")
        var percentage: int = round(100 * bytes / size)
        update.emit(id, percentage)
