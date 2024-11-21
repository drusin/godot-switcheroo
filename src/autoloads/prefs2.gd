class_name Preferences
extends Object


class Projects extends Object:
    var filter_version: int:
        get:
            return Preferences._values.get("projects.filter_version", 0)
        set(newVal):
            Preferences._set_pref("projects.filter_version", newVal)
    
    var filter_sort: int:
        get:
            return Preferences._values.get("projects.filter_sort", 0)
        set(newVal):
            Preferences._set_pref("projects.filter_sort", newVal)
    
    var filter_asc_desc: int:
        get:
            return Preferences._values.get("projects.filter_asc_desc", 1)
        set(newVal):
            Preferences._set_pref("projects.filter_asc_desc", newVal)
    
    var scan_dir: String:
        get:
            return Preferences._values.get("projects.scan_dir", "")
        set(newVal):
            Preferences._set_pref("projects.scan_dir", newVal)

static var projects := Projects.new()


class Installations extends Object:
    var filter_usage: int:
        get:
            return Preferences._values.get("installations.filter_usage", 0)
        set(newVal):
            Preferences._set_pref("installations.filter_usage", newVal)
    
    var filter_managed: int:
        get:
            return Preferences._values.get("installations.filter_managed", 0)
        set(newVal):
            Preferences._set_pref("installations.filter_managed", newVal)
    
    var filter_sort: int:
        get:
            return Preferences._values.get("installations.filter_sort", 0)
        set(newVal):
            Preferences._set_pref("installations.filter_sort", newVal)
    
    var filter_asc_desc: int:
        get:
            return Preferences._values.get("installations.filter_asc_desc", 0)
        set(newVal):
            Preferences._set_pref("installations.filter_asc_desc", newVal)
    
    var last_custom_installation_dir: String:
        get:
            return Preferences._values.get("installations.last_custom_installation_dir", "")
        set(newVal):
            Preferences._set_pref("installations.last_custom_installation_dir", newVal)

static var installations := Installations.new()


class ChooseVersion extends Object:
    var managed: int:
        get:
            return Preferences._values.get("choose_version.managed", 0)
        set(newVal):
            Preferences._set_pref("choose_version.managed", newVal)
    
    var sort: int:
        get:
            return Preferences._values.get("choose_version.sort", 0)
        set(newVal):
            Preferences._set_pref("choose_version.sort", newVal)
    
    var pre_alpha: bool:
        get:
            return Preferences._values.get("choose_version.pre_alpha", false)
        set(newVal):
            Preferences._set_pref("choose_version.pre_alpha", newVal)
    
    var alpha: bool:
        get:
            return Preferences._values.get("choose_version.alpha", false)
        set(newVal):
            Preferences._set_pref("choose_version.alpha", newVal)
    
    var beta: bool:
        get:
            return Preferences._values.get("choose_version.beta", false)
        set(newVal):
            Preferences._set_pref("choose_version.beta", newVal)
    
    var rc: bool:
        get:
            return Preferences._values.get("choose_version.rc", false)
        set(newVal):
            Preferences._set_pref("choose_version.rc", newVal)
    
    var mono: bool:
        get:
            return Preferences._values.get("choose_version.mono", false)
        set(newVal):
            Preferences._set_pref("choose_version.mono", newVal)
    
    var not_installed: bool:
        get:
            return Preferences._values.get("choose_version.not_installed", true)
        set(newVal):
            Preferences._set_pref("choose_version.not_installed", newVal)

static var choose_version := ChooseVersion.new()


class System extends Object:
    var managed_installations_dir: String:
        get:
            return Preferences._values.get("system.managed_installations_dir", "user://.managed")
        set(newVal):
            Preferences._set_pref("system.managed_installations_dir", newVal)
    
    var temp_dir: String:
        get:
            return Preferences._values.get("system.temp_dir", "user://.temp")
        set(newVal):
            Preferences._set_pref("system.temp_dir", newVal)

static var system := System.new()


static var _is_prod := false
static var _values := {}


static func _set_pref(name: String, val) -> void:
    _values[name] = val
    if (_is_prod):
        _persist()


static func _persist() -> void:
    pass
