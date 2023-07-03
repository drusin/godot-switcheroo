extends Control

@export var main_tab_index := 1

# Filters and sorting
@onready var Filter: LineEdit = find_child("Filter", true)
@onready var UsageFilter: OptionButton = find_child("UsageFilter", true)
@onready var ManagedFilter: OptionButton = find_child("ManagedFilter", true)
@onready var Sorting: OptionButton = find_child("Sorting", true)
@onready var AscDesc: OptionButton = find_child("AscDesc", true)

# Content
@onready var Installations: SelectablesList = $Content/InstallationPane/Installations
@onready var InstallationLineScene := preload("res://src/installations/installation_line.tscn")

# Buttons
@onready var RemoveButton: Button = $Content/ButtonPane/Remove
@onready var StartGodot: Button = $Content/ButtonPane/StartGodot
@onready var OpenGodotFolder: Button = $Content/ButtonPane/OpenGodotFolder

# Dialogs and popups
@onready var RemoveConfirmationDialog: ConfirmationDialog = $RemoveConfirmationDialog
@onready var CustomVersionDialog: CustomVersionDialog = $CustomVersionDialog
@onready var ChooseInstallation: ChooseInstallation = find_child("ChooseInstallation", true)
@onready var InstallationExistsAlert: AcceptDialog = $InstallationExistsAlert

@onready var _managed_folder: String = PREFERENCES.read(Prefs.Keys.MANAGED_INSTALLATIONS_DIR)

var _used_versions: Array[String] = []


func _ready() -> void:
	INSTALLATIONS.installations_changed.connect(_refresh_installations)
	SIGNALS.selected_amount_changed.connect(_on_installations_selection_changed)
	_refresh_installations()
	UsageFilter.selected = PREFERENCES.read(Prefs.Keys.INST_FILTER_USAGE)
	ManagedFilter.selected = PREFERENCES.read(Prefs.Keys.INST_FILTER_MANAGED)
	Sorting.selected = PREFERENCES.read(Prefs.Keys.INST_FILTER_SORT)
	AscDesc.selected = PREFERENCES.read(Prefs.Keys.INST_FILTER_ASC_DESC)


func _refresh_installations() -> void:
	var lines := []
	for installation in INSTALLATIONS.local_versions():
		var line: InstallationLine = InstallationLineScene.instantiate()
		line.godot_version = installation
		lines.append(line)
	Installations.set_content(lines)
	_set_buttons_state.call_deferred()
	_apply_filter_and_sort()


func _on_visibility_changed() -> void:
	if visible:
		_check_used_versions()
		_apply_filter_and_sort()


func _check_used_versions() -> void:
	_used_versions.clear()
	for project in PROJECTS.all_projects():
		if project.godot_version_id != "" and not _used_versions.has(project.godot_version_id):
			_used_versions.append(project.godot_version_id)


func _on_installations_selection_changed(_selection: int) -> void:
	_set_buttons_state()


func _set_buttons_state() -> void:
	var selected_amount = Installations.get_selected_items().size()
	RemoveButton.disabled = selected_amount == 0
	StartGodot.disabled = selected_amount != 1
	OpenGodotFolder.disabled = selected_amount != 1



# filtering
func _on_filter_or_sorting_changed(_var) -> void:
	_apply_filter_and_sort()
	PREFERENCES.write(Prefs.Keys.INST_FILTER_USAGE, UsageFilter.selected)
	PREFERENCES.write(Prefs.Keys.INST_FILTER_MANAGED, ManagedFilter.selected)
	PREFERENCES.write(Prefs.Keys.INST_FILTER_SORT, Sorting.selected)
	PREFERENCES.write(Prefs.Keys.INST_FILTER_ASC_DESC, AscDesc.selected)


func _apply_filter_and_sort() -> void:
	var lines := Installations.get_items()
	for line in lines:
		var installation_line = line as InstallationLine
		installation_line.visible = _filter_text(installation_line) and \
				_usage(installation_line) and \
				_managed(installation_line)
	Installations.sort_items(_sort)


func _filter_text(line: InstallationLine) -> bool:
	var text = Filter.text
	return text == "" or \
		line.custom_name.to_lower().contains(text.to_lower()) or \
		line.version.to_lower().contains(text.to_lower()) or \
		(line.is_custom and line.path.to_lower().contains(text.to_lower()))


func _usage(line: InstallationLine) -> bool:
	match UsageFilter.selected:
		1: return _used_versions.has(line.id)
		2: return not _used_versions.has(line.id)
	return true


func _managed(line: InstallationLine) -> bool:
	match ManagedFilter.selected:
		1: return not line.is_custom
		2: return line.is_custom
	return true


func _sort(left: InstallationLine, right: InstallationLine) -> int:
	var left_field := _get_field_for_sorting(left)
	var right_field := _get_field_for_sorting(right)
	if AscDesc.selected == 0:
		return left_field.naturalnocasecmp_to(right_field)
	return right_field.naturalnocasecmp_to(left_field)


func _get_field_for_sorting(line: InstallationLine) -> String:
	match Sorting.selected:
		0: return line.godot_version.custom_name if line.godot_version.is_custom else line.godot_version.version
		1: return line.godot_version.version
		2: return line.godot_version.installation_path
	push_error("unknown sorting option!")
	return ""



# open dialogs
func _on_import_pressed() -> void: CustomVersionDialog.custom_popup()
func _on_remove_pressed() -> void: RemoveConfirmationDialog.popup()
func _on_new_managed_pressed() -> void:	ChooseInstallation.popup()



# logic for button presses
func _on_start_godot_pressed() -> void:
	var installation = INSTALLATIONS.version(Installations.get_selected_items()[0].id)
	OS.create_process(installation.installation_path, [])


func _on_open_godot_folder_pressed() -> void:
	var installation = INSTALLATIONS.version(Installations.get_selected_items()[0].id)
	OS.shell_open(installation.folder_path())


func _on_rescan_pressed() -> void:
	var dir := DirAccess.open(_managed_folder)
	var installations_to_add: Array[GodotVersion] = []
	for version in dir.get_directories():
		var path := _managed_folder + "/" + version
		var subdir := DirAccess.open(path)
		var files := subdir.get_files()
		if not files.is_empty():
			var installation := GodotVersion.new()
			installation.version = version
			installation.installation_path = FileAccess.open(path + "/" + files[0], FileAccess.READ).get_path_absolute()
			installations_to_add.append(installation)
	INSTALLATIONS.add_managed(installations_to_add)



# reacting to "external" signals
func _on_custom_version_dialog_version_created(version: GodotVersion) -> void:
	if INSTALLATIONS.version(version.id()):
		InstallationExistsAlert.popup()
		return
	INSTALLATIONS.add_custom(version)


func _on_remove_confirmation_dialog_confirmed() -> void:
	var ids_to_remove: Array[String] = []
	for selected in Installations.get_selected_items():
		ids_to_remove.append(selected.godot_version.id())
	INSTALLATIONS.remove(ids_to_remove)


func _on_choose_installation_version_set(version: GodotVersion) -> void:
	if version.installation_path != "":
		return
	version.installation_path = CONSTANTS.DOWNLOADING
	INSTALLATIONS.add_managed([version])
	DOWNLOADS.download(version.version)


func _on_version_downloaded(version: GodotVersion) -> void:
	INSTALLATIONS.add_managed([version])
