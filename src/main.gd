extends Control

@onready var Bottom := $Content/Bottom


func _on_tabs_tab_changed(tab: int) -> void:
	for child in Bottom.get_children():
		if not "index" in child:
			return
		child.visible = tab == child.index
