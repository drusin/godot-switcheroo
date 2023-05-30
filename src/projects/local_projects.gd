extends Control

@export var main_tab_index := 0

@onready var SetProjectsFolderDialog: FileDialog = $SetProjectsFolderDialog
@onready var ConfirmRemoveDialog: ConfirmationDialog = $RemoveConfirmationDialog
@onready var ImportDialog: FileDialog = $ImportDialog
@onready var Projects: SelectablesList = $Content/ProjectPane/Projects
@onready var RemoveButton: Button = $Content/ButtonPane/Remove
@onready var SetGodotButton: Button = $Content/ButtonPane/SetGodotVersion
@onready var EditButton: Button = $Content/ButtonPane/Edit
@onready var RunButton: Button = $Content/ButtonPane/Run
@onready var ChooseInstallation: ConfirmationDialog = find_child("ChooseInstallation", true)

@onready var ProjectLineScene := preload("res://src/projects/project_line.tscn")

var scan_dir: String:
	set(new_val):
		PREFERENCES.write(Prefs.Keys.SCAN_DIR, new_val)
		perform_scan()
	get:
		return PREFERENCES.read(Prefs.Keys.SCAN_DIR)


func _ready() -> void:
	_refresh_project_list()


func _project_path_to_dir(path: String) -> DirAccess:
	return DirAccess.open(path.substr(0, path.length() - "project.godot".length()))


func perform_scan() -> void:
	PROJECTS.reload_projects()
	var dir = DirAccess.open(scan_dir)
	PROJECTS.add(dir)
	for subdir in dir.get_directories():
		dir.change_dir(scan_dir + "/" + subdir)
		PROJECTS.add(dir)
	_refresh_project_list()


func _refresh_project_list() -> void:
	var project_lines := []
	for project in PROJECTS.all_projects():
		var line: ProjectLine = ProjectLineScene.instantiate()
		line.project_name = project.project_name
		line.project_path = project.general.path
		line.project_icon = project.icon_path
		line.version = project.godot_version
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
		PROJECTS.remove(line.project_path)
	_refresh_project_list()


func _on_import_pressed() -> void:
	ImportDialog.current_dir = scan_dir
	ImportDialog.popup()


func _on_import_dialog_file_selected(path: String) -> void:
	PROJECTS.add(DirAccess.open(path))
	_refresh_project_list()


func _on_projects_selection_changed(_selection) -> void:
	_set_buttons_state()


func _set_buttons_state() -> void:
	var selected_amount = Projects.get_selected_items().size()
	RemoveButton.disabled = selected_amount == 0
	SetGodotButton.disabled = selected_amount == 0
	EditButton.disabled = selected_amount != 1 or not Projects.get_selected_items()[0].version
	RunButton.disabled = selected_amount != 1 or not Projects.get_selected_items()[0].version


func _on_edit_pressed() -> void:
	var project: ProjectData = PROJECTS.get_by_path(Projects.get_selected_items()[0].project_path)
	var args := ["--path", project.general.folder_path(), "-e"] \
			if project.godot_version.is_run_supported() else []
	OS.create_process(project.godot_version.installation_path, args)


func _on_run_pressed():
	var project: ProjectData = PROJECTS.get_by_path(Projects.get_selected_items()[0].project_path)
	var args := ["--path", project.general.folder_path()] \
			if project.godot_version.is_run_supported() else []
	OS.create_process(project.godot_version.installation_path, args)


func _on_choose_installation_version_set(version: GodotVersion) -> void:
	for line in Projects.get_selected_items():
		line.version = version
		PROJECTS.set_godot_version(line.project_path, version)
	_set_buttons_state()


func _on_set_godot_version_pressed() -> void:
	ChooseInstallation.popup()
