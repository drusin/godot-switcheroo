extends ListItem
class_name ProjectLine

signal favourite_changed(favourite: bool)

@export var is_favourite := false
@export_global_file var project_icon: String
@export var project_name := "Project name"
@export var project_path := "project/path"
var version: GodotVersion:
	set(new_val):
		version = new_val
		_set_version_label()

@onready var FavouriteButton: CheckButton = $Widgets/Favourite
@onready var Icon: TextureRect = $Widgets/Icon
@onready var NameLabel: Label = $Widgets/Content/NameContainer/Name
@onready var PathLabel: CenteredCursiveLabel = find_child("PathLabel", true)
@onready var VersionPrimary: Label = $Widgets/Content/VersionContainer/PrimaryVersionLabel
@onready var VersionSecondary: CenteredCursiveLabel = find_child("SecondaryVersionLabel", true)
@onready var VersionInfoIcon: TextureRect = $Widgets/Content/VersionContainer/VersionInfoIcon
@onready var CompatibilityWarning: TextureRect = $Widgets/CompatibilityWarning
@onready var MissingVersionWarning: TextureRect = $Widgets/MissingVersionWarning

func _ready() -> void:
	FavouriteButton.button_pressed = is_favourite
	Icon.texture = _create_external_texture(project_icon)
	NameLabel.text = project_name
	PathLabel.text = project_path
	_set_version_label()


func _create_external_texture(texture_path: String) -> ImageTexture:
	var image = Image.new()
	image.load(texture_path)
	return ImageTexture.create_from_image(image)


func _set_version_label() -> void:
	if not VersionPrimary:
		return
	if not version:
		VersionPrimary.visible = false
		VersionSecondary.text = "No Godot version selected"
		return
	VersionPrimary.visible = true
	if version.is_custom:
		VersionPrimary.text = version.custom_name
		VersionSecondary.text = version.version
	else:
		VersionPrimary.text = version.version
		VersionSecondary.text = "managed"
	VersionInfoIcon.visible = not version.is_custom and version.installation_path == ""
	CompatibilityWarning.visible = not version.is_run_supported()
	MissingVersionWarning.visible = version.is_custom and version.installation_path == ""
