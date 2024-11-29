class_name Preferences
extends Object


class ProjectPrefs extends NestedPrefs:
    var filter_version: int:
        get:
            return _read("filter_version", 0)
        set(newVal):
            _write("filter_version", newVal)
    
    var filter_sort: int:
        get:
            return _read("filter_sort", 0)
        set(newVal):
            _write("filter_sort", newVal)
    
    var filter_asc_desc: int:
        get:
            return _read("filter_asc_desc", 1)
        set(newVal):
            _write("filter_asc_desc", newVal)
    
    var scan_dir: String:
        get:
            return _read("scan_dir", "")
        set(newVal):
            _write("scan_dir", newVal)

static var projects := ProjectPrefs.new("projects")


class InstallationPrefs extends NestedPrefs:
    var filter_usage: int:
        get:
            return _read("filter_usage", 0)
        set(newVal):
            _write("filter_usage", newVal)
    
    var filter_managed: int:
        get:
            return _read("filter_managed", 0)
        set(newVal):
            _write("filter_managed", newVal)
    
    var filter_sort: int:
        get:
            return _read("filter_sort", 0)
        set(newVal):
            _write("filter_sort", newVal)
    
    var filter_asc_desc: int:
        get:
            return _read("filter_asc_desc", 0)
        set(newVal):
            _write("filter_asc_desc", newVal)
    
    var last_custom_installation_dir: String:
        get:
            return _read("last_custom_installation_dir", "")
        set(newVal):
            _write("last_custom_installation_dir", newVal)

static var installations := InstallationPrefs.new("installations")


class ChooseVersion extends NestedPrefs:
    var managed: int:
        get:
            return _read("managed", 0)
        set(newVal):
            _write("managed", newVal)
    
    var sort: int:
        get:
            return _read("sort", 0)
        set(newVal):
            _write("sort", newVal)
    
    var pre_alpha: bool:
        get:
            return _read("pre_alpha", false)
        set(newVal):
            _write("pre_alpha", newVal)
    
    var alpha: bool:
        get:
            return _read("alpha", false)
        set(newVal):
            _write("alpha", newVal)
    
    var beta: bool:
        get:
            return _read("beta", false)
        set(newVal):
            _write("beta", newVal)
    
    var rc: bool:
        get:
            return _read("rc", false)
        set(newVal):
            _write("rc", newVal)
    
    var mono: bool:
        get:
            return _read("mono", false)
        set(newVal):
            _write("mono", newVal)
    
    var not_installed: bool:
        get:
            return _read("not_installed", true)
        set(newVal):
            _write("not_installed", newVal)

static var choose_version := ChooseVersion.new("choose_version")


class System extends NestedPrefs:
    var managed_installations_dir: String:
        get:
            return _read("managed_installations_dir", "user://.managed")
        set(newVal):
            _write("managed_installations_dir", newVal)
    
    var temp_dir: String:
        get:
            return _read("temp_dir", "user://.temp")
        set(newVal):
            _write("temp_dir", newVal)

static var system := System.new("system")


static var _is_prod := false
static var _values := {}


static func initialise_prefs() -> void:
    _is_prod = true
    _values = PrefsFileHandler.load_prefs()


static func _set_pref(name: String, val) -> void:
    _values[name] = val
    if (_is_prod):
        PrefsFileHandler.persist_prefs(_values)


class NestedPrefs extends Object:
    var _prefix: String

    func _init(prefix: String) -> void:
        _prefix = prefix
    

    func _read(name: String, default):
        _check_init_status()
        return Preferences._values.get(_prefix + "." + name, default)
    

    func _write(name: String, value):
        _check_init_status()
        Preferences._set_pref(_prefix + "." + name, value)
    

    func _check_init_status() -> void:
        if (not Preferences._is_prod):
            push_warning("Preferences are being read or written before they are initialized!")
