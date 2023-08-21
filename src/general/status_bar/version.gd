extends Label

func _ready() -> void:
	text = FileAccess.open("res://version.txt", FileAccess.READ).get_as_text()
