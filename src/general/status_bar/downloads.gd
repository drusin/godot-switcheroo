extends Label


func _ready():
	DOWNLOADS.all_update.connect(func (downloads, _percante): text = "Downloads: " + str(downloads)) 
