extends GdUnitTestSuite

const START_AT := 2
var skip_props: Array[String] = []

func before() -> void:
	for entry in Preferences.NestedPrefs.new("test").get_property_list():
		skip_props.append(entry.name)

	Preferences._values = {}
	Preferences._is_prod = false


func after_test() -> void:
	Preferences._values = {}


func test_sanity_check_projects() -> void:
	sanity_check(Preferences.projects, "projects")


func test_sanity_check_installations() -> void:
	sanity_check(Preferences.installations, "installations")


func test_sanity_check_choose_version() -> void:
	sanity_check(Preferences.choose_version, "choose_version")


func test_sanity_check_system() -> void:
	sanity_check(Preferences.system, "system")


func sanity_check(to_check: Object, module_name: String) -> void:
	assert_dict(Preferences._values).is_empty()
	var props := to_check.get_property_list()
	for i in range(START_AT, props.size()):
		if (skip_props.has(props[i].name)):
			continue
		print("testing " + module_name + "." + props[i].name)
		var value = get_random_for(props[i].type)
		to_check.set(props[i].name, value)
		assert_that(to_check.get(props[i].name)).is_equal(value)
	assert_dict(Preferences._values).is_not_empty()


func get_random_for(type):
	match type:
		TYPE_BOOL:
			var ran := randi()
			@warning_ignore("integer_division")
			return ran == ran / 2 * 2
		TYPE_INT:
			return randi()
		TYPE_STRING:
			return str(randi())
		_:
			push_error("Random missing for type " + str(type))
			assert_bool(false).is_true()
	
