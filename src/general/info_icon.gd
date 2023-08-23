extends TextureRect
class_name InfoIcon

@export var tooltip := "Warning text"
@export var type: Type = Type.INFO

enum Type {
	INFO = 0,
	WARNING = 1,
	ERROR = 2,
}

const ICONS: Array[Texture] = [preload("res://assets/info-circle.svg"), \
		 preload("res://assets/alert-triangle.svg"), preload("res://assets/alert-octagon-filled.svg")]


func _ready() -> void:
	tooltip_text = tooltip
	texture = ICONS[type]
