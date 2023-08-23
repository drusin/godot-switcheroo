class_name CustomVersionDialog
extends ConfirmationDialog

signal version_created(version: GodotVersion)

@export var locating_set_version := false
@export var version := ""
@export var custom_name := ""

@onready var PathEdit: LineEdit = $Content/Path/PathContent/PathEdit
@onready var VersionButton: OptionButton = find_child("VersionButton", true)
@onready var NameEdit: LineEdit = $Content/CustomName/NameEdit
@onready var PathDialog: FileDialog = $PathDialog
@onready var MandatoryAlert: AcceptDialog = $MandatoryAlert

var _version_index_mapping := {}

var last_dir: String:
	set(new_val):
		PREFERENCES.write(Prefs.Keys.LAST_CUSTOM_INSTALLATION_DIR, new_val)
	get:
		return PREFERENCES.read(Prefs.Keys.LAST_CUSTOM_INSTALLATION_DIR)


func _ready():
	VersionButton.get_popup().max_size = Vector2i(300, 300)
	DOWNLOADS.available_versions_ready.connect(_update_versions_options)


func custom_popup() -> void:
	PathEdit.clear()
	VersionButton.disabled = locating_set_version
	NameEdit.editable = not locating_set_version
	if locating_set_version:
		VersionButton.select(_version_index_mapping[version])
		NameEdit.text = custom_name
	else:
		VersionButton.select(0)
		NameEdit.clear()
	popup()


func _update_versions_options() -> void:
	VersionButton.clear()
	var versions := DOWNLOADS.available_versions()
	ArrayUtils.sort(versions, Comparators.STR_NATURAL_NO_CASE)
	for i in versions.size():
		VersionButton.add_item(versions[i], i)
		_version_index_mapping[versions[i]] = i


func _on_browse_button_pressed() -> void:
	PathDialog.current_dir = last_dir
	PathDialog.popup()


func _on_path_dialog_file_selected(new_path: String) -> void:
	PathEdit.text = new_path
	PathEdit.caret_column = PathEdit.text.length()


func _on_confirmed() -> void:
	var path := PathEdit.text
	version = VersionButton.get_item_text(VersionButton.get_selected_id())
	custom_name = NameEdit.text

	if path == "" or version == "" or custom_name == "":
		MandatoryAlert.popup()
		return

	var godot_version := GodotVersion.new()
	godot_version.installation_path = path
	godot_version.version = version
	godot_version.custom_name = custom_name
	godot_version.is_custom = true
	
	last_dir = path
	emit_signal("version_created", godot_version)
	hide()
