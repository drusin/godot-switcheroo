extends Control

@export var main_tab_index := 0

# Filtering
@onready var Filter: LineEdit = find_child("Filter", true)
@onready var VersionFilter: OptionButton = find_child("VersionFilter", true)
@onready var Sort: OptionButton = find_child("Sort", true)
@onready var AscDesc: OptionButton = find_child("AscDesc", true)

# Content
@onready var Projects: SelectablesList = $Content/ProjectPane/Projects
@onready var ProjectLineScene := preload("res://src/projects/project_line.tscn")

# Buttons
@onready var SetGodotButton: Button = $Content/ButtonPane/SetGodotVersion
@onready var EditButton: Button = $Content/ButtonPane/Edit
@onready var RunButton: Button = $Content/ButtonPane/Run
@onready var RemoveButton: Button = $Content/ButtonPane/Remove

# Dialogs
@onready var SetProjectsFolderDialog: FileDialog = $SetProjectsFolderDialog
@onready var ImportDialog: FileDialog = $ImportDialog
@onready var ChooseInstallation: ConfirmationDialog = find_child("ChooseInstallation", true)
@onready var ConfirmRemoveDialog: ConfirmationDialog = $RemoveConfirmationDialog
@onready var DownloadingMessage: AcceptDialog = find_child("DownloadingMessage", true)


var scan_dir: String:
	set(new_val):
		PREFERENCES.write(Prefs.Keys.SCAN_DIR, new_val)
		_perform_scan()
	get:
		return PREFERENCES.read(Prefs.Keys.SCAN_DIR)

var _currently_trying_to_start: ProjectData
var _currently_trying_to_edit := false

func _ready() -> void:
	VersionFilter.selected = PREFERENCES.read(Prefs.Keys.PROJ_FILTER_VERSION)
	Sort.selected = PREFERENCES.read(Prefs.Keys.PROJ_FILTER_SORT)
	AscDesc.selected = PREFERENCES.read(Prefs.Keys.PROJ_FILTER_ASC_DESC)
	EditButton.pressed.connect(_on_run_or_edit_pressed.bind(true))
	RunButton.pressed.connect(_on_run_or_edit_pressed)
	DownloadingMessage.get_label().horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	DOWNLOAD_REPOSITORY.version_downloaded.connect(_on_version_downloaded)
	_refresh_project_list()


func _perform_scan() -> void:
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
	_apply_filter_and_sort()


func _set_buttons_state() -> void:
	var selected_amount = Projects.get_selected_items().size()
	RemoveButton.disabled = selected_amount == 0
	SetGodotButton.disabled = selected_amount == 0
	EditButton.disabled = selected_amount != 1 or not Projects.get_selected_items()[0].version
	RunButton.disabled = selected_amount != 1 or not Projects.get_selected_items()[0].version


func _get_project_data_for_line(line: ProjectLine) -> ProjectData:
	return PROJECTS.get_by_path(line.project_path)


func _open_project(project: ProjectData , open_editor := false) -> void:
	PROJECTS.update_last_opened(project.general.path)
	var args := []
	if project.godot_version.is_run_supported():
		args = ["--path", project.general.folder_path()]
		if open_editor:
			args.append("-e")
	OS.create_process(project.godot_version.installation_path, args)
	_currently_trying_to_start = null


# Filtering
func _on_filter_or_sorting_changed(_var) -> void:
	_apply_filter_and_sort()
	PREFERENCES.write(Prefs.Keys.PROJ_FILTER_VERSION, VersionFilter.selected)
	PREFERENCES.write(Prefs.Keys.PROJ_FILTER_SORT, Sort.selected)
	PREFERENCES.write(Prefs.Keys.PROJ_FILTER_ASC_DESC, AscDesc.selected)


func _apply_filter_and_sort() -> void:
	var project_list := Projects.get_items()
	for line in project_list:
		var project_line = line as ProjectLine
		project_line.visible = _filter_text(project_line) and \
				_version_filter(project_line)
	Projects.sort_items(_sort)


func _filter_text(line: ProjectLine) -> bool:
	var text = Filter.text
	return text == "" or line.project_name.to_lower().contains(text.to_lower())


func _version_filter(line: ProjectLine) -> bool:
	match VersionFilter.selected:
		1: return line.version != null
		2: return line.version == null
	return true


func _sort(left: ProjectLine, right: ProjectLine) -> bool:
	var left_field := _get_field_for_sorting(left)
	var right_field := _get_field_for_sorting(right)
	if AscDesc.selected == 0:
		return left_field.naturalnocasecmp_to(right_field) <= 0
	return right_field.naturalnocasecmp_to(left_field) <= 0


func _get_field_for_sorting(line: ProjectLine) -> String:
	match Sort.selected:
		0: return _get_project_data_for_line(line).general.last_opened
		1: return line.project_name
		2: return line.project_path
	push_error("unknown sorting property")
	return ""



# Open popups
func _on_set_godot_version_pressed() -> void: ChooseInstallation.popup()
func _on_remove_pressed() -> void: ConfirmRemoveDialog.popup()


func _on_set_projects_folder_pressed() -> void:
	SetProjectsFolderDialog.current_dir = scan_dir
	SetProjectsFolderDialog.popup()


func _on_import_pressed() -> void:
	ImportDialog.current_dir = scan_dir
	ImportDialog.popup()



# Logic for button presses
func _on_run_or_edit_pressed(edit := false) -> void:
	var project := _get_project_data_for_line(Projects.get_selected_items()[0])
	if project.godot_version.installation_path == "":
		DownloadingMessage.popup()
		_currently_trying_to_start = project
		_currently_trying_to_edit = edit
		DOWNLOAD_REPOSITORY.download(project.godot_version.version)
		return
	_open_project(project, edit)
	_apply_filter_and_sort()


# Reacting to "external" Signals
func _on_confirm_remove_pressed() -> void:
	for line in Projects.get_selected_items():
		PROJECTS.remove(line.project_path)
	_refresh_project_list()


func _on_import_dialog_file_selected(path: String) -> void:
	PROJECTS.add(DirAccess.open(path))
	_refresh_project_list()


func _on_projects_selection_changed(_selection) -> void:
	_set_buttons_state()


func _on_scan_folder_dialog_dir_selected(dir: String) -> void:
	scan_dir = dir


func _on_choose_installation_version_set(version: GodotVersion) -> void:
	for line in Projects.get_selected_items():
		line.version = version
		PROJECTS.set_godot_version(line.project_path, version)
	_set_buttons_state()


func _on_downloading_message_canceled() -> void:
	_currently_trying_to_start = null


func _on_version_downloaded(version: GodotVersion) -> void:
	_refresh_project_list()
	if not _currently_trying_to_start or _currently_trying_to_start.godot_version.id() != version.id():
		return
	DownloadingMessage.hide()
	_open_project(_currently_trying_to_start, _currently_trying_to_edit)
