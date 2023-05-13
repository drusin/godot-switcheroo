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
@onready var PathLabel: RichTextLabel = $Widgets/Content/NameContainer/PathCenterContainer/Path
@onready var VersionPrimary: Label = $Widgets/Content/VersionContainer/PrimaryVersionLabel
@onready var VersionSecondary: RichTextLabel = $Widgets/Content/VersionContainer/VersionCenterContainer/SecondaryVersionLabel
@onready var CompatibilityWarning: TextureRect = $Widgets/CompatibilityWarning

func _ready() -> void:
	SelectButton = get_node("SelectButton")
	FavouriteButton.button_pressed = is_favourite
	Icon.texture = _create_external_texture(project_icon)
	NameLabel.text = project_name
	PathLabel.text = "[i]" + project_path + "[/i]"
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
		VersionSecondary.text = "[i]No Godot version selected[/i]"
		return
	VersionPrimary.visible = true
	if version.is_custom:
		VersionPrimary.text = version.custom_name
		VersionSecondary.text = "[i]" + version.version + "[/i]"
	else:
		VersionPrimary.text = version.version
		VersionSecondary.text = "[i]managed[/i]"
	CompatibilityWarning.visible = not version.is_run_supported()
