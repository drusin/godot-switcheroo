extends HBoxContainer
class_name ProjectLine

@export var is_favourite := false:
	set(newVal):
		is_favourite = newVal
		if FavouriteButton != null:
			FavouriteButton.button_pressed = newVal

@export_global_file var project_icon: String:
	set(newVal):
		project_icon = newVal
		if Icon != null:
			Icon.texture = _create_external_texture(newVal)

@export var project_name := "Project name":
	set(newVal):
		project_name = newVal
		if NameLabel != null:
			NameLabel.text = newVal
		
@export var project_path := "project/path":
	set(newVal):
		project_path = newVal
		if PathLabel != null:
			PathLabel.text = newVal

@onready var FavouriteButton: CheckButton = $Favourite
@onready var Icon: TextureRect = $Icon
@onready var NameLabel: Label = $Content/Name
@onready var PathLabel: Label = $Content/Path


func _ready() -> void:
	FavouriteButton.button_pressed = is_favourite
	Icon.texture = _create_external_texture(project_icon)
	NameLabel.text = project_name
	PathLabel.text = project_path


func _create_external_texture(texture_path: String) -> ImageTexture:
	var image = Image.new()
	image.load(texture_path)
#			var texture = ImageTexture.new()
#			texture.create_from_image(image)
	return ImageTexture.create_from_image(image)
