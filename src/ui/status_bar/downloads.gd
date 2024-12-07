extends Label


func _ready():
	Globals.downloads.all_update.connect(func (downloads, _percante): text = "Downloads: " + str(downloads)) 
