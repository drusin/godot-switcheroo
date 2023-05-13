extends Control

@export var main_tab_index := 1

@onready var CustomVersionDialog: CustomVersionDialog = $CustomVersionDialog
@onready var Installations: SelectablesList = $Content/InstallationPane/Installations
@onready var InstallationLineScene := preload("res://src/installations/installation_line.tscn")
@onready var RemoveConfirmationDialog: ConfirmationDialog = $RemoveConfirmationDialog
@onready var RemoveButton: Button = $Content/ButtonPane/Remove
@onready var InstallationExistsAlert: AcceptDialog = $InstallationExistsAlert
@onready var StartGodot: Button = $Content/ButtonPane/StartGodot
@onready var OpenGodotFolder: Button = $Content/ButtonPane/OpenGodotFolder


func _ready() -> void:
	_refresh_installations()


func _refresh_installations() -> void:
	var lines := []
	for installation in INSTALLATIONS.all_versions():
		var line: InstallationLine = InstallationLineScene.instantiate()
		line.custom_name = installation.custom_name
		line.version = installation.version
		line.path = installation.installation_path
		line.id = installation.id()
		lines.append(line)
	Installations.set_content(lines)
	_set_buttons_state.call_deferred()


func _on_import_pressed() -> void:
	CustomVersionDialog.custom_popup()


func _on_custom_version_dialog_version_created(version: GodotVersion) -> void:
	if INSTALLATIONS.version(version.id()):
		InstallationExistsAlert.popup()
		return
	INSTALLATIONS.add_custom(version)
	_refresh_installations()


func _on_remove_pressed() -> void:
	RemoveConfirmationDialog.popup()


func _on_remove_confirmation_dialog_confirmed() -> void:
	for selected in Installations.get_selected_items():
		INSTALLATIONS.remove(selected.id)
	_refresh_installations()


func _on_installations_selection_changed(_selection: Array) -> void:
	_set_buttons_state()


func _set_buttons_state() -> void:
	var selected_amount = Installations.get_selected_items().size()
	RemoveButton.disabled = selected_amount == 0
	StartGodot.disabled = selected_amount != 1
	OpenGodotFolder.disabled = selected_amount != 1


func _on_start_godot_pressed() -> void:
	var installation = INSTALLATIONS.version(Installations.get_selected_items()[0].id)
	OS.create_process(installation.installation_path, [])


func _on_open_godot_folder_pressed() -> void:
	var installation = INSTALLATIONS.version(Installations.get_selected_items()[0].id)
	OS.shell_open(installation.folder_path())


func _on_filter_text_changed(new_text):
	for installation in Installations.get_items():
		installation.visible = new_text == "" or \
				installation.custom_name.to_lower().contains(new_text.to_lower()) or \
				installation.version.to_lower().contains(new_text.to_lower()) or \
				installation.path.to_lower().contains(new_text.to_lower())
