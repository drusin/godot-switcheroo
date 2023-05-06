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
@onready var CustomNameLabel: Label = $Widgets/Content/CustomName
@onready var VersionLabel: Label = $Widgets/Content/Version
@onready var PathLabel: Label = $Widgets/Content/Path
@onready var Widgets: HBoxContainer = $Widgets


func _ready():
	if custom_name:
		CustomNameLabel.text = custom_name
		CustomNameLabel.visible = true
	select_button_path = get_node("SelectButton").get_path()
	FavouriteButton.button_pressed = is_favourite
	PseudoIcon.text = version.substr(0, 3)
	VersionLabel.text = version
	PathLabel.text = path


func _on_visibility_changed():
	(func (): size.y = Widgets.size.y).call_deferred()
