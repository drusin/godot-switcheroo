extends ListItem
class_name InstallationLine

signal favourite_changed(favourite: bool)

# @export var is_favourite := false
@export var custom_name := ""
@export var version := "4.0.3 RC 1"
@export var path := "managed"
@export var id := ""
@export var is_custom := false

# @onready var FavouriteButton: CheckButton = $Widgets/Favourite
@onready var PseudoIcon: Label = $Widgets/PseudoIcon
@onready var NamePrimary: Label = find_child("NamePrimary", true)
@onready var NameSecondary: CenteredCursiveLabel = find_child("NameSecondary", true)
@onready var InfoPrimary: CenteredCursiveLabel = find_child("InfoPrimary", true)
@onready var Downloading: CenteredCursiveLabel = find_child("Downloading", true)
@onready var Widgets: HBoxContainer = $Widgets


func _ready():
	SelectButton = get_node("SelectButton")
	#FavouriteButton.button_pressed = is_favourite
	PseudoIcon.text = version.substr(0, 3)
	if is_custom:
		NamePrimary.text = custom_name
		NameSecondary.visible = true
		NameSecondary.text = version
		InfoPrimary.text = path
	else:
		NamePrimary.text = version
		InfoPrimary.text = "managed"
	if path == CONSTANTS.DOWNLOADING:
		Downloading.visible = true
