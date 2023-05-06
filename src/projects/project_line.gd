extends ListItem
class_name ProjectLine

signal favourite_changed(favourite: bool)

@export var is_favourite := false
@export_global_file var project_icon: String
@export var project_name := "Project name"
@export var project_path := "project/path"

@onready var FavouriteButton: CheckButton = $Widgets/Favourite
@onready var Icon: TextureRect = $Widgets/Icon
@onready var NameLabel: Label = $Widgets/Content/Name
@onready var PathLabel: Label = $Widgets/Content/Path


func _ready() -> void:
	SelectButton = get_node("SelectButton")
	FavouriteButton.button_pressed = is_favourite
	Icon.texture = _create_external_texture(project_icon)
	NameLabel.text = project_name
	PathLabel.text = project_path


func _create_external_texture(texture_path: String) -> ImageTexture:
	var image = Image.new()
	image.load(texture_path)
	return ImageTexture.create_from_image(image)
