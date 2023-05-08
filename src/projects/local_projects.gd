extends Control

@export var main_tab_index := 0

@onready var SetProjectsFolderDialog: FileDialog = $SetProjectsFolderDialog
@onready var ConfirmRemoveDialog: ConfirmationDialog = $RemoveConfirmationDialog
@onready var ImportDialog: FileDialog = $ImportDialog
@onready var Projects: SelectablesList = $Content/ProjectPane/Projects
@onready var RemoveButton: Button = $Content/ButtonPane/Remove
@onready var SetGodotButton: MenuButton = $Content/ButtonPane/SetGodotVersion

@onready var ProjectLineScene := preload("res://src/projects/project_line.tscn")

var scan_dir: String:
	set(new_val):
		PREFERENCES.write(Prefs.Keys.SCAN_DIR, new_val)
		perform_scan()
	get:
		return PREFERENCES.read(Prefs.Keys.SCAN_DIR)

var projects := {}


func _ready() -> void:
	var projects_array := Persistence.load_persisted_projects()
	for project in projects_array:
		_scan_single_dir(_project_path_to_dir(project))
	_refresh_project_list()
	SetGodotButton.get_popup().index_pressed.connect(_on_set_godot_version_selected)
	_populate_version_menu()


func _project_path_to_dir(path: String) -> DirAccess:
	return DirAccess.open(path.substr(0, path.length() - "project.godot".length()))


func perform_scan() -> void:
	var checked_paths := _scan_project_dir()
	var not_in_project_dir := projects.keys().filter(func(el): return !checked_paths.has(el))
	for project_path in not_in_project_dir:
		_scan_single_dir(_project_path_to_dir(project_path))
	_refresh_project_list()
	Persistence.persist_projects(projects.keys())


func _scan_project_dir() -> Array[String]:
	if scan_dir == "":
		return []
	var dir := DirAccess.open(scan_dir)
	if not dir:
		push_error("needs to show error popup!")
		return []
	var checked_paths: Array[String] = []
	var dirs_to_check := dir.get_directories()
	checked_paths.append(dir.get_current_dir())
	_scan_single_dir(dir)
	for subdir in dirs_to_check:
		dir.change_dir(scan_dir + "/" + subdir)
		checked_paths.append(dir.get_current_dir())
		_scan_single_dir(dir)
	return checked_paths


func _scan_single_dir(dir: DirAccess) -> void:
	if not dir.file_exists("project.godot"):
		return
	var config = ConfigFile.new()
	var path := dir.get_current_dir(true) + "/project.godot"
	config.load(path)
	var project_name: String = config.get_value("application", "config/name")
	var icon_path := dir.get_current_dir(true) + \
			(config.get_value("application", "config/icon") as String).substr(5)
	var project_data := Persistence.ProjectData.new()
	project_data.name = project_name
	project_data.path = path
	project_data.icon_path = icon_path
	#### debug
	var version := Persistence.GodotVersion.new()
	version.custom_name = "some custom name"
	version.version = "5.0.1"
	project_data.godot_version = version
	### end debug
	projects[project_data.path] = project_data


func _refresh_project_list() -> void:
	var project_lines := []
	for project in projects.values():
		var line: ProjectLine = ProjectLineScene.instantiate()
		line.project_name = project.name
		line.project_path = project.path
		line.project_icon = project.icon_path
		project_lines.append(line)
	Projects.set_content(project_lines)
	_set_buttons_state()


func _on_scan_folder_dialog_dir_selected(dir: String) -> void:
	scan_dir = dir


func _on_set_projects_folder_pressed() -> void:
	SetProjectsFolderDialog.current_dir = scan_dir
	SetProjectsFolderDialog.popup()


func _on_filter_text_changed(new_text: String) -> void:
	for project in Projects.get_items():
		project.visible = new_text == "" or project.project_name.to_lower().contains(new_text.to_lower())


func _on_remove_pressed() -> void:
	ConfirmRemoveDialog.popup()


func _on_confirm_remove_pressed() -> void:
	for line in Projects.get_selected_items():
		projects.erase(line.project_path)
	_refresh_project_list()
	Persistence.persist_projects(projects.keys())


func _on_import_pressed() -> void:
	ImportDialog.current_dir = scan_dir
	ImportDialog.popup()


func _on_import_dialog_file_selected(path: String) -> void:
	_scan_single_dir(_project_path_to_dir(path))
	_refresh_project_list()
	Persistence.persist_projects(projects.keys())


func _on_projects_selection_changed(_selection) -> void:
	_set_buttons_state()


func _set_buttons_state() -> void:
	var selected_amount = Projects.get_selected_items().size()
	RemoveButton.disabled = selected_amount == 0
	SetGodotButton.disabled = selected_amount == 0


func _populate_version_menu() -> void:
	var menu := SetGodotButton.get_popup()
	menu.clear()
	for installation in INSTALLATIONS.all_versions():
		menu.add_item(installation.custom_name if installation.is_custom else installation.version)
		menu.set_item_metadata(-1, installation.id())


func _on_visibility_changed() -> void:
	_populate_version_menu.call_deferred()


func _on_set_godot_version_selected(index: int) -> void:
	var version := INSTALLATIONS.version(SetGodotButton.get_popup().get_item_metadata(index))
	for line in Projects.get_selected_items():
		line.version = version
