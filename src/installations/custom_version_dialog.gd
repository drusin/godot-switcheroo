extends ConfirmationDialog
class_name CustomVersionDialog

signal version_created(version: INSTALLATIONS.GodotVersion)
signal version_edited(version: EditedGodotVersion)

@export var path := "":
	set(new_val):
		path = new_val
		if PathEdit:
			PathEdit.text = new_val
			PathEdit.caret_column = new_val.length()

@export var version := "":
	set(new_val):
		version = new_val
		if VersionEdit:
			VersionEdit.text = new_val

@export var custom_name := "":
	set(new_val):
		custom_name = new_val
		if NameEdit:
			NameEdit.text = new_val

@onready var PathEdit: LineEdit = $Content/Path/PathContent/PathEdit
@onready var VersionEdit: LineEdit = $Content/Version/VersionEdit
@onready var NameEdit: LineEdit = $Content/CustomName/NameEdit
@onready var PathDialog: FileDialog = $PathDialog
@onready var MandatoryAlert: AcceptDialog = $MandatoryAlert

var old_name := ""


func custom_popup(current_name := "") -> void:
	old_name = current_name
	popup()


func _on_browse_button_pressed() -> void:
	PathDialog.popup()


func _on_path_dialog_file_selected(new_path: String) -> void:
	path = new_path


func _on_confirmed() -> void:
	path = PathEdit.text
	version = VersionEdit.text
	custom_name = NameEdit.text

	if path == "" or version == "" or custom_name == "":
		MandatoryAlert.popup()
		return

	var godot_version := INSTALLATIONS.GodotVersion.new()
	godot_version.installation_path = path
	godot_version.version = version
	godot_version.custom_name = custom_name
	godot_version.is_custom = true

	if old_name == "":
		emit_signal("version_created", godot_version)
	else:
		var edited_version := EditedGodotVersion.new()
		edited_version.old_name = old_name
		edited_version.godot_version = godot_version
		emit_signal("version_edited", edited_version)
	hide()


class EditedGodotVersion extends RefCounted:
	var old_name := ""
	var godot_version: INSTALLATIONS.GodotVersion
