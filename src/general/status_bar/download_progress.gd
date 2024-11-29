extends ProgressBar

func _ready() -> void:
	Globals.downloads.all_update.connect(func (downloads, percentage):
		if downloads == 0:
			value = 0
		value = percentage)
