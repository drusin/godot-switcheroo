extends ConfirmationDialog
class_name CustomVersionDialog

signal version_created(version: INSTALLATIONS.GodotVersion)
signal version_edited(version: EditedGodotVersion)

@onready var PathEdit: LineEdit = $Content/Path/PathContent/PathEdit
@onready var VersionEdit: LineEdit = $Content/Version/VersionEdit
@onready var NameEdit: LineEdit = $Content/CustomName/NameEdit
@onready var PathDialog: FileDialog = $PathDialog
@onready var MandatoryAlert: AcceptDialog = $MandatoryAlert

var old_name := ""


func custom_popup(current_name := "") -> void:
	PathEdit.clear()
	VersionEdit.clear()
	NameEdit.clear()
	old_name = current_name
	popup()


func _on_browse_button_pressed() -> void:
	PathDialog.current_dir = PREFERENCES.values.last_custom_installation_dir
	PathDialog.popup()


func _on_path_dialog_file_selected(new_path: String) -> void:
	PathEdit.text = new_path
	PathEdit.caret_column = PathEdit.text.length()


func _on_confirmed() -> void:
	var path = PathEdit.text
	var version = VersionEdit.text
	var custom_name = NameEdit.text

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
