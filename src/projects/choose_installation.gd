extends ConfirmationDialog

signal version_set(version: GodotVersion)

@onready var ManagedCustomFilter: OptionButton = find_child("ManagedCustomFilter", true)
@onready var AscDescOption: OptionButton = find_child("AscDescOption", true)
@onready var PreAlpha: CheckBox = find_child("PreAlpha", true)
@onready var Alpha: CheckBox = find_child("Alpha", true)
@onready var Beta: CheckBox = find_child("Beta", true)
@onready var Rc: CheckBox = find_child("Rc", true)
@onready var Mono: CheckBox = find_child("Mono", true)
@onready var Uninstalled: CheckBox = find_child("Uninstalled", true)
@onready var VersionOption: OptionButton = find_child("VersionOption", true)

var _alpha_regex = RegEx.new()


func _ready() -> void:
	ManagedCustomFilter.selected = PREFERENCES.read(Prefs.Keys.CHOOSE_MANAGED)
	AscDescOption.selected = PREFERENCES.read(Prefs.Keys.CHOOSE_SORT)
	PreAlpha.button_pressed = PREFERENCES.read(Prefs.Keys.CHOOSE_PRE_ALPHA)
	Alpha.button_pressed = PREFERENCES.read(Prefs.Keys.CHOOSE_ALPHA)
	Beta.button_pressed = PREFERENCES.read(Prefs.Keys.CHOOSE_BETA)
	Rc.button_pressed = PREFERENCES.read(Prefs.Keys.CHOOSE_RC)
	Mono.button_pressed = PREFERENCES.read(Prefs.Keys.CHOOSE_MONO)
	Uninstalled.button_pressed = PREFERENCES.read(Prefs.Keys.CHOOSE_UNISTALLED)
	_alpha_regex.compile("\\d-alpha")


func _on_confirmed() -> void:
	PREFERENCES.write(Prefs.Keys.CHOOSE_MANAGED, ManagedCustomFilter.selected)
	PREFERENCES.write(Prefs.Keys.CHOOSE_SORT, AscDescOption.selected)
	PREFERENCES.write(Prefs.Keys.CHOOSE_PRE_ALPHA, PreAlpha.button_pressed)
	PREFERENCES.write(Prefs.Keys.CHOOSE_ALPHA, Alpha.button_pressed)
	PREFERENCES.write(Prefs.Keys.CHOOSE_BETA, Beta.button_pressed)
	PREFERENCES.write(Prefs.Keys.CHOOSE_RC, Rc.button_pressed)
	PREFERENCES.write(Prefs.Keys.CHOOSE_MONO, Mono.button_pressed)
	PREFERENCES.write(Prefs.Keys.CHOOSE_UNISTALLED, Uninstalled.button_pressed)
	emit_signal("version_set", INSTALLATIONS.version(VersionOption.get_item_metadata(VersionOption.selected)))


func _on_about_to_popup() -> void:
	_refresh_version_list()


func _some_filter_changed(_ignore) -> void:
	_refresh_version_list()


func _refresh_version_list() -> void:
	var versions := INSTALLATIONS.all_versions() if Uninstalled.button_pressed else INSTALLATIONS.local_versions()
	var filtered := versions\
			.filter(_managed)\
			.filter(_pre_alpha)\
			.filter(_alpha)\
			.filter(_beta)\
			.filter(_rc)\
			.filter(_mono)
	filtered.sort_custom(_sort)

	VersionOption.clear()
	for version in filtered:
		VersionOption.add_item(version.custom_name if version.is_custom else version.version)
		VersionOption.set_item_metadata(-1, version.id())


#####################
# Filtering helpers #
#####################

func _managed(version: GodotVersion) -> bool:
	if ManagedCustomFilter.selected == 0:
		return true
	return (ManagedCustomFilter.selected == 1 and not version.is_custom) or \
			(ManagedCustomFilter.selected == 2 and version.is_custom)

func _pre_alpha(version: GodotVersion) -> bool:
	return PreAlpha.button_pressed or (not version.version.contains("dev"))

func _alpha(version: GodotVersion) -> bool:
	# Using regex to not match "pre-alpha"
	return Alpha.button_pressed or _alpha_regex.search_all(version.version).is_empty()

func _beta(version: GodotVersion) -> bool:
	return Beta.button_pressed or not version.version.contains("beta")

func _rc(version: GodotVersion) -> bool:
	return Rc.button_pressed or not version.version.contains("rc")

func _mono(version: GodotVersion) -> bool:
	return Mono.button_pressed or not version.version.contains("mono")

func _sort(left: GodotVersion, right: GodotVersion) -> bool:
	if AscDescOption.selected == 0:
		return right.version.naturalnocasecmp_to(left.version) <= 0
	return left.version.naturalnocasecmp_to(right.version) <= 0
