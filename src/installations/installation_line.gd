extends ListItem
class_name InstallationLine

signal favourite_changed(favourite: bool)

@export var is_favourite := false
@export var custom_name := ""
@export var version := "4.0.3 RC 1"
@export var path := "managed"
@export var id := ""

@onready var FavouriteButton: CheckButton = $Widgets/Favourite
@onready var PseudoIcon: Label = $Widgets/PseudoIcon
@onready var NamePrimary: Label = find_child("NamePrimary", true)
@onready var NameSecondary: CenteredCursiveLabel = find_child("NameSecondary", true)
@onready var Path: CenteredCursiveLabel = find_child("Path", true)
@onready var Widgets: HBoxContainer = $Widgets


func _ready():
	SelectButton = get_node("SelectButton")
	FavouriteButton.button_pressed = is_favourite
	PseudoIcon.text = version.substr(0, 3)
	if custom_name:
		NamePrimary.text = custom_name
		NameSecondary.visible = true
		NameSecondary.text = version
	else:
		NamePrimary.text = version
	Path.text = path
