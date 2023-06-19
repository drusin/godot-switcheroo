class_name ListItem
extends Control

signal selected_changed(selected: bool)

enum IconType { TEXTURE, TEXT }

@export var icon_type:IconType = IconType.TEXT
@export_global_file var icon_texture_path: String
@export var icon_text := "4.0"

@onready var is_selected := false:
	set(new_val):
		is_selected = new_val
		SelectButton.button_pressed = new_val

@onready var is_favourite := false:
	set(new_val):
		is_favourite = new_val
		FavouriteButton.button_pressed = new_val

@onready var top_main_text := "top main text":
	set(new_val):
		top_main_text = new_val
		TopMain.text = new_val

@onready var top_secondary_text := "top secondary text":
	set(new_val):
		top_secondary_text = new_val
		TopSecondary.text = new_val

@onready var bottom_main_text := "bottom main text":
	set(new_val):
		bottom_main_text = new_val
		BottomMain.text = new_val

@onready var bottom_secondary_text := "bottom secondary text":
	set(new_val):
		bottom_secondary_text = new_val
		BottomSecondary.text = new_val

@onready var warnings: Array[Warning] = []

@onready var SelectButton: Button = find_child("SelectButton", true)
@onready var FavouriteButton: CheckButton = find_child("FavouriteButton", true)
@onready var TextureIcon: TextureRect = find_child("TextureIcon", true)
@onready var TextIcon: Label = find_child("TextIcon", true)
@onready var TopMain: Label = find_child("TopMain", true)
@onready var TopSecondary: CenteredCursiveLabel = find_child("TopSecondary", true)
@onready var BottomMain: Label = find_child("BottomMain", true)
@onready var BottomSecondary: CenteredCursiveLabel = find_child("BottomSecondary", true)


func _ready() -> void:
	TextureIcon.visible = icon_type == IconType.TEXTURE
	TextIcon.visible = icon_type == IconType.TEXT
	if icon_type == IconType.TEXT:
		TextIcon.text = icon_text
	else:
		var image = Image.new()
		image.load(icon_texture_path)
		TextureIcon.texture = ImageTexture.create_from_image(image)


func _on_select_button_pressed() -> void:
	is_selected = SelectButton.button_pressed
	emit_signal("selected_changed", is_selected)

class Warning extends Node:
	enum Type { INFO, WARNING }
	@export var type: Type = Type.INFO
	@export var tooltipp := ""
