extends Control
class_name ProjectLine

signal selected_changed(selected: bool)
signal favourite_changed(favourite: bool)

@export var is_favourite := false:
	set(newVal):
		is_favourite = newVal
		if FavouriteButton:
			FavouriteButton.button_pressed = newVal

@export_global_file var project_icon: String:
	set(newVal):
		project_icon = newVal
		if Icon:
			Icon.texture = _create_external_texture(newVal)

@export var project_name := "Project name":
	set(newVal):
		project_name = newVal
		if NameLabel:
			NameLabel.text = newVal

@export var project_path := "project/path":
	set(newVal):
		project_path = newVal
		if PathLabel:
			PathLabel.text = newVal

@export var is_selected := false:
	set(newVal):
		is_selected = newVal
		if SelectButton:
			SelectButton.button_pressed = newVal

@onready var SelectButton: Button = $SelectButton
@onready var FavouriteButton: CheckButton = $Widgets/Favourite
@onready var Icon: TextureRect = $Widgets/Icon
@onready var NameLabel: Label = $Widgets/Content/Name
@onready var PathLabel: Label = $Widgets/Content/Path


func _ready() -> void:
	FavouriteButton.button_pressed = is_favourite
	Icon.texture = _create_external_texture(project_icon)
	NameLabel.text = project_name
	PathLabel.text = project_path


func _create_external_texture(texture_path: String) -> ImageTexture:
	var image = Image.new()
	image.load(texture_path)
	return ImageTexture.create_from_image(image)


func _on_select_button_pressed() -> void:
	is_selected = SelectButton.button_pressed
	emit_signal("selected_changed", is_selected)
