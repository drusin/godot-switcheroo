extends ProgressBar

func _ready() -> void:
	DOWNLOADS.all_update.connect(func (downloads, percentage):
		if downloads == 0:
			value = 0
		value = percentage)
