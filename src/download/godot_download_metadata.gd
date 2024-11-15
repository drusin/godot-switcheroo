class_name GodotDownloadMetadata
extends RefCounted

var name: String
var size: int
var browser_download_url


static func from_dict(from: Dictionary) -> GodotDownloadMetadata:
    var return_val := GodotDownloadMetadata.new()
    return_val.name = from.get("name")
    return_val.size = from.get("size")
    return_val.browser_download_url = from.get("browser_download_url")
    return return_val
