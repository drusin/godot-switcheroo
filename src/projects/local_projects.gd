extends Control

@export var index := 0

@onready var SetProjectsFolderDialog: FileDialog = $SetProjectsFolderDialog
@onready var ConfirmRemoveDialog: ConfirmationDialog = $RemoveConfirmationDialog
@onready var Projects: VBoxContainer = $Content/ProjectPane/ScrollContainer/Projects
@onready var RemoveButton: Button = $Content/ButtonPane/Remove

@onready var ProjectLineScene := preload("res://src/projects/project_line.tscn")

var scan_dir: String:
	set(newVal):
		PREFERENCES.values.scan_dir = newVal
		PREFERENCES.persist_prefs()
		perform_scan()
	get:
		return PREFERENCES.values.scan_dir

var projects := {}

var selected_projects: Array[String] = []


func _ready() -> void:
	ConfirmRemoveDialog.get_ok_button().pressed.connect(_on_confirm_remove_pressed)

	var projects_array := Persistence.load_persisted_projects()
	for project in  projects_array:
		_scan_single_dir(_project_path_to_dir(project))
	_refresh_project_list()


func _project_path_to_dir(path: String) -> DirAccess:
	return DirAccess.open(path.substr(0, path.length() - "project.godot".length()))


func perform_scan() -> void:
	var checked_paths := _scan_project_dir()
	var to_check := projects.keys().filter(func(el): return !checked_paths.has(el))
	for project_path in to_check:
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
	selected_projects.clear()
	RemoveButton.disabled = true
	for child in Projects.get_children():
		child.queue_free()
	for project in projects.values():
		var line: ProjectLine = ProjectLineScene.instantiate()
		line.project_name = project.name
		line.project_path = project.path
		line.project_icon = project.icon_path
		line.selected_changed.connect(_project_selected_handler(project.path))
		line.selected_changed.connect(_project_selected_behaviour(line))
		Projects.add_child(line)


func _on_scan_folder_dialog_dir_selected(dir: String) -> void:
	scan_dir = dir


func _on_set_projects_folder_pressed() -> void:
	SetProjectsFolderDialog.current_dir = scan_dir
	SetProjectsFolderDialog.popup()


func _on_filter_text_changed(new_text: String) -> void:
	for project in Projects.get_children():
		project.visible = new_text == "" or project.project_name.to_lower().contains(new_text.to_lower())


func _on_remove_pressed() -> void:
	ConfirmRemoveDialog.popup()


func _on_confirm_remove_pressed() -> void:
	for project_path in selected_projects:
		projects.erase(project_path)
	_refresh_project_list()
	Persistence.persist_projects(projects.keys())


func _project_selected_behaviour(line: ProjectLine) -> Callable:
	return func (_selected: bool) -> void:
		for child in Projects.get_children():
			if child != line:
				child.is_selected = false
				_project_selected_handler(child.project_path).call(false)


func _project_selected_handler(path: String) -> Callable:
	return func (selected: bool) -> void:
		if selected:
			selected_projects.append(path)
		else:
			selected_projects.erase(path)
		RemoveButton.disabled = selected_projects.size() == 0
