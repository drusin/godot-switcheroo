class_name Preferences
extends Object


class Projects extends NestedPrefs:
    var filter_version: int:
        get:
            return read("filter_version", 0)
        set(newVal):
            write("filter_version", newVal)
    
    var filter_sort: int:
        get:
            return read("filter_sort", 0)
        set(newVal):
            write("filter_sort", newVal)
    
    var filter_asc_desc: int:
        get:
            return read("filter_asc_desc", 1)
        set(newVal):
            write("filter_asc_desc", newVal)
    
    var scan_dir: String:
        get:
            return read("scan_dir", "")
        set(newVal):
            write("scan_dir", newVal)

static var projects := Projects.new("projects")


class Installations extends NestedPrefs:
    var filter_usage: int:
        get:
            return read("filter_usage", 0)
        set(newVal):
            write("filter_usage", newVal)
    
    var filter_managed: int:
        get:
            return read("filter_managed", 0)
        set(newVal):
            write("filter_managed", newVal)
    
    var filter_sort: int:
        get:
            return read("filter_sort", 0)
        set(newVal):
            write("filter_sort", newVal)
    
    var filter_asc_desc: int:
        get:
            return read("filter_asc_desc", 0)
        set(newVal):
            write("filter_asc_desc", newVal)
    
    var last_custom_installation_dir: String:
        get:
            return read("last_custom_installation_dir", "")
        set(newVal):
            write("last_custom_installation_dir", newVal)

static var installations := Installations.new("installations")


class ChooseVersion extends NestedPrefs:
    var managed: int:
        get:
            return read("managed", 0)
        set(newVal):
            write("managed", newVal)
    
    var sort: int:
        get:
            return read("sort", 0)
        set(newVal):
            write("sort", newVal)
    
    var pre_alpha: bool:
        get:
            return read("pre_alpha", false)
        set(newVal):
            write("pre_alpha", newVal)
    
    var alpha: bool:
        get:
            return read("alpha", false)
        set(newVal):
            write("alpha", newVal)
    
    var beta: bool:
        get:
            return read("beta", false)
        set(newVal):
            write("beta", newVal)
    
    var rc: bool:
        get:
            return read("rc", false)
        set(newVal):
            write("rc", newVal)
    
    var mono: bool:
        get:
            return read("mono", false)
        set(newVal):
            write("mono", newVal)
    
    var not_installed: bool:
        get:
            return read("not_installed", true)
        set(newVal):
            write("not_installed", newVal)

static var choose_version := ChooseVersion.new("choose_version")


class System extends NestedPrefs:
    var managed_installations_dir: String:
        get:
            return read("managed_installations_dir", "user://.managed")
        set(newVal):
            write("managed_installations_dir", newVal)
    
    var temp_dir: String:
        get:
            return read("temp_dir", "user://.temp")
        set(newVal):
            write("temp_dir", newVal)

static var system := System.new("system")


static var _is_prod := false
static var _values := {}


static func _set_pref(name: String, val) -> void:
    _values[name] = val
    if (_is_prod):
        _persist()


static func _persist() -> void:
    pass


class NestedPrefs extends Object:
    var _prefix: String

    func _init(prefix: String) -> void:
        _prefix = prefix
    

    func read(name: String, default):
        return Preferences._values.get(_prefix + "." + name, default)
    

    func write(name: String, value):
        Preferences._set_pref(_prefix + "." + name, value)
