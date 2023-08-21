class_name ListItem
extends Control

signal selected_changed(selected: bool)
signal double_clicked

enum IconType { TEXTURE, TEXT }

@export var icon_type: IconType = IconType.TEXT
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
		TopMain.visible = new_val != ""

@onready var top_secondary_text := "top secondary text":
	set(new_val):
		top_secondary_text = new_val
		TopSecondary.text = new_val
		TopSecondary.visible = new_val != ""

@onready var bottom_main_text := "bottom main text":
	set(new_val):
		bottom_main_text = new_val
		BottomMain.text = new_val
		BottomMain.visible = new_val != ""

@onready var bottom_secondary_text := "bottom secondary text":
	set(new_val):
		bottom_secondary_text = new_val
		BottomSecondary.text = new_val
		BottomSecondary.visible = new_val != ""

@onready var warnings: Array[Warning] = []

@onready var SelectButton: Button = find_child("SelectButton", true)
@onready var FavouriteButton: CheckButton = find_child("FavouriteButton", true)
@onready var TextureIcon: TextureRect = find_child("TextureIcon", true)
@onready var TextIcon: Label = find_child("TextIcon", true)
@onready var TopMain: Label = find_child("TopMain", true)
@onready var TopSecondary: CenteredCursiveLabel = find_child("TopSecondary", true)
@onready var BottomMain: Label = find_child("BottomMain", true)
@onready var BottomSecondary: CenteredCursiveLabel = find_child("BottomSecondary", true)

var _double_clicked := false


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
	if not _double_clicked:
		is_selected = SelectButton.button_pressed
		selected_changed.emit(is_selected)
		return
	_double_clicked = false
	is_selected = true
	SelectButton.button_pressed = true
	double_clicked.emit()


func _on_select_button_gui_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
	var button_event := event as InputEventMouseButton
	if button_event.double_click and \
			not Input.is_key_pressed(KEY_SHIFT) and not Input.is_key_pressed(KEY_CTRL):
		_double_clicked = true


class Warning extends Node:
	enum Type { INFO, WARNING }
	@export var type: Type = Type.INFO
	@export var tooltipp := ""
