extends Control

@export var index := 0

@onready var SetProjectsFolderDialog: FileDialog = $SetProjectsFolderDialog
@onready var Projects: VBoxContainer = $Content/ProjectPane/ScrollContainer/Projects

@onready var ProjectLineScene := preload("res://src/projects/project_line.tscn")

var scan_dir: String: 
	set(newVal):
		PREFERENCES.values.scan_dir = newVal
		PREFERENCES.persist_prefs()
		perform_scan()
	get:
		return PREFERENCES.values.scan_dir

var projects := {}


func _ready() -> void:
	var projects_array := Persistence.load_persisted_projects()
	for project in  projects_array:
		projects[project.path] = project
	_refresh_project_list()


func perform_scan() -> void:
	var checked_paths := _scan_project_dir()
	var to_check := projects.keys().filter(func(el): return !checked_paths.has(el))
	for project_path in to_check:
		_scan_single_dir(DirAccess.open(project_path.substr(0, project_path.length() - "project.godot".length())))
	_refresh_project_list()
	var project_data_array: Array[Persistence.ProjectData] = []
	project_data_array.append_array(projects.values())
	Persistence.persist_projects(project_data_array)


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
	for child in Projects.get_children():
		child.queue_free()
	for project in projects.values():
		var line: ProjectLine = ProjectLineScene.instantiate()
		line.project_name = project.name
		line.project_path = project.path
		line.project_icon = project.icon_path
		Projects.add_child(line)


func _on_scan_folder_dialog_dir_selected(dir: String) -> void:
	scan_dir = dir


func _on_set_projects_folder_pressed() -> void:
	SetProjectsFolderDialog.current_dir = scan_dir
	SetProjectsFolderDialog.popup()
