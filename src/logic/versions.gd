class_name Versions
extends Object

var _api_gateway := ApiGateway.new()
var _versions := {}
var _remote_dl_lookup := {}     # "version_name": "details_url"


func get_available_versions() -> Array[GodotVersion]:
    _remote_dl_lookup = await _api_gateway.get_available_versions()
    for key: String in _remote_dl_lookup.keys():
        if (_versions.has(key)):
            continue
        var version := GodotVersion.new()
        version.version = key
        _versions[key] = version
    var return_val: Array[GodotVersion] = []
    return_val.append_array(_versions.values())
    return return_val