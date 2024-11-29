extends Control

@onready var MainContent: Control = find_child("MainContent", true)


func _on_tabs_tab_changed(tab: int) -> void:
	for child in MainContent.get_children():
		if not "main_tab_index" in child:
			continue
		child.visible = tab == child.main_tab_index
