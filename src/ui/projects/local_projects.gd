extends Control

@export var main_tab_index := 0

# Filtering
@onready var Filter: LineEdit = find_child("Filter", true)
@onready var VersionFilter: OptionButton = find_child("VersionFilter", true)
@onready var Sort: OptionButton = find_child("Sort", true)
@onready var AscDesc: OptionButton = find_child("AscDesc", true)

# Content
@onready var Projects: SelectablesList = $Content/ProjectPane/Projects
@export var ProjectLineScene: PackedScene

# Buttons
@onready var SetGodotButton: Button = $Content/ButtonPane/SetGodotVersion
@onready var EditButton: Button = $Content/ButtonPane/Edit
@onready var RunButton: Button = $Content/ButtonPane/Run
@onready var OpenFolder: Button = find_child("OpenFolder", true)
@onready var RemoveButton: Button = $Content/ButtonPane/Remove

# Dialogs
@onready var SetProjectsFolderDialog: FileDialog = $SetProjectsFolderDialog
@onready var ImportDialog: FileDialog = $ImportDialog
@onready var ChooseInstallation: ConfirmationDialog = find_child("ChooseInstallation", true)
@onready var ConfirmRemoveDialog: ConfirmationDialog = $RemoveConfirmationDialog
@onready var DownloadingMessage: AcceptDialog = find_child("DownloadingMessage", true)
@onready var MissingCustomVersion: MissingCustomVersion = find_child("MissingCustomVersion", true)
@onready var CustomVersionDialog: CustomVersionDialog = find_child("CustomVersionDialog", true)

var scan_dir: String:
	set(new_val):
		Preferences.projects.scan_dir = new_val
		_perform_scan()
	get:
		return Preferences.projects.scan_dir

var _currently_trying_to_start: ProjectData
var _currently_trying_to_edit := false


func _ready() -> void:
	VersionFilter.selected = Preferences.projects.filter_version
	Sort.selected = Preferences.projects.filter_sort
	AscDesc.selected = Preferences.projects.filter_asc_desc
	EditButton.pressed.connect(_on_run_or_edit_pressed.bind(true))
	RunButton.pressed.connect(_on_run_or_edit_pressed)
	DownloadingMessage.get_label().horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	Globals.installations.installations_changed.connect(_on_installations_changed)
	Globals.projects.projects_changed.connect(_refresh_project_list)
	SIGNALS.selected_amount_changed.connect(_on_projects_selection_changed)
	_refresh_project_list()


func _perform_scan() -> void:
	Globals.projects.reload_projects()
	var dirs_to_add: Array[String] = [scan_dir]
	var dir := DirAccess.open(scan_dir)
	for subdir in dir.get_directories():
		dir.change_dir(scan_dir + "/" + subdir)
		dirs_to_add.append(dir.get_current_dir(true))
	Globals.projects.add_from_dirs(dirs_to_add)


func _refresh_project_list() -> void:
	var project_lines := []
	for project in Globals.projects.all_projects():
		var line: ProjectLine = ProjectLineScene.instantiate()
		line.project = project
		line.double_clicked.connect(_on_run_or_edit_pressed.bind(true, project))
		project_lines.append(line)
	Projects.set_content(project_lines)
	_set_buttons_state()
	_apply_filter_and_sort()


func _set_buttons_state() -> void:
	var selected_amount = Projects.get_selected_items().size()
	RemoveButton.disabled = selected_amount == 0
	SetGodotButton.disabled = selected_amount == 0
	EditButton.disabled = selected_amount != 1 or not Projects.get_selected_items()[0].can_run
	RunButton.disabled = selected_amount != 1 or not Projects.get_selected_items()[0].can_run
	OpenFolder.disabled = selected_amount != 1


func _open_project(project: ProjectData , open_editor := false) -> void:
	Globals.projects.update_last_opened(project.general.path)
	_apply_filter_and_sort()
	var args := ["--path", project.general.folder_path()]
	var godot_version = Globals.installations.version(project.godot_version_id)
	if open_editor:
		args.append("-e")
	OS.create_process(godot_version.installation_path, args)
	_currently_trying_to_start = null


# Filtering
func _on_filter_or_sorting_changed(_var) -> void:
	_apply_filter_and_sort()
	Preferences.projects.filter_version = VersionFilter.selected
	Preferences.projects.filter_sort = Sort.selected
	Preferences.projects.filter_asc_desc = AscDesc.selected


func _apply_filter_and_sort() -> void:
	var project_list := Projects.get_items()
	for line in project_list:
		var project_line = line as ProjectLine
		project_line.visible = _filter_text(project_line) and \
				_version_filter(project_line)
	if not Sort.selected == 1:
		Projects.sort_items(func (left, right):
			return left.project.project_name.naturalnocasecmp_to(right.project.project_name))
	Projects.sort_items(_sort)


func _filter_text(line: ProjectLine) -> bool:
	var text = Filter.text
	return text == "" or line.project.project_name.to_lower().contains(text.to_lower())


func _version_filter(line: ProjectLine) -> bool:
	match VersionFilter.selected:
		1: return line.project.godot_version_id != ""
		2: return line.project.godot_version_id == ""
	return true


func _sort(left: ProjectLine, right: ProjectLine) -> int:
	var left_field := _get_field_for_sorting(left)
	var right_field := _get_field_for_sorting(right)
	if AscDesc.selected == 0:
		return left_field.naturalnocasecmp_to(right_field)
	return right_field.naturalnocasecmp_to(left_field)


func _get_field_for_sorting(line: ProjectLine) -> String:
	match Sort.selected:
		0: return line.project.general.last_opened
		1: return line.project.project_name
		2: return line.project.general.path
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
func _on_run_or_edit_pressed(edit := false, selected: ProjectData = null) -> void:
	var project: ProjectData = Projects.get_selected_items()[0].project if selected == null else selected
	var godot_version := Globals.installations.version(project.godot_version_id)
	if godot_version != null and godot_version.installation_path != "":
		_open_project(project, edit)
		return
	_currently_trying_to_start = project
	_currently_trying_to_edit = edit
	if godot_version == null:
		MissingCustomVersion.popup()
		return
	DownloadingMessage.popup()
	Globals.downloads.download(godot_version.version)


func _on_open_folder_pressed() -> void:
	var project := Globals.projects.get_by_path(Projects.get_selected_items()[0].project_path)
	OS.shell_open(project.general.folder_path())


# Reacting to "external" Signals
func _on_confirm_remove_pressed() -> void:
	var to_remove: Array[String] = []
	for line in Projects.get_selected_items():
		to_remove.append(line.project_path)
	Globals.projects.remove(to_remove)


func _on_import_dialog_file_selected(path: String) -> void:
	Globals.projects.add(path)


func _on_projects_selection_changed(_selection: int) -> void:
	_set_buttons_state()


func _on_scan_folder_dialog_dir_selected(dir: String) -> void:
	scan_dir = dir


func _on_choose_installation_version_set(version: GodotVersion) -> void:
	for line in Projects.get_selected_items():
		Globals.projects.set_godot_version(line.project.general.path, version)
		line.reset()
	_set_buttons_state()


func _on_downloading_message_canceled() -> void:
	_currently_trying_to_start = null


func _on_installations_changed() -> void:
	_refresh_project_list()
	if not _currently_trying_to_start or \
			Globals.installations.version(_currently_trying_to_start.godot_version_id).installation_path == "":
		return
	DownloadingMessage.hide()
	_open_project(_currently_trying_to_start, _currently_trying_to_edit)


func _on_missing_custom_version_locate_custom_version():
	var installation := GodotVersion.from_id(_currently_trying_to_start.godot_version_id)
	CustomVersionDialog.version = installation.version
	CustomVersionDialog.custom_name = installation.custom_name
	CustomVersionDialog.custom_popup()


func _on_missing_custom_version_select_new_version():
	ChooseInstallation.popup()


func _on_custom_version_dialog_version_created(version):
	Globals.installations.add_custom(version)
	_refresh_project_list()
