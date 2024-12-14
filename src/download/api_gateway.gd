class_name ApiGateway
extends RefCounted

const MAIN_JSON_URL := "https://drusin.github.io/gd-gh-dl-json-wrapper/json/main.json"


func download_godot(url: String) -> DownloadRequest:
    return DownloadRequest.new(url)


func get_available_versions() -> Dictionary:
    var req = DownloadRequest.new(MAIN_JSON_URL)
    var to_parse = (await req.request()).body.get_string_from_utf8()
    return JSON.parse_string(to_parse)


func get_version_metadata(url: String) -> GodotDownloadMetadata:
    var req = DownloadRequest.new(url)
    var to_parse = (await req.request()).body.get_string_from_utf8()
    var parsed: Dictionary = JSON.parse_string(to_parse)
    return GodotDownloadMetadata.from_dict(parsed)
