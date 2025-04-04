extends GdUnitTestSuite

var old_prefs_file_value: String
var test_prefs_file_path := "user://tmp_prefs.json"

func before() -> void:
	old_prefs_file_value = PrefsFileHandler._file_path
	PrefsFileHandler._file_path = test_prefs_file_path
	DirAccess.remove_absolute(test_prefs_file_path);


func after() -> void:
	PrefsFileHandler._file_path = old_prefs_file_value
	Preferences._is_prod = false
	Preferences._values = {}


func test_persisting_prefs() -> void:
	Preferences.initialise_prefs()
	assert_int(Preferences.projects.filter_version).is_equal(0)     # initial value
	Preferences.projects.filter_version = 2
	assert_int(Preferences.projects.filter_version).is_equal(2)
	Preferences._values = {}
	assert_int(Preferences.projects.filter_version).is_equal(0)     # initial value again
	Preferences.initialise_prefs()
	assert_int(Preferences.projects.filter_version).is_equal(2)     # value loaded from file
