extends Control

@export var index := 0

@onready var SetProjectsFolderDialog: FileDialog = $SetProjectsFolderDialog
@onready var Projects: VBoxContainer = $Content/ProjectPane/ScrollContainer/Projects

@onready var ProjectLineScene := preload("res://src/projects/project_line.tscn")

var scan_dir: String: 
	set(newVal):
		scan_dir = newVal
		perform_scan()

var projects: Array[ProjectData] = []


func perform_scan() -> void:
	var dir := DirAccess.open(scan_dir)
	if not dir:
		push_error("needs to show error popup!")
		return
	var dirs_to_check := dir.get_directories()
	_scan_single_dir(dir)
	for subdir in dirs_to_check:
		dir.change_dir(scan_dir + "/" + subdir)
		_scan_single_dir(dir)
	_refresh_project_list()


func _scan_single_dir(dir: DirAccess) -> void:
	if not dir.file_exists("project.godot"):
		return
	var config = ConfigFile.new()
	var path := dir.get_current_dir(true) + "/project.godot"
	config.load(path)
	var project_name: String = config.get_value("application", "config/name")
	var icon_path := dir.get_current_dir(true) + \
			(config.get_value("application", "config/icon") as String).substr(5)
	var project_data := ProjectData.new()
	project_data.name = project_name
	project_data.path = path
	project_data.icon_path = icon_path
	projects.append(project_data)


func _refresh_project_list() -> void:
	for project in projects:
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


class ProjectData extends RefCounted:
	var name: String
	var path: String
	var is_favourite: bool
	var icon_path: String
	var godot_version: INSTALLATIONS.GodotVersion
