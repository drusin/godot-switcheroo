extends ListItem
class_name InstallationLine

signal favourite_changed(favourite: bool)

@export var is_favourite := false:
	set(new_val):
		is_favourite = new_val
		if FavouriteButton:
			FavouriteButton.button_pressed = new_val

@export var version := "4.0.3 RC 1":
	set(new_val):
		version = new_val
		if VersionLabel:
			VersionLabel.text = new_val
		if PseudoIcon:
			PseudoIcon.text = new_val.substr(0, 3)

@export var path := "managed":
	set(new_val):
		path = path
		if PathLabel:
			PathLabel.text = new_val

@onready var FavouriteButton: CheckButton = $Widgets/Favourite
@onready var PseudoIcon: Label = $Widgets/PseudoIcon
@onready var VersionLabel: Label = $Widgets/Content/Version
@onready var PathLabel: Label = $Widgets/Content/Path


func _ready():
	select_button_path = get_node("SelectButton").get_path()
