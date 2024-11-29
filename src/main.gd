extends Control

@onready var MainContent: Control = find_child("MainContent", true)


func _ready() -> void:
	Preferences.initialise_prefs()
	OS.low_processor_usage_mode = true


func _on_tabs_tab_changed(tab: int) -> void:
	for child in MainContent.get_children():
		if not "main_tab_index" in child:
			continue
		child.visible = tab == child.main_tab_index
